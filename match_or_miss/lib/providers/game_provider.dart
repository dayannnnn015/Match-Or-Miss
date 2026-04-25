// lib/providers/game_provider.dart
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';
import '../services/game_service.dart';
import '../services/ai_service.dart';
import '../services/openai_service.dart' as ai_svc;
import '../services/secure_storage_service.dart';

class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();
  final AIService _aiService = AIService();
  final ai_svc.OpenAIService _openAIService = ai_svc.OpenAIService();

  GameSession? _currentSession;
  List<Color> _currentGuess = [];
  bool _isSubmitting = false;
  bool _showHistory = true;
  List<Color> _previousGuess = [];

  String _postGameInsight = '';
  bool _isLoadingInsight = false;
  String _lastHint = '';

  bool get hasHint => _lastHint.isNotEmpty;
  String get lastHint => _lastHint;
  String get postGameInsight => _postGameInsight;
  bool get isLoadingInsight => _isLoadingInsight;
  bool get hasAIKey => _openAIService.hasValidKey;

  GameSession? get currentSession => _currentSession;
  List<Color> get currentGuess => _currentGuess;
  bool get isSubmitting => _isSubmitting;
  bool get showHistory => _showHistory;

  bool get canSubmit {
    if (_currentGuess.isEmpty) return false;
    return _gameService.isValidGuess(_currentGuess);
  }

  GameProvider() {
    _loadApiKey();
  }

  /// On startup: try loading key in this order:
  /// 1. Previously saved key in secure storage (persists across launches)
  /// 2. Key baked in at build time via --dart-define (first-run seed)
  ///
  /// This means:
  /// - First build: key comes from --dart-define, gets saved to secure storage
  /// - Every launch after: key loads from secure storage automatically
  /// - No user action ever needed
  Future<void> _loadApiKey() async {
    // 1. Try secure storage first (fastest path after first launch)
    String? storedKey = await SecureStorageService.getAPIKey('gemini');

    if (storedKey != null && storedKey.isNotEmpty) {
      _openAIService.setApiKey(storedKey, provider: ai_svc.AIProvider.googleGemini);
      return;
    }

    // 2. Fall back to build-time key, and save it for future launches
    const buildTimeKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (buildTimeKey.isNotEmpty) {
      _openAIService.setApiKey(buildTimeKey, provider: ai_svc.AIProvider.googleGemini);
      // Save so future launches don't need --dart-define
      await SecureStorageService.saveAPIKey('gemini', buildTimeKey);
    }

    // 3. No key found — local fallback will be used silently
  }

  /// Lets you update the key at runtime (e.g. from a dev settings screen)
  /// Saves to secure storage so it persists after the app restarts.
  Future<void> setAndSaveApiKey(String apiKey,
      {ai_svc.AIProvider provider = ai_svc.AIProvider.googleGemini}) async {
    _openAIService.setApiKey(apiKey, provider: provider);
    await SecureStorageService.saveAPIKey('gemini', apiKey);
    notifyListeners();
  }

  // Keep for backward compatibility with api_key_dialog
  void setAIApiKey(String apiKey,
      {ai_svc.AIProvider provider = ai_svc.AIProvider.googleGemini}) {
    _openAIService.setApiKey(apiKey, provider: provider);
    notifyListeners();
  }

  // ─── Game lifecycle ────────────────────────────────────────────────────────

  void initializeGame(GameMode mode) {
    final hidden = _gameService.generateHiddenSequence();
    _currentSession = GameSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mode: mode,
      timeLimit: _getTimeLimit(mode),
      maxMoves: _getMaxMoves(mode),
      startTime: DateTime.now(),
      hiddenSequence: hidden,
    );
    _currentGuess = List.filled(GameService.SEQUENCE_LENGTH, Colors.grey);
    _previousGuess = List.from(_currentGuess);
    _isSubmitting = false;
    _lastHint = '';
    _postGameInsight = '';
    _isLoadingInsight = false;
    notifyListeners();
  }

  int _getTimeLimit(GameMode mode) {
    switch (mode) {
      case GameMode.quick:       return AppConstants.quickModeTime;
      case GameMode.standard:    return AppConstants.standardModeTime;
      case GameMode.competitive: return AppConstants.competitiveModeTime;
    }
  }

  int _getMaxMoves(GameMode mode) {
    switch (mode) {
      case GameMode.quick:       return AppConstants.quickModeMaxMoves;
      case GameMode.standard:    return AppConstants.standardModeMaxMoves;
      case GameMode.competitive: return AppConstants.competitiveModeMaxMoves;
    }
  }

  // ─── Guess handling ────────────────────────────────────────────────────────

  void updateGuess(int index, Color color) {
    if (_isSubmitting) return;
    _currentGuess[index] = color;
    notifyListeners();
  }

  void swapGuess(int index1, int index2) {
    if (_isSubmitting) return;
    final temp = _currentGuess[index1];
    _currentGuess[index1] = _currentGuess[index2];
    _currentGuess[index2] = temp;
    notifyListeners();
  }

  Future<void> submitGuess() async {
    if (_isSubmitting || _currentSession == null) return;
    if (!canSubmit) return;

    _isSubmitting = true;
    _lastHint = '';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final variablesChanged = _gameService.calculateVariablesChanged(
      _previousGuess.every((c) => c == Colors.grey) ? _currentGuess : _previousGuess,
      _currentGuess,
    );
    final matches = _gameService.calculateMatches(
        _currentGuess, _currentSession!.hiddenSequence);
    final matchedPositions = _gameService.getMatchedPositions(
        _currentGuess, _currentSession!.hiddenSequence);
    final prevMatches = _currentSession!.attempts.isNotEmpty
        ? _currentSession!.attempts.last.matches
        : 0;
    final isImpulsive =
        _gameService.isImpulsiveMove(variablesChanged, prevMatches, matches);

    final attempt = Attempt(
      attemptNumber: _currentSession!.currentMoves + 1,
      guess: List.from(_currentGuess),
      matches: matches,
      matchedPositions: matchedPositions,
      timestamp: DateTime.now(),
      variablesChanged: variablesChanged,
      wasImpulsive: isImpulsive,
    );

    _currentSession!.attempts.add(attempt);
    _currentSession!.currentMoves++;
    _previousGuess = List.from(_currentGuess);

    // Local hint — instant, no network
    _lastHint = _aiService.getRealTimeHint(attempt, _currentSession!.currentMoves);

    if (_gameService.isSequenceSolved(_currentGuess, _currentSession!.hiddenSequence)) {
      final score = _gameService.calculateScore(
        matches,
        _currentSession!.currentMoves,
        _currentSession!.remainingTime,
        mode: _currentSession!.mode,
      );
      _currentSession!.currentScore += score;
    }

    _isSubmitting = false;
    notifyListeners();
  }

  // ─── Post-game AI insight ──────────────────────────────────────────────────

  void loadPostGameInsight() {
    final session = _currentSession;
    if (session == null || session.attempts.isEmpty) {
      _postGameInsight = _buildLocalInsight();
      notifyListeners();
      return;
    }

    // Step 1: show local insight immediately — dialog is never empty
    _postGameInsight = _buildLocalInsight();
    notifyListeners();

    // Step 2: upgrade to real AI in background if key is available
    if (_openAIService.hasValidKey) {
      _isLoadingInsight = true;
      notifyListeners();

      print('🤖 AI key found — calling Gemini for post-game insight...');
      final timeSpent = DateTime.now().difference(session.startTime).inSeconds;

      _openAIService
          .getGameCompletionFeedback(
            attempts: session.attempts,
            score: session.currentScore,
            moves: session.currentMoves,
            timeSpent: timeSpent,
          )
          .then((aiInsight) {
            print('✅ Gemini responded: ${aiInsight.substring(0, aiInsight.length.clamp(0, 80))}...');
            if (aiInsight.isNotEmpty) _postGameInsight = aiInsight;
            _isLoadingInsight = false;
            notifyListeners();
          })
          .catchError((e) {
            print('❌ AI insight failed, using local fallback: $e');
            _isLoadingInsight = false;
            notifyListeners();
          });
    }
  }

  // ─── Local fallback ────────────────────────────────────────────────────────

  String _buildLocalInsight() {
    final session = _currentSession;
    if (session == null || session.attempts.isEmpty) return '';

    final attempts = session.attempts;
    final best = attempts.reduce((a, b) => a.matches > b.matches ? a : b);
    final avgChanged = attempts
            .map((a) => a.variablesChanged.toDouble())
            .reduce((a, b) => a + b) /
        attempts.length;
    final impulsive = attempts.where((a) => a.wasImpulsive).length;
    final won = attempts.last.matches == GameService.SEQUENCE_LENGTH;

    final buf = StringBuffer();
    if (won) {
      buf.writeln('🎉 Puzzle solved in ${session.currentMoves} moves!');
    } else {
      buf.writeln('You reached ${attempts.last.matches}/8 matches.');
    }
    buf.writeln('Best move: Move ${best.attemptNumber} with ${best.matches}/8.');
    buf.writeln('Avg bottles swapped per move: ${avgChanged.toStringAsFixed(1)}.');
    if (impulsive > 0) {
      buf.writeln('$impulsive impulsive move(s) — try changing fewer bottles at a time.');
    } else {
      buf.writeln('No impulsive moves — great discipline!');
    }
    buf.write(avgChanged > 2.5
        ? 'Tip: Swap 1–2 bottles per move for cleaner feedback.'
        : 'Tip: Keep isolating one variable at a time — you\'re on the right track.');
    return buf.toString();
  }

  String buildPostGameAnalysis() => _buildLocalInsight();

  // ─── Misc ──────────────────────────────────────────────────────────────────

  void toggleHistory() {
    _showHistory = !_showHistory;
    notifyListeners();
  }

  void resetGuess() {
    _currentGuess = List.filled(GameService.SEQUENCE_LENGTH, Colors.grey);
    _lastHint = '';
    notifyListeners();
  }

  void resetGame() {
    _currentSession = null;
    _currentGuess = [];
    _isSubmitting = false;
    _lastHint = '';
    _postGameInsight = '';
    _isLoadingInsight = false;
    notifyListeners();
  }

  void updateTimer() {
    if (_currentSession != null &&
        _currentSession!.status == GameStatus.active &&
        _currentSession!.isTimeUp) {
      _currentSession!.status = GameStatus.timeout;
    }
    notifyListeners();
  }
}
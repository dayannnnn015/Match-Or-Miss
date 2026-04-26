// lib/providers/game_provider.dart
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';
import '../services/game_service.dart';
import '../services/openai_service.dart' as ai_svc;
import '../services/secure_storage_service.dart';

class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();
  final ai_svc.OpenAIService _openAIService = ai_svc.OpenAIService();

  GameSession? _currentSession;
  List<Bottle?> _currentGuessSlots = [];
  List<Bottle?> _previousGuessSlots = []; // Track previous state for attempt recording
  bool _isSubmitting = false;
  bool _resultDialogShown = false; // Track whether result dialog has been shown

  String _postGameInsight = '';
  bool _isLoadingInsight = false;

  String get postGameInsight => _postGameInsight;
  bool get isLoadingInsight => _isLoadingInsight;
  bool get hasAIKey => _openAIService.hasValidKey;

  GameSession? get currentSession => _currentSession;
  List<Bottle?> get currentGuessSlots => _currentGuessSlots;
  bool get isSubmitting => _isSubmitting;

  bool get canSubmit => false; // No submit button needed

  GameProvider() {
    _loadApiKey();
    // Default to Gemini - users can change in settings if needed
    _openAIService.setApiKey('', provider: ai_svc.AIProvider.googleGemini);
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

  void initializeGame(GameMode mode, {int? customMaxMoves}) {
    final hidden = _gameService.generateHiddenSequence();
    // Shuffle bottles so puzzle starts unsolved
    final shuffledBottles = _gameService.generateAvailableBottles(hidden);
    
    final maxMoves = customMaxMoves ?? _getMaxMoves(mode);
    final timeLimit = _getTimeLimit(mode);
    
    _currentSession = GameSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mode: mode,
      timeLimit: timeLimit,
      maxMoves: maxMoves,
      startTime: DateTime.now(),
      hiddenSequence: hidden,
      currentGuessSlots: shuffledBottles.cast<Bottle?>(),
      availableBottles: [],
    );
    _currentGuessSlots = shuffledBottles.cast<Bottle?>();
    _previousGuessSlots = shuffledBottles.cast<Bottle?>(); // Initialize previous state
    _isSubmitting = false;
    _resultDialogShown = false; // Reset result dialog flag for new game
    _postGameInsight = '';
    _isLoadingInsight = false;
    notifyListeners();
  }

  int _getTimeLimit(GameMode mode) {
    switch (mode) {
      case GameMode.quick:       return 999999; // Essentially unlimited for quick mode
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

  void swapBottles(int index1, int index2) {
    if (_currentSession == null) return;
    
    // Step 1: Record state before swap
    final previousMatches = _gameService.calculateMatches(
        _currentGuessSlots, _currentSession!.hiddenSequence);
    
    // Step 2: Perform the swap
    final temp = _currentGuessSlots[index1];
    _currentGuessSlots[index1] = _currentGuessSlots[index2];
    _currentGuessSlots[index2] = temp;
    
    // Step 3: Calculate new state after swap
    final currentMatches = _gameService.calculateMatches(
        _currentGuessSlots, _currentSession!.hiddenSequence);
    final matchedPositions = _gameService.getMatchedPositions(
        _currentGuessSlots, _currentSession!.hiddenSequence);
    
    // Step 4: Calculate variables changed
    final variablesChanged = _gameService.calculateVariablesChanged(
        _previousGuessSlots, _currentGuessSlots);
    
    // Step 5: Detect impulsive move
    final wasImpulsive = _gameService.isImpulsiveMove(
        variablesChanged, previousMatches, currentMatches);
    
    // Step 6: Create attempt record
    final attempt = Attempt(
      attemptNumber: _currentSession!.attempts.length + 1,
      guess: List<Bottle?>.from(_currentGuessSlots),
      matches: currentMatches,
      matchedPositions: matchedPositions,
      timestamp: DateTime.now(),
      variablesChanged: variablesChanged,
      wasImpulsive: wasImpulsive,
    );
    
    // Step 7: Record attempt in session
    _currentSession!.attempts.add(attempt);
    
    // Step 8: Update previous state for next move
    _previousGuessSlots = List<Bottle?>.from(_currentGuessSlots);
    
    // Step 9: Count moves
    _currentSession!.currentMoves++;
    notifyListeners();
  }
  
  /// Get current matches and matched positions
  int getCurrentMatches() {
    if (_currentSession == null) return 0;
    return _gameService.calculateMatches(
        _currentGuessSlots, _currentSession!.hiddenSequence);
  }
  
  List<int> getCurrentMatchedPositions() {
    if (_currentSession == null) return [];
    return _gameService.getMatchedPositions(
        _currentGuessSlots, _currentSession!.hiddenSequence);
  }
  
  bool isSolved() {
    if (_currentSession == null) return false;
    return _gameService.isSequenceSolved(
        _currentGuessSlots, _currentSession!.hiddenSequence);
  }

  /// Called periodically to check if game is won
  void checkGameState() {
    if (_currentSession == null) return;
    if (isSolved() && !_resultDialogShown) {
      _resultDialogShown = true;

      final score = _gameService.calculateScore(
        getCurrentMatches(),
        _currentSession!.currentMoves,
        _currentSession!.remainingTime,
        mode: _currentSession!.mode,
      );
      _currentSession!.currentScore += score;
      loadPostGameInsight();
    }
  }

  // ─── Post-game AI insight ──────────────────────────────────────────────────

  void loadPostGameInsight() {
    final session = _currentSession;
    if (session == null || session.attempts.isEmpty) {
      _postGameInsight = 'No game data to analyze.';
      notifyListeners();
      return;
    }

    // Prioritize AI API feedback — only use local fallback if API unavailable
    if (_openAIService.hasValidKey) {
      _isLoadingInsight = true;
      _postGameInsight = '🔄 Analyzing your performance...';
      notifyListeners();

      final timeSpent = DateTime.now().difference(session.startTime).inSeconds;

      _openAIService
          .getGameCompletionFeedback(
            attempts: session.attempts,
            score: session.currentScore,
            moves: session.currentMoves,
            timeSpent: timeSpent,
          )
          .then((aiInsight) {
            if (aiInsight.isNotEmpty) {
              _postGameInsight = aiInsight;
            } else {
              _postGameInsight = _buildLocalInsight();
            }
            _isLoadingInsight = false;
            notifyListeners();
          })
          .catchError((e) {
            // API failed — fall back to local
            _postGameInsight = _buildLocalInsight();
            _isLoadingInsight = false;
            notifyListeners();
          });
    } else {
      // No API key — use local fallback
      _postGameInsight = _buildLocalInsight();
      notifyListeners();
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

  void resetGuess() {
    if (_currentSession == null) return;
    // Reset bottles to shuffled order
    final shuffledBottles = _gameService.generateAvailableBottles(_currentSession!.hiddenSequence);
    _currentGuessSlots = shuffledBottles.cast<Bottle?>();
    _previousGuessSlots = shuffledBottles.cast<Bottle?>();
    _currentSession!.currentMoves = 0;
    _currentSession!.attempts.clear(); // Clear recorded attempts
    notifyListeners();
  }

  void resetGame() {
    _currentSession = null;
    _currentGuessSlots = [];
    _previousGuessSlots = [];
    _isSubmitting = false;
    _resultDialogShown = false;
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
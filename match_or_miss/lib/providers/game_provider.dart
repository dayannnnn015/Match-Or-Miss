// lib/providers/game_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';
import '../services/game_service.dart';
import '../services/ai_service.dart';
import '../services/openai_service.dart' as ai_svc;
import '../services/secure_storage_service.dart';

class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();
  final AIService   _aiService   = AIService();
  final ai_svc.OpenAIService _openAIService = ai_svc.OpenAIService();

  GameSession? _currentSession;
  List<Color>  _currentGuess = [];
  bool _isSubmitting  = false;
  bool _showHistory   = true;
  List<Color> _previousGuess = [];

  String _postGameInsight  = '';
  bool   _isLoadingInsight = false;
  String _lastHint = '';

  // ── Inhibitory Control state ────────────────────────────────────────────────
  /// Timestamp when the player last changed their guess.
  DateTime? _lastGuessChangeTime;
  int _patienceBonusEarned = 0; // accumulated across all moves this session

  // ── Cognitive Flexibility state ─────────────────────────────────────────────
  bool _sequenceShifted    = false;
  bool _shiftAlertPending  = false; // true for one frame so the UI can flash
  bool _solvedAfterShift   = false;

  // Expose for UI
  bool get sequenceJustShifted => _shiftAlertPending;
  bool get sequenceHasShifted  => _sequenceShifted;

  // ── Standard getters ────────────────────────────────────────────────────────
  bool   get hasHint          => _lastHint.isNotEmpty;
  String get lastHint         => _lastHint;
  String get postGameInsight  => _postGameInsight;
  bool   get isLoadingInsight => _isLoadingInsight;
  bool   get hasAIKey         => _openAIService.hasValidKey;

  GameSession? get currentSession => _currentSession;
  List<Color>  get currentGuess   => _currentGuess;
  bool         get isSubmitting   => _isSubmitting;
  bool         get showHistory    => _showHistory;

  bool get canSubmit {
    if (_currentGuess.isEmpty) return false;
    return _gameService.isValidGuess(_currentGuess);
  }

  // ── Constructor ──────────────────────────────────────────────────────────────
  GameProvider() { _loadApiKey(); }

  Future<void> _loadApiKey() async {
    // Key is baked in at build time via --dart-define-from-file=env.json
    // env.json lives on your machine only and is never committed to git
    // Players never see or interact with this key
    const key = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (key.isNotEmpty) {
      _openAIService.setApiKey(key, provider: ai_svc.AIProvider.googleGemini);
      print('🤖 Gemini AI ready');
    } else {
      print('⚠️ No AI key found — using local fallback. Run with --dart-define-from-file=env.json');
    }
  }

  Future<void> setAndSaveApiKey(String apiKey,
      {ai_svc.AIProvider provider = ai_svc.AIProvider.googleGemini}) async {
    _openAIService.setApiKey(apiKey, provider: provider);
    await SecureStorageService.saveAPIKey('gemini', apiKey);
    notifyListeners();
  }

  void setAIApiKey(String apiKey,
      {ai_svc.AIProvider provider = ai_svc.AIProvider.googleGemini}) {
    _openAIService.setApiKey(apiKey, provider: provider);
    notifyListeners();
  }

  // ── Game lifecycle ────────────────────────────────────────────────────────────

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
    _currentGuess       = List.filled(GameService.SEQUENCE_LENGTH, Colors.grey);
    _previousGuess      = List.from(_currentGuess);
    _isSubmitting       = false;
    _lastHint           = '';
    _postGameInsight    = '';
    _isLoadingInsight   = false;
    _lastGuessChangeTime = null;
    _patienceBonusEarned = 0;
    _sequenceShifted    = false;
    _shiftAlertPending  = false;
    _solvedAfterShift   = false;
    notifyListeners();
  }

  int _getTimeLimit(GameMode mode) {
    switch (mode) {
      case GameMode.quick:       return AppConstants.workingMemoryModeTime;
      case GameMode.standard:    return AppConstants.inhibitoryModeTime;
      case GameMode.competitive: return AppConstants.flexibilityModeTime;
    }
  }

  int _getMaxMoves(GameMode mode) {
    switch (mode) {
      case GameMode.quick:       return AppConstants.workingMemoryModeMaxMoves;
      case GameMode.standard:    return AppConstants.inhibitoryModeMaxMoves;
      case GameMode.competitive: return AppConstants.flexibilityModeMaxMoves;
    }
  }

  // ── Guess handling ────────────────────────────────────────────────────────────

  void updateGuess(int index, Color color) {
    if (_isSubmitting) return;
    _currentGuess[index] = color;
    // Record the time of the last change — used by inhibitory mode patience check
    _lastGuessChangeTime = DateTime.now();
    notifyListeners();
  }

  void swapGuess(int index1, int index2) {
    if (_isSubmitting) return;
    final temp = _currentGuess[index1];
    _currentGuess[index1] = _currentGuess[index2];
    _currentGuess[index2] = temp;
    _lastGuessChangeTime = DateTime.now();
    notifyListeners();
  }

  Future<void> submitGuess() async {
    if (_isSubmitting || _currentSession == null) return;
    if (!canSubmit) return;

    _isSubmitting     = true;
    _shiftAlertPending = false;
    _lastHint         = '';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final session = _currentSession!;
    final mode    = session.mode;

    // ── Inhibitory Control: check patience ────────────────────────────────────
    int patienceThisTurn = 0;
    if (mode == GameMode.standard && _lastGuessChangeTime != null) {
      final waited = DateTime.now().difference(_lastGuessChangeTime!).inSeconds;
      if (waited >= AppConstants.inhibitoryPatientSecs) {
        patienceThisTurn = 1;
        _patienceBonusEarned++;
      }
    }

    // ── Score the attempt ─────────────────────────────────────────────────────
    final variablesChanged = _gameService.calculateVariablesChanged(
      _previousGuess.every((c) => c == Colors.grey) ? _currentGuess : _previousGuess,
      _currentGuess,
    );
    final matches         = _gameService.calculateMatches(_currentGuess, session.hiddenSequence);
    final matchedPositions= _gameService.getMatchedPositions(_currentGuess, session.hiddenSequence);
    final prevMatches     = session.attempts.isNotEmpty ? session.attempts.last.matches : 0;
    final isImpulsive     = _gameService.isImpulsiveMove(variablesChanged, prevMatches, matches);

    final attempt = Attempt(
      attemptNumber:    session.currentMoves + 1,
      guess:            List.from(_currentGuess),
      matches:          matches,
      matchedPositions: matchedPositions,
      timestamp:        DateTime.now(),
      variablesChanged: variablesChanged,
      wasImpulsive:     isImpulsive,
      patienceBonus:    patienceThisTurn,
    );

    session.attempts.add(attempt);
    session.currentMoves++;
    _previousGuess       = List.from(_currentGuess);
    _lastGuessChangeTime = null; // reset after each submit

    // ── Local AI hint ─────────────────────────────────────────────────────────
    _lastHint = _aiService.getRealTimeHint(attempt, session.currentMoves);

    // ── Cognitive Flexibility: shift after move N ─────────────────────────────
    if (mode == GameMode.competitive &&
        !_sequenceShifted &&
        session.currentMoves >= AppConstants.flexibilityShiftAfterMove) {
      session.hiddenSequence = _gameService.shiftSequence(session.hiddenSequence);
      _sequenceShifted   = true;
      _shiftAlertPending = true;
    }

    // ── Update score on solve ─────────────────────────────────────────────────
    final solved = _gameService.isSequenceSolved(_currentGuess, session.hiddenSequence);
    if (solved) {
      if (_sequenceShifted) _solvedAfterShift = true;
      final score = _gameService.calculateScore(
        matches,
        session.currentMoves,
        session.remainingTime,
        mode: mode,
        attempts: session.attempts,
        patienceBonusEarned: _patienceBonusEarned,
        solvedAfterShift: _solvedAfterShift,
      );
      session.currentScore += score;
    }

    _isSubmitting = false;
    notifyListeners();

    // Clear the shift alert after one notification cycle
    if (_shiftAlertPending) {
      await Future.delayed(const Duration(milliseconds: 50));
      _shiftAlertPending = false;
      notifyListeners();
    }
  }

  // ── Post-game insight ─────────────────────────────────────────────────────────

  void loadPostGameInsight() {
    final session = _currentSession;
    if (session == null || session.attempts.isEmpty) {
      _postGameInsight = _buildLocalInsight();
      notifyListeners();
      return;
    }
    _postGameInsight = _buildLocalInsight();
    notifyListeners();

    if (_openAIService.hasValidKey) {
      _isLoadingInsight = true;
      notifyListeners();
      print('🤖 Calling Gemini for post-game insight...');
      final timeSpent = DateTime.now().difference(session.startTime).inSeconds;
      _openAIService
          .getGameCompletionFeedback(
            attempts: session.attempts,
            score: session.currentScore,
            moves: session.currentMoves,
            timeSpent: timeSpent,
          )
          .then((aiInsight) {
            print('✅ Gemini responded successfully');
            if (aiInsight.isNotEmpty) _postGameInsight = aiInsight;
            _isLoadingInsight = false;
            notifyListeners();
          })
          .catchError((e) {
            print('❌ Gemini call failed: \$e');
            _isLoadingInsight = false;
            notifyListeners();
          });
    }
  }

  String _buildLocalInsight() {
    final session = _currentSession;
    if (session == null || session.attempts.isEmpty) return '';

    final attempts   = session.attempts;
    final best       = attempts.reduce((a, b) => a.matches > b.matches ? a : b);
    final methodical = attempts.where((a) => a.variablesChanged <= 2).length;
    final impulsive  = attempts.where((a) => a.wasImpulsive).length;
    final avgChanged = attempts.map((a) => a.variablesChanged.toDouble())
            .reduce((a, b) => a + b) / attempts.length;
    final won = attempts.last.matches == GameService.SEQUENCE_LENGTH;

    final buf = StringBuffer();
    if (won) {
      buf.writeln('🎉 Solved in ${session.currentMoves} moves!');
    } else {
      buf.writeln('Best: ${attempts.last.matches}/8 matches.');
    }
    buf.writeln('Best move: #${best.attemptNumber} with ${best.matches}/8.');
    buf.writeln('Methodical moves (≤2 changes): $methodical — earned ${methodical * AppConstants.strategyBonusPerMove} bonus pts.');
    if (impulsive > 0) {
      buf.writeln('Impulsive moves: $impulsive — lost ${impulsive * AppConstants.impulsivePenaltyPerMove} pts.');
    } else {
      buf.writeln('No impulsive moves — full strategy bonus!');
    }
    if (session.mode == GameMode.standard && _patienceBonusEarned > 0) {
      buf.writeln('Patience bonuses earned: $_patienceBonusEarned × ${AppConstants.inhibitoryPatienceBonus} pts.');
    }
    if (session.mode == GameMode.competitive && _sequenceShifted) {
      buf.writeln(_solvedAfterShift
          ? '🔄 You adapted after the mid-game shift — +200 flexibility bonus!'
          : '🔄 The puzzle shifted mid-game. Adaptation is key next time.');
    }
    buf.write(avgChanged > 2.5
        ? 'Tip: Swap 1–2 bottles per move for cleaner deduction.'
        : 'Tip: Keep isolating one variable at a time — good discipline.');
    return buf.toString();
  }

  String buildPostGameAnalysis() => _buildLocalInsight();

  // ── Misc ──────────────────────────────────────────────────────────────────────

  void toggleHistory() { _showHistory = !_showHistory; notifyListeners(); }

  void resetGuess() {
    _currentGuess = List.filled(GameService.SEQUENCE_LENGTH, Colors.grey);
    _lastHint = '';
    _lastGuessChangeTime = null;
    notifyListeners();
  }

  void resetGame() {
    _currentSession      = null;
    _currentGuess        = [];
    _isSubmitting        = false;
    _lastHint            = '';
    _postGameInsight     = '';
    _isLoadingInsight    = false;
    _patienceBonusEarned = 0;
    _sequenceShifted     = false;
    _shiftAlertPending   = false;
    _solvedAfterShift    = false;
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
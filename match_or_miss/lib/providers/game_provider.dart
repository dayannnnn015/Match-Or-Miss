// lib/providers/game_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';
import '../services/game_service.dart';
import '../services/openai_service.dart' as ai_svc;
import '../services/secure_storage_service.dart';

class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();
<<<<<<< HEAD
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
=======
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
>>>>>>> 8d87ab68c965739798a3c6e1013055dcba777fb8

  bool get canSubmit => false; // No submit button needed

<<<<<<< HEAD
  // ── Constructor ──────────────────────────────────────────────────────────────
  GameProvider() { _loadApiKey(); }
=======
  GameProvider() {
    _loadApiKey();
    // Default to Gemini - users can change in settings if needed
    _openAIService.setApiKey('', provider: ai_svc.AIProvider.googleGemini);
  }
>>>>>>> 8d87ab68c965739798a3c6e1013055dcba777fb8

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
<<<<<<< HEAD
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
=======
    _currentGuessSlots = shuffledBottles.cast<Bottle?>();
    _previousGuessSlots = shuffledBottles.cast<Bottle?>(); // Initialize previous state
    _isSubmitting = false;
    _resultDialogShown = false; // Reset result dialog flag for new game
    _postGameInsight = '';
    _isLoadingInsight = false;
>>>>>>> 8d87ab68c965739798a3c6e1013055dcba777fb8
    notifyListeners();
  }

  int _getTimeLimit(GameMode mode) {
    switch (mode) {
<<<<<<< HEAD
      case GameMode.quick:       return AppConstants.workingMemoryModeTime;
      case GameMode.standard:    return AppConstants.inhibitoryModeTime;
      case GameMode.competitive: return AppConstants.flexibilityModeTime;
=======
      case GameMode.quick:       return 999999; // Essentially unlimited for quick mode
      case GameMode.standard:    return AppConstants.standardModeTime;
      case GameMode.competitive: return AppConstants.competitiveModeTime;
>>>>>>> 8d87ab68c965739798a3c6e1013055dcba777fb8
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

<<<<<<< HEAD
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
=======
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
>>>>>>> 8d87ab68c965739798a3c6e1013055dcba777fb8
      matchedPositions: matchedPositions,
      timestamp:        DateTime.now(),
      variablesChanged: variablesChanged,
<<<<<<< HEAD
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
=======
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
>>>>>>> 8d87ab68c965739798a3c6e1013055dcba777fb8
  }

  // ── Post-game insight ─────────────────────────────────────────────────────────

  void loadPostGameInsight() {
    final session = _currentSession;
    if (session == null || session.attempts.isEmpty) {
      _postGameInsight = 'No game data to analyze.';
      notifyListeners();
      return;
    }
<<<<<<< HEAD
    _postGameInsight = _buildLocalInsight();
    notifyListeners();

=======

    // Prioritize AI API feedback — only use local fallback if API unavailable
>>>>>>> 8d87ab68c965739798a3c6e1013055dcba777fb8
    if (_openAIService.hasValidKey) {
      _isLoadingInsight = true;
      _postGameInsight = '🔄 Analyzing your performance...';
      notifyListeners();
<<<<<<< HEAD
      print('🤖 Calling Gemini for post-game insight...');
=======

>>>>>>> 8d87ab68c965739798a3c6e1013055dcba777fb8
      final timeSpent = DateTime.now().difference(session.startTime).inSeconds;
      _openAIService
          .getGameCompletionFeedback(
            attempts: session.attempts,
            score: session.currentScore,
            moves: session.currentMoves,
            timeSpent: timeSpent,
          )
          .then((aiInsight) {
<<<<<<< HEAD
            print('✅ Gemini responded successfully');
            if (aiInsight.isNotEmpty) _postGameInsight = aiInsight;
=======
            if (aiInsight.isNotEmpty) {
              _postGameInsight = aiInsight;
            } else {
              _postGameInsight = _buildLocalInsight();
            }
>>>>>>> 8d87ab68c965739798a3c6e1013055dcba777fb8
            _isLoadingInsight = false;
            notifyListeners();
          })
          .catchError((e) {
<<<<<<< HEAD
            print('❌ Gemini call failed: \$e');
=======
            // API failed — fall back to local
            _postGameInsight = _buildLocalInsight();
>>>>>>> 8d87ab68c965739798a3c6e1013055dcba777fb8
            _isLoadingInsight = false;
            notifyListeners();
          });
    } else {
      // No API key — use local fallback
      _postGameInsight = _buildLocalInsight();
      notifyListeners();
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

<<<<<<< HEAD
  // ── Misc ──────────────────────────────────────────────────────────────────────

  void toggleHistory() { _showHistory = !_showHistory; notifyListeners(); }

  void resetGuess() {
    _currentGuess = List.filled(GameService.SEQUENCE_LENGTH, Colors.grey);
    _lastHint = '';
    _lastGuessChangeTime = null;
=======
  void resetGuess() {
    if (_currentSession == null) return;
    // Reset bottles to shuffled order
    final shuffledBottles = _gameService.generateAvailableBottles(_currentSession!.hiddenSequence);
    _currentGuessSlots = shuffledBottles.cast<Bottle?>();
    _previousGuessSlots = shuffledBottles.cast<Bottle?>();
    _currentSession!.currentMoves = 0;
    _currentSession!.attempts.clear(); // Clear recorded attempts
>>>>>>> 8d87ab68c965739798a3c6e1013055dcba777fb8
    notifyListeners();
  }

  void resetGame() {
<<<<<<< HEAD
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
=======
    _currentSession = null;
    _currentGuessSlots = [];
    _previousGuessSlots = [];
    _isSubmitting = false;
    _resultDialogShown = false;
    _postGameInsight = '';
    _isLoadingInsight = false;

>>>>>>> 8d87ab68c965739798a3c6e1013055dcba777fb8
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
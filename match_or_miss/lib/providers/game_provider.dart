// lib/providers/game_provider.dart
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../services/game_service.dart';

class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();

  GameSession? _currentSession;
  List<Color> _currentGuess = [];
  bool _isSubmitting = false;
  bool _showHistory = true;
  int _confirmationDelay = 0;
  List<Color> _previousGuess = [];

  GameSession? get currentSession => _currentSession;
  List<Color> get currentGuess => _currentGuess;
  bool get isSubmitting => _isSubmitting;
  bool get showHistory => _showHistory;

  void initializeGame(GameMode mode) {
    _currentSession = GameSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mode: mode,
      timeLimit: _getTimeLimit(mode),
      maxMoves: 12,
      startTime: DateTime.now(),
      hiddenSequence: _gameService.generateHiddenSequence(),
    );

    _currentGuess = List.from(
      _currentSession!.hiddenSequence.map((_) => Colors.grey),
    );
    _previousGuess = List.from(_currentGuess);
    _isSubmitting = false;

    notifyListeners();
  }

  int _getTimeLimit(GameMode mode) {
    switch (mode) {
      case GameMode.quick:
        return 120; // 2 minutes
      case GameMode.standard:
        return 300; // 5 minutes
      case GameMode.competitive:
        return 600; // 10 minutes
    }
  }

  void updateGuess(int index, Color color) {
    if (_isSubmitting) return;
    _currentGuess[index] = color;
    notifyListeners();
  }

  void swapGuess(int index1, int index2) {
    if (_isSubmitting) return;
    Color temp = _currentGuess[index1];
    _currentGuess[index1] = _currentGuess[index2];
    _currentGuess[index2] = temp;
    notifyListeners();
  }

  Future<void> submitGuess() async {
    if (_isSubmitting || _currentSession == null) return;

    // Check if all colors are selected
    if (_currentGuess.contains(Colors.grey)) {
      return;
    }

    // Apply confirmation delay
    _isSubmitting = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: _confirmationDelay));

    int variablesChanged = _gameService.calculateVariablesChanged(
      _previousGuess,
      _currentGuess,
    );
    int matches = _gameService.calculateMatches(
      _currentGuess,
      _currentSession!.hiddenSequence,
    );
    bool isImpulsive = _gameService.isImpulsiveMove(
      variablesChanged,
      _currentSession!.attempts.isNotEmpty
          ? _currentSession!.attempts.last.matches
          : 0,
      matches,
    );

    Attempt attempt = Attempt(
      attemptNumber: _currentSession!.currentMoves + 1,
      guess: List.from(_currentGuess),
      matches: matches,
      timestamp: DateTime.now(),
      variablesChanged: variablesChanged,
      wasImpulsive: isImpulsive,
    );

    _currentSession!.attempts.add(attempt);
    _currentSession!.currentMoves++;

    // Check for solution
    if (_gameService.isSequenceSolved(
      _currentGuess,
      _currentSession!.hiddenSequence,
    )) {
      _handleSolution();
    } else {
      _previousGuess = List.from(_currentGuess);
    }

    _isSubmitting = false;
    notifyListeners();
  }

  void _handleSolution() {
    // Calculate score
    int score = _gameService.calculateScore(
      _currentSession!.attempts.last.matches,
      _currentSession!.currentMoves,
      _currentSession!.remainingTime,
    );

    _currentSession!.currentScore += score;

    // Add time bonus
    int timeBonus = _getTimeBonus();
    _currentSession!.timeBonus += timeBonus;

    // Generate new sequence for next puzzle
    _currentSession!.hiddenSequence = _gameService.generateHiddenSequence();
    _currentGuess = List.from(
      _currentSession!.hiddenSequence.map((_) => Colors.grey),
    );
    _previousGuess = List.from(_currentGuess);

    // Reset moves for new puzzle but keep session
    _currentSession!.currentMoves = 0;

    notifyListeners();
  }

  int _getTimeBonus() {
    // Bonus based on remaining time and moves used
    int remainingTime = _currentSession!.remainingTime;
    int movesUsed = _currentSession!.currentMoves;

    if (remainingTime > 60 && movesUsed < 8) {
      return 10;
    } else if (remainingTime > 30 && movesUsed < 10) {
      return 7;
    } else {
      return 5;
    }
  }

  void toggleHistory() {
    _showHistory = !_showHistory;
    notifyListeners();
  }

  void setConfirmationDelay(int seconds) {
    _confirmationDelay = seconds;
  }

  void resetGuess() {
    if (_currentSession != null) {
      _currentGuess = List.from(
        _currentSession!.hiddenSequence.map((_) => Colors.grey),
      );
      notifyListeners();
    }
  }

  void resetGame() {
    _currentSession = null;
    _currentGuess = [];
    _isSubmitting = false;
    notifyListeners();
  }

  void updateTimer() {
    if (_currentSession != null &&
        _currentSession!.status == GameStatus.active &&
        _currentSession!.isTimeUp) {
      _currentSession!.status = GameStatus.timeout;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }
}

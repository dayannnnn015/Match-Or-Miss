// lib/models/game_models.dart
import 'package:flutter/material.dart';

enum GameMode { quick, standard, competitive }
enum GameStatus { waiting, active, paused, completed, timeout }

class GameSession {
  final String id;
  final GameMode mode;
  final int timeLimit;
  int maxMoves;
  int currentMoves;
  int currentScore;
  int timeBonus;
  GameStatus status;
  DateTime startTime;
  List<Attempt> attempts;
  List<Color> hiddenSequence; // mutable — flexibility mode can shift it

  GameSession({
    required this.id,
    required this.mode,
    required this.timeLimit,
    required this.maxMoves,
    this.currentMoves = 0,
    this.currentScore = 0,
    this.timeBonus    = 0,
    this.status       = GameStatus.waiting,
    required this.startTime,
    List<Attempt>? attempts,
    required this.hiddenSequence,
  }) : attempts = attempts ?? [];

  int get remainingTime {
    if (timeLimit == 0) return 999999; // no timer
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    return (timeLimit + timeBonus) - elapsed;
  }

  bool get isTimeUp      => timeLimit > 0 && remainingTime <= 0;
  bool get isMovesExhausted => currentMoves >= maxMoves;
}

class Attempt {
  final int attemptNumber;
  final List<Color> guess;
  final int matches;
  final List<int> matchedPositions;
  final DateTime timestamp;
  final int variablesChanged;
  final bool wasImpulsive;
  final int patienceBonus; // 1 if player waited ≥8s before submitting, else 0

  Attempt({
    required this.attemptNumber,
    required this.guess,
    required this.matches,
    required this.matchedPositions,
    required this.timestamp,
    required this.variablesChanged,
    this.wasImpulsive  = false,
    this.patienceBonus = 0,
  });
}

class GameStat {
  final DateTime date;
  final GameMode mode;
  final int score;
  final int movesUsed;
  final int timeUsed;
  final bool won;
  GameStat({
    required this.date, required this.mode, required this.score,
    required this.movesUsed, required this.timeUsed, required this.won,
  });
}

// ── AI models (kept in same file for simplicity) ──────────────────────────────

class AIPlayerAnalysis {
  final double avgVariablesChanged;
  final int impulsiveMoves;
  final int repeatedMistakes;
  final double progressRate;
  final List<String> suggestions;
  final List<MoveEfficiency> moveEfficiencies;
  final List<String> strengths;
  final List<String> weaknesses;
  final String cognitiveProfile;
  final int estimatedSkillLevel;
  final double efficiencyScore;

  AIPlayerAnalysis({
    required this.avgVariablesChanged,
    required this.impulsiveMoves,
    required this.repeatedMistakes,
    required this.progressRate,
    required this.suggestions,
    required this.moveEfficiencies,
    this.strengths           = const [],
    this.weaknesses          = const [],
    this.cognitiveProfile    = '',
    this.estimatedSkillLevel = 0,
    this.efficiencyScore     = 0,
  });
}

class MoveEfficiency {
  final int moveNumber;
  final double efficiency;
  final String feedback;
  MoveEfficiency({required this.moveNumber, required this.efficiency, required this.feedback});
}
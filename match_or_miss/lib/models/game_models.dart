// lib/models/game_models.dart
import 'package:flutter/material.dart';

enum GameMode { quick, standard, competitive }

enum GameStatus { waiting, active, paused, completed, timeout }

/// Represents a bottle with liquid color
class Bottle {
  final String id;
  final Color color;
  final int position; // Position in the hidden sequence (for matching)

  const Bottle({
    required this.id,
    required this.color,
    required this.position,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bottle &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          color == other.color &&
          position == other.position;

  @override
  int get hashCode => id.hashCode ^ color.hashCode ^ position.hashCode;
}

class GameSession {
  final String id;
  final GameMode mode;
  final int timeLimit; // in seconds
  final int maxMoves;
  int currentMoves;
  int currentScore;
  int timeBonus;
  GameStatus status;
  DateTime startTime;
  List<Attempt> attempts; // ← mutable list, NOT const []
  List<Bottle> hiddenSequence;
  List<Bottle?> currentGuessSlots; // The bottles placed in slots (can be null for empty slots)
  List<Bottle> availableBottles; // Bottles available to drag

  GameSession({
    required this.id,
    required this.mode,
    required this.timeLimit,
    required this.maxMoves,
    this.currentMoves = 0,
    this.currentScore = 0,
    this.timeBonus = 0,
    this.status = GameStatus.waiting,
    required this.startTime,
    List<Attempt>? attempts,
    required this.hiddenSequence,
    List<Bottle?>? currentGuessSlots,
    List<Bottle>? availableBottles,
  })  : currentGuessSlots =
            currentGuessSlots ?? List<Bottle?>.filled(hiddenSequence.length, null),
        availableBottles = availableBottles ?? [],
        attempts = attempts ?? [];

  int get remainingTime {
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    return (timeLimit + timeBonus) - elapsed;
  }

  bool get isTimeUp => remainingTime <= 0;
  bool get isMovesExhausted => currentMoves >= maxMoves;
  bool get isSlotsFilled => currentGuessSlots.every((b) => b != null);
}

class Attempt {
  final int attemptNumber;
  final List<Bottle?> guess;
  final int matches;
  final List<int> matchedPositions; // which indexes were correct
  final DateTime timestamp;
  final int variablesChanged;
  final bool wasImpulsive;

  Attempt({
    required this.attemptNumber,
    required this.guess,
    required this.matches,
    required this.matchedPositions,
    required this.timestamp,
    required this.variablesChanged,
    this.wasImpulsive = false,
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
    required this.date,
    required this.mode,
    required this.score,
    required this.movesUsed,
    required this.timeUsed,
    required this.won,
  });
}

// lib/models/ai_models.dart
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
    this.strengths = const [],
    this.weaknesses = const [],
    this.cognitiveProfile = '',
    this.estimatedSkillLevel = 0,
    this.efficiencyScore = 0,
  });
}

class MoveEfficiency {
  final int moveNumber;
  final double efficiency;
  final String feedback;

  MoveEfficiency({
    required this.moveNumber,
    required this.efficiency,
    required this.feedback,
  });
}
// lib/services/game_service.dart
import 'dart:math';
import 'package:flutter/material.dart';

class GameService {
  static const int SEQUENCE_LENGTH = 8;
  static const List<Color> AVAILABLE_COLORS = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  List<Color> generateHiddenSequence() {
    final random = Random();
    return List.generate(
      SEQUENCE_LENGTH,
      (index) => AVAILABLE_COLORS[random.nextInt(AVAILABLE_COLORS.length)],
    );
  }

  int calculateMatches(List<Color> guess, List<Color> hidden) {
    int matches = 0;
    for (int i = 0; i < SEQUENCE_LENGTH; i++) {
      if (guess[i] == hidden[i]) {
        matches++;
      }
    }
    return matches;
  }

  bool isSequenceSolved(List<Color> guess, List<Color> hidden) {
    return calculateMatches(guess, hidden) == SEQUENCE_LENGTH;
  }

  int calculateVariablesChanged(List<Color> previous, List<Color> current) {
    int changes = 0;
    for (int i = 0; i < SEQUENCE_LENGTH; i++) {
      if (previous[i] != current[i]) {
        changes++;
      }
    }
    return changes;
  }

  bool isImpulsiveMove(
    int changesChanged,
    int previousMatches,
    int currentMatches,
  ) {
    // Impulsive if changed too many variables without improvement
    return changesChanged > 3 && currentMatches <= previousMatches;
  }

  int calculateScore(int matches, int movesUsed, int timeRemaining) {
    // Base score from matches
    int baseScore = matches * 100;

    // Bonus for early solving
    int moveBonus = max(0, (12 - movesUsed)) * 50;

    // Time bonus
    int timeBonus = (timeRemaining ~/ 10) * 25;

    return baseScore + moveBonus + timeBonus;
  }
}

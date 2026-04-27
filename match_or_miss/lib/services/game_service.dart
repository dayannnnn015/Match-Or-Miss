// lib/services/game_service.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';

class GameService {
  static const int SEQUENCE_LENGTH = AppConstants.sequenceLength;

  // Single source of truth — reads from AppConstants, same as the color picker
  static List<Color> get AVAILABLE_COLORS => AppConstants.availableColors;
  static List<String> get COLOR_NAMES => AppConstants.colorNames;

  static String getColorName(Color color) => AppConstants.getColorName(color);

  /// Hidden sequence: bottles with random permutation of all colors.
  /// Every color appears exactly once — player knows this as a rule.
  List<Bottle> generateHiddenSequence({int? length}) {
    final targetLength = (length ?? SEQUENCE_LENGTH)
        .clamp(1, AVAILABLE_COLORS.length)
        .toInt();
    final colors = List<Color>.from(AVAILABLE_COLORS);
    colors.shuffle(Random());
    final selected = colors.take(targetLength).toList();
    final roundSeed = DateTime.now().microsecondsSinceEpoch;
    final result = <Bottle>[];
    for (int i = 0; i < selected.length; i++) {
      result.add(Bottle(
        id: 'b_${roundSeed}_$i',
        color: selected[i],
        position: i,
      ));
    }
    return result;
  }

  /// Generate available bottles for dragging (shuffled order)
  List<Bottle> generateAvailableBottles(List<Bottle> hidden) {
    final shuffledHidden = List<Bottle>.from(hidden)..shuffle(Random());
    final result = <Bottle>[];
    for (int i = 0; i < shuffledHidden.length; i++) {
      result.add(Bottle(
        id: shuffledHidden[i].id,
        color: shuffledHidden[i].color,
        position: i,
      ));
    }
    return result;
  }

  /// Valid guess: all slots filled with unique bottles
  bool isValidGuess(List<Bottle?> guess) {
    if (guess.isEmpty) return false;
    if (guess.contains(null)) return false;
    final colors = guess.cast<Bottle>().map((b) => b.color).toSet();
    return colors.length == guess.length;
  }

  int calculateMatches(List<Bottle?> guess, List<Bottle> hidden) {
    int matches = 0;
    final limit = min(guess.length, hidden.length);
    for (int i = 0; i < limit; i++) {
      if (guess[i] != null && guess[i]!.color == hidden[i].color) {
        matches++;
      }
    }
    return matches;
  }

  /// Returns the list of indexes where guess colors match hidden colors
  List<int> getMatchedPositions(List<Bottle?> guess, List<Bottle> hidden) {
    final positions = <int>[];
    final limit = min(guess.length, hidden.length);
    for (int i = 0; i < limit; i++) {
      if (guess[i] != null && guess[i]!.color == hidden[i].color) {
        positions.add(i);
      }
    }
    return positions;
  }

  bool isSequenceSolved(List<Bottle?> guess, List<Bottle> hidden) =>
      hidden.isNotEmpty && calculateMatches(guess, hidden) == hidden.length;

  int calculateVariablesChanged(List<Bottle?> previous, List<Bottle?> current) {
    int changes = 0;
    final limit = min(previous.length, current.length);
    for (int i = 0; i < limit; i++) {
      if (previous[i]?.id != current[i]?.id) changes++;
    }
    changes += (previous.length - current.length).abs();
    return changes;
  }

  bool isImpulsiveMove(int changesChanged, int previousMatches, int currentMatches) {
    return changesChanged > 2 && currentMatches <= previousMatches;
  }

  int calculateScore(int matches, int movesUsed, int timeRemaining,
      {GameMode mode = GameMode.standard}) {
    int baseScore = matches * AppConstants.matchBaseScore;

    final int maxMoves = _maxMovesForMode(mode);
    final int moveMultiplier =
        mode == GameMode.competitive ? 80 : AppConstants.moveBonusMultiplier;
    final int timeMultiplier =
        mode == GameMode.competitive ? 40 : AppConstants.timeBonusMultiplier;

    int moveBonus = max(0, (maxMoves - movesUsed)) * moveMultiplier;
    int timeBonus = (timeRemaining ~/ AppConstants.timeBonusDivisor) * timeMultiplier;

    // Competitive speed bonus: +500 if solved with more than half time left
    int speedBonus = 0;
    if (mode == GameMode.competitive &&
        matches == AppConstants.sequenceLength &&
        timeRemaining > AppConstants.competitiveModeTime ~/ 2) {
      speedBonus = 500;
    }

    return baseScore + moveBonus + timeBonus + speedBonus;
  }

  int _maxMovesForMode(GameMode mode) {
    switch (mode) {
      case GameMode.quick:       return AppConstants.quickModeMaxMoves;
      case GameMode.standard:    return AppConstants.standardModeMaxMoves;
      case GameMode.competitive: return AppConstants.competitiveModeMaxMoves;
    }
  }

  String getStrategyHint(int attemptsCount, int maxMatches, {int? sequenceLength}) {
    final total = sequenceLength ?? AppConstants.sequenceLength;
    if (attemptsCount == 0) {
      return 'Each color is used exactly once. Drag bottles into slots to find the right order.';
    }
    if (maxMatches == 0) {
      return 'No matches yet — every bottle is in the wrong position. Try swapping them all.';
    }
    if (maxMatches > 0 && maxMatches < 4) {
      return 'You have $maxMatches correct positions! Lock those in and swap the rest.';
    }
    if (maxMatches >= 4) {
      return 'More than halfway! Focus on the remaining ${total - maxMatches} positions.';
    }
    return 'Drag only 1–2 bottles at a time to isolate what\'s correct.';
  }
}
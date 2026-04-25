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

  /// Hidden sequence: a random permutation of all 8 colors.
  /// Every color appears exactly once — player knows this as a rule.
  List<Color> generateHiddenSequence() {
    final list = List<Color>.from(AVAILABLE_COLORS);
    list.shuffle(Random());
    return list;
  }

  /// Valid guess: all 8 slots filled, no grey, no duplicates.
  bool isValidGuess(List<Color> guess) {
    if (guess.length != SEQUENCE_LENGTH) return false;
    if (guess.contains(Colors.grey)) return false;
    return guess.toSet().length == SEQUENCE_LENGTH;
  }

  int calculateMatches(List<Color> guess, List<Color> hidden) {
    int matches = 0;
    for (int i = 0; i < SEQUENCE_LENGTH; i++) {
      if (guess[i] == hidden[i]) matches++;
    }
    return matches;
  }

  /// Returns the list of indexes where guess[i] == hidden[i]
  List<int> getMatchedPositions(List<Color> guess, List<Color> hidden) {
    final positions = <int>[];
    for (int i = 0; i < SEQUENCE_LENGTH; i++) {
      if (guess[i] == hidden[i]) positions.add(i);
    }
    return positions;
  }

  bool isSequenceSolved(List<Color> guess, List<Color> hidden) =>
      calculateMatches(guess, hidden) == SEQUENCE_LENGTH;

  int calculateVariablesChanged(List<Color> previous, List<Color> current) {
    int changes = 0;
    for (int i = 0; i < SEQUENCE_LENGTH; i++) {
      if (previous[i] != current[i]) changes++;
    }
    return changes;
  }

  bool isImpulsiveMove(int changesChanged, int previousMatches, int currentMatches) {
    return changesChanged > 3 && currentMatches <= previousMatches;
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
        matches == SEQUENCE_LENGTH &&
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

  String getStrategyHint(int attemptsCount, int maxMatches) {
    if (attemptsCount == 0) {
      return 'Each color is used exactly once. Swap positions to find the right order.';
    }
    if (maxMatches == 0) {
      return 'No matches yet — every bottle is wrong. Try rotating them all.';
    }
    if (maxMatches > 0 && maxMatches < 4) {
      return 'You have $maxMatches correct! Lock those in and swap the rest.';
    }
    if (maxMatches >= 4) {
      return 'More than halfway! Focus on the remaining ${SEQUENCE_LENGTH - maxMatches} positions.';
    }
    return 'Swap only 1–2 bottles at a time to isolate what\'s correct.';
  }
}
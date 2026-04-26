// lib/services/game_service.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';

class GameService {
  static const int SEQUENCE_LENGTH = AppConstants.sequenceLength;
  static List<Color> get AVAILABLE_COLORS => AppConstants.availableColors;
  static List<String> get COLOR_NAMES => AppConstants.colorNames;
  static String getColorName(Color color) => AppConstants.getColorName(color);

  /// Always a permutation — every color used exactly once.
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

  bool isImpulsiveMove(int variablesChanged, int previousMatches, int currentMatches) {
    return variablesChanged > 3 && currentMatches <= previousMatches;
  }

  /// Strategy-aware scoring:
  ///   Base        = matches × 100
  ///   Strategy +  = methodical moves (≤2 changes) × 60
  ///   Impulsive − = impulsive moves × 40
  ///   Efficiency +  = unused moves × 50
  ///   Time +      = remainingTime ÷ 10 × 25  (modes with timer only)
  ///   Patience +  = patienceBonusEarned × 75  (inhibitory mode only)
  ///   Flexibility+= +200 flat for solving after a mid-game shift
  int calculateScore(
    int matches,
    int movesUsed,
    int timeRemaining, {
    GameMode mode = GameMode.standard,
    required List<Attempt> attempts,
    int patienceBonusEarned = 0,
    bool solvedAfterShift = false,
  }) {
    // Base
    int score = matches * AppConstants.matchBaseScore;

    // Strategy analysis over all attempts
    final methodical = attempts.where((a) => a.variablesChanged <= 2).length;
    final impulsive  = attempts.where((a) => a.wasImpulsive).length;
    score += methodical * AppConstants.strategyBonusPerMove;
    score -= impulsive  * AppConstants.impulsivePenaltyPerMove;

    // Efficiency — unused moves
    final maxMoves = _maxMovesForMode(mode);
    score += max(0, maxMoves - movesUsed) * AppConstants.moveBonusMultiplier;

    // Time bonus (only when timer is active)
    if (AppConstants.workingMemoryModeTime != 0 || mode != GameMode.quick) {
      if (timeRemaining > 0) {
        score += (timeRemaining ~/ AppConstants.timeBonusDivisor) *
            AppConstants.timeBonusMultiplier;
      }
    }

    // Inhibitory Control patience bonus
    score += patienceBonusEarned * AppConstants.inhibitoryPatienceBonus;

    // Cognitive Flexibility bonus
    if (solvedAfterShift) score += 200;

    return score.clamp(0, 99999);
  }

  /// Cognitive Flexibility: swap two random positions in the hidden sequence.
  /// Returns the mutated sequence. Called by GameProvider after move N.
  List<Color> shiftSequence(List<Color> hidden) {
    final rng = Random();
    final copy = List<Color>.from(hidden);
    int a = rng.nextInt(SEQUENCE_LENGTH);
    int b;
    do { b = rng.nextInt(SEQUENCE_LENGTH); } while (b == a);
    final tmp = copy[a]; copy[a] = copy[b]; copy[b] = tmp;
    return copy;
  }

  int _maxMovesForMode(GameMode mode) {
    switch (mode) {
      case GameMode.quick:       return AppConstants.workingMemoryModeMaxMoves;
      case GameMode.standard:    return AppConstants.inhibitoryModeMaxMoves;
      case GameMode.competitive: return AppConstants.flexibilityModeMaxMoves;
    }
  }

  String getStrategyHint(int attemptsCount, int maxMatches) {
    if (attemptsCount == 0) return 'Each color appears exactly once. Swap to find the order.';
    if (maxMatches == 0) return 'No matches — every bottle is wrong. Try a completely different arrangement.';
    if (maxMatches < 4)  return '$maxMatches correct! Keep those fixed, systematically swap the rest.';
    return 'Over halfway! Focus on the remaining ${SEQUENCE_LENGTH - maxMatches} positions.';
  }
}
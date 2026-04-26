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

<<<<<<< HEAD
  /// Always a permutation — every color used exactly once.
  List<Color> generateHiddenSequence() {
    final list = List<Color>.from(AVAILABLE_COLORS);
    list.shuffle(Random());
    return list;
=======
  /// Hidden sequence: bottles with random permutation of all colors.
  /// Every color appears exactly once — player knows this as a rule.
  List<Bottle> generateHiddenSequence() {
    final colors = List<Color>.from(AVAILABLE_COLORS);
    colors.shuffle(Random());
    final result = <Bottle>[];
    for (int i = 0; i < colors.length; i++) {
      result.add(Bottle(
        id: 'hidden_$i',
        color: colors[i],
        position: i,
      ));
    }
    return result;
>>>>>>> 8d87ab68c965739798a3c6e1013055dcba777fb8
  }

  /// Generate available bottles for dragging (shuffled order)
  List<Bottle> generateAvailableBottles(List<Bottle> hidden) {
    final availableColors = hidden.map((b) => b.color).toList();
    availableColors.shuffle(Random());
    final result = <Bottle>[];
    for (int i = 0; i < availableColors.length; i++) {
      result.add(Bottle(
        id: 'available_$i',
        color: availableColors[i],
        position: i,
      ));
    }
    return result;
  }

  /// Valid guess: all slots filled with unique bottles
  bool isValidGuess(List<Bottle?> guess) {
    if (guess.length != SEQUENCE_LENGTH) return false;
    if (guess.contains(null)) return false;
    final colors = guess.cast<Bottle>().map((b) => b.color).toSet();
    return colors.length == SEQUENCE_LENGTH;
  }

  int calculateMatches(List<Bottle?> guess, List<Bottle> hidden) {
    int matches = 0;
    for (int i = 0; i < SEQUENCE_LENGTH; i++) {
      if (guess[i] != null && guess[i]!.color == hidden[i].color) {
        matches++;
      }
    }
    return matches;
  }

<<<<<<< HEAD
  List<int> getMatchedPositions(List<Color> guess, List<Color> hidden) {
=======
  /// Returns the list of indexes where guess colors match hidden colors
  List<int> getMatchedPositions(List<Bottle?> guess, List<Bottle> hidden) {
>>>>>>> 8d87ab68c965739798a3c6e1013055dcba777fb8
    final positions = <int>[];
    for (int i = 0; i < SEQUENCE_LENGTH; i++) {
      if (guess[i] != null && guess[i]!.color == hidden[i].color) {
        positions.add(i);
      }
    }
    return positions;
  }

  bool isSequenceSolved(List<Bottle?> guess, List<Bottle> hidden) =>
      calculateMatches(guess, hidden) == SEQUENCE_LENGTH;

  int calculateVariablesChanged(List<Bottle?> previous, List<Bottle?> current) {
    int changes = 0;
    for (int i = 0; i < SEQUENCE_LENGTH; i++) {
      if (previous[i]?.id != current[i]?.id) changes++;
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
<<<<<<< HEAD
    if (attemptsCount == 0) return 'Each color appears exactly once. Swap to find the order.';
    if (maxMatches == 0) return 'No matches — every bottle is wrong. Try a completely different arrangement.';
    if (maxMatches < 4)  return '$maxMatches correct! Keep those fixed, systematically swap the rest.';
    return 'Over halfway! Focus on the remaining ${SEQUENCE_LENGTH - maxMatches} positions.';
=======
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
      return 'More than halfway! Focus on the remaining ${SEQUENCE_LENGTH - maxMatches} positions.';
    }
    return 'Drag only 1–2 bottles at a time to isolate what\'s correct.';
>>>>>>> 8d87ab68c965739798a3c6e1013055dcba777fb8
  }
}
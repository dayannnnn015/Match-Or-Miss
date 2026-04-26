// lib/utils/constants.dart
import 'package:flutter/material.dart';
import '../models/game_models.dart';

class AppConstants {
  // ─── Sequence ─────────────────────────────────────────────────────────────
  static const int sequenceLength = 8;

  // ─── Mode settings ────────────────────────────────────────────────────────
  //
  // Each mode trains a DIFFERENT executive function:
  //
  // WORKING MEMORY  — No timer. Very few moves. Forces you to mentally hold
  //                   every past result before acting. Pure deduction.
  //
  // INHIBITORY CONTROL — Timer exists but rewards patience. Waiting ≥8s
  //                      before submitting earns a patience bonus to the
  //                      score. Penalizes impulsive moves in the final tally.
  //
  // COGNITIVE FLEXIBILITY — Mid-game (after move 4) two random bottles in the
  //                         hidden sequence are silently swapped. The player
  //                         must detect that their previous knowledge is now
  //                         partially wrong and adapt. Tests the ability to
  //                         discard old assumptions under pressure.

  // Working Memory mode — no timer (0 = disabled), tight move budget
  static const int workingMemoryModeTime     = 0;   // 0 = no timer
  static const int workingMemoryModeMaxMoves = 10;

  // Inhibitory Control mode — moderate time, patience rewarded
  static const int inhibitoryModeTime     = 300; // 5 min
  static const int inhibitoryModeMaxMoves = 12;
  static const int inhibitoryPatientSecs  = 8;   // wait this long to earn bonus
  static const int inhibitoryPatienceBonus = 75;  // points per patient move

  // Cognitive Flexibility mode — time pressure, environment changes mid-game
  static const int flexibilityModeTime     = 240; // 4 min
  static const int flexibilityModeMaxMoves = 14;  // more moves because the puzzle mutates
  static const int flexibilityShiftAfterMove = 4; // sequence shifts after this move

  // ─── Colors ───────────────────────────────────────────────────────────────
  static const List<Color> availableColors = [
    Color(0xFFE53935), // Red
    Color(0xFF1E88E5), // Blue
    Color(0xFF43A047), // Green
    Color(0xFFFDD835), // Yellow
    Color(0xFF8E24AA), // Purple
    Color(0xFFFF6F00), // Orange
    Color(0xFF00ACC1), // Cyan
    Color(0xFFEC407A), // Pink
  ];

  static const List<String> colorNames = [
    'Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Orange', 'Cyan', 'Pink',
  ];

  static String getColorName(Color color) {
    final idx = availableColors.indexOf(color);
    return idx >= 0 ? colorNames[idx] : 'Unknown';
  }

  // ─── Scoring ──────────────────────────────────────────────────────────────
  // Base: matches × 100
  // Strategy bonus: moves where variablesChanged ≤ 2 earn +60 each
  // Impulsive penalty: wasImpulsive moves cost -40 each
  // Efficiency bonus: solved early = (movesLeft × moveMultiplier)
  // Time bonus (where applicable): (remainingSeconds ÷ 10) × timeMultiplier

  static const int matchBaseScore          = 100;
  static const int strategyBonusPerMove    = 60;   // for moves with ≤2 changes
  static const int impulsivePenaltyPerMove = 40;   // deducted for impulsive moves
  static const int moveBonusMultiplier     = 50;   // per unused move
  static const int timeBonusDivisor        = 10;
  static const int timeBonusMultiplier     = 25;

  // ─── AI thresholds ────────────────────────────────────────────────────────
  static const double impulsiveChangeThreshold = 3.0;
  static const double highImpulsiveCount       = 3;
  static const double highRepeatedMistakes     = 2;
  static const double lowProgressRate          = 0.1;
  static const double mediumProgressRate       = 0.3;
  static const double highProgressRate         = 0.5;

  // ─── UI ───────────────────────────────────────────────────────────────────
  static const double bottleWidth       = 60.0;
  static const double bottleHeight      = 80.0;
  static const double gridSpacing       = 12.0;
  static const double borderRadius      = 20.0;
  static const double animationDuration = 300;

  static const Map<GameMode, GameModeConfig> modeConfigs = {
    GameMode.quick: GameModeConfig(
      name: 'WORKING MEMORY',
      description: 'No timer — but only 10 moves. Every guess must count.',
      timeLimit: workingMemoryModeTime,
      icon: Icons.psychology,
      color: Colors.green,
    ),
    GameMode.standard: GameModeConfig(
      name: 'INHIBITORY CONTROL',
      description: 'Think before you act — patience earns bonus points.',
      timeLimit: inhibitoryModeTime,
      icon: Icons.self_improvement,
      color: Colors.blue,
    ),
    GameMode.competitive: GameModeConfig(
      name: 'COGNITIVE FLEXIBILITY',
      description: 'The puzzle changes mid-game. Adapt your strategy.',
      timeLimit: flexibilityModeTime,
      icon: Icons.device_hub,
      color: Colors.orange,
    ),
  };

  // ─── Storage keys ─────────────────────────────────────────────────────────
  static const String storageUserPrefs         = 'user_preferences';
  static const String storageGameHistory       = 'game_history';
  static const String storageSoundEnabled      = 'sound_enabled';
  static const String storageMusicEnabled      = 'music_enabled';
  static const String storageConfirmationDelay = 'confirmation_delay';
  static const String storageShowHistory       = 'show_history';

  // ─── Animations ───────────────────────────────────────────────────────────
  static const Duration shortAnimation  = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation   = Duration(milliseconds: 800);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const List<LinearGradient> backgroundGradients = [
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0a0a2a), Color(0xFF1a0033), Color(0xFF002244)],
    ),
  ];

  // ─── Sounds ───────────────────────────────────────────────────────────────
  static const String soundMatch   = 'sounds/match.mp3';
  static const String soundSubmit  = 'sounds/submit.mp3';
  static const String soundWin     = 'sounds/win.mp3';
  static const String soundTimeout = 'sounds/timeout.mp3';
  static const String soundClick   = 'sounds/click.mp3';
  static const String soundBonus   = 'sounds/bonus.mp3';

  // ─── Helpers ──────────────────────────────────────────────────────────────
  static Color getRandomColor() =>
      availableColors[DateTime.now().millisecondsSinceEpoch % availableColors.length];
  static bool isValidColor(Color color) => availableColors.contains(color);
}

// ─── Supporting classes ───────────────────────────────────────────────────────

class GameModeConfig {
  final String name;
  final String description;
  final int timeLimit;
  final IconData icon;
  final Color color;
  const GameModeConfig({
    required this.name,
    required this.description,
    required this.timeLimit,
    required this.icon,
    required this.color,
  });
}

class UIConstants {
  static const double paddingSmall      = 8.0;
  static const double paddingMedium     = 16.0;
  static const double paddingLarge      = 24.0;
  static const double paddingExtraLarge = 32.0;
  static const double fontSizeSmall     = 12.0;
  static const double fontSizeMedium    = 16.0;
  static const double fontSizeLarge     = 20.0;
  static const double fontSizeHuge      = 32.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge  = 20.0;
  static const double buttonHeight = 48.0;
  static const double iconSizeSmall  = 20.0;
  static const double iconSizeMedium = 30.0;
  static const double iconSizeLarge  = 40.0;
}

class GameRules {
  static const int minSequenceLength     = 4;
  static const int maxSequenceLength     = 12;
  static const int defaultSequenceLength = 8;
  static const int minMoves              = 5;
  static const int maxMoves              = 20;
  static const int defaultMoves          = 12;
  static const int minTimeLimit          = 0;
  static const int maxTimeLimit          = 1800;
  static const double impulsiveThreshold = 3.0;
  static const double efficiencyThreshold = 0.6;
}

class AnimationConstants {
  static const Duration bottleDropDuration   = Duration(milliseconds: 400);
  static const Duration bottleSwapDuration   = Duration(milliseconds: 300);
  static const Duration feedbackFadeDuration = Duration(milliseconds: 200);
  static const Duration timerTickDuration    = Duration(seconds: 1);
  static const Curve bottleDropCurve   = Curves.bounceOut;
  static const Curve bottleSwapCurve   = Curves.easeInOut;
  static const Curve feedbackFadeCurve = Curves.easeIn;
}

class DatabaseConstants {
  static const String usersCollection             = 'users';
  static const String gamesCollection             = 'games';
  static const String multiplayerRoomsCollection  = 'multiplayer_rooms';
  static const String leaderboardCollection       = 'leaderboard';
  static const String fieldUserId    = 'userId';
  static const String fieldUserName  = 'userName';
  static const String fieldScore     = 'score';
  static const String fieldTimestamp = 'timestamp';
  static const String fieldGameMode  = 'gameMode';
  static const String fieldMovesUsed = 'movesUsed';
  static const String fieldTimeUsed  = 'timeUsed';
  static const String fieldWon       = 'won';
}

class ErrorMessages {
  static const String gameInitError      = 'Failed to initialize game. Please restart.';
  static const String submitError        = 'Failed to submit guess. Please try again.';
  static const String networkError       = 'Network connection error.';
  static const String firebaseError      = 'Firebase service error.';
  static const String invalidGuessError  = 'Invalid guess. Please select all bottles.';
  static const String timeoutError       = 'Game session timed out.';
}
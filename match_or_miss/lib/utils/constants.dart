// lib/utils/constants.dart
import 'package:flutter/material.dart';
import '../models/game_models.dart';

/// Single source of truth for ALL game configuration.
/// Both GameService and the UI read from here — no more duplicate color lists.
class AppConstants {
  // ─── Sequence ────────────────────────────────────────────────────────────
  static const int sequenceLength = 8;
  static const int quickModeStartLength = 3;
  static const int quickModeMaxLength = sequenceLength;

  // ─── Mode settings ────────────────────────────────────────────────────────
  // Quick:       relaxed intro — enough time to think, enough moves to learn
  // Standard:    comfortable challenge — the main experience
  // Competitive: real pressure — limited moves, limited time, high reward
  static const int quickModeTime       = 240; // 4 min
  static const int standardModeTime    = 240; // 4 min
  static const int competitiveModeTime = 180; // 3 min (tight!)

  static const int quickModeMaxMoves       = 12; // generous for newcomers
  static const int standardModeMaxMoves    = 10; // balanced
  static const int competitiveModeMaxMoves = 8;  // precision required

  // ─── Colors — ONE list, used everywhere ──────────────────────────────────
  // Chosen for visual clarity: distinct hues, not too similar to each other
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

  // ─── Score multipliers ────────────────────────────────────────────────────
  static const int matchBaseScore        = 100;
  static const int moveBonusMultiplier   = 50;
  static const int timeBonusDivisor      = 10;
  static const int timeBonusMultiplier   = 25;

  // ─── AI thresholds ────────────────────────────────────────────────────────
  static const double impulsiveChangeThreshold = 3.0;
  static const double highImpulsiveCount       = 3;
  static const double highRepeatedMistakes     = 2;
  static const double lowProgressRate          = 0.1;
  static const double mediumProgressRate       = 0.3;
  static const double highProgressRate         = 0.5;

  // ─── UI ───────────────────────────────────────────────────────────────────
  static const double bottleWidth    = 60.0;
  static const double bottleHeight   = 80.0;
  static const double gridSpacing    = 12.0;
  static const double borderRadius   = 20.0;
  static const double animationDuration = 300;

  static const Map<GameMode, GameModeConfig> modeConfigs = {
    GameMode.quick: GameModeConfig(
      name: 'QUICK MODE',
      description: 'Starts at 3 bottles and scales up as you improve',
      timeLimit: quickModeTime,
      icon: Icons.flash_on,
      color: Colors.green,
    ),
    GameMode.standard: GameModeConfig(
      name: 'STANDARD MODE',
      description: 'Balanced challenge — recommended for beginners',
      timeLimit: standardModeTime,
      icon: Icons.timer,
      color: Colors.blue,
    ),
    GameMode.competitive: GameModeConfig(
      name: 'COMPETITIVE MODE',
      description: 'Max pressure — ranked scoring',
      timeLimit: competitiveModeTime,
      icon: Icons.emoji_events,
      color: Colors.orange,
    ),
  };

  // ─── Feedback messages ────────────────────────────────────────────────────
  static const Map<String, String> feedbackMessages = {
    'no_matches':  '0 Matches – Try a new pattern',
    'some_matches':'✓ You have {matches} matches. Keep these and try changing others.',
    'perfect':     '🎉 PERFECT! Puzzle solved!',
    'timeout':     '⏰ Time\'s up! Game Over!',
    'moves_exhausted': '📊 No moves left! Game Over!',
  };

  static const Map<String, String> aiHints = {
    'too_many_changes':
        '🎯 You changed {count} variables. Try isolating 1-2 at a time!',
    'no_progress':   '💡 No matches found. Try a completely different pattern.',
    'impulsive':     '⚠️ Take a moment to analyze before making large changes.',
    'good_progress': '👍 Good! You have {matches} matches. Keep them and modify others.',
    'default_hint':  '🎮 Keep going! Methodical changes lead to solutions.',
    'strategy_hint': '💡 Try the binary search method: test half the positions at once.',
    'memory_hint':   '🧠 Remember which colors worked in previous attempts.',
  };

  // ─── Storage keys ─────────────────────────────────────────────────────────
  static const String storageUserPrefs        = 'user_preferences';
  static const String storageGameHistory      = 'game_history';
  static const String storageSoundEnabled     = 'sound_enabled';
  static const String storageMusicEnabled     = 'music_enabled';
  static const String storageConfirmationDelay= 'confirmation_delay';
  static const String storageShowHistory      = 'show_history';

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

  // ─── Achievements ─────────────────────────────────────────────────────────
  static const Map<String, int> achievements = {
    'first_win':    1,
    'perfect_game': 8,
    'speed_demon':  60,
    'marathon':     5,
    'strategist':   3,
  };

  // ─── Helpers ──────────────────────────────────────────────────────────────
  static Color getRandomColor() =>
      availableColors[DateTime.now().millisecondsSinceEpoch % availableColors.length];

  static bool isValidColor(Color color) => availableColors.contains(color);
}

// ─── Supporting classes ────────────────────────────────────────────────────

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

  static const double fontSizeSmall      = 12.0;
  static const double fontSizeMedium     = 16.0;
  static const double fontSizeLarge      = 20.0;
  static const double fontSizeExtraLarge = 24.0;
  static const double fontSizeHuge       = 32.0;

  static const double borderRadiusSmall      = 8.0;
  static const double borderRadiusMedium     = 12.0;
  static const double borderRadiusLarge      = 20.0;
  static const double borderRadiusExtraLarge = 30.0;

  static const double buttonHeight = 48.0;
  static const double buttonWidth  = 120.0;

  static const double iconSizeSmall      = 20.0;
  static const double iconSizeMedium     = 30.0;
  static const double iconSizeLarge      = 40.0;
  static const double iconSizeExtraLarge = 60.0;
}

class GameRules {
  static const int minSequenceLength     = 4;
  static const int maxSequenceLength     = 12;
  static const int defaultSequenceLength = 8;
  static const int minMoves              = 5;
  static const int maxMoves              = 20;
  static const int defaultMoves          = 12;
  static const int minTimeLimit          = 60;
  static const int maxTimeLimit          = 1800;
  static const double impulsiveThreshold = 3.0;
  static const double efficiencyThreshold = 0.6;
}

class AnimationConstants {
  static const Duration bottleDropDuration   = Duration(milliseconds: 400);
  static const Duration bottleSwapDuration   = Duration(milliseconds: 300);
  static const Duration feedbackFadeDuration = Duration(milliseconds: 200);
  static const Duration timerTickDuration    = Duration(seconds: 1);
  static const Curve bottleDropCurve  = Curves.bounceOut;
  static const Curve bottleSwapCurve  = Curves.easeInOut;
  static const Curve feedbackFadeCurve = Curves.easeIn;
}

class DatabaseConstants {
  static const String usersCollection            = 'users';
  static const String gamesCollection            = 'games';
  static const String multiplayerRoomsCollection = 'multiplayer_rooms';
  static const String leaderboardCollection      = 'leaderboard';
  static const String fieldUserId   = 'userId';
  static const String fieldUserName = 'userName';
  static const String fieldScore    = 'score';
  static const String fieldTimestamp = 'timestamp';
  static const String fieldGameMode  = 'gameMode';
  static const String fieldMovesUsed = 'movesUsed';
  static const String fieldTimeUsed  = 'timeUsed';
  static const String fieldWon       = 'won';
}

class ErrorMessages {
  static const String gameInitError   = 'Failed to initialize game. Please restart.';
  static const String submitError     = 'Failed to submit guess. Please try again.';
  static const String networkError    = 'Network connection error. Please check your connection.';
  static const String firebaseError   = 'Firebase service error. Please restart the app.';
  static const String invalidGuessError = 'Invalid guess. Please select all bottles.';
  static const String timeoutError    = 'Game session timed out. Starting new session.';
}
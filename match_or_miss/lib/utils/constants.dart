// lib/utils/constants.dart
import 'package:flutter/material.dart';
import '../models/game_models.dart';

class AppConstants {
  // Game Configuration
  static const int sequenceLength = 8;
  static const int maxMovesPerPuzzle = 12;
  static const int minConfirmationDelay = 2;
  static const int maxConfirmationDelay = 3;

  // Time Limits (in seconds)
  static const int quickModeTime = 120; // 2 minutes
  static const int standardModeTime = 300; // 5 minutes
  static const int competitiveModeTime = 600; // 10 minutes

  // Bonus Time (in seconds)
  static const int fastSolveBonus = 10;
  static const int normalSolveBonus = 7;
  static const int slowSolveBonus = 5;

  // Score Multipliers
  static const int matchBaseScore = 100;
  static const int moveBonusMultiplier = 50;
  static const int timeBonusDivisor = 10;
  static const int timeBonusMultiplier = 25;

  // AI Thresholds
  static const double impulsiveChangeThreshold = 3.0;
  static const double highImpulsiveCount = 3;
  static const double highRepeatedMistakes = 2;
  static const double lowProgressRate = 0.1;
  static const double mediumProgressRate = 0.3;
  static const double highProgressRate = 0.5;

  // Available Colors for Bottles
  static const List<Color> availableColors = [
    Color(0xFFFF4444), // Red
    Color(0xFF44FF44), // Green
    Color(0xFF4444FF), // Blue
    Color(0xFFFFFF44), // Yellow
    Color(0xFFFF44FF), // Purple
    Color(0xFFFF8844), // Orange
    Color(0xFF44FFFF), // Cyan
    Color(0xFFFF66CC), // Pink
  ];

  // Color Names for Display
  static final Map<Color, String> colorNames = {
    const Color(0xFFFF4444): 'Red',
    const Color(0xFF44FF44): 'Green',
    const Color(0xFF4444FF): 'Blue',
    const Color(0xFFFFFF44): 'Yellow',
    const Color(0xFFFF44FF): 'Purple',
    const Color(0xFFFF8844): 'Orange',
    const Color(0xFF44FFFF): 'Cyan',
    const Color(0xFFFF66CC): 'Pink',
  };

  // UI Constants
  static const double bottleWidth = 60.0;
  static const double bottleHeight = 80.0;
  static const double gridSpacing = 12.0;
  static const double borderRadius = 20.0;
  static const double animationDuration = 300; // milliseconds

  // Game Mode Configuration
  static const Map<GameMode, GameModeConfig> modeConfigs = {
    GameMode.quick: GameModeConfig(
      name: 'QUICK MODE',
      description: 'Perfect for short sessions',
      timeLimit: quickModeTime,
      icon: Icons.flash_on,
      color: Colors.green,
    ),
    GameMode.standard: GameModeConfig(
      name: 'STANDARD MODE',
      description: 'Balanced challenge',
      timeLimit: standardModeTime,
      icon: Icons.timer,
      color: Colors.blue,
    ),
    GameMode.competitive: GameModeConfig(
      name: 'COMPETITIVE MODE',
      description: 'Maximum concentration',
      timeLimit: competitiveModeTime,
      icon: Icons.emoji_events,
      color: Colors.purple,
    ),
  };

  // Feedback Messages
  static const Map<String, String> feedbackMessages = {
    'no_matches': '0 Matches – Try a new pattern',
    'some_matches':
        '✓ You have {matches} matches. Keep these and try changing others.',
    'perfect': '🎉 PERFECT! Puzzle solved! Generating next sequence...',
    'timeout': '⏰ Time\'s up! Game Over!',
    'moves_exhausted': '📊 No moves left! Game Over!',
  };

  // AI Hint Messages
  static const Map<String, String> aiHints = {
    'too_many_changes':
        '🎯 You changed {count} variables. Try isolating 1-2 at a time!',
    'no_progress': '💡 No matches found. Try a completely different pattern.',
    'impulsive': '⚠️ Take a moment to analyze before making large changes.',
    'good_progress':
        '👍 Good! You have {matches} matches. Keep them and modify others.',
    'default_hint': '🎮 Keep going! Methodical changes lead to solutions.',
    'strategy_hint':
        '💡 Try the binary search method: test half the positions at once.',
    'memory_hint':
        '🧠 Write down or remember which colors worked in previous attempts.',
  };

  // Storage Keys
  static const String storageUserPrefs = 'user_preferences';
  static const String storageGameHistory = 'game_history';
  static const String storageSoundEnabled = 'sound_enabled';
  static const String storageMusicEnabled = 'music_enabled';
  static const String storageConfirmationDelay = 'confirmation_delay';
  static const String storageShowHistory = 'show_history';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Gradients
  static const List<LinearGradient> backgroundGradients = [
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0a0a2a), Color(0xFF1a0033), Color(0xFF002244)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1a0033), Color(0xFF0a0a2a), Color(0xFF003366)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF002244), Color(0xFF1a0033), Color(0xFF0a0a2a)],
    ),
  ];

  // Bottle Gradients
  static Map<Color, LinearGradient> getBottleGradient(Color baseColor) {
    return {
      baseColor: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          baseColor.withOpacity(0.8),
          baseColor,
          baseColor.withOpacity(0.9),
        ],
      ),
    };
  }

  // Sound Asset Paths
  static const String soundMatch = 'sounds/match.mp3';
  static const String soundSubmit = 'sounds/submit.mp3';
  static const String soundWin = 'sounds/win.mp3';
  static const String soundTimeout = 'sounds/timeout.mp3';
  static const String soundClick = 'sounds/click.mp3';
  static const String soundBonus = 'sounds/bonus.mp3';

  // Achievement Thresholds
  static const Map<String, int> achievements = {
    'first_win': 1,
    'perfect_game': 8, // 8 matches in minimum moves
    'speed_demon': 60, // Solve under 60 seconds
    'marathon': 5, // Solve 5 puzzles in one session
    'strategist': 3, // 3 games with high efficiency
  };

  // Leaderboard Categories
  static const List<String> leaderboardCategories = [
    'Highest Score',
    'Fastest Solve',
    'Most Puzzles',
    'Best Efficiency',
  ];

  // Helper method to get random color
  static Color getRandomColor() {
    return availableColors[
        DateTime.now().millisecondsSinceEpoch % availableColors.length];
  }

  // Helper method to check if color is valid
  static bool isValidColor(Color color) {
    return availableColors.contains(color);
  }

  // Helper method to get color name
  static String getColorName(Color color) {
    return colorNames[color] ?? 'Unknown';
  }
}

// Game Mode Configuration Class
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

// UI Constants Class
class UIConstants {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeExtraLarge = 24.0;
  static const double fontSizeHuge = 32.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusExtraLarge = 30.0;

  static const double buttonHeight = 48.0;
  static const double buttonWidth = 120.0;

  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 30.0;
  static const double iconSizeLarge = 40.0;
  static const double iconSizeExtraLarge = 60.0;
}

// Game Rules Constants
class GameRules {
  static const int minSequenceLength = 4;
  static const int maxSequenceLength = 12;
  static const int defaultSequenceLength = 8;

  static const int minMoves = 5;
  static const int maxMoves = 20;
  static const int defaultMoves = 12;

  static const int minTimeLimit = 60; // 1 minute
  static const int maxTimeLimit = 1800; // 30 minutes

  static const int minBonusTime = 5;
  static const int maxBonusTime = 15;

  static const double impulsiveThreshold =
      3.0; // More than 3 changes is impulsive
  static const double efficiencyThreshold = 0.6; // 60% efficiency is good
}

// Animation Constants
class AnimationConstants {
  static const Duration bottleDropDuration = Duration(milliseconds: 400);
  static const Duration bottleSwapDuration = Duration(milliseconds: 300);
  static const Duration feedbackFadeDuration = Duration(milliseconds: 200);
  static const Duration timerTickDuration = Duration(seconds: 1);

  static const Curve bottleDropCurve = Curves.bounceOut;
  static const Curve bottleSwapCurve = Curves.easeInOut;
  static const Curve feedbackFadeCurve = Curves.easeIn;
}

// Database Constants
class DatabaseConstants {
  static const String usersCollection = 'users';
  static const String gamesCollection = 'games';
  static const String multiplayerRoomsCollection = 'multiplayer_rooms';
  static const String leaderboardCollection = 'leaderboard';

  static const String fieldUserId = 'userId';
  static const String fieldUserName = 'userName';
  static const String fieldScore = 'score';
  static const String fieldTimestamp = 'timestamp';
  static const String fieldGameMode = 'gameMode';
  static const String fieldMovesUsed = 'movesUsed';
  static const String fieldTimeUsed = 'timeUsed';
  static const String fieldWon = 'won';
}

// Error Messages
class ErrorMessages {
  static const String gameInitError =
      'Failed to initialize game. Please restart.';
  static const String submitError = 'Failed to submit guess. Please try again.';
  static const String networkError =
      'Network connection error. Please check your connection.';
  static const String firebaseError =
      'Firebase service error. Please restart the app.';
  static const String invalidGuessError =
      'Invalid guess. Please select all bottles.';
  static const String timeoutError =
      'Game session timed out. Starting new session.';
}

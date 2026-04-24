// lib/services/ai_service.dart
import '../models/game_models.dart';

class AIService {
  Future<AIPlayerAnalysis> analyzePlayerBehavior(List<Attempt> attempts) async {
    if (attempts.isEmpty) {
      return AIPlayerAnalysis(
        avgVariablesChanged: 0,
        impulsiveMoves: 0,
        repeatedMistakes: 0,
        progressRate: 0,
        suggestions: ["Start with a consistent pattern to isolate variables."],
        moveEfficiencies: [],
      );
    }

    double avgChanges = _calculateAvgVariablesChanged(attempts);
    int impulsiveCount = attempts.where((a) => a.wasImpulsive).length;
    int repeatedMistakes = _findRepeatedMistakes(attempts);
    double progressRate = _calculateProgressRate(attempts);

    List<String> suggestions = _generateSuggestions(
      avgChanges,
      impulsiveCount,
      repeatedMistakes,
      progressRate,
      attempts.last.matches,
    );

    List<MoveEfficiency> efficiencies = _calculateMoveEfficiencies(attempts);

    return AIPlayerAnalysis(
      avgVariablesChanged: avgChanges,
      impulsiveMoves: impulsiveCount,
      repeatedMistakes: repeatedMistakes,
      progressRate: progressRate,
      suggestions: suggestions,
      moveEfficiencies: efficiencies,
    );
  }

  String getRealTimeHint(Attempt lastAttempt, int totalMoves) {
    if (lastAttempt.variablesChanged > 3) {
      return "🎯 You changed ${lastAttempt.variablesChanged} variables. Try isolating 1-2 at a time!";
    }

    if (lastAttempt.matches == 0 && totalMoves > 3) {
      return "💡 No matches found. Try a completely different pattern.";
    }

    if (lastAttempt.wasImpulsive) {
      return "⚠️ Take a moment to analyze before making large changes.";
    }

    if (lastAttempt.matches > 0 && lastAttempt.matches < 4) {
      return "👍 Good! You have ${lastAttempt.matches} matches. Keep them and modify others.";
    }

    return "🎮 Keep going! Methodical changes lead to solutions.";
  }

  double _calculateAvgVariablesChanged(List<Attempt> attempts) {
    if (attempts.isEmpty) return 0;
    return attempts
            .map((a) => a.variablesChanged.toDouble())
            .reduce((a, b) => a + b) /
        attempts.length;
  }

  int _findRepeatedMistakes(List<Attempt> attempts) {
    int repeats = 0;
    for (int i = 1; i < attempts.length; i++) {
      if (attempts[i].guess == attempts[i - 1].guess) {
        repeats++;
      }
    }
    return repeats;
  }

  double _calculateProgressRate(List<Attempt> attempts) {
    if (attempts.length < 2) return 0;
    int firstMatches = attempts.first.matches;
    int lastMatches = attempts.last.matches;
    return (lastMatches - firstMatches) / attempts.length;
  }

  List<String> _generateSuggestions(
    double avgChanges,
    int impulsiveCount,
    int repeatedMistakes,
    double progressRate,
    int currentMatches,
  ) {
    List<String> suggestions = [];

    if (avgChanges > 2.5) {
      suggestions.add(
        "• You're changing too many variables (avg: ${avgChanges.toStringAsFixed(1)}). Try changing just 1-2 per move.",
      );
    }

    if (impulsiveCount > 3) {
      suggestions.add(
        "• Detected impulsive patterns. Use the 3-second delay to plan your moves.",
      );
    }

    if (repeatedMistakes > 2) {
      suggestions.add(
        "• You're repeating the same patterns. Track what worked and what didn't.",
      );
    }

    if (progressRate < 0.1 && currentMatches < 4) {
      suggestions.add(
        "• Progress is slow. Consider a systematic approach - test each position individually.",
      );
    }

    if (currentMatches == 0 && suggestions.isEmpty) {
      suggestions.add(
        "• Start fresh! None of your current colors match. Try all different colors.",
      );
    }

    if (suggestions.isEmpty) {
      suggestions.add("• Great systematic approach! Keep isolating variables.");
    }

    return suggestions;
  }

  List<MoveEfficiency> _calculateMoveEfficiencies(List<Attempt> attempts) {
    List<MoveEfficiency> efficiencies = [];

    for (int i = 0; i < attempts.length; i++) {
      double efficiency;
      String feedback;

      if (i == 0) {
        efficiency = attempts[i].matches / 8.0;
        feedback = efficiency > 0
            ? "Good starting point!"
            : "No matches - try different colors";
      } else {
        int improvement = attempts[i].matches - attempts[i - 1].matches;
        efficiency = improvement / 8.0;
        feedback = improvement > 0
            ? "Improved by $improvement match(es)! 🎉"
            : improvement < 0
            ? "Lost $improvement matches - review changes"
            : "No change - isolate variables";
      }

      efficiencies.add(
        MoveEfficiency(
          moveNumber: i + 1,
          efficiency: efficiency,
          feedback: feedback,
        ),
      );
    }

    return efficiencies;
  }

  String getPostGameAnalysis(AIPlayerAnalysis analysis, bool won, int score) {
    StringBuffer analysisText = StringBuffer();

    analysisText.writeln("=== POST-GAME ANALYSIS ===\n");

    if (won) {
      analysisText.writeln("🎉 Congratulations on solving the puzzle! 🎉\n");
    } else {
      analysisText.writeln(
        "📊 Game completed. Here's your performance analysis:\n",
      );
    }

    analysisText.writeln("Score: $score");
    analysisText.writeln(
      "Average variables changed: ${analysis.avgVariablesChanged.toStringAsFixed(1)}",
    );
    analysisText.writeln(
      "Impulsive moves detected: ${analysis.impulsiveMoves}",
    );
    analysisText.writeln("Repeated mistakes: ${analysis.repeatedMistakes}");
    analysisText.writeln(
      "Progress rate: ${analysis.progressRate.toStringAsFixed(2)}\n",
    );

    analysisText.writeln("=== BEST MOVES ===");
    var bestMoves = analysis.moveEfficiencies
        .where((m) => m.efficiency > 0)
        .toList();
    if (bestMoves.isNotEmpty) {
      for (var move in bestMoves.take(3)) {
        analysisText.writeln("Move ${move.moveNumber}: ${move.feedback}");
      }
    } else {
      analysisText.writeln("Try isolating variables in your next game.");
    }

    analysisText.writeln("\n=== SUGGESTIONS FOR IMPROVEMENT ===");
    for (var suggestion in analysis.suggestions) {
      analysisText.writeln(suggestion);
    }

    return analysisText.toString();
  }
}

// lib/screens/game_screen_with_ai.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/ai_provider.dart';
import '../widgets/bottle_grid.dart';
import '../widgets/attempt_history.dart';
import '../widgets/timer_widget.dart';

class GameScreenWithAI extends StatefulWidget {
  const GameScreenWithAI({super.key});

  @override
  _GameScreenWithAIState createState() => _GameScreenWithAIState();
}

class _GameScreenWithAIState extends State<GameScreenWithAI> {
  bool _gameFinished = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Consumer2<GameProvider, AIProvider>(
        builder: (context, gameProvider, aiProvider, child) {
          if (gameProvider.currentSession == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1a0033), Color(0xFF003366)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(gameProvider),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: BottleGrid(
                        colors: gameProvider.currentGuess,
                        onColorTap: (index, color) => gameProvider.updateGuess(index, color),
                        onSwap: (index1, index2) => gameProvider.swapGuess(index1, index2),
                        isEnabled: !gameProvider.isSubmitting && !_gameFinished,
                      ),
                    ),
                  ),
                  _buildFeedback(gameProvider),
                  _buildActionButtons(gameProvider),
                  if (gameProvider.showHistory)
                    Expanded(
                      child: AttemptHistory(
                        attempts: gameProvider.currentSession!.attempts,
                        isVisible: gameProvider.showHistory,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('MATCH OR MISS', style: TextStyle(letterSpacing: 2)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
  
  Widget _buildHeader(GameProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TimerWidget(
            remainingTime: provider.currentSession!.remainingTime,
            onTimeout: () => _handleTimeout(provider),
          ),
          Column(
            children: [
              const Text('Moves', style: TextStyle(color: Colors.white70)),
              Text(
                '${provider.currentSession!.currentMoves}/${provider.currentSession!.maxMoves}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          Column(
            children: [
              const Text('Score', style: TextStyle(color: Colors.white70)),
              Text(
                '${provider.currentSession!.currentScore}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.yellow),
              ),
            ],
          ),
          IconButton(
            icon: Icon(provider.showHistory ? Icons.visibility : Icons.visibility_off),
            onPressed: () => provider.toggleHistory(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback(GameProvider provider) {
    if (provider.currentSession == null || provider.currentSession!.attempts.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            "Make your first guess to get feedback",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ),
      );
    }
    
    final lastMatches = provider.currentSession!.attempts.last.matches;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          lastMatches == 0 
              ? "0 Matches – Try a new pattern"
              : lastMatches == 8
                  ? "🎉 PERFECT! Puzzle solved!"
                  : "✓ You have $lastMatches matches",
          style: TextStyle(
            fontSize: 16,
            color: lastMatches > 0 ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(GameProvider gameProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: gameProvider.isSubmitting ? null : () => _submitGuess(gameProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: gameProvider.isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SUBMIT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _resetGuess(gameProvider),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.cyan,
                side: const BorderSide(color: Colors.cyan),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('RESET', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitGuess(GameProvider gameProvider) async {
    await gameProvider.submitGuess();
    
    // Check if game is won
    if (gameProvider.currentSession != null && 
        gameProvider.currentSession!.attempts.isNotEmpty &&
        gameProvider.currentSession!.attempts.last.matches == 8) {
      _gameFinished = true;
      await _showGameCompleteFeedback(gameProvider);
    }
  }

  void _resetGuess(GameProvider gameProvider) {
    gameProvider.resetGuess();
  }

  Future<void> _showGameCompleteFeedback(GameProvider gameProvider) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Congratulations!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Score: ${gameProvider.currentSession!.currentScore}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Moves: ${gameProvider.currentSession!.currentMoves}/${gameProvider.currentSession!.maxMoves}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              const Text(
                'Getting AI feedback...',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );

    // Get Gemini feedback
    try {
      final aiProvider = Provider.of<AIProvider>(context, listen: false);
      final feedback = await aiProvider.analyzeGamePerformance(
        attempts: gameProvider.currentSession!.attempts,
        totalScore: gameProvider.currentSession!.currentScore,
        totalMoves: gameProvider.currentSession!.currentMoves,
        timeSpent: gameProvider.currentSession!.timeLimit - gameProvider.currentSession!.remainingTime,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showFeedbackDialog(feedback);
      }
    } catch (e) {
      print('Error getting feedback: $e');
      if (mounted) {
        Navigator.pop(context);
        _showFeedbackDialog('Great job completing the puzzle! Keep practicing to improve your score.');
      }
    }
  }

  void _showFeedbackDialog(String feedback) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🤖 AI Analysis'),
        content: SingleChildScrollView(
          child: Text(
            feedback,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  void _handleTimeout(GameProvider gameProvider) {
    _gameFinished = true;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("⏱️ Time's Up!"),
        content: Text('Final Score: ${gameProvider.currentSession!.currentScore}'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

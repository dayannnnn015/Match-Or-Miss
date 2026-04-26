// lib/screens/game_screen_with_ai.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../services/game_service.dart';
import '../widgets/bottle_slot.dart';
import '../widgets/bottle_widget.dart';
import '../widgets/attempt_history.dart';
import '../widgets/timer_widget.dart';

class GameScreenWithAI extends StatefulWidget {
  const GameScreenWithAI({super.key});

  @override
  _GameScreenWithAIState createState() => _GameScreenWithAIState();
}

class _GameScreenWithAIState extends State<GameScreenWithAI> {
  bool _gameFinished = false;
  bool _resultShown = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.currentSession == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final session = gameProvider.currentSession!;
          final mode = session.mode;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_resultShown && mounted) {
              _checkEndConditions(gameProvider);
            }
          });

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
                  _buildHeader(gameProvider, mode),
                  _buildModeBadge(mode),
                  if (mode == GameMode.competitive)
                    _buildCompetitiveBar(session),
                  Expanded(
                    flex: 2,
                    child: _buildGameSlots(gameProvider, session),
                  ),
                  _buildFeedbackArea(gameProvider),
                  Expanded(
                    flex: 1,
                    child: _buildAvailableBottles(gameProvider, session),
                  ),
                  _buildActionButtons(gameProvider),
                  if (gameProvider.showHistory)
                    Expanded(
                      child: AttemptHistory(
                        attempts: session.attempts,
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
      backgroundColor: const Color(0xFF0a0015),
      title: const Text(
        '🎮 Match or Miss - Bottle Edition',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildHeader(GameProvider gameProvider, GameMode mode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Score: ${gameProvider.currentSession?.currentScore ?? 0}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                ),
              ),
              Text(
                'Moves: ${gameProvider.currentSession?.currentMoves ?? 0}/${gameProvider.currentSession?.maxMoves ?? 0}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          TimerWidget(
            remainingTime: gameProvider.currentSession?.remainingTime ?? 0,
            onTimeout: () {
              // Handle timeout if needed
            },
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (gameProvider.hasHint)
                Text(
                  gameProvider.lastHint,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.yellowAccent,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeBadge(GameMode mode) {
    final String modeText = mode.toString().split('.').last.toUpperCase();
    final Color modeColor = _getModeColor(mode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: modeColor.withOpacity(0.2),
        border: Border.all(color: modeColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        modeText,
        style: TextStyle(
          color: modeColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getModeColor(GameMode mode) {
    switch (mode) {
      case GameMode.quick:
        return Colors.greenAccent;
      case GameMode.standard:
        return Colors.blueAccent;
      case GameMode.competitive:
        return Colors.redAccent;
    }
  }

  Widget _buildCompetitiveBar(GameSession session) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.redAccent, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '⚡ COMPETITIVE MODE',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            'Time Left: ${session.remainingTime}s',
            style: TextStyle(
              color: session.remainingTime < 10
                  ? Colors.redAccent
                  : Colors.orangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameSlots(GameProvider gameProvider, GameSession session) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Target Slots - Drag bottles here:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: gameProvider.currentGuessSlots.length,
              itemBuilder: (context, index) {
                return BottleSlot(
                  index: index,
                  bottle: gameProvider.currentGuessSlots[index],
                  onBottleDropped: (slotIndex, bottle) {
                    gameProvider.placeBottle(slotIndex, bottle);
                  },
                  onBottleRemoved: () {
                    gameProvider.removeBottle(index);
                  },
                  isEnabled: !gameProvider.isSubmitting && !_gameFinished,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableBottles(GameProvider gameProvider, GameSession session) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Bottles - Drag to slots:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: session.availableBottles
                    .map(
                      (bottle) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Draggable<Bottle>(
                          data: bottle,
                          feedback: Material(
                            color: Colors.transparent,
                            child: BottleWidget(
                              bottle: bottle,
                              size: 60,
                              isDragging: true,
                            ),
                          ),
                          childWhenDragging: Container(
                            width: 60,
                            height: 78,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade600,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade800.withOpacity(0.5),
                            ),
                          ),
                          child: BottleWidget(
                            bottle: bottle,
                            size: 60,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackArea(GameProvider gameProvider) {
    final session = gameProvider.currentSession;
    if (session == null || session.attempts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            border: Border.all(color: Colors.cyanAccent, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '💡 Arrange all 4 bottles in the target slots and submit to check your guess!',
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    final lastAttempt = session.attempts.last;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: lastAttempt.matches == GameService.SEQUENCE_LENGTH
              ? Colors.green.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          border: Border.all(
            color: lastAttempt.matches == GameService.SEQUENCE_LENGTH
                ? Colors.greenAccent
                : Colors.orangeAccent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              lastAttempt.matches == GameService.SEQUENCE_LENGTH
                  ? Icons.check_circle
                  : Icons.info,
              color: lastAttempt.matches == GameService.SEQUENCE_LENGTH
                  ? Colors.greenAccent
                  : Colors.orangeAccent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Correct positions: ${lastAttempt.matches}/${GameService.SEQUENCE_LENGTH}',
                style: TextStyle(
                  color: lastAttempt.matches == GameService.SEQUENCE_LENGTH
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
            child: ElevatedButton.icon(
              onPressed: gameProvider.isSubmitting
                  ? null
                  : () => gameProvider.resetGuess(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                disabledBackgroundColor: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: gameProvider.isSubmitting || !gameProvider.canSubmit
                  ? null
                  : () => gameProvider.submitGuess(),
              icon: const Icon(Icons.check),
              label: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                disabledBackgroundColor: Colors.cyan.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkEndConditions(GameProvider gp) {
    if (_resultShown || _gameFinished) return;
    final session = gp.currentSession;
    if (session == null || session.attempts.isEmpty) return;

    final last = session.attempts.last;
    final solved = last.matches == GameService.SEQUENCE_LENGTH;
    final outOfMoves = session.currentMoves >= session.maxMoves;

    if (solved) {
      _gameFinished = true;
      _resultShown = true;
      gp.loadPostGameInsight();
      _showResultDialog(gp, won: true);
    } else if (outOfMoves) {
      _gameFinished = true;
      _resultShown = true;
      gp.loadPostGameInsight();
      _showResultDialog(gp, won: false);
    }
  }

  void _showResultDialog(GameProvider gp, {required bool won}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          won ? '🎉 Congratulations!' : '😢 Game Over',
          style: TextStyle(
            color: won ? Colors.greenAccent : Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gp.postGameInsight,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              if (gp.isLoadingInsight)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: const [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Getting AI insights...',
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
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

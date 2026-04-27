// lib/screens/game_screen_with_ai.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/bottle_widget.dart';
import '../widgets/timer_widget.dart';

class GameScreenWithAI extends StatefulWidget {
  const GameScreenWithAI({super.key});

  @override
  State<GameScreenWithAI> createState() => GameScreenWithAIState();
}

class GameScreenWithAIState extends State<GameScreenWithAI>
    with TickerProviderStateMixin {
  bool _gameFinished = false;
  bool _resultShown = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    // Check game state periodically
    Future.delayed(const Duration(milliseconds: 500), () {
      _checkGamePeriodically();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _checkGamePeriodically() {
    if (!mounted) return;
    final provider = context.read<GameProvider>();
    provider.checkGameState();
    if (!_gameFinished) {
      Future.delayed(const Duration(milliseconds: 300), _checkGamePeriodically);
    }
  }

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

          // Reset dialog flags when a new game starts
          if (_resultShown && _gameFinished) {
            _gameFinished = false;
            _resultShown = false;
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_resultShown && gameProvider.isSolved() && mounted) {
              _gameFinished = true;
              _resultShown = true;
              _showResultDialog(gameProvider, won: true);
            }
          });

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF09111F), Color(0xFF10283D), Color(0xFF183948)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(gameProvider, mode),
                  _buildModeBadge(mode),
                  _buildHiddenSequenceBox(
                    session.hiddenSequence,
                    gameProvider.isSolved(),
                  ),
                  if (mode == GameMode.competitive)
                    _buildCompetitiveBar(session),
                  const SizedBox(height: 20),
                  _buildFeedback(gameProvider, session),
                  const SizedBox(height: 20),
                  _buildDraggableBottles(gameProvider, session),
                  const SizedBox(height: 16),
                  _buildResetButton(gameProvider),
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
      backgroundColor: const Color(0xFF0E1D2D),
      title: const Text(
        'Match or Miss',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Moves ',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    AnimatedCounter(
                      value: gameProvider.currentSession?.currentMoves ?? 0,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF6DD3FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text(
                      'Score ',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    AnimatedCounter(
                      value: gameProvider.currentSession?.currentScore ?? 0,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFFC37A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const TimerWidget(),
        ],
      ),
    );
  }

  Widget _buildModeBadge(GameMode mode) {
    final String modeText = mode.toString().split('.').last.toUpperCase();
    final Color modeColor = _getModeColor(mode);

    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              modeColor.withValues(alpha: 0.28),
              modeColor.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: modeColor.withValues(alpha: 0.7), width: 1.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: modeColor.withValues(alpha: 0.25),
              blurRadius: 12,
              spreadRadius: 1,
            )
          ],
        ),
        child: Text(
          '$modeText MODE',
          style: TextStyle(
            color: modeColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.2,
          ),
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
        color: const Color(0xFFFF875A).withValues(alpha: 0.12),
        border: Border.all(color: const Color(0xFFFFA15E), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'COMPETITIVE MODE',
            style: TextStyle(
              color: Color(0xFFFFC37A),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            'Time Left: ${session.remainingTime}s',
            style: TextStyle(
              color: session.remainingTime < 10
                  ? const Color(0xFFFF7A7A)
                  : const Color(0xFFFFC37A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenSequenceBox(List<Bottle> hiddenSequence, bool revealed) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                revealed ? Icons.lock_open_rounded : Icons.lock_rounded,
                color: revealed ? const Color(0xFF56D676) : const Color(0xFF9DDFFF),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                revealed
                    ? 'Hidden Sequence Revealed'
                    : 'Hidden Sequence Box (Locked)',
                style: TextStyle(
                  color: revealed ? const Color(0xFF56D676) : const Color(0xFF9DDFFF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(hiddenSequence.length, (index) {
                final bottle = hiddenSequence[index];
                return Container(
                  width: 30,
                  height: 34,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: revealed
                        ? bottle.color
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: revealed
                          ? Colors.white.withValues(alpha: 0.45)
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: revealed
                        ? const Icon(Icons.local_drink, size: 14, color: Colors.white)
                        : const Icon(Icons.help_outline, size: 14, color: Colors.white54),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildFeedback(GameProvider gameProvider, GameSession session) {
    final currentMatches = gameProvider.getCurrentMatches();
    final maxMatches = session.hiddenSequence.length;
    final isSolved = gameProvider.isSolved();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSolved
            ? const Color(0xFF56D676).withValues(alpha: 0.15)
            : const Color(0xFF6DD3FF).withValues(alpha: 0.12),
        border: Border.all(
          color: isSolved ? const Color(0xFF56D676) : const Color(0xFF6DD3FF),
          width: 1.6,
        ),
        borderRadius: BorderRadius.circular(12),
        // Keep a stable shadow list shape so implicit lerp does not scale
        // shadow values through negatives on web during overshoot transitions.
        boxShadow: [
          BoxShadow(
            color: isSolved
                ? const Color(0xFF56D676).withValues(alpha: 0.45)
                : Colors.transparent,
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          AnimatedScale(
            scale: isSolved ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 600),
            child: Text(
              isSolved ? '🎉 SOLVED!' : 'Correct Matches',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSolved ? const Color(0xFF56D676) : const Color(0xFF9DDFFF),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 500),
            style: TextStyle(
              fontSize: isSolved ? 32 : 28,
              fontWeight: FontWeight.bold,
              color: isSolved ? const Color(0xFF56D676) : Colors.white,
            ),
            child: Text(
              '$currentMatches / $maxMatches',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableBottles(GameProvider gameProvider, GameSession session) {
    final total = gameProvider.currentGuessSlots.length;
    final viewportWidth = MediaQuery.of(context).size.width;

    int columns;
    if (viewportWidth >= 1300) {
      columns = total.clamp(1, 8);
    } else if (viewportWidth >= 1000) {
      columns = total.clamp(1, 6);
    } else if (viewportWidth >= 700) {
      columns = total.clamp(1, 5);
    } else if (viewportWidth >= 520) {
      columns = total.clamp(1, 4);
    } else {
      columns = total <= 2 ? total : 3;
    }

    final compactDesignWidth = (columns * 82.0) + ((columns - 1) * 12);
    final availableWidth = viewportWidth - 32;
    final maxGridWidth = compactDesignWidth < availableWidth
      ? compactDesignWidth
      : availableWidth;

    final cellWidth =
        (maxGridWidth - ((columns - 1) * 12)) / columns;
    var bottleSize = cellWidth * 0.46;
    bottleSize = bottleSize.clamp(26.0, 38.0);
    final cellHeight = bottleSize * 1.34;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: const [Color(0xFF6DD3FF), Color(0xFFB7EBFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'Drag bottle assets into the sequence grid',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxGridWidth),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: total,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: cellHeight,
                    ),
                    itemBuilder: (context, index) {
                      final bottle = gameProvider.currentGuessSlots[index];
                      if (bottle == null) return const SizedBox.shrink();

                      return _buildAnimatedBottleWrapper(
                        bottle,
                        index,
                        gameProvider,
                        bottleSize,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBottleWrapper(
    Bottle bottle,
    int index,
    GameProvider gameProvider,
    double bottleSize,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return ScaleTransition(
          scale: AlwaysStoppedAnimation(value),
          child: FadeTransition(
            opacity: AlwaysStoppedAnimation(value),
            child: child,
          ),
        );
      },
      child: _buildDraggableBottle(
        bottle,
        index,
        gameProvider,
        bottleSize,
      ),
    );
  }

  Widget _buildDraggableBottle(
    Bottle bottle,
    int index,
    GameProvider gameProvider,
    double bottleSize,
  ) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        if (details.data != index) {
          gameProvider.swapBottles(details.data, index);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Draggable<int>(
          data: index,
          feedback: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: AlwaysStoppedAnimation(1.15),
              child: BottleWidget(
                bottle: bottle,
                size: bottleSize,
                isDragging: true,
              ),
            ),
          ),
          childWhenDragging: SizedBox(
            width: bottleSize,
            height: bottleSize * 1.3,
            child: Opacity(
              opacity: 0.4,
              child: BottleWidget(
                bottle: bottle,
                size: bottleSize,
              ),
            ),
          ),
          child: AnimatedScale(
            scale: candidateData.isNotEmpty ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: BottleWidget(
              bottle: bottle,
              size: bottleSize,
            ),
          ),
        );
      },
    );
  }

  Widget _buildResetButton(GameProvider gameProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFA15E), Color(0xFFD46A2F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFA15E).withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => gameProvider.resetGuess(),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.restart_alt, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Reset Guess',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResultDialog(GameProvider gp, {required bool won}) {
    final parentContext = context;
    final hiddenSequence = gp.currentSession?.hiddenSequence ?? const <Bottle>[];
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
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
              if (hiddenSequence.isNotEmpty) ...[
                const Text(
                  'Hidden Sequence',
                  style: TextStyle(
                    color: Color(0xFF9DDFFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(hiddenSequence.length, (index) {
                      final bottle = hiddenSequence[index];
                      return Container(
                        width: 30,
                        height: 34,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: bottle.color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white38),
                        ),
                        child: const Icon(Icons.local_drink, size: 14, color: Colors.white),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
              ],
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
              final provider = parentContext.read<GameProvider>();
              final nextMode = provider.currentSession?.mode ?? GameMode.standard;
              Navigator.pop(dialogContext);
              provider.initializeGame(nextMode);
              _gameFinished = false;
              _resultShown = false;
            },
            child: const Text('Next Game'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(parentContext);
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

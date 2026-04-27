import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_models.dart';
import '../providers/game_provider.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/api_key_dialog.dart';
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
  bool _hasPlayerMoved = false;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    Future.delayed(const Duration(milliseconds: 500), _checkGamePeriodically);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _checkGamePeriodically() {
    if (!mounted) return;
    final provider = context.read<GameProvider>();
    final moves = provider.currentSession?.currentMoves ?? 0;
    if (moves > 0) {
      provider.checkGameState();
    }
    if (!_gameFinished) {
      Future.delayed(const Duration(milliseconds: 300), _checkGamePeriodically);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: _buildAppBar(context),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final session = gameProvider.currentSession;
          if (session == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final mode = session.mode;

          final moves = session.currentMoves;
          if (moves > 0 && !_hasPlayerMoved) {
            _hasPlayerMoved = true;
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_resultShown && _hasPlayerMoved && gameProvider.isSolved() && mounted) {
              _gameFinished = true;
              _resultShown = true;
              _celebrationController.forward();
              _showResultDialog(gameProvider, won: true);
            }
          });

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0A0E1A),
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                ],
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
                  if (mode == GameMode.competitive) _buildCompetitiveBar(session),
                  const SizedBox(height: 16),
                  _buildFeedback(gameProvider, session),
                  const SizedBox(height: 16),
                  _buildDraggableBottles(gameProvider),
                  const SizedBox(height: 10),
                  _buildResetButton(gameProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A2E).withValues(alpha: 0.8),
      title: const Text(
        'MATCH OR MISS',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          color: Color(0xFF9DDFFF),
        ),
      ),
      centerTitle: true,
      elevation: 0,
      actions: [
        Consumer<GameProvider>(
          builder: (context, gp, _) => Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gp.hasAIKey
                      ? const Color(0xFF00D2FF).withValues(alpha: 0.15)
                      : Colors.transparent,
                  border: Border.all(
                    color: gp.hasAIKey
                        ? const Color(0xFF00D2FF)
                        : const Color(0xFF4A5568),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  gp.hasAIKey ? Icons.auto_awesome : Icons.smart_toy_outlined,
                  color: gp.hasAIKey ? const Color(0xFF00D2FF) : const Color(0xFF718096),
                  size: 22,
                ),
              ),
              tooltip: gp.hasAIKey ? 'AI Coach Active' : 'Connect AI Coach',
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const APIKeyDialog(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(GameProvider gameProvider, GameMode mode) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withValues(alpha: 0.7),
            const Color(0xFF0F0F1A).withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2D2D44).withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildStatBadge(
                label: 'MOVES',
                value: gameProvider.currentSession?.currentMoves ?? 0,
                color: const Color(0xFF00D2FF),
              ),
              const SizedBox(width: 20),
              _buildStatBadge(
                label: 'SCORE',
                value: gameProvider.currentSession?.currentScore ?? 0,
                color: const Color(0xFF7CFFB2),
              ),
            ],
          ),
          const TimerWidget(),
        ],
      ),
    );
  }

  Widget _buildStatBadge({required String label, required int value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedCounter(
            value: value,
            textStyle: TextStyle(
              fontSize: 22,
              color: color,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: color.withValues(alpha: 0.5), blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBadge(GameMode mode) {
    final modeText = mode.toString().split('.').last.toUpperCase();
    final modeColor = _getModeColor(mode);

    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              modeColor.withValues(alpha: 0.2),
              modeColor.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(color: modeColor.withValues(alpha: 0.6), width: 1.2),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: modeColor.withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getModeIcon(mode), color: modeColor, size: 14),
            const SizedBox(width: 8),
            Text(
              '$modeText MODE',
              style: TextStyle(
                color: modeColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getModeIcon(GameMode mode) {
    switch (mode) {
      case GameMode.quick:
        return Icons.flash_on;
      case GameMode.standard:
        return Icons.timer;
      case GameMode.competitive:
        return Icons.emoji_events;
    }
  }

  Color _getModeColor(GameMode mode) {
    switch (mode) {
      case GameMode.quick:
        return const Color(0xFF7CFFB2);
      case GameMode.standard:
        return const Color(0xFF00D2FF);
      case GameMode.competitive:
        return const Color(0xFFFF6B6B);
    }
  }

  Widget _buildCompetitiveBar(GameSession session) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B6B).withValues(alpha: 0.15),
            const Color(0xFFFF6B6B).withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: const Color(0xFFFF6B6B), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.whatshot, color: Color(0xFFFF6B6B), size: 16),
              const SizedBox(width: 8),
              const Text(
                'COMPETITIVE',
                style: TextStyle(
                  color: Color(0xFFFFA0A0),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: session.remainingTime < 10
                      ? const Color(0xFFFF6B6B).withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${session.remainingTime}s',
                  style: TextStyle(
                    color: session.remainingTime < 10
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFFFFA0A0),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: session.remainingTime < 10
                        ? [Shadow(color: const Color(0xFFFF6B6B).withValues(alpha: 0.5), blurRadius: 8)]
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenSequenceBox(List<Bottle> hiddenSequence, bool revealed) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withValues(alpha: 0.8),
            const Color(0xFF0F0F1A).withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: revealed
              ? const Color(0xFF7CFFB2).withValues(alpha: 0.5)
              : const Color(0xFF2D2D44).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: revealed
                      ? const Color(0xFF7CFFB2).withValues(alpha: 0.2)
                      : Colors.transparent,
                ),
                child: Icon(
                  revealed ? Icons.visibility : Icons.visibility_off,
                  color: revealed ? const Color(0xFF7CFFB2) : const Color(0xFF4A5568),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                revealed ? 'SECRET SEQUENCE' : '?? LOCKED PATTERN ??',
                style: TextStyle(
                  color: revealed ? const Color(0xFF7CFFB2) : const Color(0xFF4A5568),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(hiddenSequence.length, (index) {
                final bottle = hiddenSequence[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.only(right: 8),
                  width: 32,
                  height: 38,
                  decoration: BoxDecoration(
                    color: revealed
                        ? bottle.color.withValues(alpha: 0.85)
                        : const Color(0xFF2D2D44).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: revealed
                          ? bottle.color
                          : const Color(0xFF4A5568),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.local_drink,
                      size: 16,
                      color: revealed ? Colors.white : const Color(0xFF4A5568),
                    ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isSolved
            ? LinearGradient(
                colors: [
                  const Color(0xFF7CFFB2).withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              )
            : null,
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
        border: Border.all(
          color: isSolved
              ? const Color(0xFF7CFFB2).withValues(alpha: 0.6)
              : const Color(0xFF2D2D44).withValues(alpha: 0.4),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          AnimatedScale(
            scale: isSolved ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSolved
                    ? const Color(0xFF7CFFB2).withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isSolved ? '✨ PERFECT MATCH! ✨' : 'MATCH PROGRESS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isSolved ? const Color(0xFF7CFFB2) : const Color(0xFF00D2FF),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: currentMatches / maxMatches,
                  strokeWidth: 6,
                  backgroundColor: const Color(0xFF2D2D44),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSolved ? const Color(0xFF7CFFB2) : const Color(0xFF00D2FF),
                  ),
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isSolved ? 26 : 22,
                  fontWeight: FontWeight.bold,
                  color: isSolved ? const Color(0xFF7CFFB2) : Colors.white,
                ),
                child: Text('$currentMatches/$maxMatches'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableBottles(GameProvider gameProvider) {
    final total = gameProvider.currentGuessSlots.length;
    if (total <= 0) {
      return const Expanded(child: SizedBox.shrink());
    }

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
    columns = columns.clamp(1, 8);

    final compactDesignWidth = (columns * 82.0) + ((columns - 1) * 12);
    final availableWidth = viewportWidth - 32;
    final maxGridWidth = compactDesignWidth < availableWidth
        ? compactDesignWidth
        : availableWidth;

    final cellWidth = (maxGridWidth - ((columns - 1) * 12)) / columns;
    var bottleSize = cellWidth * 0.46;
    bottleSize = bottleSize.clamp(26.0, 38.0);
    final cellHeight = bottleSize * 1.54;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00D2FF).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app, color: Color(0xFF00D2FF), size: 12),
                  const SizedBox(width: 6),
                  Text(
                    'Drag & drop to rearrange',
                    style: TextStyle(
                      color: const Color(0xFF00D2FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
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
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: _buildDraggableBottle(bottle, index, gameProvider, bottleSize),
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
              scale: const AlwaysStoppedAnimation(1.15),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: bottle.color.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: BottleWidget(
                  bottle: bottle,
                  size: bottleSize,
                  isDragging: true,
                ),
              ),
            ),
          ),
          childWhenDragging: SizedBox(
            width: bottleSize,
            height: bottleSize * 1.54,
            child: Opacity(
              opacity: 0.3,
              child: BottleWidget(bottle: bottle, size: bottleSize),
            ),
          ),
          child: AnimatedScale(
            scale: candidateData.isNotEmpty ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: candidateData.isNotEmpty
                    ? [
                        BoxShadow(
                          color: bottle.color.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: BottleWidget(bottle: bottle, size: bottleSize),
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
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2D2D44),
                    const Color(0xFF1A1A2E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: const Color(0xFF00D2FF).withValues(alpha: 0.4 + _glowController.value * 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D2FF).withValues(alpha: 0.1),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: gameProvider.resetGuess,
                  borderRadius: BorderRadius.circular(30),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, color: Color(0xFF00D2FF), size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Reset Sequence',
                          style: TextStyle(
                            color: Color(0xFF00D2FF),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              won ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              color: won ? const Color(0xFF7CFFB2) : const Color(0xFFFF6B6B),
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              won ? 'VICTORY!' : 'GAME OVER',
              style: TextStyle(
                color: won ? const Color(0xFF7CFFB2) : const Color(0xFFFF6B6B),
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hiddenSequence.isNotEmpty) ...[
                const Text(
                  'THE SECRET PATTERN',
                  style: TextStyle(
                    color: Color(0xFF00D2FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(hiddenSequence.length, (index) {
                      final bottle = hiddenSequence[index];
                      return Container(
                        width: 40,
                        height: 44,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: bottle.color,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: bottle.color.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.local_drink, size: 18, color: Colors.white),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2D2D44)),
                ),
                child: Text(
                  gp.postGameInsight,
                  style: const TextStyle(color: Color(0xFFA0A0B0), height: 1.5, fontSize: 13),
                ),
              ),
              if (gp.isLoadingInsight)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D2FF)),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Analyzing your performance...',
                        style: TextStyle(color: Color(0xFF00D2FF), fontSize: 12),
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
              _hasPlayerMoved = false;
              _celebrationController.reset();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D2FF), Color(0xFF0077B6)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'PLAY AGAIN',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(parentContext);
            },
            child: const Text(
              'EXIT',
              style: TextStyle(color: Color(0xFF4A5568), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
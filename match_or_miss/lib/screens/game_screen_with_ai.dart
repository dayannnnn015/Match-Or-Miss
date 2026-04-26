// lib/screens/game_screen_with_ai.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../services/game_service.dart';
import '../widgets/bottle_widget.dart';
import '../widgets/timer_widget.dart';
import '../widgets/api_key_dialog.dart';

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
      appBar: _buildAppBar(context),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.currentSession == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final session = gameProvider.currentSession!;
          final mode = session.mode;

          if (_resultShown && _gameFinished) {
            _gameFinished = false;
            _resultShown = false;
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_resultShown && gameProvider.isSolved() && mounted) {
              _gameFinished = true;
              _resultShown = true;
              _showResultDialog(context, won: true);
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0a0015),
      title: const Text(
        '🎮 Match or Miss - Bottle Edition',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 0,
      actions: [
        Consumer<GameProvider>(
          builder: (context, gp, _) => IconButton(
            icon: Icon(
              gp.hasAIKey ? Icons.smart_toy : Icons.smart_toy_outlined,
              color: gp.hasAIKey ? Colors.greenAccent : Colors.white38,
            ),
            tooltip: gp.hasAIKey ? 'AI connected' : 'Connect AI for insights',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const APIKeyDialog(),
            ),
          ),
        ),
      ],
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
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 500),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                  shadows: [
                    Shadow(
                      color: Colors.cyanAccent.withOpacity(0.5),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Text(
                  'Moves: ${gameProvider.currentSession?.currentMoves ?? 0}',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Score: ${gameProvider.currentSession?.currentScore ?? 0}',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
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
              modeColor.withOpacity(0.3),
              modeColor.withOpacity(0.1),
            ],
          ),
          border: Border.all(color: modeColor, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: modeColor.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 1,
            )
          ],
        ),
        child: Text(
          '⚡ $modeText',
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
      case GameMode.quick:       return Colors.greenAccent;
      case GameMode.standard:    return Colors.blueAccent;
      case GameMode.competitive: return Colors.redAccent;
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
          const Text('⚡ COMPETITIVE MODE',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          Text(
            'Time Left: ${session.remainingTime}s',
            style: TextStyle(
              color: session.remainingTime < 10 ? Colors.redAccent : Colors.orangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback(GameProvider gameProvider, GameSession session) {
    final currentMatches = gameProvider.getCurrentMatches();
    const maxMatches = GameService.SEQUENCE_LENGTH;
    final isSolved = gameProvider.isSolved();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSolved ? Colors.green.withOpacity(0.15) : Colors.blue.withOpacity(0.1),
        border: Border.all(
          color: isSolved ? Colors.greenAccent : Colors.cyanAccent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSolved
            ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)]
            : [],
      ),
      child: Column(
        children: [
          AnimatedScale(
            scale: isSolved ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 600),
            child: Text(
              isSolved ? '🎉 SOLVED!' : 'Correct Positions',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 500),
            style: TextStyle(
              fontSize: isSolved ? 32 : 28,
              fontWeight: FontWeight.bold,
              color: isSolved ? Colors.greenAccent : Colors.white,
            ),
            child: Text('$currentMatches / $maxMatches'),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableBottles(GameProvider gameProvider, GameSession session) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.cyan, Colors.cyanAccent],
              ).createShader(bounds),
              child: const Text(
                'Drag to swap bottles:',
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    gameProvider.currentGuessSlots.length,
                    (index) {
                      final bottle = gameProvider.currentGuessSlots[index];
                      if (bottle == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _buildAnimatedBottleWrapper(bottle, index, gameProvider),
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

  Widget _buildAnimatedBottleWrapper(Bottle bottle, int index, GameProvider gameProvider) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return ScaleTransition(
          scale: AlwaysStoppedAnimation(value),
          child: FadeTransition(opacity: AlwaysStoppedAnimation(value), child: child),
        );
      },
      child: _buildDraggableBottle(bottle, index, gameProvider),
    );
  }

  Widget _buildDraggableBottle(Bottle bottle, int index, GameProvider gameProvider) {
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
              child: BottleWidget(bottle: bottle, size: 70, isDragging: true),
            ),
          ),
          childWhenDragging: SizedBox(
            width: 70,
            height: 91,
            child: Opacity(
              opacity: 0.4,
              child: BottleWidget(bottle: bottle, size: 70),
            ),
          ),
          child: AnimatedScale(
            scale: candidateData.isNotEmpty ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: BottleWidget(bottle: bottle, size: 70),
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
            gradient: LinearGradient(
              colors: [Colors.grey.shade600, Colors.grey.shade800],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => gameProvider.resetGuess(),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restart_alt, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Reset Game',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext ctx, {required bool won}) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogContext) => Consumer<GameProvider>(
        builder: (_, gp, __) => Dialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.75,
              maxWidth: 500,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Text(
                    won ? '🎉 Congratulations!' : '😢 Game Over',
                    style: TextStyle(
                      color: won ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (gp.isLoadingInsight) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.cyanAccent.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '🤖 Analyzing your game…',
                                    style: TextStyle(color: Colors.cyanAccent, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (gp.postGameInsight.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: gp.hasAIKey
                                  ? Colors.cyanAccent.withOpacity(0.07)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: gp.hasAIKey
                                    ? Colors.cyanAccent.withOpacity(0.3)
                                    : Colors.white12,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      gp.hasAIKey ? Icons.smart_toy : Icons.analytics_outlined,
                                      color: gp.hasAIKey ? Colors.cyanAccent : Colors.white38,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      gp.hasAIKey ? 'AI Feedback' : 'Performance Summary',
                                      style: TextStyle(
                                        color: gp.hasAIKey ? Colors.cyanAccent : Colors.white38,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  gp.postGameInsight,
                                  style: const TextStyle(color: Colors.white, height: 1.6, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          if (!gp.hasAIKey) ...[
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(dialogContext);
                                showDialog(
                                  context: ctx,
                                  builder: (_) => const APIKeyDialog(),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.cyan.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.cyan.withOpacity(0.4)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.key, color: Colors.cyan, size: 15),
                                    SizedBox(width: 8),
                                    Text(
                                      'Connect AI for richer feedback →',
                                      style: TextStyle(color: Colors.cyan, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                // Action buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          context.read<GameProvider>().initializeGame(
                            context.read<GameProvider>().currentSession?.mode ?? GameMode.standard,
                          );
                          _gameFinished = false;
                          _resultShown = false;
                        },
                        child: const Text('Next Game', style: TextStyle(color: Colors.cyanAccent)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Back to Home', style: TextStyle(color: Colors.white54)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
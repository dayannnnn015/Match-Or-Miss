// lib/screens/game_screen_with_ai.dart
// ENHANCED GAME SCREEN - ADAPTIVE SPRINT MODE + PREMIUM VISUALS
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
  State<GameScreenWithAI> createState() => _GameScreenWithAIState();
}

class _GameScreenWithAIState extends State<GameScreenWithAI>
    with TickerProviderStateMixin {
  bool _gameFinished = false;
  bool _resultShown = false;
  bool _hasPlayerMoved = false;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _celebrationController;
  late AnimationController _matchPulseController;
  
  // For match feedback animation
  int _lastMatchCount = 0;
  bool _showMatchAnimation = false;

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
    
    _matchPulseController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    Future.delayed(const Duration(milliseconds: 500), _checkGamePeriodically);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _celebrationController.dispose();
    _matchPulseController.dispose();
    super.dispose();
  }

  void _checkGamePeriodically() {
    if (!mounted) return;
    final provider = context.read<GameProvider>();
    final moves = provider.currentSession?.currentMoves ?? 0;
    if (moves > 0) {
      provider.checkGameState();
    }
    if (!_gameFinished && mounted) {
      Future.delayed(const Duration(milliseconds: 300), _checkGamePeriodically);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 1200;
    final maxContentWidth = isWeb ? 1000.0 : double.infinity;
    final horizontalPadding = isWeb ? (screenWidth - maxContentWidth) / 2 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
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
          
          // Trigger match animation when match count increases
          final currentMatches = gameProvider.getCurrentMatches();
          if (currentMatches > _lastMatchCount && currentMatches > 0) {
            _lastMatchCount = currentMatches;
            _matchPulseController.forward(from: 0);
            _showMatchAnimation = true;
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) setState(() => _showMatchAnimation = false);
            });
          } else if (currentMatches != _lastMatchCount) {
            _lastMatchCount = currentMatches;
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_resultShown && _hasPlayerMoved && gameProvider.isSolved() && mounted) {
              _gameFinished = true;
              _resultShown = true;
              _celebrationController.forward();
              // Small delay so loadPostGameInsight() sets initial local feedback
              // before _ResultDialogState.initState() captures it
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (mounted) _showResultDialog(gameProvider, won: true);
              });
            }
          });

          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.3,
                colors: const [
                  Color(0xFF1A1A2E),
                  Color(0xFF0F0F1A),
                  Color(0xFF05050A),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    children: [
                      _buildHeader(gameProvider, mode),
                      _buildModeBadge(mode, session.sequenceLength),
                      _buildHiddenSequenceBox(
                        session.hiddenSequence,
                        gameProvider.isSolved(),
                      ),
                      if (mode == GameMode.competitive) _buildCompetitiveBar(session),
                      const SizedBox(height: 16),
                      _buildEnhancedFeedback(gameProvider, session),
                      const SizedBox(height: 16),
                      _buildDraggableBottles(gameProvider),
                      const SizedBox(height: 10),
                      _buildActionBar(gameProvider),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(GameProvider gameProvider, GameMode mode) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF2D2D44), width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatBadge('MOVES', gameProvider.currentSession?.currentMoves ?? 0, const Color(0xFF6C63FF)),
          const TimerWidget(),
          _buildStatBadge('SCORE', gameProvider.currentSession?.currentScore ?? 0, const Color(0xFFFF6584)),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1)),
          const SizedBox(height: 2),
          AnimatedCounter(value: value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildModeBadge(GameMode mode, int sequenceLength) {
    final modeText = mode == GameMode.quick 
        ? 'SPRINT MODE • $sequenceLength BOTTLES' 
        : mode == GameMode.standard 
            ? 'FOCUS MODE' 
            : 'GLADIATOR MODE';
            
    final modeColor = mode == GameMode.quick 
        ? const Color(0xFF00D2FF) 
        : mode == GameMode.standard 
            ? const Color(0xFF6C63FF) 
            : const Color(0xFFFF6584);

    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [modeColor.withValues(alpha: 0.15), Colors.transparent],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: modeColor.withValues(alpha: 0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getModeIcon(mode), color: modeColor, size: 14),
            const SizedBox(width: 8),
            Text(
              modeText,
              style: TextStyle(
                color: modeColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
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
      case GameMode.quick: return Icons.flash_on;
      case GameMode.standard: return Icons.timer;
      case GameMode.competitive: return Icons.emoji_events;
    }
  }

  Widget _buildCompetitiveBar(GameSession session) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFF6584).withValues(alpha: 0.12), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF6584).withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6584), size: 14),
              SizedBox(width: 8),
              Text('GLADIATOR MODE', style: TextStyle(color: Color(0xFFFF6584), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, _) => Text(
              '${session.remainingTime}s',
              style: TextStyle(
                color: session.remainingTime < 10 ? const Color(0xFFFF6584) : const Color(0xFFFFB347),
                fontWeight: FontWeight.bold,
                fontSize: 14,
                shadows: session.remainingTime < 10 
                    ? [Shadow(color: const Color(0xFFFF6584).withValues(alpha: 0.5), blurRadius: 8)] 
                    : null,
              ),
            ),
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
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: revealed ? const Color(0xFF6C63FF).withValues(alpha: 0.4) : const Color(0xFF2D2D44),
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
                  color: revealed ? const Color(0xFF6C63FF).withValues(alpha: 0.2) : Colors.transparent,
                ),
                child: Icon(
                  revealed ? Icons.visibility : Icons.visibility_off,
                  color: revealed ? const Color(0xFF6C63FF) : const Color(0xFF4A4A5A),
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                revealed ? 'TARGET PATTERN' : '?? CLASSIFIED ??',
                style: TextStyle(
                  color: revealed ? const Color(0xFF6C63FF) : const Color(0xFF4A4A5A),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
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
                  width: 40,
                  height: 48,
                  decoration: BoxDecoration(
                    color: revealed ? bottle.color.withValues(alpha: 0.85) : const Color(0xFF2D2D44).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: revealed ? bottle.color : const Color(0xFF4A4A5A),
                      width: 1.5,
                    ),
                    boxShadow: revealed ? [
                      BoxShadow(color: bottle.color.withValues(alpha: 0.3), blurRadius: 8),
                    ] : null,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.local_drink,
                      size: 18,
                      color: revealed ? Colors.white : const Color(0xFF4A4A5A),
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

  // ==========================================================================
  // ENHANCED FEEDBACK WITH ANIMATION
  // ==========================================================================

  Widget _buildEnhancedFeedback(GameProvider gameProvider, GameSession session) {
    final currentMatches = gameProvider.getCurrentMatches();
    final maxMatches = session.hiddenSequence.length;
    final isSolved = gameProvider.isSolved();
    final progress = currentMatches / maxMatches;
    
    return AnimatedBuilder(
      animation: _matchPulseController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Main feedback card
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isSolved
                      ? LinearGradient(
                          colors: [const Color(0xFF6C63FF).withValues(alpha: 0.15), const Color(0xFF00D2FF).withValues(alpha: 0.08)],
                        )
                      : null,
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isSolved
                        ? const Color(0xFF6C63FF).withValues(alpha: 0.6)
                        : const Color(0xFF2D2D44),
                    width: 1,
                  ),
                  boxShadow: _showMatchAnimation
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    // Status text with animation
                    AnimatedScale(
                      scale: _showMatchAnimation ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSolved
                              ? const Color(0xFF6C63FF).withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isSolved 
                              ? '✨ SEQUENCE DECODED! ✨' 
                              : _showMatchAnimation && currentMatches > 0
                                  ? '🎯 +${currentMatches - (currentMatches - 1)} MATCH FOUND!'
                                  : 'DECODING PROGRESS',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: isSolved
                                ? const Color(0xFF6C63FF)
                                : _showMatchAnimation
                                    ? const Color(0xFF6C63FF)
                                    : const Color(0xFF8B8B9A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Large circular progress
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: const Color(0xFF2D2D44),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isSolved ? const Color(0xFF6C63FF) : const Color(0xFF6C63FF),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: _showMatchAnimation ? 34 : 28,
                                fontWeight: FontWeight.bold,
                                color: isSolved
                                    ? const Color(0xFF6C63FF)
                                    : _showMatchAnimation
                                        ? const Color(0xFF6C63FF)
                                        : Colors.white,
                              ),
                              child: Text('$currentMatches'),
                            ),
                            Text(
                              '/ $maxMatches',
                              style: const TextStyle(color: Color(0xFF8B8B9A), fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Progress bar with bottle icons
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D44),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Row(
                        children: List.generate(maxMatches, (index) {
                          final isMatched = index < currentMatches;
                          return Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              height: 4,
                              decoration: BoxDecoration(
                                color: isMatched
                                    ? const Color(0xFF6C63FF)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Match count text
                    Text(
                      _getMatchFeedback(currentMatches, maxMatches),
                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMatchFeedback(int matches, int total) {
    if (matches == 0) return '⚡ No matches yet — try a different pattern';
    if (matches == total) return '🏆 PERFECT! All bottles in position!';
    if (matches >= total * 0.75) return '🎯 Almost there! ${total - matches} more to go!';
    if (matches >= total * 0.5) return '📈 Getting warmer! Keep going!';
    if (matches >= total * 0.25) return '💡 You\'re on the right track!';
    return '👍 ${matches} correct - keep them locked!';
  }

  // ==========================================================================
  // DRAGGABLE BOTTLES GRID
  // ==========================================================================

  Widget _buildDraggableBottles(GameProvider gameProvider) {
    final total = gameProvider.currentGuessSlots.length;
    if (total <= 0) {
      return const Expanded(child: SizedBox.shrink());
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 1200;
    final maxContentWidth = isWeb ? 1000.0 : double.infinity;
    final availableWidth = isWeb ? maxContentWidth - 32 : screenWidth - 32;
    
    // Responsive grid based on bottle count
    int columns;
    if (total <= 3) {
      columns = total;
    } else if (total <= 4) {
      columns = 4;
    } else if (total <= 6) {
      columns = 3;
    } else {
      columns = 4;
    }
    
    const spacing = 12.0;
    final cellWidth = (availableWidth - ((columns - 1) * spacing)) / columns;
    final bottleSize = (cellWidth * 0.48).clamp(42.0, 65.0);
    final cellHeight = bottleSize * 1.54;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app, color: Color(0xFF6C63FF), size: 12),
                  const SizedBox(width: 6),
                  Text(
                    'DRAG & DROP TO REARRANGE',
                    style: TextStyle(
                      color: const Color(0xFF6C63FF),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Center(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: total,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    mainAxisExtent: cellHeight,
                  ),
                  itemBuilder: (context, index) {
                    final bottle = gameProvider.currentGuessSlots[index];
                    if (bottle == null) return const SizedBox.shrink();
                    return _buildDraggableBottle(
                      bottle,
                      index,
                      gameProvider,
                      bottleSize,
                      gameProvider.getCurrentMatchedPositions().contains(index),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableBottle(
    Bottle bottle,
    int index,
    GameProvider gameProvider,
    double bottleSize,
    bool isMatched,
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
            child: Transform.scale(
              scale: 1.1,
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
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: BottleWidget(bottle: bottle, size: bottleSize),
          ),
          child: AnimatedScale(
            scale: candidateData.isNotEmpty ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Stack(
              children: [
                Container(
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
                if (isMatched)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // ACTION BAR
  // ==========================================================================

  Widget _buildActionBar(GameProvider gameProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: gameProvider.resetGuess,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D44),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, color: Color(0xFF8B8B9A), size: 18),
                      SizedBox(width: 8),
                      Text('RESET', style: TextStyle(color: Color(0xFF8B8B9A), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                // Submit is handled automatically on swap, but we can add a hint button
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Drag bottles to rearrange and find the correct sequence!'),
                    backgroundColor: Color(0xFF6C63FF),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.psychology, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('GET HINT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // RESULT DIALOG
  // ==========================================================================

  void _showResultDialog(GameProvider gp, {required bool won}) {
    final hiddenSequence = gp.currentSession?.hiddenSequence ?? const <Bottle>[];
    final sequenceLength = hiddenSequence.length;
    final isSprintMode = gp.currentSession?.mode == GameMode.quick;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        gp: gp,
        won: won,
        hiddenSequence: hiddenSequence,
        sequenceLength: sequenceLength,
        isSprintMode: isSprintMode,
      ),
    );
  }

  // ==========================================================================
  // APP BAR WITH BACK BUTTON
  // ==========================================================================

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF6C63FF), size: 18),
        ),
        onPressed: () => _showExitConfirmation(context),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF6C63FF)),
          ),
          const SizedBox(width: 8),
          const Text(
            'NEBULA CODE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF6584)),
          ),
        ],
      ),
      centerTitle: true,
      elevation: 0,
      actions: [
        Consumer<GameProvider>(
          builder: (context, gp, _) => Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: gp.hasAIKey ? const Color(0xFF6C63FF) : const Color(0xFF2D2D44),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  gp.hasAIKey ? Icons.auto_awesome : Icons.psychology_outlined,
                  color: gp.hasAIKey ? const Color(0xFF6C63FF) : const Color(0xFF4A4A5A),
                  size: 18,
                ),
              ),
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

  // ==========================================================================
  // EXIT CONFIRMATION DIALOG
  // ==========================================================================

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'EXIT GAME?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'Your current progress will be lost.',
          style: TextStyle(color: Color(0xFF8B8B9A), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<GameProvider>(context, listen: false);
              provider.resetGame();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6584),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('EXIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
// ─── Result Dialog ────────────────────────────────────────────────────────────
// StatefulWidget that manually listens to GameProvider so it always
// rebuilds when AI feedback arrives — works reliably on Flutter Web.

class _ResultDialog extends StatefulWidget {
  final GameProvider gp;
  final bool won;
  final List<Bottle> hiddenSequence;
  final int sequenceLength;
  final bool isSprintMode;

  const _ResultDialog({
    required this.gp,
    required this.won,
    required this.hiddenSequence,
    required this.sequenceLength,
    required this.isSprintMode,
  });

  @override
  State<_ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<_ResultDialog> {
  @override
  void initState() {
    super.initState();
    widget.gp.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.gp.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (!mounted) return;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    final insight = widget.gp.postGameInsight;
    final loading = widget.gp.isLoadingInsight;
    final feedback = widget.isSprintMode && widget.won
        ? '🎉 Amazing! You solved a ${widget.sequenceLength}-bottle sequence!\n\nNext challenge will be ${widget.sequenceLength + 1} bottles!'
        : insight.isEmpty || loading
            ? '🔄 Analyzing your performance...'
            : insight;

    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      title: Row(
        children: [
          Icon(
            widget.won ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            color: widget.won ? const Color(0xFFFFB347) : const Color(0xFFFF6584),
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(
            widget.won ? 'VICTORY!' : 'DEFEAT',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
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
            if (widget.hiddenSequence.isNotEmpty) ...[
              const Text(
                'TARGET SEQUENCE',
                style: TextStyle(
                  color: Color(0xFF6C63FF),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(widget.hiddenSequence.length, (i) {
                    final bottle = widget.hiddenSequence[i];
                    return Container(
                      width: 48,
                      height: 52,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: bottle.color,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: bottle.color.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.local_drink, size: 22, color: Colors.white),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
            ],
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Container(
                key: ValueKey(feedback),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2D2D44)),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: SingleChildScrollView(
                    child: Text(
                      feedback,
                      style: const TextStyle(
                        color: Color(0xFFB0B0C0),
                        height: 1.4,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (loading)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'ANALYZING PERFORMANCE...',
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
            Navigator.of(context).pop();
            widget.gp.resetGame();
          },
          child: const Text(
            'EXIT LAB',
            style: TextStyle(color: Color(0xFF4A4A5A), fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.gp.resetGame();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'NEXT RUN',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
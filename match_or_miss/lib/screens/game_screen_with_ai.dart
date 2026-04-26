// lib/screens/game_screen_with_ai.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../services/game_service.dart';
import '../widgets/bottle_grid.dart';
import '../widgets/attempt_history.dart';
import '../widgets/timer_widget.dart';
import '../utils/constants.dart';
import '../providers/settings_provider.dart';

class GameScreenWithAI extends StatefulWidget {
  const GameScreenWithAI({super.key});

  @override
  _GameScreenWithAIState createState() => _GameScreenWithAIState();
}

class _GameScreenWithAIState extends State<GameScreenWithAI>
    with SingleTickerProviderStateMixin {
  bool _gameFinished = false;
  bool _resultShown  = false;

  // Shake animation for flexibility shift alert
  late AnimationController _shakeCtrl;
  late Animation<double>   _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween<double>(begin: -8, end: 8)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeCtrl);
  }

  @override
  void dispose() { _shakeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Consumer<GameProvider>(
        builder: (context, gp, child) {
          if (gp.currentSession == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final session = gp.currentSession!;
          final mode    = session.mode;

          // Trigger shift alert
          if (gp.sequenceJustShifted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _shakeCtrl.forward(from: 0);
              _showShiftAlert();
            });
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_resultShown && mounted) _checkEndConditions(gp);
          });

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF1a0033), Color(0xFF003366)]),
            ),
            child: SafeArea(
              child: Column(children: [
                _buildHeader(gp, mode),
                _buildModeBadge(mode, session),
                _buildModeSpecificBar(gp, session),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (ctx, child) => Transform.translate(
                        offset: Offset(_shakeCtrl.isAnimating ? _shakeAnim.value : 0, 0),
                        child: child,
                      ),
                      child: BottleGrid(
                        colors: gp.currentGuess,
                        onColorTap: (i, c) => gp.updateGuess(i, c),
                        onSwap:     (a, b) => gp.swapGuess(a, b),
                        isEnabled:  !gp.isSubmitting && !_gameFinished,
                      ),
                    ),
                  ),
                ),
                _buildFeedbackArea(gp, session),
                _buildActionButtons(gp),
                if (gp.showHistory)
                  Expanded(
                    child: AttemptHistory(
                      attempts:  session.attempts,
                      isVisible: gp.showHistory,
                    ),
                  ),
              ]),
            ),
          );
        },
      ),
    );
  }

  // ── End condition check ───────────────────────────────────────────────────────

  void _checkEndConditions(GameProvider gp) {
    if (_resultShown || _gameFinished) return;
    final session = gp.currentSession;
    if (session == null || session.attempts.isEmpty) return;

    final last   = session.attempts.last;
    final solved = last.matches == GameService.SEQUENCE_LENGTH;
    final outOfMoves = session.currentMoves >= session.maxMoves;

    if (solved || outOfMoves) {
      _gameFinished = true;
      _resultShown  = true;
      gp.loadPostGameInsight();
      _showResultDialog(gp, won: solved,
          reason: outOfMoves && !solved ? 'No moves left!' : null);
    }
  }

  // ── App bar ───────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() => AppBar(
    title: const Text('MATCH OR MISS', style: TextStyle(letterSpacing: 2)),
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    ),
  );

  // ── Mode badge ────────────────────────────────────────────────────────────────

  Widget _buildModeBadge(GameMode mode, GameSession session) {
    const info = {
      GameMode.quick: (
        '🧠 WORKING MEMORY',
        Colors.green,
        'No timer — 10 moves — every guess must count'
      ),
      GameMode.standard: (
        '🧘 INHIBITORY CONTROL',
        Colors.blue,
        'Wait ≥8s before submitting to earn patience bonus'
      ),
      GameMode.competitive: (
        '🔄 COGNITIVE FLEXIBILITY',
        Colors.orange,
        'Puzzle shifts after move 4 — adapt your strategy'
      ),
    };
    final (label, color, subtitle) = info[mode]!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(children: [
        Text(label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold,
                fontSize: 12, letterSpacing: 1)),
        Text(subtitle,
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 10)),
      ]),
    );
  }

  // ── Mode-specific status bar ──────────────────────────────────────────────────

  Widget _buildModeSpecificBar(GameProvider gp, GameSession session) {
    switch (session.mode) {
      // Working Memory: no bar needed — the move counter in header is enough
      case GameMode.quick:
        return const SizedBox.shrink();

      // Inhibitory Control: patience meter
      case GameMode.standard:
        return _PatienceBar(gp: gp);

      // Cognitive Flexibility: shift status
      case GameMode.competitive:
        return _FlexibilityBar(shifted: gp.sequenceHasShifted);
    }
  }

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader(GameProvider gp, GameMode mode) {
    final session = gp.currentSession!;
    final hasTimer = session.timeLimit > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        hasTimer
            ? TimerWidget(
                remainingTime: session.remainingTime,
                onTimeout: () => _handleTimeout(gp),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Text('∞ NO TIMER',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
        Column(children: [
          const Text('Moves', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text('${session.currentMoves}/${session.maxMoves}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
        Column(children: [
          const Text('Score', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text('${session.currentScore}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.yellow)),
        ]),
        IconButton(
          icon: Icon(gp.showHistory ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70),
          onPressed: gp.toggleHistory,
        ),
      ]),
    );
  }

  // ── Feedback area ─────────────────────────────────────────────────────────────

  Widget _buildFeedbackArea(GameProvider gp, GameSession session) {
    final attempts = session.attempts;
    return Column(children: [
      // Match count
      Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: attempts.isEmpty
              ? const Text(
                  'Tap a bottle to pick its color. Fill all 8 to unlock SUBMIT.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                  textAlign: TextAlign.center)
              : () {
                  final m = attempts.last.matches;
                  return Text(
                    m == 0
                        ? '0 / 8 matches — every bottle is in the wrong spot'
                        : m == GameService.SEQUENCE_LENGTH
                            ? '🎉 PERFECT! All 8 matched!'
                            : '✓  $m / ${GameService.SEQUENCE_LENGTH} bottles are in the correct position',
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold,
                      color: m == GameService.SEQUENCE_LENGTH
                          ? Colors.greenAccent
                          : m > 0 ? Colors.green : Colors.orange,
                    ),
                    textAlign: TextAlign.center,
                  );
                }(),
        ),
      ),

      // Hint — only shown when 'Show AI Hints' is enabled in settings
      if (gp.hasHint && context.watch<SettingsProvider>().hintsEnabled)
        Container(
          margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.cyan.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.psychology_outlined, color: Colors.cyan, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(gp.lastHint,
                style: const TextStyle(color: Colors.cyan, fontSize: 12))),
          ]),
        ),

      // Duplicate warning
      if (!gp.canSubmit &&
          !gp.currentGuess.contains(Colors.grey) &&
          gp.currentGuess.toSet().length < GameService.SEQUENCE_LENGTH)
        Container(
          margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.withOpacity(0.4)),
          ),
          child: const Row(children: [
            Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 16),
            SizedBox(width: 8),
            Expanded(child: Text('Each color can only be used once. Fix the duplicate!',
                style: TextStyle(color: Colors.orange, fontSize: 12))),
          ]),
        ),
    ]);
  }

  // ── Action buttons ────────────────────────────────────────────────────────────

  Widget _buildActionButtons(GameProvider gp) {
    final allFilled    = !gp.currentGuess.contains(Colors.grey);
    final hasDuplicates = allFilled &&
        gp.currentGuess.toSet().length < GameService.SEQUENCE_LENGTH;
    final canSubmit = gp.canSubmit && !gp.isSubmitting && !_gameFinished;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(children: [
        Expanded(
          child: ElevatedButton(
            onPressed: canSubmit ? () => gp.submitGuess() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              disabledBackgroundColor: Colors.green.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: gp.isSubmitting
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(
                    !allFilled   ? 'Fill all bottles first'
                    : hasDuplicates ? 'Fix duplicate colors'
                    : 'SUBMIT',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: _gameFinished ? null : gp.resetGuess,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.cyan,
              side: const BorderSide(color: Colors.cyan),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('RESET', style: TextStyle(fontSize: 16)),
          ),
        ),
      ]),
    );
  }

  // ── Shift alert dialog ────────────────────────────────────────────────────────

  void _showShiftAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2a1500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🔄 THE PUZZLE SHIFTED!',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text(
          'Two bottles in the hidden sequence have been secretly swapped.\n\n'
          'Your previous knowledge is now partially wrong. '
          'Look at your match count — if it dropped, you know which area changed.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('GOT IT — I\'LL ADAPT'),
          ),
        ],
      ),
    );
  }

  // ── Result dialog ─────────────────────────────────────────────────────────────

  void _showResultDialog(GameProvider gp, {required bool won, String? reason}) {
    final session = gp.currentSession!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Consumer<GameProvider>(
        builder: (ctx, gp2, __) => AlertDialog(
          backgroundColor: const Color(0xFF1a1a3a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            won ? '🎉 Puzzle Solved!' : '📊 Game Over',
            style: TextStyle(color: won ? Colors.greenAccent : Colors.orange,
                fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!won && reason != null)
                Padding(padding: const EdgeInsets.only(bottom: 8),
                    child: Text(reason,
                        style: const TextStyle(color: Colors.orange, fontSize: 13))),
              _statRow('Score',     '${session.currentScore}',    Colors.yellow),
              _statRow('Moves used','${session.currentMoves}',    Colors.cyan),
              _statRow('Attempts',  '${session.attempts.length}', Colors.white70),
              const Divider(color: Colors.white24, height: 20),
              Row(children: [
                const Icon(Icons.psychology, color: Colors.cyan, size: 14),
                const SizedBox(width: 6),
                const Text('AI ANALYSIS',
                    style: TextStyle(color: Colors.cyan,
                        fontWeight: FontWeight.bold, fontSize: 13)),
                if (gp2.isLoadingInsight) ...[
                  const SizedBox(width: 8),
                  const SizedBox(width: 12, height: 12,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.cyan)),
                  const SizedBox(width: 4),
                  const Text('enhancing...', style: TextStyle(color: Colors.cyan, fontSize: 10)),
                ] else if (gp2.hasAIKey) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.4)),
                    ),
                    child: const Text('AI', style: TextStyle(color: Colors.green, fontSize: 9)),
                  ),
                ],
              ]),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  gp2.postGameInsight.isEmpty
                      ? 'Analyzing your game...'
                      : gp2.postGameInsight,
                  key: ValueKey(gp2.postGameInsight),
                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                ),
              ),
            ]),
          ),
          actions: [
            ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(
                backgroundColor: won ? Colors.green : Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    ]),
  );

  void _handleTimeout(GameProvider gp) {
    if (_resultShown) return;
    _gameFinished = true;
    _resultShown  = true;
    gp.loadPostGameInsight();
    _showResultDialog(gp, won: false, reason: "Time's up!");
  }
}

// ── Supporting mode-specific widgets ─────────────────────────────────────────

/// Inhibitory Control: patience meter — shows how long since last change
class _PatienceBar extends StatefulWidget {
  final GameProvider gp;
  const _PatienceBar({required this.gp});

  @override
  State<_PatienceBar> createState() => _PatienceBarState();
}

class _PatienceBarState extends State<_PatienceBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.25)),
      ),
      child: Row(children: [
        const Icon(Icons.hourglass_empty, color: Colors.blue, size: 14),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Wait ≥8 seconds after your last swap before submitting to earn a patience bonus (+75 pts)',
            style: TextStyle(color: Colors.blue, fontSize: 11),
          ),
        ),
      ]),
    );
  }
}

/// Cognitive Flexibility: shows shift status
class _FlexibilityBar extends StatelessWidget {
  final bool shifted;
  const _FlexibilityBar({required this.shifted});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: shifted
            ? Colors.orange.withOpacity(0.15)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: shifted ? Colors.orange.withOpacity(0.5) : Colors.white12,
        ),
      ),
      child: Row(children: [
        Icon(shifted ? Icons.warning_amber : Icons.info_outline,
            color: shifted ? Colors.orange : Colors.white38, size: 14),
        const SizedBox(width: 8),
        Text(
          shifted
              ? '🔄 Sequence shifted after move ${AppConstants.flexibilityShiftAfterMove}! Adapt your strategy.'
              : 'Puzzle shifts after move ${AppConstants.flexibilityShiftAfterMove}. Stay flexible.',
          style: TextStyle(
            color: shifted ? Colors.orange : Colors.white38, fontSize: 11,
          ),
        ),
      ]),
    );
  }
}
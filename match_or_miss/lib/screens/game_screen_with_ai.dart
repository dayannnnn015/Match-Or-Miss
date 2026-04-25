// lib/screens/game_screen_with_ai.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../services/game_service.dart';
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
              child: Column(children: [
                _buildHeader(gameProvider, mode),
                _buildModeBadge(mode),
                // Competitive streak bar
                if (mode == GameMode.competitive)
                  _buildCompetitiveBar(session),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: BottleGrid(
                      colors: gameProvider.currentGuess,
                      onColorTap: (index, color) => gameProvider.updateGuess(index, color),
                      onSwap: (index1, index2) => gameProvider.swapGuess(index1, index2),
                      isEnabled: !gameProvider.isSubmitting && !_gameFinished,
                    ),
                  ),
                ),
                _buildFeedbackArea(gameProvider),
                _buildActionButtons(gameProvider),
                if (gameProvider.showHistory)
                  Expanded(
                    child: AttemptHistory(
                      attempts: session.attempts,
                      isVisible: gameProvider.showHistory,
                    ),
                  ),
              ]),
            ),
          );
        },
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
      gp.loadPostGameInsight(); // fire-and-forget, never blocks
      _showResultDialog(gp, won: true);
    } else if (outOfMoves) {
      _gameFinished = true;
      _resultShown = true;
      gp.loadPostGameInsight();
      _showResultDialog(gp, won: false, reason: 'No moves left!');
    }
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

  Widget _buildModeBadge(GameMode mode) {
    final labels = {
      GameMode.quick:       ('⚡ QUICK',       Colors.green,  '6 moves · 2 min'),
      GameMode.standard:    ('⏱ STANDARD',     Colors.blue,   '12 moves · 5 min'),
      GameMode.competitive: ('🏆 COMPETITIVE',  Colors.orange, '10 moves · 5 min · Ranked'),
    };
    final info = labels[mode]!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: info.$2.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: info.$2.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(info.$1,
            style: TextStyle(
                color: info.$2,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1)),
        const SizedBox(width: 8),
        Text(info.$3,
            style: TextStyle(color: info.$2.withOpacity(0.7), fontSize: 11)),
      ]),
    );
  }

  /// Competitive-only pressure bar showing move efficiency rating
  Widget _buildCompetitiveBar(GameSession session) {
    final movesUsed = session.currentMoves;
    final movesLeft = session.maxMoves - movesUsed;
    final pct = movesLeft / session.maxMoves;
    final barColor = pct > 0.5
        ? Colors.greenAccent
        : pct > 0.25
            ? Colors.orange
            : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('MOVE BUDGET',
              style: TextStyle(
                  color: Colors.white54, fontSize: 10, letterSpacing: 1.5)),
          Text('$movesLeft left',
              style: TextStyle(
                  color: barColor, fontSize: 10, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 5,
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader(GameProvider provider, GameMode mode) {
    final session = provider.currentSession!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TimerWidget(
            remainingTime: session.remainingTime,
            onTimeout: () => _handleTimeout(provider),
          ),
          Column(children: [
            const Text('Moves', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text(
              '${session.currentMoves}/${session.maxMoves}',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ]),
          Column(children: [
            const Text('Score', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text('${session.currentScore}',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.yellow)),
          ]),
          IconButton(
            icon: Icon(
                provider.showHistory ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70),
            onPressed: () => provider.toggleHistory(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackArea(GameProvider provider) {
    final session = provider.currentSession!;
    final attempts = session.attempts;

    return Column(children: [
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
                            : '✓  $m / ${GameService.SEQUENCE_LENGTH} bottles are correct',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: m == GameService.SEQUENCE_LENGTH
                          ? Colors.greenAccent
                          : m > 0
                              ? Colors.green
                              : Colors.orange,
                    ),
                    textAlign: TextAlign.center,
                  );
                }(),
        ),
      ),

      // Instant local hint
      if (provider.hasHint)
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
            Expanded(
                child: Text(provider.lastHint,
                    style: const TextStyle(color: Colors.cyan, fontSize: 12))),
          ]),
        ),

      // Duplicate warning
      if (!provider.canSubmit &&
          !provider.currentGuess.contains(Colors.grey) &&
          provider.currentGuess.toSet().length < GameService.SEQUENCE_LENGTH)
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
            Expanded(
                child: Text(
              'Each color can only be used once. You have a duplicate!',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            )),
          ]),
        ),
    ]);
  }

  Widget _buildActionButtons(GameProvider provider) {
    final allFilled = !provider.currentGuess.contains(Colors.grey);
    final hasDuplicates =
        allFilled && provider.currentGuess.toSet().length < GameService.SEQUENCE_LENGTH;
    final canSubmit = provider.canSubmit && !provider.isSubmitting && !_gameFinished;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(children: [
        Expanded(
          child: ElevatedButton(
            onPressed: canSubmit ? () => provider.submitGuess() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              disabledBackgroundColor: Colors.green.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: provider.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(
                    !allFilled
                        ? 'Fill all bottles first'
                        : hasDuplicates
                            ? 'Fix duplicate colors'
                            : 'SUBMIT',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: _gameFinished ? null : () => provider.resetGuess(),
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
            style: TextStyle(
              color: won ? Colors.greenAccent : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!won && reason != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(reason,
                        style: const TextStyle(color: Colors.orange, fontSize: 13)),
                  ),
                _statRow('Score', '${session.currentScore}', Colors.yellow),
                _statRow('Moves used', '${session.currentMoves}', Colors.cyan),
                _statRow('Attempts', '${session.attempts.length}', Colors.white70),
                const Divider(color: Colors.white24, height: 20),
                Row(children: [
                  const Icon(Icons.psychology, color: Colors.cyan, size: 14),
                  const SizedBox(width: 6),
                  const Text('AI ANALYSIS',
                      style: TextStyle(
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  if (gp2.isLoadingInsight) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 1.5, color: Colors.cyan)),
                    const SizedBox(width: 4),
                    const Text('enhancing...',
                        style: TextStyle(color: Colors.cyan, fontSize: 10)),
                  ] else if (gp2.hasAIKey) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.4)),
                      ),
                      child: const Text('AI',
                          style: TextStyle(color: Colors.green, fontSize: 9)),
                    ),
                  ],
                ]),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    gp2.postGameInsight.isEmpty
                        ? 'Play more moves to get analysis.'
                        : gp2.postGameInsight,
                    key: ValueKey(gp2.postGameInsight),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
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

  Widget _statRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        Text(value,
            style:
                TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    );
  }

  void _handleTimeout(GameProvider gp) {
    if (_resultShown) return;
    _gameFinished = true;
    _resultShown = true;
    gp.loadPostGameInsight();
    _showResultDialog(gp, won: false, reason: "Time's up!");
  }
}
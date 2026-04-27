// lib/screens/multiplayer_screen.dart
// Same-device pass-and-play multiplayer — Turn-based & Race modes.
// No Firebase / network needed.
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../services/ai_service.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';

// ─── Setup ────────────────────────────────────────────────────────────────────

class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {
  final _p1Ctrl = TextEditingController(text: 'Player 1');
  final _p2Ctrl = TextEditingController(text: 'Player 2');
  _MPMode _mode = _MPMode.turnBased;

  @override
  void dispose() { _p1Ctrl.dispose(); _p2Ctrl.dispose(); super.dispose(); }

  void _start() {
    final hidden = GameService().generateHiddenSequence();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => _MPRound(
        mode: _mode,
        hidden: hidden,
        p1: _p1Ctrl.text.trim().isEmpty ? 'Player 1' : _p1Ctrl.text.trim(),
        p2: _p2Ctrl.text.trim().isEmpty ? 'Player 2' : _p2Ctrl.text.trim(),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09111F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF09111F), Color(0xFF10283D), Color(0xFF183948)]),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
                    onPressed: () => Navigator.pop(context)),
                const Text('MULTIPLAYER', style: TextStyle(color: Color(0xFF6DD3FF), fontSize: 20,
                    fontWeight: FontWeight.bold, letterSpacing: 2,
                  shadows: [Shadow(color: Color(0xFF6DD3FF), blurRadius: 10)])),
              ]),
              const SizedBox(height: 28),
              _sectionLabel('SELECT MODE'),
              const SizedBox(height: 10),
              Row(children: [
                _modeCard('🔄', 'TURN BASED', 'Take turns.\nFewest moves wins.', _MPMode.turnBased),
                const SizedBox(width: 12),
                _modeCard('⚡', 'RACE', 'Same puzzle.\nFastest time wins.', _MPMode.race),
              ]),
              const SizedBox(height: 24),
              _sectionLabel('PLAYER NAMES'),
              const SizedBox(height: 10),
              _nameField(_p1Ctrl, 'Player 1', const Color(0xFF6DD3FF)),
              const SizedBox(height: 10),
              _nameField(_p2Ctrl, 'Player 2', const Color(0xFFFFA15E)),
              const SizedBox(height: 24),
              _infoCard(),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _start,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFA15E), Color(0xFFD46A2F)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: const Color(0xFFFFA15E).withValues(alpha: 0.4),
                        blurRadius: 20, offset: const Offset(0, 6))],
                  ),
                  child: const Center(child: Text('START MATCH',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900,
                        fontSize: 18, letterSpacing: 3))),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) => Text(t, style: const TextStyle(
      color: Colors.white38, fontSize: 11, letterSpacing: 3, fontWeight: FontWeight.bold));

  Widget _modeCard(String icon, String title, String sub, _MPMode m) {
    final sel = _mode == m;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _mode = m),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel
              ? const Color(0xFFFFA15E).withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sel ? const Color(0xFFFFA15E) : Colors.white24,
            width: sel ? 1.5 : 1,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: sel ? const Color(0xFFFFC37A) : Colors.white70,
              fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11, height: 1.4)),
        ]),
      ),
    ));
  }

  Widget _nameField(TextEditingController c, String label, Color color) => TextField(
    controller: c,
    style: TextStyle(color: color, fontWeight: FontWeight.bold),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 12),
      filled: true, fillColor: Colors.white.withValues(alpha: 0.06),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 1.5)),
      prefixIcon: Icon(Icons.person_outline, color: color.withValues(alpha: 0.6), size: 18),
    ),
  );

  Widget _infoCard() {
    final isTurn = _mode == _MPMode.turnBased;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFA15E).withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(isTurn ? '🔄  HOW TURN-BASED WORKS' : '⚡  HOW RACE MODE WORKS',
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold,
              fontSize: 12, letterSpacing: 1)),
        const SizedBox(height: 8),
        Text(
          isTurn
              ? 'Player 1 plays first (4 min · 10 moves), then hands the device to Player 2. '
                'Both solve the SAME hidden sequence. Fewer moves wins. If neither solves it, higher match score wins.'
              : 'Player 1 plays and their time is recorded. Player 2 solves the same sequence. '
                'Fastest solve wins. 10 moves max · 4 min limit. Each color appears exactly once.',
          style: const TextStyle(color: Colors.white38, fontSize: 12, height: 1.5),
        ),
      ]),
    );
  }
}

// ─── Shared types ─────────────────────────────────────────────────────────────

enum _MPMode { turnBased, race }

class _Result {
  final String name;
  final bool solved;
  final int moves;
  final int bestMatch;
  final int secs;
  const _Result({required this.name, required this.solved,
      required this.moves, required this.bestMatch, required this.secs});

  bool beats(_Result o) {
    if (solved && !o.solved) return true;
    if (!solved && o.solved) return false;
    if (solved && o.solved) {
      return moves < o.moves || (moves == o.moves && secs < o.secs);
    }
    return bestMatch > o.bestMatch;
  }
}

// ─── Orchestrator ─────────────────────────────────────────────────────────────

class _MPRound extends StatefulWidget {
  final _MPMode mode;
  final List<Bottle> hidden;
  final String p1, p2;
  const _MPRound({required this.mode, required this.hidden, required this.p1, required this.p2});

  @override
  State<_MPRound> createState() => _MPRoundState();
}

class _MPRoundState extends State<_MPRound> {
  int _phase = 0;
  _Result? _r1, _r2;

  @override
  Widget build(BuildContext context) {
    if (_phase == 3) {
      return _ResultsScreen(
        r1: _r1!,
        r2: _r2!,
        onPlayAgain: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MultiplayerScreen()),
        ),
        onHome: () => Navigator.popUntil(context, (r) => r.isFirst),
      );
    }

    if (_phase == 1) {
      return _HandoffScreen(
        done: widget.p1,
        next: widget.p2,
        r1: _r1!,
        mode: widget.mode,
        onReady: () => setState(() => _phase = 2),
      );
    }

    final isP1 = _phase == 0;
    return _ActiveGame(
      name: isP1 ? widget.p1 : widget.p2,
      color: isP1 ? Colors.cyan : Colors.orange,
      hidden: widget.hidden,
      mode: widget.mode,
      onDone: (r) {
        if (isP1) { _r1 = r; setState(() => _phase = 1); }
        else       { _r2 = r; setState(() => _phase = 3); }
      },
    );
  }
}

// ─── One player's turn ────────────────────────────────────────────────────────

class _ActiveGame extends StatefulWidget {
  final String name;
  final Color color;
  final List<Bottle> hidden;
  final _MPMode mode;
  final void Function(_Result) onDone;
  const _ActiveGame({required this.name, required this.color, required this.hidden,
      required this.mode, required this.onDone});

  @override
  State<_ActiveGame> createState() => _ActiveGameState();
}

class _ActiveGameState extends State<_ActiveGame> {
  // Multiplayer uses Standard pacing — fair for both players on the same device
  static const _maxMoves = AppConstants.standardModeMaxMoves; // 10
  static const _timeLimit = AppConstants.standardModeTime;    // 240s = 4 min

  final _gs = GameService();
  final _ai = AIService();

  int get _sequenceLength => widget.hidden.length;

  late List<Bottle?> _guess;
  bool _submitting = false;
  int _moves = 0;
  int? _lastMatch;
  String _hint = '';
  bool _done = false;
  bool _resultShown = false;
  final List<Attempt> _history = [];

  Timer? _timer;
  int _secs = 0;

  @override
  void initState() {
    super.initState();
    _guess = List<Bottle?>.filled(_sequenceLength, null);
    // Both modes use a timer:
    // Race  — counts UP   (fastest solver wins)
    // Turn  — counts DOWN (auto-ends turn at time limit so no one stalls)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secs++);
      // Turn-based: auto-submit when time runs out
      if (widget.mode == _MPMode.turnBased && _secs >= _timeLimit && !_done) {
        _timeOut();
      }
    });
  }

  void _timeOut() {
    if (_done || _resultShown) return;
    _timer?.cancel();
    _done = true;
    _resultShown = true;
    final best = _history.isEmpty ? 0 : _history.map((a) => a.matches).reduce((a,b) => a>b?a:b);
    widget.onDone(_Result(
      name: widget.name,
      solved: false,
      moves: _moves,
      bestMatch: best,
      secs: _secs,
    ));
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  bool get _canSubmit => _gs.isValidGuess(_guess) && !_submitting && !_done;
  bool get _allFilled => !_guess.contains(null);
  bool get _hasDup => false; // Bottles can't be duplicated since we only have unique ones

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() { _submitting = true; _hint = ''; });
    await Future.delayed(const Duration(milliseconds: 300));

    final prev = _history.isNotEmpty ? _history.last.guess : _guess;
    final changed = _gs.calculateVariablesChanged(prev, _guess);
    final matches = _gs.calculateMatches(_guess, widget.hidden);
    final prevM = _history.isNotEmpty ? _history.last.matches : 0;

    final attempt = Attempt(
      attemptNumber: _moves + 1,
      guess: List.from(_guess),
      matches: matches,
      matchedPositions: const [],
      timestamp: DateTime.now(),
      variablesChanged: changed,
      wasImpulsive: _gs.isImpulsiveMove(changed, prevM, matches),
    );
    _history.add(attempt);
    _moves++;

    final hint = _ai.getRealTimeHint(attempt, _moves);
    final solved = matches == _sequenceLength;
    final out = _moves >= _maxMoves || (widget.mode == _MPMode.turnBased && _secs >= _timeLimit);

    setState(() {
      _lastMatch = matches;
      _hint = hint;
      _submitting = false;
      _done = solved || out;
    });

    if (_done && !_resultShown) {
      _resultShown = true;
      _timer?.cancel();
      await Future.delayed(const Duration(milliseconds: 500));
      widget.onDone(_Result(
        name: widget.name,
        solved: solved,
        moves: _moves,
        bestMatch: _history.map((a) => a.matches).reduce(max),
        secs: _secs,
      ));
    }
  }

  void _pick(int i, Bottle b) {
    if (_done || _submitting) return;
    setState(() => _guess[i] = b);
  }

  void _showPicker(int i) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a3a),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose a color for bottle ${i + 1}',
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Each color can only be used once.',
                style: TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 16),
            Wrap(spacing: 12, runSpacing: 12,
              children: AppConstants.availableColors.asMap().entries.map((e) {
                final color = e.value;
                final bottle = Bottle(id: 'mp_${i}_${e.key}', color: color, position: i);
                final used = _guess.any((b) => b?.color == color) && _guess[i]?.color != color;
                return GestureDetector(
                  onTap: used ? null : () { _pick(i, bottle); Navigator.pop(context); },
                  child: Opacity(
                    opacity: used ? 0.25 : 1.0,
                    child: Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: used ? const Icon(Icons.block, color: Colors.white54, size: 20) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF09111F), Color(0xFF10283D), Color(0xFF183948)]),
        ),
        child: SafeArea(child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: widget.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: widget.color.withValues(alpha: 0.5))),
                child: Row(children: [
                  Icon(Icons.person, color: widget.color, size: 16),
                  const SizedBox(width: 6),
                  Text(widget.name.toUpperCase(), style: TextStyle(color: widget.color,
                      fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                ]),
              ),
              const Spacer(),
              if (widget.mode == _MPMode.race)
                _chip('⏱ ${_secs ~/ 60}:${(_secs % 60).toString().padLeft(2, "0")}', widget.color)
              else
                _chip('$_moves / $_maxMoves moves', Colors.white54),
            ]),
          ),

          const SizedBox(height: 10),

          // Match feedback
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(
              _lastMatch == null
                  ? 'Tap each bottle to assign a color. Every color is used exactly once.'
                  : _lastMatch == _sequenceLength
                      ? '🎉 All $_sequenceLength bottles matched!'
                      : '$_lastMatch / $_sequenceLength correct matches',
              style: TextStyle(
                color: _lastMatch == null ? Colors.white38
                    : _lastMatch == _sequenceLength ? const Color(0xFF56D676)
                    : _lastMatch! > 0 ? const Color(0xFF56D676) : const Color(0xFFFFA15E),
                fontSize: 13),
              textAlign: TextAlign.center,
            )),
          ),

          if (_hint.isNotEmpty) Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF6DD3FF).withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF6DD3FF).withValues(alpha: 0.25))),
              child: Row(children: [
                const Icon(Icons.psychology_outlined, color: Color(0xFF6DD3FF), size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(_hint,
                    style: const TextStyle(color: Color(0xFF6DD3FF), fontSize: 12))),
              ]),
            ),
          ),

          if (_hasDup) Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFFFA15E).withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFA15E).withValues(alpha: 0.4))),
              child: const Row(children: [
                Icon(Icons.warning_amber_outlined, color: Color(0xFFFFA15E), size: 16),
                SizedBox(width: 8),
                Expanded(child: Text('Duplicate color! Each color can only be used once.',
                    style: TextStyle(color: Color(0xFFFFA15E), fontSize: 12))),
              ]),
            ),
          ),

          const SizedBox(height: 10),

          // Bottle grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, crossAxisSpacing: 10,
                    mainAxisSpacing: 10, childAspectRatio: 0.8),
                itemCount: _sequenceLength,
                itemBuilder: (_, i) {
                  final b = _guess[i];
                  final isEmpty = b == null;
                  final c = b?.color;
                  return GestureDetector(
                    onTap: (_done || _submitting) ? null : () => _showPicker(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isEmpty ? Colors.white.withValues(alpha: 0.08) : c,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isEmpty ? Colors.white24 : Colors.white38,
                          width: isEmpty ? 1 : 2,
                        ),
                      ),
                      child: Stack(alignment: Alignment.center, children: [
                        Center(child: isEmpty
                            ? const Icon(Icons.add, color: Colors.white30, size: 28)
                            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(AppConstants.getColorName(c!),
                                    style: const TextStyle(color: Colors.white,
                                        fontSize: 10, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center),
                              ])),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ),

          // History strip — shows colored bottles with match indicators
          if (_history.isNotEmpty) SizedBox(
            height: 60,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _history.length,
              reverse: true, // newest first
              itemBuilder: (_, i) {
                final a = _history[_history.length - 1 - i];
                final ratio = a.matches / _sequenceLength;
                final col = ratio == 1.0 ? Colors.greenAccent
                    : ratio >= 0.5 ? Colors.cyan : Colors.orange;
                return Opacity(
                  opacity: i == 0 ? 1.0 : 0.4,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      Text('#${a.attemptNumber}',
                          style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      ...List.generate(_sequenceLength, (idx) {
                        final bottle = a.guess[idx];
                        final bottleColor = bottle?.color ?? Colors.grey;
                        return Container(
                          width: 18, height: 22,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: bottleColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      Text('${a.matches}/$_sequenceLength',
                          style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                );
              },
            ),
          ),

          // Submit
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: ElevatedButton(
              onPressed: _canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                disabledBackgroundColor: Colors.white12,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      !_allFilled ? 'Fill all $_sequenceLength bottles first'
                          : _hasDup ? 'Fix duplicate colors'
                          : _done ? '✓ Done'
                          : 'SUBMIT GUESS',
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
            ),
          ),
        ])),
      ),
    );
  }

  Widget _chip(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.4))),
    child: Text(t, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 13)),
  );
}

// ─── Handoff screen ───────────────────────────────────────────────────────────

class _HandoffScreen extends StatelessWidget {
  final String done, next;
  final _Result r1;
  final _MPMode mode;
  final VoidCallback onReady;
  const _HandoffScreen({required this.done, required this.next, required this.r1,
      required this.mode, required this.onReady});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF09111F), Color(0xFF10283D), Color(0xFF183948)])),
      child: SafeArea(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('📱', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          const Text('HAND THE DEVICE TO',
              style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 3)),
          const SizedBox(height: 8),
            Text(next.toUpperCase(), style: const TextStyle(color: Color(0xFFFFA15E), fontSize: 34,
              fontWeight: FontWeight.w900, letterSpacing: 2,
              shadows: [Shadow(color: Color(0xFFFFA15E), blurRadius: 16)])),
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF6DD3FF).withValues(alpha: 0.25))),
            child: Column(children: [
              Text("$done's result",
                  style: const TextStyle(color: Color(0xFF6DD3FF), fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _stat('STATUS', r1.solved ? '✅ Solved' : '❌ Failed',
                    r1.solved ? Colors.greenAccent : Colors.redAccent),
                _stat('MOVES', '${r1.moves}', const Color(0xFF6DD3FF)),
                if (mode == _MPMode.race)
                  _stat('TIME', '${r1.secs}s', const Color(0xFFFFA15E)),
                _stat('BEST', '${r1.bestMatch}', Colors.white70),
              ]),
            ]),
          ),
          const SizedBox(height: 28),
          const Text('Same hidden sequence awaits.\nGood luck!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.5)),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: onReady,
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFA15E), Color(0xFFD46A2F)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text('${next.toUpperCase()} — I\'M READY!',
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2))),
            ),
          ),
        ]),
      )),
    ));
  }

  Widget _stat(String l, String v, Color c) => Column(children: [
    Text(l, style: TextStyle(color: c.withValues(alpha: 0.6), fontSize: 9, letterSpacing: 2)),
    const SizedBox(height: 4),
    Text(v, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 13)),
  ]);
}

// ─── Results ──────────────────────────────────────────────────────────────────

class _ResultsScreen extends StatelessWidget {
  final _Result r1, r2;
  final VoidCallback onPlayAgain, onHome;
  const _ResultsScreen({required this.r1, required this.r2,
      required this.onPlayAgain, required this.onHome});

  @override
  Widget build(BuildContext context) {
    final p1w = r1.beats(r2), p2w = r2.beats(r1);
    final tie = !p1w && !p2w;
    return Scaffold(body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF09111F), Color(0xFF10283D), Color(0xFF183948)])),
      child: SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 20),
          Text(tie ? '🤝' : '🏆', style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(tie ? "IT'S A TIE!" : '${(p1w ? r1 : r2).name.toUpperCase()} WINS!',
            style: TextStyle(color: tie ? Colors.white70 : const Color(0xFFFFC37A),
                fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2,
                shadows: [Shadow(color: tie ? Colors.white30 : const Color(0xFFFFC37A), blurRadius: 16)])),
          const SizedBox(height: 32),
          Row(children: [
            _card(r1, p1w && !tie, const Color(0xFF6DD3FF)),
            const SizedBox(width: 12),
            _card(r2, p2w && !tie, const Color(0xFFFFA15E)),
          ]),
          const Spacer(),
          ElevatedButton(onPressed: onPlayAgain,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFA15E),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('PLAY AGAIN',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2))),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onHome,
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white54,
                side: const BorderSide(color: Colors.white24),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('BACK TO HOME')),
        ]),
      )),
    ));
  }

  Widget _card(_Result r, bool winner, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: winner ? c.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: winner ? c : Colors.white24, width: winner ? 2 : 1),
        boxShadow: winner ? [BoxShadow(color: c.withValues(alpha: 0.25), blurRadius: 16)] : null,
    ),
    child: Column(children: [
      if (winner) const Text('👑', style: TextStyle(fontSize: 22)),
      Text(r.name, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(height: 10),
      _row('Status', r.solved ? '✅' : '❌', c),
      _row('Moves', '${r.moves}', c),
      _row('Best', '${r.bestMatch}', c),
      _row('Time', '${r.secs}s', c),
    ]),
  ));

  Widget _row(String l, String v, Color c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: TextStyle(color: c.withValues(alpha: 0.5), fontSize: 10, letterSpacing: 1)),
      Text(v, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 12)),
    ]),
  );
}
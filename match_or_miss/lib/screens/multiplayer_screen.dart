// lib/screens/multiplayer_screen.dart
// Premium multiplayer experience: Turn-based & Race modes with smooth UX
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../services/ai_service.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';
import '../widgets/bottle_widget.dart';

enum _MPMode { turnBased, race }

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
  void dispose() {
    _p1Ctrl.dispose();
    _p2Ctrl.dispose();
    super.dispose();
  }

  void _start() {
    final hidden = GameService().generateHiddenSequence();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _MPRound(
          mode: _mode,
          hidden: hidden,
          p1: _p1Ctrl.text.trim().isEmpty ? 'Player 1' : _p1Ctrl.text.trim(),
          p2: _p2Ctrl.text.trim().isEmpty ? 'Player 2' : _p2Ctrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxContentWidth = width > 1200 ? 920.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF3D4),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFBF3D4), Color(0xFFF1D8B8), Color(0xFFDBE9C0)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Color(0xFF6B5A72), size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'MULTIPLAYER',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFC5A7CD),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _buildLabel('SELECT MODE'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildModeCard('\ud83d\udd04', 'TURN BASED',
                            'Take turns solving the same puzzle. Fewer moves wins.',
                            _MPMode.turnBased),
                        const SizedBox(width: 12),
                        _buildModeCard('\u26a1', 'RACE',
                            'Same puzzle, different times. Fastest solver wins.',
                            _MPMode.race),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _buildLabel('PLAYER NAMES'),
                    const SizedBox(height: 12),
                    _buildPlayerField(_p1Ctrl, 'Player 1', const Color(0xFF6DD3FF),
                        Icons.person_outline),
                    const SizedBox(height: 10),
                    _buildPlayerField(_p2Ctrl, 'Player 2', const Color(0xFFFFA15E),
                        Icons.person_outline),
                    const SizedBox(height: 28),
                    _buildInfoBox(),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: _start,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFA15E), Color(0xFFD46A2F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFA15E).withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: const Center(
                          child: Text('START MATCH',
                              style: TextStyle(
                                color: Color(0xFF4A3856),
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: 3,
                              )),
                        ),
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

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFF6B5A72),
      fontSize: 11,
      letterSpacing: 3,
      fontWeight: FontWeight.bold,
    ),
  );

  Widget _buildModeCard(
      String icon, String title, String desc, _MPMode mode) {
    final isSelected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFC5A7CD).withValues(alpha: 0.2)
                : const Color(0xFFC5A7CD).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFFC5A7CD) : const Color(0xFFC5A7CD).withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFC5A7CD)
                      : const Color(0xFF6B5A72),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                  color: Color(0xFF9B8AA3),
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerField(TextEditingController ctrl, String label,
      Color color, IconData icon) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 12),
        filled: true,
        fillColor: const Color(0xFFC5A7CD).withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
        prefixIcon: Icon(icon, color: color.withValues(alpha: 0.6), size: 18),
      ),
    );
  }

  Widget _buildInfoBox() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFFFA15E).withValues(alpha: 0.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _mode == _MPMode.turnBased
              ? '\ud83d\udd04  HOW TURN-BASED WORKS'
              : '\u26a1  HOW RACE MODE WORKS',
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _mode == _MPMode.turnBased
              ? 'Players alternate solving the SAME hidden sequence. Player 1 goes first (4 min, 10 moves). Then Player 2. Fewer moves = victory. Match score breaks ties.'
              : 'Both players solve the same sequence. Player 1\'s time is recorded, then Player 2 races. Fastest solver wins. 10 moves max, 4 min limit.',
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

class _MPRound extends StatefulWidget {
  final _MPMode mode;
  final List<Bottle> hidden;
  final String p1, p2;
  const _MPRound({
    required this.mode,
    required this.hidden,
    required this.p1,
    required this.p2,
  });

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
        mode: widget.mode,
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
      color: isP1 ? const Color(0xFF6DD3FF) : const Color(0xFFFFA15E),
      hidden: widget.hidden,
      mode: widget.mode,
      onDone: (r) {
        if (isP1) {
          _r1 = r;
          setState(() => _phase = 1);
        } else {
          _r2 = r;
          setState(() => _phase = 3);
        }
      },
    );
  }
}

class _Result {
  final String name;
  final bool solved;
  final int moves;
  final int bestMatch;
  final int secs;
  const _Result({
    required this.name,
    required this.solved,
    required this.moves,
    required this.bestMatch,
    required this.secs,
  });

  bool beats(_Result o) {
    if (solved && !o.solved) return true;
    if (!solved && o.solved) return false;
    if (solved && o.solved) {
      return moves < o.moves || (moves == o.moves && secs < o.secs);
    }
    return bestMatch > o.bestMatch;
  }
}

class _ActiveGame extends StatefulWidget {
  final String name;
  final Color color;
  final List<Bottle> hidden;
  final _MPMode mode;
  final void Function(_Result) onDone;
  const _ActiveGame({
    required this.name,
    required this.color,
    required this.hidden,
    required this.mode,
    required this.onDone,
  });

  @override
  State<_ActiveGame> createState() => _ActiveGameState();
}

class _ActiveGameState extends State<_ActiveGame> {
  static const _maxMoves = AppConstants.standardModeMaxMoves;
  static const _timeLimit = AppConstants.standardModeTime;

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
    _guess = List<Bottle?>.filled(widget.hidden.length, null, growable: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secs++);
      if (widget.mode == _MPMode.turnBased &&
          _secs >= _timeLimit &&
          !_done) {
        _timeOut();
      }
    });
  }

  void _timeOut() {
    if (_done || _resultShown) return;
    _timer?.cancel();
    _done = true;
    _resultShown = true;
    final best = _history.isEmpty
        ? 0
        : _history.map((a) => a.matches).reduce((a, b) => a > b ? a : b);
    widget.onDone(_Result(
      name: widget.name,
      solved: false,
      moves: _moves,
      bestMatch: best,
      secs: _secs,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _canSubmit => _gs.isValidGuess(_guess) && !_submitting && !_done;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _submitting = true;
      _hint = '';
    });
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
    final out = _moves >= _maxMoves ||
        (widget.mode == _MPMode.turnBased && _secs >= _timeLimit);

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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxContentWidth = width > 1200 ? 980.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFF09111F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF09111F), Color(0xFF10283D), Color(0xFF183948)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: widget.color.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person, color: widget.color, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                widget.name.toUpperCase(),
                                style: TextStyle(
                                  color: widget.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (widget.mode == _MPMode.race)
                          _buildChip(
                            '\u23f1 ${_secs ~/ 60}:${(_secs % 60).toString().padLeft(2, "0")}',
                            widget.color,
                          )
                        else
                          _buildChip('$_moves / $_maxMoves moves', const Color(0xFFC5A7CD)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _lastMatch == null
                              ? 'Assign all colors to the bottles (each used once)'
                              : _lastMatch == _sequenceLength
                                  ? '\ud83c\udf89 Perfect! All $_sequenceLength matches!'
                                  : '$_lastMatch / $_sequenceLength matches correct',
                          style: TextStyle(
                            color: _lastMatch == null
                                ? Colors.white38
                                : _lastMatch == _sequenceLength
                                    ? const Color(0xFF56D676)
                                    : _lastMatch! > 0
                                        ? const Color(0xFF61B8FF)
                                        : const Color(0xFFFFA15E),
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  if (_hint.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6DD3FF).withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF6DD3FF).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.psychology_outlined,
                                color: Color(0xFF6DD3FF), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_hint,
                                  style: const TextStyle(
                                    color: Color(0xFF6DD3FF),
                                    fontSize: 12,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final screenWidth = MediaQuery.of(context).size.width;
                          const spacing = 10.0;
                          final gridWidth = constraints.maxWidth;
                          final cellWidth = (gridWidth - (3 * spacing)) / 4;
                          final scale = screenWidth <= 430
                              ? 0.34
                              : screenWidth <= 560
                                  ? 0.39
                                  : 0.46;
                          final bottleSize = (cellWidth * scale).clamp(24.0, 74.0);

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: spacing,
                              mainAxisSpacing: spacing,
                              childAspectRatio: 0.62,
                            ),
                            itemCount: _sequenceLength,
                            itemBuilder: (_, i) {
                              final b = _guess[i];
                              return GestureDetector(
                                onTap: (_done || _submitting)
                                    ? null
                                    : () => _showColorPicker(i),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: b == null
                                          ? [
                                              Colors.white.withValues(alpha: 0.08),
                                              const Color(0xFF6DD3FF).withValues(alpha: 0.04),
                                            ]
                                          : [
                                              b.color.withValues(alpha: 0.12),
                                              Colors.white.withValues(alpha: 0.03),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: b == null ? Colors.white24 : Colors.white38,
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: b == null
                                            ? const Color(0xFF6DD3FF).withValues(alpha: 0.10)
                                            : b.color.withValues(alpha: 0.22),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned.fill(
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(14),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.white.withValues(alpha: 0.10),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (b == null)
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.add_circle_outline,
                                                color: Colors.white30, size: 26),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Slot ${i + 1}',
                                              style: const TextStyle(
                                                color: Colors.white30,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        BottleWidget(
                                          bottle: b,
                                          size: bottleSize,
                                          isDragging: false,
                                        ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black.withValues(alpha: 0.45),
                                            border: Border.all(color: Colors.white24),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${i + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_history.isNotEmpty)
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _history.length,
                        reverse: true,
                        itemBuilder: (_, idx) {
                          final i = _history.length - 1 - idx;
                          final a = _history[i];
                          final ratio = a.matches / _sequenceLength;
                          final color = ratio == 1.0
                              ? Colors.greenAccent
                              : ratio >= 0.5
                                  ? Colors.cyan
                                  : Colors.orange;
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: color.withValues(alpha: 0.3)),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('M${a.attemptNumber}',
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  Text('${a.matches}/$_sequenceLength',
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: _canSubmit ? _submit : null,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: _canSubmit
                              ? LinearGradient(
                                  colors: [
                                    widget.color,
                                    widget.color.withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.1),
                                    Colors.white.withValues(alpha: 0.05),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _canSubmit
                              ? [
                                  BoxShadow(
                                    color: widget.color.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            _submitting ? 'Checking...' : 'SUBMIT GUESS',
                            style: TextStyle(
                              color: _canSubmit ? Colors.white : Colors.white38,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(int i) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF172534),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose color for position ${i + 1}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 4),
            const Text('Each color used exactly once.',
                style: TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppConstants.availableColors.asMap().entries.map((e) {
                final color = e.value;
                final bottle = Bottle(id: 'mp_${i}_${e.key}', color: color, position: i);
                final used = _guess.any((b) => b?.color == color) &&
                    _guess[i]?.color != color;
                return GestureDetector(
                  onTap: used
                      ? null
                      : () {
                          _pick(i, bottle);
                          Navigator.pop(context);
                        },
                  child: Opacity(
                    opacity: used ? 0.25 : 1.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        BottleWidget(
                          bottle: bottle,
                          size: 40,
                          isDragging: false,
                        ),
                        if (used)
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.35),
                            ),
                            child: const Icon(Icons.block, color: Colors.white54, size: 20),
                          ),
                      ],
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

  Widget _buildChip(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}

class _HandoffScreen extends StatelessWidget {
  final String done, next;
  final _Result r1;
  final _MPMode mode;
  final VoidCallback onReady;
  const _HandoffScreen({
    required this.done,
    required this.next,
    required this.r1,
    required this.mode,
    required this.onReady,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxContentWidth = width > 1200 ? 920.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFF09111F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF09111F), Color(0xFF10283D), Color(0xFF183948)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF56D676), Color(0xFF3AA05B)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF56D676).withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                Text(
                  '${done.toUpperCase()} FINISHED',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Moves: ${r1.moves} | Best Match: ${r1.bestMatch} | Time: ${r1.secs}s',
                  style: const TextStyle(color: Color(0xFF6B5A72), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.back_hand_outlined,
                          color: Color(0xFFFFA15E), size: 40),
                      const SizedBox(height: 16),
                      Text(
                        '${next.toUpperCase()}, IT\'S YOUR TURN!',
                        style: const TextStyle(
                          color: Color(0xFFFFA15E),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Get ready to solve the same puzzle.',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: onReady,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFA15E), Color(0xFFD46A2F)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'READY TO PLAY',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultsScreen extends StatelessWidget {
  final _Result r1, r2;
  final _MPMode mode;
  final VoidCallback onPlayAgain, onHome;
  const _ResultsScreen({
    required this.r1,
    required this.r2,
    required this.mode,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxContentWidth = width > 1200 ? 920.0 : double.infinity;

    final p1Wins = r1.beats(r2);
    final p2Wins = r2.beats(r1);
    final isTie = !p1Wins && !p2Wins;

    return Scaffold(
      backgroundColor: const Color(0xFF09111F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF09111F), Color(0xFF10283D), Color(0xFF183948)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                const SizedBox(height: 12),
                Text(
                  isTie ? '\ud83e\udd1d' : '\ud83c\udfc6',
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 16),
                Text(
                  isTie
                      ? "IT'S A TIE!"
                      : '${(p1Wins ? r1 : r2).name.toUpperCase()} WINS!',
                  style: TextStyle(
                    color: isTie ? Colors.white70 : const Color(0xFFFFC37A),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: isTie
                            ? Colors.white30
                            : const Color(0xFFFFC37A).withValues(alpha: 0.4),
                        blurRadius: 16,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    _buildResultCard(r1, p1Wins && !isTie, const Color(0xFF6DD3FF)),
                    const SizedBox(width: 12),
                    _buildResultCard(r2, p2Wins && !isTie, const Color(0xFFFFA15E)),
                  ],
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: onPlayAgain,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFA15E), Color(0xFFD46A2F)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'PLAY AGAIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onHome,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white54,
                    side: const BorderSide(color: Colors.white24),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('BACK TO HOME'),
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

  Widget _buildResultCard(_Result r, bool winner, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: winner ? color.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: winner ? color : Colors.white24,
            width: winner ? 2 : 1,
          ),
          boxShadow: winner
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            if (winner) const Text('\ud83d\udc51', style: TextStyle(fontSize: 22)),
            Text(
              r.name,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            _buildStat('Status', r.solved ? '\u2705 Solved' : '\u274c Timeout', color),
            const SizedBox(height: 6),
            _buildStat('Moves', '${r.moves}', color),
            const SizedBox(height: 6),
            _buildStat('Best Match', '${r.bestMatch}', color),
            const SizedBox(height: 6),
            _buildStat('Time', '${r.secs}s', color),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.5),
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

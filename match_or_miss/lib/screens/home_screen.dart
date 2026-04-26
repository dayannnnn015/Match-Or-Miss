// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import 'game_screen_with_ai.dart';
import 'multiplayer_screen.dart';
import 'analysis_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0a0a2a), Color(0xFF1a0033), Color(0xFF002244)],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _buildHeader(context),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTitle(),
                      const SizedBox(height: 50),
                      _buildGameModes(context),
                      const SizedBox(height: 30),
                      _buildMultiplayerButton(context),
                      const SizedBox(height: 20),
                      _buildAnalysisButton(context),
                      const SizedBox(height: 20),
                      _buildSettingsButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettingsDialog(context),
          ),
          const Text('MATCH OR MISS',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                letterSpacing: 2, color: Colors.cyan,
                shadows: [Shadow(color: Colors.cyan, blurRadius: 10)])),
          IconButton(
            icon: const Icon(Icons.leaderboard, color: Colors.white),
            onPressed: () => _showLeaderboard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [Colors.cyan.withValues(alpha: 0.3), Colors.transparent])),
        child: const Icon(Icons.psychology, size: 80, color: Colors.cyan),
      ),
      const SizedBox(height: 20),
      const Text('Train Your Brain',
          style: const TextStyle(fontSize: 16, color: Colors.white70, letterSpacing: 1)),
    ]);
  }

  Widget _buildGameModes(BuildContext context) {
    return Column(children: [
      _buildModeCard(context, 'QUICK MODE', 'No Time Limit',
          'Relaxed — player-paced, align all bottles to start', Colors.green, GameMode.quick),
      const SizedBox(height: 15),
      _buildModeCard(context, 'STANDARD MODE', '4 Min Stopwatch • 10 Moves',
          'Balanced — timed challenge with strategy', Colors.blue, GameMode.standard),
      const SizedBox(height: 15),
      _buildModeCard(context, 'COMPETITIVE MODE', '3 Min • Custom Moves',
          'Max pressure — you choose your move limit', Colors.orange, GameMode.competitive),
    ]);
  }

  Widget _buildModeCard(BuildContext context, String title, String subtitle,
      String description, Color color, GameMode mode) {
    return GestureDetector(
      onTap: () {
        if (mode == GameMode.competitive) {
          _showCompetitiveMoveDialog(context);
        } else {
          Provider.of<GameProvider>(context, listen: false).initializeGame(mode);
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const GameScreenWithAI()));
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 2)],
        ),
        child: Row(children: [
          Container(width: 60, height: 60,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(_getModeIcon(mode), color: Colors.white, size: 30)),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 5),
            Text(subtitle, style: const TextStyle(color: Colors.white70)),
            Text(description, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ])),
          Icon(Icons.arrow_forward, color: color),
        ]),
      ),
    );
  }

  IconData _getModeIcon(GameMode mode) {
    switch (mode) {
      case GameMode.quick:       return Icons.flash_on;
      case GameMode.standard:    return Icons.timer;
      case GameMode.competitive: return Icons.emoji_events;
    }
  }

  Widget _buildMultiplayerButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const MultiplayerScreen())),
      icon: const Icon(Icons.people),
      label: const Text('PLAY MULTIPLAYER'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildAnalysisButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AnalysisScreen())),
      icon: const Icon(Icons.analytics),
      label: const Text('VIEW ANALYSIS'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.cyan,
        side: const BorderSide(color: Colors.cyan),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showSettingsDialog(context),
      icon: const Icon(Icons.settings, color: Colors.white54),
      label: const Text('Game Settings', style: TextStyle(color: Colors.white54)),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const _SettingsDialog());
  }

  void _showCompetitiveMoveDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a3a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.emoji_events, color: Colors.redAccent),
          SizedBox(width: 10),
          Text('Competitive Mode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
            'How many moves do you challenge yourself with? (5-12)',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
              hintText: '8',
              hintStyle: const TextStyle(color: Colors.white38),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              final input = controller.text.trim();
              final moves = int.tryParse(input);
              if (moves != null && moves >= 5 && moves <= 12) {
                Provider.of<GameProvider>(context, listen: false)
                    .initializeGame(GameMode.competitive, customMaxMoves: moves);
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const GameScreenWithAI()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Enter a number between 5 and 12'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('START', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLeaderboard(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a3a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.leaderboard, color: Colors.amber),
          SizedBox(width: 10),
          Text('Leaderboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Scores will appear here after completed games.',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ...List.generate(5, (i) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Text('${i + 1}', style: TextStyle(
                  color: i == 0 ? Colors.amber : Colors.white38,
                  fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 12),
              Text('Player ${i + 1}', style: const TextStyle(color: Colors.white60)),
              const Spacer(),
              Text('—', style: const TextStyle(color: Colors.white30)),
            ]),
          )),
        ]),
        actions: [TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE', style: const TextStyle(color: Colors.cyan)),
        )],
      ),
    );
  }
}

// ── Settings dialog ────────────────────────────────────────────────────────────
class _SettingsDialog extends StatefulWidget {
  const _SettingsDialog();

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  bool _sound = true;
  bool _music = false;
  bool _hints = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1a1a3a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(children: [
        Icon(Icons.settings, color: Colors.cyan),
        SizedBox(width: 10),
        Text('Game Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _toggle('Sound Effects', Icons.volume_up, _sound, (v) => setState(() => _sound = v)),
        _toggle('Background Music', Icons.music_note, _music, (v) => setState(() => _music = v)),
        _toggle('Show AI Hints', Icons.psychology, _hints, (v) => setState(() => _hints = v)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            Icon(Icons.info_outline, color: Colors.white38, size: 14),
            SizedBox(width: 8),
            Expanded(child: Text(
              'Each color appears exactly once in every puzzle. Use swap & tap to build your guess.',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            )),
          ]),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54))),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Settings saved!'),
              backgroundColor: Colors.cyan,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ));
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('SAVE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _toggle(String label, IconData icon, bool value, ValueChanged<bool> onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Icon(icon, color: Colors.cyan, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
        Switch(value: value, onChanged: onChange,
            activeThumbColor: Colors.cyan, inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white12),
      ]),
    );
  }
}
// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
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
              colors: [Colors.cyan.withOpacity(0.3), Colors.transparent])),
        child: const Icon(Icons.psychology, size: 80, color: Colors.cyan),
      ),
      const SizedBox(height: 20),
      const Text('Train Your Brain',
          style: TextStyle(fontSize: 16, color: Colors.white70, letterSpacing: 1)),
    ]);
  }

  Widget _buildGameModes(BuildContext context) {
    return Column(children: [
      _buildModeCard(context,
          'WORKING MEMORY', 'No Timer • 10 Moves',
          'Pure deduction — every move must be deliberate',
          Colors.green, GameMode.quick),
      const SizedBox(height: 15),
      _buildModeCard(context,
          'INHIBITORY CONTROL', '5 Minutes • 12 Moves',
          'Wait ≥8s before submitting — patience earns bonus points',
          Colors.blue, GameMode.standard),
      const SizedBox(height: 15),
      _buildModeCard(context,
          'COGNITIVE FLEXIBILITY', '4 Minutes • 14 Moves',
          'Puzzle shifts mid-game — detect the change and adapt',
          Colors.orange, GameMode.competitive),
    ]);
  }

  Widget _buildModeCard(BuildContext context, String title, String subtitle,
      String description, Color color, GameMode mode) {
    return GestureDetector(
      onTap: () {
        Provider.of<GameProvider>(context, listen: false).initializeGame(mode);
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const GameScreenWithAI()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [color.withOpacity(0.3), color.withOpacity(0.1)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)],
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
      case GameMode.quick:       return Icons.psychology;
      case GameMode.standard:    return Icons.self_improvement;
      case GameMode.competitive: return Icons.device_hub;
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
              style: TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ...List.generate(5, (i) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Text('${i + 1}', style: TextStyle(
                  color: i == 0 ? Colors.amber : Colors.white38,
                  fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 12),
              Text('Player ${i + 1}', style: const TextStyle(color: Colors.white60)),
              const Spacer(),
              Text('—', style: TextStyle(color: Colors.white30)),
            ]),
          )),
        ]),
        actions: [TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE', style: TextStyle(color: Colors.cyan)),
        )],
      ),
    );
  }
}

// ── Settings dialog — wired to SettingsProvider ───────────────────────────────
class _SettingsDialog extends StatelessWidget {
  const _SettingsDialog();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return AlertDialog(
      backgroundColor: const Color(0xFF1a1a3a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(children: [
        Icon(Icons.settings, color: Colors.cyan),
        SizedBox(width: 10),
        Text('Game Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _toggle(context, 'Sound Effects',    Icons.volume_up,      settings.sfxEnabled,   (v) => settings.setSfx(v)),
        _toggle(context, 'Background Music', Icons.music_note,     settings.musicEnabled, (v) => settings.setMusic(v)),
        _toggle(context, 'Show AI Hints',    Icons.psychology,     settings.hintsEnabled, (v) => settings.setHints(v)),
        const SizedBox(height: 12),
        // Volume slider
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            const Icon(Icons.volume_down, color: Colors.cyan, size: 18),
            Expanded(
              child: Slider(
                value: settings.volume,
                min: 0, max: 1,
                activeColor: Colors.cyan,
                inactiveColor: Colors.white12,
                onChanged: (v) => settings.setVolume(v),
              ),
            ),
            const Icon(Icons.volume_up, color: Colors.cyan, size: 18),
          ]),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            Icon(Icons.info_outline, color: Colors.white38, size: 14),
            SizedBox(width: 8),
            Expanded(child: Text(
              'Each color appears exactly once in every puzzle. Settings are saved automatically.',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            )),
          ]),
        ),
      ]),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('DONE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _toggle(BuildContext context, String label, IconData icon, bool value,
      void Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Icon(icon, color: Colors.cyan, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.cyan,
          inactiveThumbColor: Colors.white38,
          inactiveTrackColor: Colors.white12,
        ),
      ]),
    );
  }
}
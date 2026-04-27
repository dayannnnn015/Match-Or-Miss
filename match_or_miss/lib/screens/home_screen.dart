import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_models.dart';
import '../providers/game_provider.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/glassmorphic_widgets.dart';
import 'analysis_screen.dart';
import 'game_screen_with_ai.dart';
import 'multiplayer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heroController;
  late final Animation<double> _heroFade;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();
    _heroFade = CurvedAnimation(parent: _heroController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF09111F), Color(0xFF11243A), Color(0xFF1A3142)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _heroFade,
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                    child: Column(
                      children: [
                        _buildHeroSection(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Choose A Mode'),
                        const SizedBox(height: 10),
                        _buildModeCards(context),
                        const SizedBox(height: 18),
                        _buildSectionTitle('More Ways To Play'),
                        const SizedBox(height: 10),
                        _buildMultiplayerButton(context),
                        const SizedBox(height: 10),
                        _buildAnalysisButton(context),
                        const SizedBox(height: 10),
                        _buildSettingsButton(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => _showSettingsDialog(context),
              ),
              const Expanded(
                child: Text(
                  'MATCH OR MISS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFE9F5FF),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.leaderboard, color: Colors.white),
                onPressed: () => _showLeaderboard(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      border: Border.all(color: const Color(0xFF73C7FF).withValues(alpha: 0.3)),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.75, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (_, value, child) => Transform.scale(scale: value, child: child),
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF6DD3FF), Color(0xFF2A80C9)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6DD3FF).withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Train Your Brain',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Memorize, swap, and solve under pressure with stylish cognitive challenges.',
                  style: TextStyle(color: Colors.white70, height: 1.35, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFBED6EA),
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildModeCards(BuildContext context) {
    return Column(
      children: [
        _buildModeCard(
          context,
          icon: Icons.flash_on,
          title: 'Quick Mode',
          subtitle: 'No Time Limit',
          description: 'Relaxed and player-paced.',
          mode: GameMode.quick,
          color: const Color(0xFF56D676),
        ),
        const SizedBox(height: 10),
        _buildModeCard(
          context,
          icon: Icons.timer,
          title: 'Standard Mode',
          subtitle: '4 Minutes • 10 Moves',
          description: 'Balanced challenge with clear pressure.',
          mode: GameMode.standard,
          color: const Color(0xFF61B8FF),
        ),
        const SizedBox(height: 10),
        _buildModeCard(
          context,
          icon: Icons.emoji_events,
          title: 'Competitive Mode',
          subtitle: '3 Minutes • Your Move Limit',
          description: 'Hardcore setup for high focus players.',
          mode: GameMode.competitive,
          color: const Color(0xFFFFA15E),
        ),
      ],
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required GameMode mode,
  }) {
    return GlassmorphicCard(
      onTap: () {
        if (mode == GameMode.competitive) {
          _showCompetitiveMoveDialog(context);
          return;
        }
        Provider.of<GameProvider>(context, listen: false).initializeGame(mode);
        Navigator.push(
          context,
          SmoothPageTransition(page: const GameScreenWithAI()),
        );
      },
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      border: Border.all(color: color.withValues(alpha: 0.35)),
      boxShadow: [
        BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 14, spreadRadius: 1),
      ],
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(description, style: const TextStyle(color: Colors.white38, fontSize: 11.5)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_rounded, color: color),
        ],
      ),
    );
  }

  Widget _buildMultiplayerButton(BuildContext context) {
    return GradientButton(
      label: 'Play Multiplayer',
      gradient: const LinearGradient(
        colors: [Color(0xFFFFA15E), Color(0xFFD46A2F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      leftIcon: const Icon(Icons.groups_rounded, color: Colors.white),
      onPressed: () => Navigator.push(
        context,
        SmoothPageTransition(page: const MultiplayerScreen()),
      ),
    );
  }

  Widget _buildAnalysisButton(BuildContext context) {
    return GradientButton(
      label: 'View Analysis',
      gradient: const LinearGradient(
        colors: [Color(0xFF4CC2DB), Color(0xFF2B89BC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      leftIcon: const Icon(Icons.analytics_rounded, color: Colors.white),
      onPressed: () => Navigator.push(
        context,
        SmoothPageTransition(page: const AnalysisScreen()),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: TextButton.icon(
        onPressed: () => _showSettingsDialog(context),
        icon: const Icon(Icons.tune_rounded, color: Colors.white60),
        label: const Text('Game Settings', style: TextStyle(color: Colors.white60)),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const _SettingsDialog());
  }

  void _showCompetitiveMoveDialog(BuildContext context) {
    final controller = TextEditingController(text: '8');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF172534),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Competitive Mode', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose move limit between 5 and 12',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFA15E)),
            onPressed: () {
              final moves = int.tryParse(controller.text.trim());
              if (moves == null || moves < 5 || moves > 12) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a number from 5 to 12')),
                );
                return;
              }
              Provider.of<GameProvider>(context, listen: false)
                  .initializeGame(GameMode.competitive, customMaxMoves: moves);
              Navigator.pop(context);
              Navigator.push(
                context,
                SmoothPageTransition(page: const GameScreenWithAI()),
              );
            },
            child: const Text('Start', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLeaderboard(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF172534),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Leaderboard', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Text('${i + 1}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Player ${i + 1}', style: const TextStyle(color: Colors.white)),
                  ),
                  const Text('---', style: TextStyle(color: Colors.white38)),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

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
      backgroundColor: const Color(0xFF172534),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Game Settings', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggle('Sound Effects', Icons.volume_up, _sound, (v) => setState(() => _sound = v)),
          _toggle('Background Music', Icons.music_note, _music, (v) => setState(() => _music = v)),
          _toggle('Show AI Hints', Icons.psychology, _hints, (v) => setState(() => _hints = v)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  Widget _toggle(String label, IconData icon, bool value, ValueChanged<bool> onChange) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
        Switch(value: value, onChanged: onChange, activeColor: const Color(0xFF73C7FF)),
      ],
    );
  }
}

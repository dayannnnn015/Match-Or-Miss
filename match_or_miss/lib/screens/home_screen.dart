import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_models.dart';
import '../providers/game_provider.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/api_key_dialog.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 1200;
    final maxContentWidth = isWeb ? 900 : double.infinity;
    final horizontalPadding = isWeb ? (screenWidth - maxContentWidth) / 2 : 22.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFBF3D4), Color(0xFFF1D8B8), Color(0xFFDBE9C0)],
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
                    padding: EdgeInsets.fromLTRB(
                        horizontalPadding, 16, horizontalPadding, 24),
                    child: Column(
                      children: [
                        _buildHeroSection(),
                        const SizedBox(height: 14),
                        _buildAIStatus(context),
                        const SizedBox(height: 28),
                        _buildSectionTitle('Choose A Mode'),
                        const SizedBox(height: 12),
                        _buildModeCards(context),
                        const SizedBox(height: 24),
                        _buildSectionTitle('More Ways To Play'),
                        const SizedBox(height: 12),
                        _buildActionButtons(context),
                        const SizedBox(height: 16),
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
            color: const Color(0xFFC5A7CD).withValues(alpha: 0.15),
            border: Border(
              bottom: BorderSide(
                  color: const Color(0xFFC5A7CD).withValues(alpha: 0.2)),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.settings, color: Color(0xFF5A4B66)),
                onPressed: () => _showSettingsDialog(context),
              ),
              const Expanded(
                child: Text(
                  'MATCH OR MISS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4A3856),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.leaderboard, color: Color(0xFF5A4B66)),
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
      border: Border.all(color: const Color(0xFFC5A7CD).withValues(alpha: 0.4)),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.75, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (_, value, child) =>
                Transform.scale(scale: value, child: child),
            child: Container(
              width: 74,
              height: 74,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFFC5A7CD), Color(0xFFEEBBDD)],
                ),
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
                    color: Color(0xFF4A3856),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Memorize, swap, and solve under pressure with stylish cognitive challenges.',
                  style: TextStyle(
                      color: Color(0xFF6B5A72), height: 1.35, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIStatus(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gp, _) {
        final hasKey = gp.hasAIKey;
        return GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => const APIKeyDialog(),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasKey
                    ? [
                        const Color(0xFFDBE9C0).withValues(alpha: 0.4),
                        const Color(0xFFB7D9E2).withValues(alpha: 0.3),
                      ]
                    : [
                        const Color(0xFFEEBBDD).withValues(alpha: 0.25),
                        const Color(0xFFC5A7CD).withValues(alpha: 0.2),
                      ],
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasKey ? const Color(0xFF7A9A6C) : const Color(0xFF8B6B9E),
                width: 1.4,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasKey ? Icons.smart_toy : Icons.smart_toy_outlined,
                  color: hasKey ? const Color(0xFF7A9A6C) : const Color(0xFF8B6B9E),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasKey
                        ? 'AI Coach connected — tap to change key'
                        : 'Connect AI key for post-game insights',
                    style: TextStyle(
                      color: hasKey
                          ? const Color(0xFF5A6B4F)
                          : const Color(0xFF6B5A72),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 13,
                  color: hasKey ? const Color(0xFF7A9A6C) : const Color(0xFF8B6B9E),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF5A4B66),
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
          description: 'Adaptive sequence starting at 3 bottles.',
          mode: GameMode.quick,
          color: const Color(0xFFDBE9C0),
        ),
        const SizedBox(height: 10),
        _buildModeCard(
          context,
          icon: Icons.timer,
          title: 'Standard Mode',
          subtitle: '4 Minutes • 10 Moves',
          description: 'Balanced challenge with measured pressure.',
          mode: GameMode.standard,
          color: const Color(0xFFB7D9E2),
        ),
        const SizedBox(height: 10),
        _buildModeCard(
          context,
          icon: Icons.emoji_events,
          title: 'Competitive Mode',
          subtitle: '3 Minutes • Your Move Limit',
          description: 'Hardcore setup for high focus players.',
          mode: GameMode.competitive,
          color: const Color(0xFFEEBBDD),
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
        BoxShadow(
            color: color.withValues(alpha: 0.18), blurRadius: 14, spreadRadius: 1),
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
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFF6B5A72), fontSize: 12)),
                Text(description,
                    style: const TextStyle(
                        color: Color(0xFF9B8AA3), fontSize: 11.5)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_rounded, color: color),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        GradientButton(
          label: 'Play Multiplayer',
          gradient: const LinearGradient(
            colors: [Color(0xFFEEBBDD), Color(0xFFC5A7CD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          leftIcon: const Icon(Icons.groups_rounded, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            SmoothPageTransition(page: const MultiplayerScreen()),
          ),
        ),
        const SizedBox(height: 10),
        GradientButton(
          label: 'View Analysis',
          gradient: const LinearGradient(
            colors: [Color(0xFFB7D9E2), Color(0xFF8BBFD4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          leftIcon: const Icon(Icons.analytics_rounded, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            SmoothPageTransition(page: const AnalysisScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: TextButton.icon(
        onPressed: () => _showSettingsDialog(context),
        icon: const Icon(Icons.tune_rounded, color: Colors.white60),
        label: const Text('Game Settings',
            style: TextStyle(color: Colors.white60)),
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
        title: const Text('Competitive Mode',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose move limit between 5 and 12',
              style: TextStyle(color: Color(0xFF6B5A72)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA15E)),
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
                  Text('${i + 1}',
                      style: const TextStyle(color: Color(0xFF6B5A72))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Player ${i + 1}',
                        style: const TextStyle(color: Colors.white)),
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
            child: const Text('Close', style: TextStyle(color: Color(0xFF6B5A72))),
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
          _toggle('Sound Effects', Icons.volume_up, _sound,
              (v) => setState(() => _sound = v)),
          _toggle('Background Music', Icons.music_note, _music,
              (v) => setState(() => _music = v)),
          _toggle('Show AI Hints', Icons.psychology, _hints,
              (v) => setState(() => _hints = v)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => const APIKeyDialog(),
                );
              },
              icon: const Icon(Icons.key, color: Colors.cyan, size: 16),
              label: const Text(
                'Connect / Change AI Key',
                style: TextStyle(color: Colors.cyan, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.cyan),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
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

  Widget _toggle(String label, IconData icon, bool value,
      ValueChanged<bool> onChange) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6B5A72), size: 18),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label,
                style: const TextStyle(color: Color(0xFF6B5A72)))),
        Switch(
            value: value,
            onChanged: onChange,
            activeColor: const Color(0xFFC5A7CD)),
      ],
    );
  }
}
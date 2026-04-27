import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD

import '../models/game_models.dart';
import '../providers/game_provider.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/glassmorphic_widgets.dart';
import 'analysis_screen.dart';
=======
import '../providers/game_provider.dart';
import '../providers/ai_provider.dart';
import '../models/game_models.dart';
import '../widgets/api_key_dialog.dart';
>>>>>>> 1ac71084d222f99e5cd02ad79a657cc32c1f4c0e
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
<<<<<<< HEAD
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
=======
          const Text('MATCH OR MISS',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                  letterSpacing: 2, color: Colors.cyan,
                  shadows: [Shadow(color: Colors.cyan, blurRadius: 10)])),
          IconButton(
            icon: const Icon(Icons.leaderboard, color: Colors.white),
            onPressed: () => _showLeaderboard(context),
>>>>>>> 1ac71084d222f99e5cd02ad79a657cc32c1f4c0e
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
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
=======
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
          style: TextStyle(fontSize: 16, color: Colors.white70, letterSpacing: 1)),
    ]);
  }

  /// Shows current AI key status and a connect/change button.
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasKey
                    ? [Colors.green.withValues(alpha: 0.25), Colors.teal.withValues(alpha: 0.15)]
                    : [Colors.grey.withValues(alpha: 0.15), Colors.blueGrey.withValues(alpha: 0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasKey ? Colors.greenAccent : Colors.white24,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasKey ? Icons.smart_toy : Icons.smart_toy_outlined,
                  color: hasKey ? Colors.greenAccent : Colors.white38,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    hasKey
                        ? '✅ AI Coach connected — tap to change'
                        : '🔑 Connect AI for post-game insights',
                    style: TextStyle(
                      color: hasKey ? Colors.greenAccent : Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 13,
                  color: hasKey ? Colors.greenAccent.withValues(alpha: 0.7) : Colors.white24,
                ),
              ],
            ),
          ),
        );
      },
    );
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
>>>>>>> 1ac71084d222f99e5cd02ad79a657cc32c1f4c0e
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
<<<<<<< HEAD
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
=======
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const MultiplayerScreen())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.purple.withValues(alpha: 0.3), Colors.indigo.withValues(alpha: 0.2)
          ]),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.purple, width: 2),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, color: Colors.purple),
            SizedBox(width: 10),
            Text('MULTIPLAYER', style: TextStyle(
                color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
          ],
        ),
>>>>>>> 1ac71084d222f99e5cd02ad79a657cc32c1f4c0e
      ),
    );
  }

  Widget _buildAnalysisButton(BuildContext context) {
<<<<<<< HEAD
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
=======
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AnalysisScreen())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.cyan.withValues(alpha: 0.3), Colors.blue.withValues(alpha: 0.2)
          ]),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.cyan, width: 2),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, color: Colors.cyan),
            SizedBox(width: 10),
            Text('PERFORMANCE ANALYSIS', style: TextStyle(
                color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
          ],
        ),
>>>>>>> 1ac71084d222f99e5cd02ad79a657cc32c1f4c0e
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
<<<<<<< HEAD
    return Align(
      alignment: Alignment.center,
      child: TextButton.icon(
        onPressed: () => _showSettingsDialog(context),
        icon: const Icon(Icons.tune_rounded, color: Colors.white60),
        label: const Text('Game Settings', style: TextStyle(color: Colors.white60)),
=======
    return GestureDetector(
      onTap: () => _showSettingsDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.blueGrey.withValues(alpha: 0.3), Colors.grey.withValues(alpha: 0.2)
          ]),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blueGrey, width: 2),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, color: Colors.blueGrey),
            SizedBox(width: 10),
            Text('SETTINGS', style: TextStyle(
                color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
          ],
        ),
>>>>>>> 1ac71084d222f99e5cd02ad79a657cc32c1f4c0e
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
<<<<<<< HEAD
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
=======
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
          child: const Text('CLOSE', style: TextStyle(color: Colors.cyan)),
        )],
>>>>>>> 1ac71084d222f99e5cd02ad79a657cc32c1f4c0e
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
<<<<<<< HEAD
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
=======
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
        const SizedBox(height: 16),
        // ── AI API Key section ─────────────────────────────────────────────
        const Divider(color: Colors.white12),
        const SizedBox(height: 8),
        Consumer<GameProvider>(
          builder: (context, gp, _) {
            final hasKey = gp.hasAIKey;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.smart_toy,
                      color: hasKey ? Colors.greenAccent : Colors.white38,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        hasKey ? 'AI: Connected' : 'AI: Not connected',
                        style: TextStyle(
                          color: hasKey ? Colors.greenAccent : Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // close settings first
                      showDialog(
                        context: context,
                        builder: (_) => const APIKeyDialog(),
                      );
                    },
                    icon: Icon(
                      hasKey ? Icons.edit : Icons.key,
                      size: 16,
                      color: Colors.cyan,
                    ),
                    label: Text(
                      hasKey ? 'Change API Key' : 'Connect AI API Key',
                      style: const TextStyle(color: Colors.cyan, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.cyan),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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
>>>>>>> 1ac71084d222f99e5cd02ad79a657cc32c1f4c0e
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

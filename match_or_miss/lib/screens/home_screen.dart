// lib/screens/home_screen.dart
// REDESIGNED - NEURAL ARCADE EDITION
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
    with TickerProviderStateMixin {
  late final AnimationController _orbController;
  late final AnimationController _scanController;
  late final AnimationController _glowController;
  late final Animation<double> _orbPulse;
  late final Animation<double> _scanLine;
  late final Animation<double> _glowIntensity;
  
  int _selectedTab = 0;
  final List<String> _tabs = ['CHALLENGES', 'ARENA', 'PROFILE'];

  @override
  void initState() {
    super.initState();
    
    _orbController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _scanController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _orbPulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOut),
    );
    
    _scanLine = Tween<double>(begin: -0.5, end: 1.5).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );
    
    _glowIntensity = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _orbController.dispose();
    _scanController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 1200;
    final maxContentWidth = isWeb ? 1100.0 : double.infinity;
    final horizontalPadding = isWeb ? (screenWidth - maxContentWidth) / 2 : 20.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: const [
              Color(0xFF0D0D1A),
              Color(0xFF07070D),
              Color(0xFF030308),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated Neural Grid Background
            _buildNeuralGrid(),
            
            // Scanning Effect
            _buildScanEffect(),
            
            // Floating Particles
            ..._buildFloatingParticles(),
            
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    children: [
                      _buildNeuralHeader(),
                      Expanded(
                        child: IndexedStack(
                          index: _selectedTab,
                          children: [
                            _buildChallengesPage(),
                            _buildArenaPage(),
                            _buildProfilePage(),
                          ],
                        ),
                      ),
                      _buildNeuralNavBar(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeuralGrid() {
    return CustomPaint(
      painter: NeuralGridPainter(glowIntensity: _glowIntensity.value),
      size: Size.infinite,
    );
  }

  Widget _buildScanEffect() {
    return AnimatedBuilder(
      animation: _scanLine,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).size.height * _scanLine.value,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF6C63FF).withValues(alpha: 0.8),
                  const Color(0xFFFF6584).withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(20, (index) {
      return Positioned(
        left: (index * 73) % MediaQuery.of(context).size.width,
        top: (index * 47) % MediaQuery.of(context).size.height,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(seconds: 3 + index),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: (value * 0.3).clamp(0, 0.3),
              child: Container(
                width: 1 + (index % 3),
                height: 1 + (index % 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index % 2 == 0 
                      ? const Color(0xFF6C63FF) 
                      : const Color(0xFFFF6584),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildNeuralHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _orbPulse,
            builder: (context, child) {
              return Transform.scale(
                scale: _orbPulse.value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.5),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.hexagon_outlined, color: Colors.white, size: 20),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WELCOME BACK',
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'NEURAL OPERATOR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.notifications_none, color: Color(0xFF6C63FF), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildNeuralNavBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: const Color(0xFF2D2D44).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildNavItem('CHALLENGES', 0, Icons.gamepad_outlined),
          _buildNavItem('ARENA', 1, Icons.people_outline),
          _buildNavItem('PROFILE', 2, Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF).withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF4A4A5A), size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF4A4A5A),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // CHALLENGES PAGE - MAIN GAME MODES
  // ==========================================================================
  
  Widget _buildChallengesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeroCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('SELECT PROTOCOL', Icons.flash_on),
          const SizedBox(height: 16),
          _buildModeCards(),
          const SizedBox(height: 24),
          _buildSectionHeader('NEURAL ENHANCEMENTS', Icons.psychology),
          const SizedBox(height: 16),
          _buildAIStatusCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('RECENT ACTIVITY', Icons.history),
          const SizedBox(height: 16),
          _buildRecentGames(),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return AnimatedBuilder(
      animation: _glowIntensity,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6C63FF).withValues(alpha: 0.15 + _glowIntensity.value * 0.1),
                const Color(0xFFFF6584).withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.3 + _glowIntensity.value * 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.2 * _glowIntensity.value),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFF6584), Color(0xFF6C63FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEURAL TRAINING',
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Complete challenges to unlock neural pathways and enhance cognitive performance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.3,
                      ),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const Spacer(),
        Icon(icon, color: const Color(0xFF6C63FF), size: 16),
      ],
    );
  }

  Widget _buildModeCards() {
    return Column(
      children: [
        _buildModeCard(
          title: 'SPRINT MODE',
          subtitle: 'Adaptive learning',
          description: 'Sequence length evolves with your skill',
          icon: Icons.flash_on,
          gradient: const LinearGradient(colors: [Color(0xFF00D2FF), Color(0xFF6C63FF)]),
          mode: GameMode.quick,
          timeInfo: '∞ TIME',
          moveInfo: 'ADAPTIVE',
        ),
        const SizedBox(height: 12),
        _buildModeCard(
          title: 'FOCUS MODE',
          subtitle: 'Balanced challenge',
          description: '4 minutes • 10 moves • Precision required',
          icon: Icons.timer,
          gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]),
          mode: GameMode.standard,
          timeInfo: '4:00',
          moveInfo: '10 MOVES',
        ),
        const SizedBox(height: 12),
        _buildModeCard(
          title: 'GLADIATOR MODE',
          subtitle: 'Maximum pressure',
          description: 'Custom move limit • High stakes',
          icon: Icons.emoji_events,
          gradient: const LinearGradient(colors: [Color(0xFFFF6584), Color(0xFFFFB347)]),
          mode: GameMode.competitive,
          timeInfo: '3:00',
          moveInfo: '5-12 MOVES',
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Gradient gradient,
    required GameMode mode,
    required String timeInfo,
    required String moveInfo,
  }) {
    return GestureDetector(
      onTap: () {
        if (mode == GameMode.competitive) {
          _showCompetitiveMoveDialog(context);
        } else {
          Provider.of<GameProvider>(context, listen: false).initializeGame(mode);
          Navigator.push(
            context,
            SmoothPageTransition(page: const GameScreenWithAI()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
                boxShadow: [
                  BoxShadow(
                    color: (gradient.colors.first).withValues(alpha: 0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (gradient.colors.first).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            color: gradient.colors.first,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF8B8B9A),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildModeBadge(Icons.timer_outlined, timeInfo),
                      const SizedBox(width: 8),
                      _buildModeBadge(Icons.directions_run, moveInfo),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6C63FF), size: 10),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF8B8B9A),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIStatusCard() {
    return Consumer<GameProvider>(
      builder: (context, gp, child) {
        final hasKey = gp.hasAIKey;
        return GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => const APIKeyDialog(),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasKey
                    ? [const Color(0xFF6C63FF).withValues(alpha: 0.12), const Color(0xFFFF6584).withValues(alpha: 0.06)]
                    : [const Color(0xFF1A1A2E).withValues(alpha: 0.6), const Color(0xFF1A1A2E).withValues(alpha: 0.4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: hasKey ? const Color(0xFF6C63FF) : const Color(0xFF2D2D44),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasKey ? const Color(0xFF6C63FF).withValues(alpha: 0.15) : Colors.transparent,
                  ),
                  child: Icon(
                    hasKey ? Icons.auto_awesome : Icons.psychology_outlined,
                    color: hasKey ? const Color(0xFF6C63FF) : const Color(0xFF4A4A5A),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasKey ? 'NEURAL LINK ACTIVE' : 'NEURAL LINK OFFLINE',
                        style: TextStyle(
                          color: hasKey ? const Color(0xFF6C63FF) : const Color(0xFF4A4A5A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasKey
                            ? 'AI Coach connected — Get real-time performance insights'
                            : 'Connect your AI key for neural performance analysis',
                        style: const TextStyle(
                          color: Color(0xFF8B8B9A),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasKey ? const Color(0xFF6C63FF).withValues(alpha: 0.15) : const Color(0xFF2D2D44),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: hasKey ? const Color(0xFF6C63FF) : const Color(0xFF4A4A5A),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentGames() {
    return Column(
      children: [
        _buildRecentGameItem('SPRINT MODE', '8/8 MATCHES', '⭐ 2,450', '2h ago'),
        const SizedBox(height: 8),
        _buildRecentGameItem('FOCUS MODE', '6/8 MATCHES', '⭐ 1,820', 'Yesterday'),
        const SizedBox(height: 8),
        _buildRecentGameItem('GLADIATOR', '8/8 MATCHES', '🏆 3,120', '2d ago'),
      ],
    );
  }

  Widget _buildRecentGameItem(String mode, String result, String score, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: mode == 'SPRINT MODE' 
                  ? const LinearGradient(colors: [Color(0xFF00D2FF), Color(0xFF6C63FF)])
                  : mode == 'FOCUS MODE'
                      ? const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)])
                      : const LinearGradient(colors: [Color(0xFFFF6584), Color(0xFFFFB347)]),
            ),
            child: Icon(
              mode == 'SPRINT MODE' ? Icons.flash_on : mode == 'FOCUS MODE' ? Icons.timer : Icons.emoji_events,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(result, style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(score, style: const TextStyle(color: Color(0xFFFFB347), fontWeight: FontWeight.bold, fontSize: 12)),
              Text(time, style: const TextStyle(color: Color(0xFF4A4A5A), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ARENA PAGE - MULTIPLAYER
  // ==========================================================================
  
  Widget _buildArenaPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildArenaHero(),
          const SizedBox(height: 24),
          _buildSectionHeader('LIVE BATTLES', Icons.wifi),
          const SizedBox(height: 16),
          _buildLiveMatches(),
          const SizedBox(height: 24),
          _buildSectionHeader('QUICK DUEL', Icons.flash_on),
          const SizedBox(height: 16),
          _buildQuickDuelButton(),
        ],
      ),
    );
  }

  Widget _buildArenaHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6584).withValues(alpha: 0.15),
            const Color(0xFF6C63FF).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFFF6584).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]),
            ),
            child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GLOBAL ARENA',
                  style: TextStyle(color: Color(0xFFFF6584), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2),
                ),
                SizedBox(height: 4),
                Text(
                  '1,284 Players Online',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Join the arena and test your skills against players worldwide',
                  style: TextStyle(color: Color(0xFF8B8B9A), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMatches() {
    return Column(
      children: [
        _buildMatchCard('🏆', 'Champion League', '8 Players', '2 min'),
        const SizedBox(height: 8),
        _buildMatchCard('⚡', 'Speed Trials', '4 Players', 'Now'),
        const SizedBox(height: 8),
        _buildMatchCard('🎯', 'Precision Games', '12 Players', '1 min'),
      ],
    );
  }

  Widget _buildMatchCard(String emoji, String title, String players, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(players, style: const TextStyle(color: Color(0xFF8B8B9A), fontSize: 10)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(time, style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDuelButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SmoothPageTransition(page: const MultiplayerScreen()),
        );
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFF6584), Color(0xFF6C63FF)]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
              blurRadius: 20,
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'ENTER DUEL ARENA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // PROFILE PAGE
  // ==========================================================================
  
  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildStatsGrid(),
          const SizedBox(height: 24),
          _buildSectionHeader('ACHIEVEMENTS', Icons.emoji_events),
          const SizedBox(height: 16),
          _buildAchievements(),
          const SizedBox(height: 24),
          _buildSectionHeader('SETTINGS', Icons.settings),
          const SizedBox(height: 16),
          _buildSettingsButton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withValues(alpha: 0.15),
            const Color(0xFFFF6584).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'N',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'NEURAL_OPERATOR',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'LEVEL 42 • COGNITIVE ELITE',
              style: TextStyle(color: Color(0xFF6C63FF), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard('TOTAL SCORE', '45,892', const Color(0xFFFFB347)),
        const SizedBox(width: 12),
        _buildStatCard('GAMES PLAYED', '247', const Color(0xFF6C63FF)),
        const SizedBox(width: 12),
        _buildStatCard('WIN RATE', '68%', const Color(0xFF00D2FF)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Color(0xFF8B8B9A), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildAchievementItem('🏆', 'CHAMPION', 'Win 50 games', true),
        _buildAchievementItem('⚡', 'SPEEDSTER', 'Solve in 2 min', true),
        _buildAchievementItem('🎯', 'PRECISE', 'Perfect round', false),
        _buildAchievementItem('🧠', 'GENIUS', '10 win streak', false),
        _buildAchievementItem('💪', 'WARRIOR', 'Play 100 games', true),
        _buildAchievementItem('✨', 'MASTER', 'Reach level 50', false),
      ],
    );
  }

  Widget _buildAchievementItem(String emoji, String title, String desc, bool unlocked) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFF6C63FF).withValues(alpha: 0.15) : const Color(0xFF1A1A2E).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: unlocked ? Border.all(color: const Color(0xFF6C63FF), width: 0.5) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: unlocked ? const Color(0xFF6C63FF) : const Color(0xFF4A4A5A), fontSize: 10, fontWeight: FontWeight.bold)),
          Text(desc, style: TextStyle(color: const Color(0xFF8B8B9A), fontSize: 8)),
        ],
      ),
    );
  }

  Widget _buildSettingsButton() {
    return GestureDetector(
      onTap: () => _showSettingsDialog(context),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF2D2D44)),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.tune_rounded, color: Color(0xFF6C63FF), size: 20),
              SizedBox(width: 10),
              Text(
                'SYSTEM CONFIGURATION',
                style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // DIALOGS
  // ==========================================================================

  void _showCompetitiveMoveDialog(BuildContext context) {
    final controller = TextEditingController(text: '8');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Color(0xFFFF6584), size: 28),
            SizedBox(width: 12),
            Text('GLADIATOR MODE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Configure move limit',
              style: TextStyle(color: Color(0xFF8B8B9A), fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF6C63FF), width: 2),
              ),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF0F0F1A),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '5 - 12 MOVES',
              style: TextStyle(color: Color(0xFF6C63FF), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6584),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              final moves = int.tryParse(controller.text.trim());
              if (moves == null || moves < 5 || moves > 12) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a number from 5 to 12'), backgroundColor: Color(0xFFFF6584)),
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
            child: const Text('START BATTLE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _NeuralSettingsDialog(),
    );
  }
}

// ==========================================================================
// NEURAL SETTINGS DIALOG
// ==========================================================================

class _NeuralSettingsDialog extends StatefulWidget {
  const _NeuralSettingsDialog();

  @override
  State<_NeuralSettingsDialog> createState() => _NeuralSettingsDialogState();
}

class _NeuralSettingsDialogState extends State<_NeuralSettingsDialog> {
  bool _sound = true;
  bool _music = true;
  bool _haptic = true;
  bool _neuralAI = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      title: const Row(
        children: [
          Icon(Icons.tune_rounded, color: Color(0xFF6C63FF), size: 28),
          SizedBox(width: 12),
          Text('NEURAL SETTINGS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggle('Audio Output', Icons.volume_up, _sound, (v) => setState(() => _sound = v)),
          _toggle('Neural Score', Icons.music_note, _music, (v) => setState(() => _music = v)),
          _toggle('Haptic Feedback', Icons.touch_app, _haptic, (v) => setState(() => _haptic = v)),
          _toggle('Neural AI Assistant', Icons.auto_awesome, _neuralAI, (v) => setState(() => _neuralAI = v)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                showDialog(context: context, builder: (_) => const APIKeyDialog());
              },
              icon: const Icon(Icons.link_rounded, color: Color(0xFF6C63FF), size: 16),
              label: const Text('CONNECT NEURAL AI', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF6C63FF)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w600, letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget _toggle(String label, IconData icon, bool value, ValueChanged<bool> onChange) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6C63FF), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13))),
          Switch(
            value: value,
            onChanged: onChange,
            activeColor: const Color(0xFF6C63FF),
            activeTrackColor: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            inactiveThumbColor: const Color(0xFF4A4A5A),
            inactiveTrackColor: const Color(0xFF2D2D44),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// NEURAL GRID PAINTER
// ==========================================================================

class NeuralGridPainter extends CustomPainter {
  final double glowIntensity;
  
  NeuralGridPainter({required this.glowIntensity});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6C63FF).withValues(alpha: 0.05 * glowIntensity)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    const spacing = 40.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Draw glowing nodes at intersections
    final nodePaint = Paint()
      ..color = const Color(0xFF6C63FF).withValues(alpha: 0.1 * glowIntensity)
      ..style = PaintingStyle.fill;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2, nodePaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(NeuralGridPainter oldDelegate) {
    return oldDelegate.glowIntensity != glowIntensity;
  }
}
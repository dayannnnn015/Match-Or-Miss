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
            colors: [
              Color(0xFF0a0a2a),
              Color(0xFF1a0033),
              Color(0xFF002244),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
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
                        _buildSettingsButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
          const Text(
            'MATCH OR MISS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.cyan,
              shadows: [
                Shadow(color: Colors.cyan, blurRadius: 10),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard, color: Colors.white),
            onPressed: () => _showLeaderboard(),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Colors.cyan.withOpacity(0.3), Colors.transparent],
            ),
          ),
          child: const Icon(
            Icons.psychology,
            size: 80,
            color: Colors.cyan,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Train Your Brain',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGameModes(BuildContext context) {
    return Column(
      children: [
        _buildModeCard(
          context,
          'QUICK MODE',
          '2 Minutes • 12 Moves',
          'Perfect for short sessions',
          Colors.green,
          GameMode.quick,
        ),
        const SizedBox(height: 15),
        _buildModeCard(
          context,
          'STANDARD MODE',
          '5 Minutes • 12 Moves',
          'Balanced challenge',
          Colors.blue,
          GameMode.standard,
        ),
        const SizedBox(height: 15),
        _buildModeCard(
          context,
          'COMPETITIVE MODE',
          '10 Minutes • 12 Moves',
          'Maximum concentration',
          Colors.purple,
          GameMode.competitive,
        ),
      ],
    );
  }

  Widget _buildModeCard(
    BuildContext context,
    String title,
    String subtitle,
    String description,
    Color color,
    GameMode mode,
  ) {
    return GestureDetector(
      onTap: () {
        final gameProvider = Provider.of<GameProvider>(context, listen: false);
        gameProvider.initializeGame(mode);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GameScreenWithAI()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getModeIcon(mode),
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: color),
          ],
        ),
      ),
    );
  }

  IconData _getModeIcon(GameMode mode) {
    switch (mode) {
      case GameMode.quick:
        return Icons.flash_on;
      case GameMode.standard:
        return Icons.timer;
      case GameMode.competitive:
        return Icons.emoji_events;
    }
  }

  Widget _buildMultiplayerButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MultiplayerScreen()),
        );
      },
      icon: const Icon(Icons.people),
      label: const Text('PLAY MULTIPLAYER'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildAnalysisButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnalysisScreen()),
        );
      },
      icon: const Icon(Icons.analytics),
      label: const Text('VIEW ANALYSIS'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.cyan,
        side: const BorderSide(color: Colors.cyan),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return TextButton.icon(
      onPressed: () => _showSettingsDialog(),
      icon: const Icon(Icons.settings, color: Colors.white54),
      label: const Text(
        'Game Settings',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }

  void _showSettingsDialog() {
    // Implementation for settings dialog
  }

  void _showLeaderboard() {
    // Implementation for leaderboard
  }
}

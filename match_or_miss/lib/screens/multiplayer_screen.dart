// lib/screens/multiplayer_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_models.dart';
import '../providers/multiplayer_provider.dart';

class MultiplayerScreen extends StatelessWidget {
  const MultiplayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Multiplayer Arena'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<MultiplayerProvider>(
        builder: (context, provider, child) {
          if (provider.currentRoomId == null) {
            return _buildLobbyScreen(context);
          }
          return _buildGameRoom(context, provider);
        },
      ),
    );
  }
  
  Widget _buildLobbyScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'MULTIPLAYER MODES',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.cyan,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              Provider.of<MultiplayerProvider>(context, listen: false)
                  .createRoom(GameMode.standard);
            },
            icon: const Icon(Icons.create),
            label: const Text('CREATE ROOM'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showJoinDialog(context),
            icon: const Icon(Icons.login),
            label: const Text('JOIN ROOM'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
          ),
          const SizedBox(height: 40),
          _buildMatchmakingOptions(),
        ],
      ),
    );
  }
  
  Widget _buildMatchmakingOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Text(
            'Quick Matchmaking',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuickMatchButton('1v1', Colors.red),
              const SizedBox(width: 10),
              _buildQuickMatchButton('Tournament', Colors.purple),
              const SizedBox(width: 10),
              _buildQuickMatchButton('Battle', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickMatchButton(String label, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
      ),
      child: Text(label),
    );
  }
  
  Widget _buildGameRoom(BuildContext context, MultiplayerProvider provider) {
    return Column(
      children: [
        _buildOpponentStatus(),
        const Expanded(
          child: Center(
            child: Text(
              'Waiting for opponent...',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        _buildReadyButton(),
      ],
    );
  }
  
  Widget _buildOpponentStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white.withOpacity(0.05),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, color: Colors.green),
          SizedBox(width: 10),
          Text(
            'Player 2 • Ready',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReadyButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyan,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('READY'),
      ),
    );
  }
  
  void _showJoinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String roomId = '';
        return AlertDialog(
          title: const Text('Join Room'),
          content: TextField(
            onChanged: (value) => roomId = value,
            decoration: const InputDecoration(
              hintText: 'Enter Room ID',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<MultiplayerProvider>(context, listen: false)
                    .joinRoom(roomId);
                Navigator.pop(context);
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }
}
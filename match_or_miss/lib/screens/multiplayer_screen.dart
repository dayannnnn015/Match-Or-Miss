// lib/screens/multiplayer_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../services/ai_service.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';
import '../widgets/bottle_widget.dart';

enum MultiplayerMode { classic, blitz }

class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen>
    with SingleTickerProviderStateMixin {
  final _playerNameCtrl = TextEditingController(text: '');
  String _playerName = '';
  MultiplayerMode _selectedMode = MultiplayerMode.classic;
  bool _showJoinScreen = false;
  String _roomCode = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _playerNameCtrl.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _createGame() {
    if (_playerName.trim().isEmpty) {
      _showNameDialog();
      return;
    }
    final roomCode = _generateRoomCode();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiplayerLobby(
          roomCode: roomCode,
          playerName: _playerName.trim(),
          mode: _selectedMode,
          isHost: true,
        ),
      ),
    );
  }

  void _joinGame() {
    if (_playerName.trim().isEmpty) {
      _showNameDialog();
      return;
    }
    if (_roomCode.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiplayerLobby(
          roomCode: _roomCode.trim().toUpperCase(),
          playerName: _playerName.trim(),
          mode: _selectedMode,
          isHost: false,
        ),
      ),
    );
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  void _showNameDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('ENTER YOUR NAME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _playerNameCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Warrior Name',
            hintStyle: const TextStyle(color: Color(0xFF4A4A5A)),
            filled: true,
            fillColor: const Color(0xFF0F0F1A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          onSubmitted: (_) {
            setState(() => _playerName = _playerNameCtrl.text.trim());
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Color(0xFF6C63FF))),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _playerName = _playerNameCtrl.text.trim());
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 1200;
    final maxContentWidth = isWeb ? 900.0 : double.infinity;
    final horizontalPadding = isWeb ? (screenWidth - maxContentWidth) / 2 : 20.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.3,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A), Color(0xFF05050A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
                      child: Column(
                        children: [
                          if (!_showJoinScreen) ...[
                            _buildHeroSection(),
                            const SizedBox(height: 32),
                            _buildModeSelector(),
                            const SizedBox(height: 32),
                            _buildCreateButton(),
                            const SizedBox(height: 16),
                            _buildOrDivider(),
                            const SizedBox(height: 16),
                            _buildToggleButton(),
                          ] else ...[
                            _buildJoinSection(),
                            const SizedBox(height: 24),
                            _buildBackButton(),
                          ],
                        ],
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF6C63FF), size: 18),
            ),
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'DUEL ARENA',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 3),
                ),
                Text(
                  'MULTIPLAYER',
                  style: TextStyle(color: Color(0xFF6C63FF), fontSize: 10, letterSpacing: 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6C63FF).withValues(alpha: 0.1 + _pulseController.value * 0.05),
                const Color(0xFFFF6584).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.2 + _pulseController.value * 0.1), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFFFF6584), Color(0xFF6C63FF)]),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.4), blurRadius: 15),
                  ],
                ),
                child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Challenge Players Worldwide',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Create a room or join with a code to battle opponents in real-time puzzles',
                      style: TextStyle(color: Color(0xFF8B8B9A), fontSize: 11, height: 1.3),
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

  Widget _buildModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('GAME MODE', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildModeCard('⚡', 'BLITZ', '60 sec race!', MultiplayerMode.blitz),
            const SizedBox(width: 12),
            _buildModeCard('🎯', 'CLASSIC', '4 min, 10 moves', MultiplayerMode.classic),
          ],
        ),
      ],
    );
  }

  Widget _buildModeCard(String icon, String title, String desc, MultiplayerMode mode) {
    final isSelected = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = mode),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF).withValues(alpha: 0.12) : const Color(0xFF1A1A2E).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF2D2D44),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(color: isSelected ? const Color(0xFF6C63FF) : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(desc, style: const TextStyle(color: Color(0xFF8B8B9A), fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: _createGame,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFF6584), Color(0xFF6C63FF)]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 4)),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text('CREATE BATTLE ROOM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: const Color(0xFF2D2D44), thickness: 0.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR', style: TextStyle(color: const Color(0xFF6C63FF).withValues(alpha: 0.5), fontSize: 12)),
        ),
        Expanded(child: Divider(color: const Color(0xFF2D2D44), thickness: 0.5)),
      ],
    );
  }

  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: () => setState(() => _showJoinScreen = true),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF6C63FF), width: 1.5),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFF6C63FF), size: 20),
              SizedBox(width: 10),
              Text('JOIN EXISTING ROOM', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFF6C63FF), width: 1),
          ),
          child: Column(
            children: [
              const Icon(Icons.keyboard_rounded, color: Color(0xFF6C63FF), size: 40),
              const SizedBox(height: 16),
              const Text('ENTER ROOM CODE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF6C63FF), width: 1.5),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  onChanged: (value) => _roomCode = value,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    hintText: 'XXXXXX',
                    hintStyle: TextStyle(color: Color(0xFF4A4A5A), fontSize: 20, letterSpacing: 4),
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _joinGame,
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)]),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text('JOIN BATTLE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => setState(() => _showJoinScreen = false),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D44),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: Text('BACK', style: TextStyle(color: Color(0xFF8B8B9A), fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// ============================================================================
// MULTIPLAYER LOBBY
// ============================================================================

class MultiplayerLobby extends StatefulWidget {
  final String roomCode;
  final String playerName;
  final MultiplayerMode mode;
  final bool isHost;

  const MultiplayerLobby({
    super.key,
    required this.roomCode,
    required this.playerName,
    required this.mode,
    required this.isHost,
  });

  @override
  State<MultiplayerLobby> createState() => _MultiplayerLobbyState();
}

class _MultiplayerLobbyState extends State<MultiplayerLobby>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _players = [];
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _players = [
      {
        'name': widget.playerName,
        'ready': false,
        'isHost': widget.isHost,
        'avatar': _getAvatarIcon(widget.playerName),
      },
      {
        'name': 'Challenger',
        'ready': false,
        'isHost': false,
        'avatar': '⚔️',
      },
    ];
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getAvatarIcon(String name) {
    const avatars = ['⚔️', '🛡️', '🏹', '🗡️', '🔮', '⚡', '🔥', '❄️'];
    final index = name.length % avatars.length;
    return avatars[index];
  }

  void _toggleReady() {
    setState(() {
      _players[0]['ready'] = !_players[0]['ready'];
    });
  }

  void _startGame() {
    if (!widget.isHost) return;
    if (!_players.every((p) => p['ready'])) return;
    
    final hidden = GameService().generateHiddenSequence();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MultiplayerGame(
          mode: widget.mode,
          hidden: hidden,
          players: _players.map((p) => p['name'] as String).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 1200;
    final maxContentWidth = isWeb ? 900.0 : double.infinity;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.3,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A), Color(0xFF05050A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildRoomInfo(),
                          const SizedBox(height: 32),
                          _buildPlayersList(),
                          const SizedBox(height: 32),
                          _buildReadyButton(),
                          if (widget.isHost) _buildStartButton(),
                        ],
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.close, color: Color(0xFF6C63FF), size: 18),
            ),
          ),
          const Expanded(
            child: Text(
              'BATTLE LOBBY',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildRoomInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFF6584).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text('ROOM CODE', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text(
            widget.roomCode,
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 6),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.mode == MultiplayerMode.classic ? const Color(0xFF6C63FF).withValues(alpha: 0.15) : const Color(0xFF00D2FF).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.mode == MultiplayerMode.classic ? Icons.timer : Icons.flash_on, 
                     color: widget.mode == MultiplayerMode.classic ? const Color(0xFF6C63FF) : const Color(0xFF00D2FF), size: 14),
                const SizedBox(width: 6),
                Text(
                  widget.mode == MultiplayerMode.classic ? 'CLASSIC MODE' : 'BLITZ MODE',
                  style: TextStyle(color: widget.mode == MultiplayerMode.classic ? const Color(0xFF6C63FF) : const Color(0xFF00D2FF), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersList() {
    return Column(
      children: [
        const Text('COMBATANTS', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
        const SizedBox(height: 16),
        ..._players.asMap().entries.map((entry) {
          final index = entry.key;
          final player = entry.value;
          final isCurrentPlayer = index == 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrentPlayer ? const Color(0xFF6C63FF).withValues(alpha: 0.08) : const Color(0xFF1A1A2E).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCurrentPlayer ? const Color(0xFF6C63FF) : const Color(0xFF2D2D44),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6584), Color(0xFF6C63FF)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      player['avatar'],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player['name'],
                        style: TextStyle(
                          color: isCurrentPlayer ? const Color(0xFF6C63FF) : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (player['isHost'])
                        const Text('HOST', style: TextStyle(color: Color(0xFFFFB347), fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                if (player['ready'])
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF6C63FF), size: 14),
                        SizedBox(width: 4),
                        Text('READY', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReadyButton() {
    return GestureDetector(
      onTap: _toggleReady,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: _players[0]['ready'] ? const Color(0xFF6C63FF) : const Color(0xFF2D2D44),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.5), width: 1),
        ),
        child: Center(
          child: Text(
            _players[0]['ready'] ? '✓ READY FOR BATTLE' : 'TAP TO READY UP',
            style: TextStyle(
              color: _players[0]['ready'] ? Colors.white : const Color(0xFF8B8B9A),
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    final canStart = _players.length >= 2 && _players.every((p) => p['ready']);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: GestureDetector(
        onTap: canStart ? _startGame : null,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: canStart
                ? const LinearGradient(colors: [Color(0xFFFF6584), Color(0xFF6C63FF)])
                : const LinearGradient(colors: [Color(0xFF2D2D44), Color(0xFF1A1A2E)]),
            borderRadius: BorderRadius.circular(30),
            boxShadow: canStart
                ? [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.3), blurRadius: 15)]
                : null,
          ),
          child: Center(
            child: Text(
              'START BATTLE',
              style: TextStyle(
                color: canStart ? Colors.white : const Color(0xFF4A4A5A),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MULTIPLAYER GAME
// ============================================================================

class MultiplayerGame extends StatefulWidget {
  final MultiplayerMode mode;
  final List<Bottle> hidden;
  final List<String> players;

  const MultiplayerGame({
    super.key,
    required this.mode,
    required this.hidden,
    required this.players,
  });

  @override
  State<MultiplayerGame> createState() => _MultiplayerGameState();
}

class _MultiplayerGameState extends State<MultiplayerGame> {
  int _currentPlayerIndex = 0;
  List<PlayerResult> _results = [];
  bool _gameOver = false;
  Timer? _gameTimer;
  int _timeRemaining = 0;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.mode == MultiplayerMode.classic ? 240 : 60;
    _startTimer();
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0 && !_gameOver && mounted) {
        setState(() => _timeRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _onPlayerComplete(String playerName, int moves, int score) {
    setState(() {
      _results.add(PlayerResult(name: playerName, moves: moves, score: score));
      
      if (_results.length < widget.players.length) {
        _currentPlayerIndex++;
        _timeRemaining = widget.mode == MultiplayerMode.classic ? 240 : 60;
      } else {
        _gameOver = true;
        _gameTimer?.cancel();
        _showResults();
      }
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ResultsDialog(
        results: _results,
        onPlayAgain: () {
          Navigator.pop(ctx);
          Navigator.pop(context);
        },
        onHome: () => Navigator.popUntil(ctx, (route) => route.isFirst),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) {
      return const SizedBox.shrink();
    }

    final currentPlayer = widget.players[_currentPlayerIndex];
    final isCurrentTurn = _results.length == _currentPlayerIndex;

    if (!isCurrentTurn) {
      return _buildWaitingScreen(currentPlayer);
    }

    return MultiplayerGameBoard(
      playerName: currentPlayer,
      hidden: widget.hidden,
      mode: widget.mode,
      timeRemaining: _timeRemaining,
      onComplete: (moves, score) => _onPlayerComplete(currentPlayer, moves, score),
    );
  }

  Widget _buildWaitingScreen(String currentPlayer) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.3,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A), Color(0xFF05050A)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(color: Color(0xFF6C63FF), strokeWidth: 2),
              ),
              const SizedBox(height: 32),
              Text(
                currentPlayer.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              const Text(
                'IS BATTLING',
                style: TextStyle(color: Color(0xFF6C63FF), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 3),
              ),
              const SizedBox(height: 24),
              if (_results.isNotEmpty) _buildScoreboard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreboard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('SCOREBOARD', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 12),
          ..._results.map((result) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFB347),
                    ),
                    child: const Center(child: Icon(Icons.check, color: Colors.white, size: 16)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(result.name, style: const TextStyle(color: Colors.white))),
                  Text('${result.score}', style: const TextStyle(color: Color(0xFFFFB347), fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  Text('${result.moves}m', style: const TextStyle(color: Color(0xFF8B8B9A), fontSize: 12)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================================
// MULTIPLAYER GAME BOARD
// ============================================================================

class MultiplayerGameBoard extends StatefulWidget {
  final String playerName;
  final List<Bottle> hidden;
  final MultiplayerMode mode;
  final int timeRemaining;
  final Function(int moves, int score) onComplete;

  const MultiplayerGameBoard({
    super.key,
    required this.playerName,
    required this.hidden,
    required this.mode,
    required this.timeRemaining,
    required this.onComplete,
  });

  @override
  State<MultiplayerGameBoard> createState() => _MultiplayerGameBoardState();
}

class _MultiplayerGameBoardState extends State<MultiplayerGameBoard> {
  final GameService _gs = GameService();
  List<Bottle?> _guess = [];
  int _moves = 0;
  int _score = 0;
  int _bestMatch = 0;
  bool _isComplete = false;
  int _elapsedTime = 0;
  Timer? _gameTimer;

  @override
  void initState() {
    super.initState();
    _guess = List<Bottle?>.filled(widget.hidden.length, null);
    _startTimer();
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isComplete && mounted) {
        setState(() => _elapsedTime++);
        if (_elapsedTime >= widget.timeRemaining) {
          _timeOut();
        }
      }
    });
  }

  void _timeOut() {
    if (_isComplete) return;
    setState(() => _isComplete = true);
    widget.onComplete(_moves, _score);
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _pickBottle(int index, Bottle bottle) {
    if (_isComplete) return;
    setState(() {
      _guess[index] = bottle;
    });
    _checkProgress();
  }

  void _checkProgress() {
    final matches = _gs.calculateMatches(_guess, widget.hidden);
    if (matches > _bestMatch) {
      setState(() {
        _bestMatch = matches;
        _score += 50;
      });
    }
  }

  void _submitGuess() {
    if (_isComplete) return;
    
    final matches = _gs.calculateMatches(_guess, widget.hidden);
    final isSolved = matches == widget.hidden.length;
    
    setState(() {
      _moves++;
      _score += matches * 100;
    });
    
    if (isSolved || _moves >= 10) {
      setState(() => _isComplete = true);
      _gameTimer?.cancel();
      widget.onComplete(_moves, _score);
    }
  }

  void _resetGuess() {
    if (_isComplete) return;
    setState(() {
      _guess = List<Bottle?>.filled(widget.hidden.length, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 1200;
    final maxContentWidth = isWeb ? 900.0 : double.infinity;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.3,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A), Color(0xFF05050A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildGameStats(),
                  const SizedBox(height: 16),
                  _buildGameGrid(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF2D2D44), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Color(0xFF6C63FF), size: 14),
                const SizedBox(width: 6),
                Text(
                  widget.playerName,
                  style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6584).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Color(0xFFFF6584), size: 14),
                const SizedBox(width: 6),
                Text(
                  '${(widget.timeRemaining - _elapsedTime) ~/ 60}:${((widget.timeRemaining - _elapsedTime) % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Color(0xFFFF6584), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat('MOVES', '$_moves'),
          _buildStat('BEST', '$_bestMatch/${widget.hidden.length}'),
          _buildStat('SCORE', '$_score'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8B8B9A), fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGameGrid() {
    final total = widget.hidden.length;
    int columns = total <= 4 ? total : 4;
    const spacing = 12.0;
    final availableWidth = MediaQuery.of(context).size.width - 32;
    final cellWidth = (availableWidth - ((columns - 1) * spacing)) / columns;
    final bottleSize = (cellWidth * 0.48).clamp(38.0, 58.0);
    final cellHeight = bottleSize * 1.54;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: cellHeight,
          ),
          itemCount: total,
          itemBuilder: (context, index) {
            final bottle = _guess[index];
            return GestureDetector(
              onTap: () => _showColorPicker(index),
              child: Container(
                decoration: BoxDecoration(
                  color: bottle != null ? bottle.color.withValues(alpha: 0.15) : const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: bottle != null ? bottle.color : const Color(0xFF2D2D44),
                    width: 1.5,
                  ),
                ),
                child: bottle != null
                    ? BottleWidget(bottle: bottle, size: bottleSize, isDragging: false)
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_circle_outline, color: Color(0xFF4A4A5A), size: 24),
                            const SizedBox(height: 4),
                            Text('${index + 1}', style: const TextStyle(color: Color(0xFF4A4A5A), fontSize: 10)),
                          ],
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showColorPicker(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SELECT COLOR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppConstants.availableColors.map((color) {
                final isUsed = _guess.any((b) => b?.color == color) && _guess[index]?.color != color;
                return GestureDetector(
                  onTap: isUsed ? null : () {
                    _pickBottle(index, Bottle(id: 'temp', color: color, position: index));
                    Navigator.pop(ctx);
                  },
                  child: Opacity(
                    opacity: isUsed ? 0.3 : 1.0,
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: isUsed ? const Icon(Icons.close, color: Colors.white) : null,
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

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _resetGuess,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D44),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, color: Color(0xFF8B8B9A), size: 18),
                      SizedBox(width: 8),
                      Text('RESET', style: TextStyle(color: Color(0xFF8B8B9A), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _submitGuess,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)]),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// RESULTS DIALOG
// ============================================================================

class PlayerResult {
  final String name;
  final int moves;
  final int score;
  
  PlayerResult({required this.name, required this.moves, required this.score});
}

class ResultsDialog extends StatelessWidget {
  final List<PlayerResult> results;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const ResultsDialog({
    super.key,
    required this.results,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<PlayerResult>.from(results)..sort((a, b) => b.score.compareTo(a.score));
    final winner = sorted.first;

    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Color(0xFFFFB347), size: 60),
            const SizedBox(height: 16),
            Text(
              '${winner.name.toUpperCase()} WINS!',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 24),
            ...results.map((result) {
              final isWinner = result.name == winner.name;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isWinner ? const Color(0xFFFFB347).withValues(alpha: 0.12) : const Color(0xFF2D2D44).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: isWinner ? Border.all(color: const Color(0xFFFFB347), width: 1) : null,
                ),
                child: Row(
                  children: [
                    if (isWinner) const Icon(Icons.emoji_events, color: Color(0xFFFFB347), size: 18),
                    if (!isWinner) const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(result.name, style: TextStyle(color: isWinner ? const Color(0xFFFFB347) : Colors.white, fontWeight: isWinner ? FontWeight.bold : null))),
                    Text('${result.score}', style: const TextStyle(color: Color(0xFFFFB347), fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Text('${result.moves}m', style: const TextStyle(color: Color(0xFF8B8B9A), fontSize: 12)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onPlayAgain,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFF6584), Color(0xFF6C63FF)]),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text('REMATCH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onHome,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D44),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text('EXIT', style: TextStyle(color: Color(0xFF8B8B9A), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
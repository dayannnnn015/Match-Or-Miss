// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/ai_provider.dart';
import '../models/game_models.dart';
import '../services/secure_storage_service.dart';
import '../services/openai_service.dart' as ai_svc;
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
            onPressed: () => _openSettings(context),
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [Colors.cyan.withOpacity(0.3), Colors.transparent]),
        ),
        child: const Icon(Icons.psychology, size: 80, color: Colors.cyan),
      ),
      const SizedBox(height: 20),
      const Text('Train Your Brain',
          style: TextStyle(fontSize: 16, color: Colors.white70, letterSpacing: 1)),
    ]);
  }

  Widget _buildGameModes(BuildContext context) {
    return Column(children: [
      _buildModeCard(context, 'QUICK MODE', '4 Minutes • 12 Moves',
          'Relaxed — best for learning the mechanic', Colors.green, GameMode.quick),
      const SizedBox(height: 15),
      _buildModeCard(context, 'STANDARD MODE', '4 Minutes • 10 Moves',
          'Balanced — needs strategy, not just luck', Colors.blue, GameMode.standard),
      const SizedBox(height: 15),
      _buildModeCard(context, 'COMPETITIVE MODE', '3 Minutes • 8 Moves',
          'Max pressure — precision required, ranked scoring', Colors.orange, GameMode.competitive),
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
      onPressed: () => _openSettings(context),
      icon: const Icon(Icons.settings, color: Colors.white54),
      label: const Text('Game Settings', style: TextStyle(color: Colors.white54)),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()));
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
          Text('Leaderboard',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              Text('${i + 1}',
                  style: TextStyle(
                      color: i == 0 ? Colors.amber : Colors.white38,
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 12),
              Text('Player ${i + 1}',
                  style: const TextStyle(color: Colors.white60)),
              const Spacer(),
              const Text('—', style: TextStyle(color: Colors.white30)),
            ]),
          )),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE', style: TextStyle(color: Colors.cyan)),
          )
        ],
      ),
    );
  }
}

// ── Full Settings Screen ───────────────────────────────────────────────────────

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // AI key fields
  final _keyCtrl = TextEditingController();
  bool _showKey = false;
  String _selectedProvider = 'gemini';
  bool _keySaved = false;
  bool _testing = false;
  String _testResult = '';

  static const _providers = {
    'gemini':    ('Google Gemini',    'AIza...', 'aistudio.google.com/app/apikey'),
    'openai':    ('OpenAI (GPT-4)',   'sk-...',  'platform.openai.com/api-keys'),
    'anthropic': ('Claude (Anthropic)','sk-ant-...','console.anthropic.com'),
  };

  @override
  void initState() {
    super.initState();
    _loadSavedKey();
  }

  Future<void> _loadSavedKey() async {
    final key = await SecureStorageService.getAPIKey(_selectedProvider);
    if (key != null && key.isNotEmpty) {
      setState(() { _keyCtrl.text = key; _keySaved = true; });
    }
  }

  @override
  void dispose() { _keyCtrl.dispose(); super.dispose(); }

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
          child: Consumer<SettingsProvider>(
            builder: (context, settings, _) => Column(children: [
              // App bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('SETTINGS',
                      style: TextStyle(color: Colors.cyan, fontSize: 18,
                          fontWeight: FontWeight.bold, letterSpacing: 3,
                          shadows: [Shadow(color: Colors.cyan, blurRadius: 8)])),
                ]),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── AUDIO ──────────────────────────────────────────────
                    _sectionHeader('🔊  AUDIO', Colors.cyan),
                    const SizedBox(height: 10),

                    _settingsCard(children: [
                      _toggle(
                        label: 'Sound Effects',
                        subtitle: 'Swap, submit, win sounds',
                        icon: Icons.volume_up,
                        value: settings.sfxEnabled,
                        onChanged: (v) => settings.setSfx(v),
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      _toggle(
                        label: 'Background Music',
                        subtitle: 'Ambient loop while playing',
                        icon: Icons.music_note,
                        value: settings.musicEnabled,
                        onChanged: (v) => settings.setMusic(v),
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      _volumeSlider(settings),
                    ]),

                    const SizedBox(height: 20),

                    // ── GAMEPLAY ───────────────────────────────────────────
                    _sectionHeader('🎮  GAMEPLAY', Colors.green),
                    const SizedBox(height: 10),

                    _settingsCard(children: [
                      _toggle(
                        label: 'Show AI Hints',
                        subtitle: 'Tips after each submission',
                        icon: Icons.psychology,
                        value: settings.hintsEnabled,
                        onChanged: (v) => settings.setHints(v),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // ── AI PROVIDER ────────────────────────────────────────
                    _sectionHeader('🤖  AI ASSISTANT', Colors.purple),
                    const SizedBox(height: 10),

                    _settingsCard(children: [
                      // Provider picker
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('AI Provider',
                              style: TextStyle(color: Colors.white70,
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 10),
                          Row(children: _providers.entries.map((e) {
                            final sel = _selectedProvider == e.key;
                            return Expanded(child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  _selectedProvider = e.key;
                                  _keyCtrl.clear();
                                  _keySaved = false;
                                  _testResult = '';
                                });
                                await _loadSavedKey();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: sel ? Colors.purple.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: sel ? Colors.purple : Colors.white24,
                                      width: sel ? 1.5 : 1),
                                ),
                                child: Column(children: [
                                  Text(_providerIcon(e.key),
                                      style: const TextStyle(fontSize: 18)),
                                  const SizedBox(height: 4),
                                  Text(e.key == 'gemini' ? 'Gemini'
                                      : e.key == 'openai' ? 'OpenAI'
                                      : 'Claude',
                                      style: TextStyle(
                                          color: sel ? Colors.purple : Colors.white38,
                                          fontSize: 10, fontWeight: FontWeight.bold)),
                                ]),
                              ),
                            ));
                          }).toList()),

                          // Key hint
                          const SizedBox(height: 10),
                          Text('Get key: ${_providers[_selectedProvider]!.$3}',
                              style: const TextStyle(color: Colors.white38, fontSize: 10)),
                        ]),
                      ),

                      const Divider(color: Colors.white12, height: 1),

                      // API key input
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            const Text('API Key',
                                style: TextStyle(color: Colors.white70,
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const Spacer(),
                            if (_keySaved)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green.withOpacity(0.4)),
                                ),
                                child: const Row(children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 12),
                                  SizedBox(width: 4),
                                  Text('Saved', style: TextStyle(color: Colors.green,
                                      fontSize: 10, fontWeight: FontWeight.bold)),
                                ]),
                              ),
                          ]),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _keyCtrl,
                            obscureText: !_showKey,
                            style: const TextStyle(color: Colors.white, fontSize: 13,
                                fontFamily: 'monospace'),
                            decoration: InputDecoration(
                              hintText: _providers[_selectedProvider]!.$2,
                              hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.06),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.purple, width: 1.5)),
                              suffixIcon: IconButton(
                                icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.white38, size: 18),
                                onPressed: () => setState(() => _showKey = !_showKey),
                              ),
                            ),
                          ),

                          // Test result banner
                          if (_testResult.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: _testResult.startsWith('✅')
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _testResult.startsWith('✅')
                                      ? Colors.green.withOpacity(0.4)
                                      : Colors.red.withOpacity(0.4),
                                ),
                              ),
                              child: Text(_testResult,
                                  style: TextStyle(
                                      color: _testResult.startsWith('✅')
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                      fontSize: 12)),
                            ),

                          const SizedBox(height: 12),
                          Row(children: [
                            // Test button
                            Expanded(child: OutlinedButton(
                              onPressed: _testing ? null : _testKey,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.cyan,
                                side: const BorderSide(color: Colors.cyan),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: _testing
                                  ? const SizedBox(width: 16, height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyan))
                                  : const Text('TEST'),
                            )),
                            const SizedBox(width: 10),
                            // Save button
                            Expanded(child: ElevatedButton(
                              onPressed: _keyCtrl.text.trim().isEmpty ? null : _saveKey,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                disabledBackgroundColor: Colors.white12,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('SAVE KEY',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            )),
                            const SizedBox(width: 10),
                            // Clear button
                            OutlinedButton(
                              onPressed: _keySaved ? _clearKey : null,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Icon(Icons.delete_outline, size: 18),
                            ),
                          ]),
                          const SizedBox(height: 8),
                        ]),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // ── ABOUT ──────────────────────────────────────────────
                    _sectionHeader('ℹ️  ABOUT', Colors.white38),
                    const SizedBox(height: 10),
                    _settingsCard(children: [
                      _infoRow('Version', '1.0.0'),
                      const Divider(color: Colors.white12, height: 1),
                      _infoRow('Game', 'Match or Miss'),
                      const Divider(color: Colors.white12, height: 1),
                      _infoRow('How to play',
                          'Tap each bottle to set its color. Each color is used exactly once. '
                          'Submit your guess to see how many are in the correct position.'),
                    ]),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Future<void> _testKey() async {
    final key = _keyCtrl.text.trim();
    if (key.isEmpty) return;
    setState(() { _testing = true; _testResult = ''; });

    try {
      final svc = ai_svc.OpenAIService();
      svc.setApiKey(key, provider: _getProvider());
      // Minimal test — send a tiny prompt
      final result = await svc.getAIHint(
        attempts: [],
        currentMatches: 0,
        movesLeft: 10,
        timeRemaining: 300,
      );
      setState(() {
        _testResult = result.isNotEmpty
            ? '✅ Key works! AI responded successfully.'
            : '✅ Key accepted (empty response — try saving and playing).';
      });
    } catch (e) {
      setState(() => _testResult = '❌ Error: ${e.toString().substring(0, 80)}');
    }
    setState(() => _testing = false);
  }

  Future<void> _saveKey() async {
    final key = _keyCtrl.text.trim();
    if (key.isEmpty) return;
    await SecureStorageService.saveAPIKey(_selectedProvider, key);
    // Also apply to GameProvider's service immediately
    context.read<GameProvider>().setAndSaveApiKey(key, provider: _getProvider());
    setState(() { _keySaved = true; _testResult = ''; });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('API key saved securely on this device'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _clearKey() async {
    await SecureStorageService.deleteAPIKey(_selectedProvider);
    setState(() { _keyCtrl.clear(); _keySaved = false; _testResult = ''; });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('API key removed'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  ai_svc.AIProvider _getProvider() {
    switch (_selectedProvider) {
      case 'openai':    return ai_svc.AIProvider.openAI;
      case 'anthropic': return ai_svc.AIProvider.anthropic;
      default:          return ai_svc.AIProvider.googleGemini;
    }
  }

  String _providerIcon(String key) {
    switch (key) {
      case 'openai':    return '🤖';
      case 'anthropic': return '🧠';
      default:          return '✨';
    }
  }

  Widget _sectionHeader(String title, Color color) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 2),
    child: Text(title,
        style: TextStyle(color: color, fontSize: 12,
            fontWeight: FontWeight.bold, letterSpacing: 2)),
  );

  Widget _settingsCard({required List<Widget> children}) => Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    ),
    child: Column(children: children),
  );

  Widget _toggle({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Icon(icon, color: Colors.cyan, size: 22),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14,
              fontWeight: FontWeight.w600)),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ])),
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

  Widget _volumeSlider(SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(children: [
        const Icon(Icons.volume_mute, color: Colors.white38, size: 18),
        Expanded(
          child: Slider(
            value: settings.volume,
            onChanged: settings.sfxEnabled || settings.musicEnabled
                ? (v) => settings.setVolume(v)
                : null,
            activeColor: Colors.cyan,
            inactiveColor: Colors.white12,
          ),
        ),
        const Icon(Icons.volume_up, color: Colors.cyan, size: 18),
        const SizedBox(width: 6),
        Text('${(settings.volume * 100).round()}%',
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ]),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(width: 12),
        Expanded(child: Text(value,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.right)),
      ]),
    );
  }
}
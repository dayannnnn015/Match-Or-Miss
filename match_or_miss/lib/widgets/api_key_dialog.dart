// lib/widgets/api_key_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_provider.dart';
import '../providers/game_provider.dart';
import '../services/openai_service.dart' as ai_svc;

class APIKeyDialog extends StatefulWidget {
  const APIKeyDialog({super.key});

  @override
  _APIKeyDialogState createState() => _APIKeyDialogState();
}

class _APIKeyDialogState extends State<APIKeyDialog> {
  String _apiKey = '';
  AIProviderType _selectedProvider = AIProviderType.openAI;
  bool _showKey = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF1a1a2e),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            const Row(
              children: [
                Icon(Icons.smart_toy, color: Colors.cyanAccent, size: 28),
                SizedBox(width: 10),
                Text(
                  'Connect AI',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Unlock personalized AI insights after every game.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // ── Provider selector ────────────────────────────────────────
            const Text('Choose AI Provider:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            _buildProviderSelector(),
            const SizedBox(height: 20),

            // ── API Key field ────────────────────────────────────────────
            const Text('API Key:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            TextField(
              obscureText: !_showKey,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) => _apiKey = value,
              decoration: InputDecoration(
                hintText: 'Paste your API key here',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.07),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white38),
                  onPressed: () => setState(() => _showKey = !_showKey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.link, color: Colors.white24, size: 13),
                const SizedBox(width: 6),
                Text(
                  _getProviderHint(),
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),
              ],
            ),

            // ── What AI does ─────────────────────────────────────────────
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🤖 What the AI does after each game:',
                      style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('• Analyzes your move patterns & decision-making',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                  Text('• Identifies impulsive vs. methodical thinking',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                  Text('• Gives personalized tips to improve your score',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Actions ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: (_apiKey.trim().isNotEmpty && !_isSaving)
                      ? () => _connectAI(context)
                      : null,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.black)))
                      : const Icon(Icons.check, size: 18),
                  label: Text(_isSaving ? 'Connecting…' : 'Connect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.03),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildProviderOption(AIProviderType.anthropic, 'Claude', Icons.psychology),
          _buildProviderOption(AIProviderType.openAI, 'OpenAI', Icons.auto_awesome),
          _buildProviderOption(AIProviderType.googleGemini, 'Gemini', Icons.android),
          _buildProviderOption(AIProviderType.customAPI, 'Custom', Icons.api),
        ],
      ),
    );
  }

  Widget _buildProviderOption(AIProviderType provider, String label, IconData icon) {
    final isSelected = _selectedProvider == provider;
    return GestureDetector(
      onTap: () => setState(() => _selectedProvider = provider),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyanAccent.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.cyanAccent, width: 1.5) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.cyanAccent : Colors.white38, size: 22),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.cyanAccent : Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  String _getProviderHint() {
    switch (_selectedProvider) {
      case AIProviderType.anthropic:
        return 'console.anthropic.com';
      case AIProviderType.openAI:
        return 'platform.openai.com/api-keys';
      case AIProviderType.googleGemini:
        return 'aistudio.google.com/app/apikey';
      case AIProviderType.customAPI:
        return 'Your custom backend URL';
    }
  }

  ai_svc.AIProvider _mapToServiceProvider(AIProviderType p) {
    switch (p) {
      case AIProviderType.anthropic:    return ai_svc.AIProvider.anthropic;
      case AIProviderType.openAI:       return ai_svc.AIProvider.openAI;
      case AIProviderType.googleGemini: return ai_svc.AIProvider.googleGemini;
      case AIProviderType.customAPI:    return ai_svc.AIProvider.customAPI;
    }
  }

  Future<void> _connectAI(BuildContext context) async {
    setState(() => _isSaving = true);

    final key = _apiKey.trim();
    final serviceProvider = _mapToServiceProvider(_selectedProvider);

    // 1. Wire into AIProvider (hints / analysis screens)
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    aiProvider.enableAI(key, provider: _selectedProvider);

    // 2. Wire into GameProvider AND persist to secure storage so the key
    //    survives app restarts — no need to re-enter on every launch.
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    await gameProvider.setAndSaveApiKey(key, provider: serviceProvider);

    if (!mounted) return;

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('${_selectedProvider.name} AI connected! Key saved permanently.'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    Navigator.pop(context);
  }
}
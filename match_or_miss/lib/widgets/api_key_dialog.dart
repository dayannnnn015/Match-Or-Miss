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
  bool _showKey = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFFFBF3D4),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFBF3D4), Color(0xFFEEBBDD)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            const Row(
              children: [
                Icon(Icons.smart_toy, color: Color(0xFFC5A7CD), size: 28),
                SizedBox(width: 10),
                Text(
                  'Connect AI',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A3856)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Unlock personalized AI insights after every game.',
              style: TextStyle(color: Color(0xFF6B5A72), fontSize: 12),
            ),
            const SizedBox(height: 20),

            // ── API Key field ────────────────────────────────────────────
            const Text('API Key:', style: TextStyle(color: Color(0xFF4A3856), fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            TextField(
              obscureText: !_showKey,
              style: const TextStyle(color: Color(0xFF4A3856)),
              onChanged: (value) => _apiKey = value,
              decoration: InputDecoration(
                hintText: 'Paste your API key here',
                hintStyle: const TextStyle(color: Color(0xFF9B8AA3)),
                filled: true,
                fillColor: const Color(0xFFC5A7CD).withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFC5A7CD)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFC5A7CD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFC5A7CD), width: 2),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFFC5A7CD)),
                  onPressed: () => setState(() => _showKey = !_showKey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.link, color: Color(0xFFC5A7CD), size: 13),
                const SizedBox(width: 6),
                Text(
                  'platform.openai.com/api-keys',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B5A72)),
                ),
              ],
            ),

            // ── What AI does ─────────────────────────────────────────────
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFC5A7CD).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFC5A7CD).withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🤖 What the AI does after each game:',
                      style: TextStyle(color: Color(0xFFC5A7CD), fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('• Analyzes your move patterns & decision-making',
                      style: TextStyle(color: Color(0xFF6B5A72), fontSize: 11)),
                  Text('• Identifies impulsive vs. methodical thinking',
                      style: TextStyle(color: Color(0xFF6B5A72), fontSize: 11)),
                  Text('• Gives personalized tips to improve your score',
                      style: TextStyle(color: Color(0xFF6B5A72), fontSize: 11)),
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

  Future<void> _connectAI(BuildContext context) async {
    setState(() => _isSaving = true);

    final key = _apiKey.trim();
    final serviceProvider = ai_svc.AIProvider.openAI;

    // 1. Wire into AIProvider (hints / analysis screens)
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    aiProvider.enableAI(key, provider: AIProviderType.openAI);

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
            const Text('OpenAI connected! Key saved permanently.'),
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
// lib/widgets/api_key_dialog.dart - FIXED version
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_provider.dart';
import '../providers/game_provider.dart';
import '../services/openai_service.dart' as ai_svc;

class APIKeyDialog extends StatefulWidget {
  const APIKeyDialog({super.key});

  @override
  State<APIKeyDialog> createState() => _APIKeyDialogState();
}

class _APIKeyDialogState extends State<APIKeyDialog> {
  String _apiKey = '';
  bool _showKey = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      backgroundColor: const Color(0xFF1A1A2E),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF6C63FF), size: 28),
                SizedBox(width: 12),
                Text('NEURAL LINK', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Connect your AI key for real-time insights and performance analysis.',
              style: TextStyle(color: Color(0xFF8B8B9A), fontSize: 12),
            ),
            const SizedBox(height: 24),
            const Text('API KEY', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: 8),
            TextField(
              obscureText: !_showKey,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => _apiKey = v,
              decoration: InputDecoration(
                hintText: 'sk-...',
                hintStyle: const TextStyle(color: Color(0xFF4A4A5A)),
                filled: true,
                fillColor: const Color(0xFF0F0F1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF6C63FF)),
                  onPressed: () => setState(() => _showKey = !_showKey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.2)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚡ NEURAL FEATURES', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('• Real-time move analysis', style: TextStyle(color: Color(0xFF8B8B9A), fontSize: 11)),
                  Text('• Pattern recognition insights', style: TextStyle(color: Color(0xFF8B8B9A), fontSize: 11)),
                  Text('• Personalized improvement plans', style: TextStyle(color: Color(0xFF8B8B9A), fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: Color(0xFF4A4A5A), fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: (_apiKey.trim().isNotEmpty && !_isSaving) ? () => _connectAI() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('ACTIVATE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connectAI() async {
    setState(() => _isSaving = true);
    final key = _apiKey.trim();
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    aiProvider.enableAI(key, provider: AIProviderType.openAI);
    await gameProvider.setAndSaveApiKey(key, provider: ai_svc.AIProvider.openAI);
    
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('NEURAL LINK ESTABLISHED'),
            ],
          ),
        ),
      );
      Navigator.pop(context);
    }
  }
}
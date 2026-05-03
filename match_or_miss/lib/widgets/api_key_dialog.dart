// lib/widgets/api_key_dialog.dart - DUAL KEYS version
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/openai_service.dart' as ai_svc;

class APIKeyDialog extends StatefulWidget {
  const APIKeyDialog({super.key});

  @override
  State<APIKeyDialog> createState() => _APIKeyDialogState();
}

class _APIKeyDialogState extends State<APIKeyDialog> {
  String _geminiKey = '';
  String _openaiKey = '';
  bool _showGeminiKey = false;
  bool _showOpenaiKey = false;
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF6C63FF), size: 28),
                  SizedBox(width: 12),
                  Text('DUAL NEURAL LINK', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Add both AI providers for automatic fallback. (At least one required)',
                style: TextStyle(color: Color(0xFF8B8B9A), fontSize: 12),
              ),
              const SizedBox(height: 24),
              
              // Google Gemini Key
              const Text('GOOGLE GEMINI API KEY (Free & Fast)', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 8),
              TextField(
                obscureText: !_showGeminiKey,
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => _geminiKey = v,
                decoration: InputDecoration(
                  hintText: 'AIza... (optional)',
                  hintStyle: const TextStyle(color: Color(0xFF4A4A5A)),
                  filled: true,
                  fillColor: const Color(0xFF0F0F1A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_showGeminiKey ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF6C63FF)),
                    onPressed: () => setState(() => _showGeminiKey = !_showGeminiKey),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // OpenAI Key
              const Text('OPENAI API KEY (Reliable Backup)', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 8),
              TextField(
                obscureText: !_showOpenaiKey,
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => _openaiKey = v,
                decoration: InputDecoration(
                  hintText: 'sk-... (optional)',
                  hintStyle: const TextStyle(color: Color(0xFF4A4A5A)),
                  filled: true,
                  fillColor: const Color(0xFF0F0F1A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_showOpenaiKey ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF6C63FF)),
                    onPressed: () => setState(() => _showOpenaiKey = !_showOpenaiKey),
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
                    Text('⚡ DUAL MODE BENEFITS', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('• Gemini first (faster, free)', style: TextStyle(color: Color(0xFF8B8B9A), fontSize: 11)),
                    Text('• Falls back to OpenAI if needed', style: TextStyle(color: Color(0xFF8B8B9A), fontSize: 11)),
                    Text('• Automatic, no manual switching', style: TextStyle(color: Color(0xFF8B8B9A), fontSize: 11)),
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
                    onPressed: (_geminiKey.trim().isNotEmpty || _openaiKey.trim().isNotEmpty) && !_isSaving ? () => _connectAI() : null,
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
      ),
    );
  }

  Future<void> _connectAI() async {
    setState(() => _isSaving = true);
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    // Set dual keys in the service
    gameProvider.setDualAIKeys(
      geminiKey: _geminiKey.trim(),
      openaiKey: _openaiKey.trim(),
    );
    
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(_geminiKey.isNotEmpty && _openaiKey.isNotEmpty
                  ? 'DUAL NEURAL LINK ESTABLISHED (Gemini → OpenAI)'
                  : _geminiKey.isNotEmpty
                      ? 'NEURAL LINK ESTABLISHED (Gemini)'
                      : 'NEURAL LINK ESTABLISHED (OpenAI)'),
            ],
          ),
        ),
      );
      Navigator.pop(context);
    }
  }
}
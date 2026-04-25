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
  AIProviderType _selectedProvider = AIProviderType.anthropic; // default to Claude
  bool _showKey = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: Colors.cyan, size: 30),
                SizedBox(width: 10),
                Text(
                  'Connect AI Assistant',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Unlock real AI insights after each game.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            const Text('Choose AI Provider:'),
            const SizedBox(height: 10),
            _buildProviderSelector(),
            const SizedBox(height: 20),
            const Text('API Key:'),
            const SizedBox(height: 10),
            TextField(
              obscureText: !_showKey,
              onChanged: (value) => _apiKey = value,
              decoration: InputDecoration(
                hintText: 'Paste your API key here',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showKey = !_showKey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getProviderHint(),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _apiKey.trim().isNotEmpty ? () => _connectAI(context) : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Connect'),
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
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyan.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.cyan) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.cyan : Colors.grey),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.cyan : Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  String _getProviderHint() {
    switch (_selectedProvider) {
      case AIProviderType.anthropic:
        return 'Get your key at: console.anthropic.com';
      case AIProviderType.openAI:
        return 'Get your key at: platform.openai.com/api-keys';
      case AIProviderType.googleGemini:
        return 'Get your key at: aistudio.google.com/app/apikey';
      case AIProviderType.customAPI:
        return 'Enter your custom backend API endpoint URL';
    }
  }

  /// Maps the UI enum to the service-layer enum
  ai_svc.AIProvider _mapToServiceProvider(AIProviderType p) {
    switch (p) {
      case AIProviderType.anthropic:    return ai_svc.AIProvider.anthropic;
      case AIProviderType.openAI:       return ai_svc.AIProvider.openAI;
      case AIProviderType.googleGemini: return ai_svc.AIProvider.googleGemini;
      case AIProviderType.customAPI:    return ai_svc.AIProvider.customAPI;
    }
  }

  void _connectAI(BuildContext context) {
    final key = _apiKey.trim();
    final serviceProvider = _mapToServiceProvider(_selectedProvider);

    // 1. Wire into AIProvider (used by hints / analysis screens)
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    aiProvider.enableAI(key, provider: _selectedProvider);

    // 2. Wire into GameProvider (used by post-game insight in result dialog)
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.setAIApiKey(key, provider: serviceProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedProvider.name} connected — AI insights enabled!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}
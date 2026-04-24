// lib/widgets/api_key_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_provider.dart';

class APIKeyDialog extends StatefulWidget {
  const APIKeyDialog({super.key});

  @override
  _APIKeyDialogState createState() => _APIKeyDialogState();
}

class _APIKeyDialogState extends State<APIKeyDialog> {
  String _apiKey = '';
  AIProviderType _selectedProvider = AIProviderType.openAI;
  bool _saveKey = false;
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                hintText: 'Enter your API key',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showKey = !_showKey),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _getProviderHint(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _saveKey,
                  onChanged: (value) => setState(() => _saveKey = value ?? false),
                ),
                const Text('Save API key securely'),
              ],
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
                  onPressed: _apiKey.isNotEmpty
                      ? () => _connectAI(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
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
          _buildProviderOption(AIProviderType.openAI, 'OpenAI', Icons.auto_awesome),
          _buildProviderOption(AIProviderType.anthropic, 'Claude', Icons.psychology),
          _buildProviderOption(AIProviderType.googleGemini, 'Gemini', Icons.android),
          _buildProviderOption(AIProviderType.customAPI, 'Custom', Icons.api),
        ],
      ),
    );
  }
  
  Widget _buildProviderOption(AIProviderType provider, String label, IconData icon) {
    bool isSelected = _selectedProvider == provider;
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
            Text(label, style: TextStyle(
              color: isSelected ? Colors.cyan : Colors.grey,
              fontSize: 12,
            )),
          ],
        ),
      ),
    );
  }
  
  String _getProviderHint() {
    switch (_selectedProvider) {
      case AIProviderType.openAI:
        return 'Get API key from: platform.openai.com/api-keys';
      case AIProviderType.anthropic:
        return 'Get API key from: console.anthropic.com';
      case AIProviderType.googleGemini:
        return 'Get API key from: makersuite.google.com/app/apikey';
      case AIProviderType.customAPI:
        return 'Enter your custom API endpoint URL';
    }
  }
  
  void _connectAI(BuildContext context) {
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    aiProvider.enableAI(_apiKey, provider: _selectedProvider);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI Assistant connected successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.pop(context);
  }
}
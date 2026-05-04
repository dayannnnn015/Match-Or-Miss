// lib/utils/env_config.dart
class EnvConfig {
  // For development - never commit real API keys!
  static const String openAIKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  static const String anthropicKey = String.fromEnvironment('ANTHROPIC_API_KEY', defaultValue: '');
  static const String geminiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const String grokKey    = String.fromEnvironment('GROK_API_KEY',   defaultValue: '');
  
  // API endpoints
  static const String openAIEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String anthropicEndpoint = 'https://api.anthropic.com/v1/messages';
  static const String geminiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  // Feature flags
  static const bool enableAIByDefault = false;
  static const bool enableDetailedAnalytics = true;
  static const int maxAIHintsPerGame = 10;
}
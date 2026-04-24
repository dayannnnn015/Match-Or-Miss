// lib/providers/ai_provider.dart
import 'package:flutter/material.dart';
import '../services/openai_service.dart' as ai;
import '../models/game_models.dart';

class AIProvider extends ChangeNotifier {
  final ai.OpenAIService _aiService = ai.OpenAIService();
  
  bool _isAIEnabled = false;
  bool _isLoading = false;
  String _currentHint = "";
  AIPlayerAnalysis? _lastAnalysis;
  
  bool get isAIEnabled => _isAIEnabled;
  bool get isLoading => _isLoading;
  String get currentHint => _currentHint;
  AIPlayerAnalysis? get lastAnalysis => _lastAnalysis;
  
  void enableAI(String apiKey, {AIProviderType provider = AIProviderType.openAI}) {
    _aiService.setApiKey(apiKey, provider: _mapProvider(provider));
    _isAIEnabled = true;
    notifyListeners();
  }
  
  void disableAI() {
    _isAIEnabled = false;
    notifyListeners();
  }
  
  Future<void> getHint({
    required List<Attempt> attempts,
    required int currentMatches,
    required int movesLeft,
    required int timeRemaining,
  }) async {
    if (!_isAIEnabled) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final hint = await _aiService.getAIHint(
        attempts: attempts,
        currentMatches: currentMatches,
        movesLeft: movesLeft,
        timeRemaining: timeRemaining,
      );
      
      _currentHint = hint;
    } catch (e) {
      _currentHint = "AI temporarily unavailable. Using smart hints.";
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> analyzePerformance(List<Attempt> attempts) async {
    if (!_isAIEnabled || attempts.isEmpty) return;
    
    _isLoading = true;
    notifyListeners();
    
    _lastAnalysis = await _aiService.getDeepAnalysis(attempts);
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<String> analyzeGamePerformance({
    required List<Attempt> attempts,
    required int totalScore,
    required int totalMoves,
    required int timeSpent,
  }) async {
    try {
      final feedback = await _aiService.getGameCompletionFeedback(
        attempts: attempts,
        score: totalScore,
        moves: totalMoves,
        timeSpent: timeSpent,
      );
      return feedback;
    } catch (e) {
      return 'Great job completing the puzzle! Keep practicing to improve your score.';
    }
  }
  
  ai.AIProvider _mapProvider(AIProviderType provider) {
    switch (provider) {
      case AIProviderType.openAI:
        return ai.AIProvider.openAI;
      case AIProviderType.anthropic:
        return ai.AIProvider.anthropic;
      case AIProviderType.googleGemini:
        return ai.AIProvider.googleGemini;
      case AIProviderType.customAPI:
        return ai.AIProvider.customAPI;
    }
  }
  
  void clearHint() {
    _currentHint = "";
    notifyListeners();
  }
}

enum AIProviderType {
  openAI,
  anthropic,
  googleGemini,
  customAPI,
}
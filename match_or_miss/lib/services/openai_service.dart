// lib/services/openai_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/game_models.dart';

enum AIProvider {
  openAI,
  anthropic,    // Claude
  googleGemini,
  customAPI,
}

class OpenAIService {
  String? _apiKey;
  AIProvider _currentProvider = AIProvider.openAI;
  final Map<AIProvider, String> _apiEndpoints = {
    AIProvider.openAI: 'https://api.openai.com/v1/chat/completions',
    AIProvider.anthropic: 'https://api.anthropic.com/v1/messages',
    AIProvider.googleGemini: 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent',
  };
  
  void setApiKey(String key, {AIProvider provider = AIProvider.openAI}) {
    _apiKey = key;
    _currentProvider = provider;
  }
  
  Future<String> getAIHint({
    required List<Attempt> attempts,
    required int currentMatches,
    required int movesLeft,
    required int timeRemaining,
    String? playerId,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return _getFallbackHint(attempts, currentMatches);
    }
    
    try {
      final prompt = _buildPrompt(attempts, currentMatches, movesLeft, timeRemaining, playerId);
      
      switch (_currentProvider) {
        case AIProvider.openAI:
          return await _callOpenAI(prompt);
        case AIProvider.anthropic:
          return await _callAnthropic(prompt);
        case AIProvider.googleGemini:
          return await _callGemini(prompt);
        case AIProvider.customAPI:
          return await _callCustomAPI(prompt);
      }
    } catch (e) {
      print('AI API Error: $e');
      return _getFallbackHint(attempts, currentMatches);
    }
  }

  Future<String> getGameCompletionFeedback({
    required List<Attempt> attempts,
    required int score,
    required int moves,
    required int timeSpent,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return 'Great job completing the puzzle! Keep practicing to improve your score.';
    }
    
    try {
      final prompt = _buildCompletionPrompt(attempts, score, moves, timeSpent);
      
      switch (_currentProvider) {
        case AIProvider.openAI:
          return await _callOpenAI(prompt);
        case AIProvider.anthropic:
          return await _callAnthropic(prompt);
        case AIProvider.googleGemini:
          return await _callGemini(prompt);
        case AIProvider.customAPI:
          return await _callCustomAPI(prompt);
      }
    } catch (e) {
      print('Game Feedback API Error: $e');
      return 'Congratulations on completing the puzzle! Practice more games to develop better strategies.';
    }
  }
  
  String _buildCompletionPrompt(
    List<Attempt> attempts,
    int score,
    int moves,
    int timeSpent,
  ) {
    return '''You are a cognitive training AI providing personalized feedback for the game "Match or Miss".

The player just completed a puzzle with these results:
- Score: $score
- Moves used: $moves out of 12 allowed
- Time spent: ${timeSpent ~/ 60} minutes ${timeSpent % 60} seconds
- Total attempts: ${attempts.length}

Move History:
${_formatAttemptHistory(attempts)}

Provide encouraging, specific feedback on their performance. Focus on:
1. What they did well (strategy, decision-making, efficiency)
2. One area to improve
3. A tip for the next game

Keep it concise (3-4 sentences), positive, and actionable.''';
  }
  
  String _buildPrompt(
    List<Attempt> attempts,
    int currentMatches,
    int movesLeft,
    int timeRemaining,
    String? playerId,
  ) {
    return '''
You are an expert cognitive training AI for the game "Match or Miss" - a puzzle game training executive functions.

GAME CONTEXT:
- Player must decode a hidden sequence of 8 colored bottles
- Only told how many are correct (matches), not which positions
- Has $movesLeft moves remaining
- Has $timeRemaining seconds remaining
- Current matches: $currentMatches/8

ATTEMPT HISTORY:
${_formatAttemptHistory(attempts)}

PLAYER STATISTICS:
- Total attempts: ${attempts.length}
- Average variables changed per move: ${_calculateAvgChanges(attempts)}
- Progress rate: ${_calculateProgressRate(attempts)}
- Impulsive moves detected: ${_countImpulsiveMoves(attempts)}

Based on this data, provide a short, actionable hint (max 100 characters) that:
1. Encourages systematic thinking
2. Addresses specific mistakes in their strategy
3. Suggests a concrete next action
4. Uses positive, motivating language

Be specific and tactical. Don't just say "keep trying" - give actual strategy advice.

HINT:''';
  }
  
  String _formatAttemptHistory(List<Attempt> attempts) {
    if (attempts.isEmpty) return "No attempts yet.";
    
    StringBuffer history = StringBuffer();
    for (int i = max(0, attempts.length - 5); i < attempts.length; i++) {
      final a = attempts[i];
      history.writeln(
        "Move ${a.attemptNumber}: ${a.matches}/8 matches, "
        "changed ${a.variablesChanged} bottles, "
        "${a.wasImpulsive ? 'IMPULSIVE' : 'methodical'}"
      );
    }
    return history.toString();
  }
  
  double _calculateAvgChanges(List<Attempt> attempts) {
    if (attempts.isEmpty) return 0;
    return attempts.map((a) => a.variablesChanged.toDouble()).reduce((a, b) => a + b) / attempts.length;
  }
  
  double _calculateProgressRate(List<Attempt> attempts) {
    if (attempts.length < 2) return 0;
    return (attempts.last.matches - attempts.first.matches) / attempts.length;
  }
  
  int _countImpulsiveMoves(List<Attempt> attempts) {
    return attempts.where((a) => a.wasImpulsive).length;
  }
  
  Future<String> _callOpenAI(String prompt) async {
    final response = await http.post(
      Uri.parse(_apiEndpoints[AIProvider.openAI]!),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4-turbo-preview', // or 'gpt-3.5-turbo' for lower cost
        'messages': [
          {
            'role': 'system',
            'content': 'You are a cognitive training expert. Provide concise, actionable hints for a puzzle game.',
          },
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'max_tokens': 150,
        'temperature': 0.7,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('OpenAI API error: ${response.statusCode}');
    }
  }
  
  Future<String> _callAnthropic(String prompt) async {
    final response = await http.post(
      Uri.parse(_apiEndpoints[AIProvider.anthropic]!),
      headers: {
        'x-api-key': _apiKey!,
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'claude-3-opus-20240229',
        'max_tokens': 150,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'].trim();
    } else {
      throw Exception('Anthropic API error: ${response.statusCode}');
    }
  }
  
  Future<String> _callGemini(String prompt) async {
    final response = await http.post(
      Uri.parse('${_apiEndpoints[AIProvider.googleGemini]!}?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'maxOutputTokens': 150,
          'temperature': 0.7,
        }
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'].trim();
    } else {
      throw Exception('Gemini API error: ${response.statusCode}');
    }
  }
  
  Future<String> _callCustomAPI(String prompt) async {
    // For custom backend API
    final response = await http.post(
      Uri.parse('https://your-backend.com/api/ai-hint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt,
        'apiKey': _apiKey,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['hint'];
    } else {
      throw Exception('Custom API error: ${response.statusCode}');
    }
  }
  
  String _getFallbackHint(List<Attempt> attempts, int currentMatches) {
    if (attempts.isEmpty) {
      return "🎮 Start with all bottles the same color to find how many match!";
    }
    
    final lastAttempt = attempts.last;
    
    if (lastAttempt.variablesChanged > 3) {
      return "🎯 You changed ${lastAttempt.variablesChanged} bottles. Try changing just 1-2 at a time!";
    }
    
    if (currentMatches == 0 && attempts.length > 2) {
      return "💡 No matches yet. Try a completely different color pattern.";
    }
    
    if (currentMatches > 0 && currentMatches < 4) {
      return "👍 Keep your $currentMatches matches and change the other bottles systematically.";
    }
    
    return "🧠 Methodical changes lead to solutions. What's your hypothesis for this move?";
  }
  
  Future<AIPlayerAnalysis> getDeepAnalysis(List<Attempt> attempts) async {
    if (_apiKey == null || attempts.isEmpty) {
      return _getBasicAnalysis(attempts);
    }
    
    try {
      final analysisPrompt = '''
Analyze this player's performance in a cognitive puzzle game:

${_formatAttemptHistory(attempts)}

Provide analysis in JSON format:
{
  "strengths": ["strength1", "strength2"],
  "weaknesses": ["weakness1", "weakness2"],
  "cognitiveProfile": "description of cognitive style",
  "suggestions": ["suggestion1", "suggestion2", "suggestion3"],
  "estimatedSkillLevel": 1-10,
  "efficiencyScore": 0-100
}
''';
      
      final response = await _callOpenAI(analysisPrompt);
      // Parse JSON response
      final jsonStr = response.substring(response.indexOf('{'), response.lastIndexOf('}') + 1);
      final data = jsonDecode(jsonStr);
      
      return AIPlayerAnalysis(
        avgVariablesChanged: _calculateAvgChanges(attempts),
        impulsiveMoves: _countImpulsiveMoves(attempts),
        repeatedMistakes: _countRepeatedMistakes(attempts),
        progressRate: _calculateProgressRate(attempts),
        suggestions: List<String>.from(data['suggestions']),
        moveEfficiencies: _calculateMoveEfficiencies(attempts),
        strengths: List<String>.from(data['strengths']),
        weaknesses: List<String>.from(data['weaknesses']),
        cognitiveProfile: data['cognitiveProfile'],
        estimatedSkillLevel: data['estimatedSkillLevel'],
        efficiencyScore: data['efficiencyScore'],
      );
    } catch (e) {
      print('Deep analysis error: $e');
      return _getBasicAnalysis(attempts);
    }
  }
  
  int _countRepeatedMistakes(List<Attempt> attempts) {
    int repeats = 0;
    for (int i = 1; i < attempts.length; i++) {
      if (attempts[i].matches == attempts[i-1].matches && 
          attempts[i].guess != attempts[i-1].guess) {
        repeats++;
      }
    }
    return repeats;
  }
  
  List<MoveEfficiency> _calculateMoveEfficiencies(List<Attempt> attempts) {
    List<MoveEfficiency> efficiencies = [];
    for (int i = 0; i < attempts.length; i++) {
      double efficiency = i == 0 
          ? attempts[i].matches / 8.0 
          : (attempts[i].matches - attempts[i-1].matches) / 8.0;
      
      efficiencies.add(MoveEfficiency(
        moveNumber: i + 1,
        efficiency: efficiency,
        feedback: efficiency > 0 
            ? "Improved by ${(efficiency * 8).round()} match(es)" 
            : "No improvement",
      ));
    }
    return efficiencies;
  }
  
  AIPlayerAnalysis _getBasicAnalysis(List<Attempt> attempts) {
    return AIPlayerAnalysis(
      avgVariablesChanged: _calculateAvgChanges(attempts),
      impulsiveMoves: _countImpulsiveMoves(attempts),
      repeatedMistakes: _countRepeatedMistakes(attempts),
      progressRate: _calculateProgressRate(attempts),
      suggestions: [
        "Try changing only 1-2 bottles per move",
        "Keep successful matches in place",
        "Use a systematic testing strategy",
      ],
      moveEfficiencies: _calculateMoveEfficiencies(attempts),
      strengths: [],
      weaknesses: [],
      cognitiveProfile: "Analyzing...",
      estimatedSkillLevel: 5,
      efficiencyScore: _calculateEfficiencyScore(attempts),
    );
  }
  
  double _calculateEfficiencyScore(List<Attempt> attempts) {
    if (attempts.isEmpty) return 0;
    final progressRate = _calculateProgressRate(attempts);
    final avgChanges = _calculateAvgChanges(attempts);
    return (progressRate * 100) - (avgChanges * 5);
  }
}
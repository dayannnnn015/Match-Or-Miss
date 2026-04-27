// lib/services/openai_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/game_models.dart';

enum AIProvider {
  openAI,
  anthropic, // Claude
  googleGemini,
  customAPI,
}

class OpenAIService {
  String? _apiKey;
  AIProvider _currentProvider = AIProvider.googleGemini;

  final Map<AIProvider, String> _apiEndpoints = {
    AIProvider.openAI: 'https://api.openai.com/v1/chat/completions',
    AIProvider.anthropic: 'https://api.anthropic.com/v1/messages',
    AIProvider.googleGemini:
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent',
  };

  // Timeout prevents the submit button from hanging forever
  static const Duration _timeout = Duration(seconds: 15);

  void setApiKey(String key, {AIProvider provider = AIProvider.openAI}) {
    _apiKey = key.trim();
    _currentProvider = provider;
  }

  bool get hasValidKey {
    // Gemini and other providers need an API key
    return _apiKey != null && _apiKey!.isNotEmpty;
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<String> getAIHint({
    required List<Attempt> attempts,
    required int currentMatches,
    required int movesLeft,
    required int timeRemaining,
    String? playerId,
  }) async {
    if (!hasValidKey) {
      return _getFallbackHint(attempts, currentMatches);
    }
    try {
      final prompt = _buildHintPrompt(attempts, currentMatches, movesLeft, timeRemaining, playerId);
      return await _dispatch(prompt);
    } catch (e) {
      return _getFallbackHint(attempts, currentMatches);
    }
  }

  Future<String> getGameCompletionFeedback({
    required List<Attempt> attempts,
    required int score,
    required int moves,
    required int timeSpent,
  }) async {
    if (!hasValidKey) {
      return _buildLocalFeedback(attempts, score, moves, timeSpent);
    }
    try {
      final prompt = _buildCompletionPrompt(attempts, score, moves, timeSpent);
      final result = await _dispatch(prompt);
      return result.isEmpty ? _buildLocalFeedback(attempts, score, moves, timeSpent) : result;
    } catch (e) {
      return _buildLocalFeedback(attempts, score, moves, timeSpent);
    }
  }

  Future<AIPlayerAnalysis> getDeepAnalysis(List<Attempt> attempts) async {
    if (!hasValidKey || attempts.isEmpty) {
      return _getBasicAnalysis(attempts);
    }
    try {
      final analysisPrompt = '''
Analyze this player in a cognitive puzzle game.

${_formatAttemptHistory(attempts)}

Respond ONLY with valid JSON (no markdown, no explanation):
{
  "strengths": ["strength1", "strength2"],
  "weaknesses": ["weakness1", "weakness2"],
  "cognitiveProfile": "brief description",
  "suggestions": ["tip1", "tip2", "tip3"],
  "estimatedSkillLevel": 5,
  "efficiencyScore": 60
}
''';
      final response = await _dispatch(analysisPrompt);
      final start = response.indexOf('{');
      final end = response.lastIndexOf('}');
      if (start == -1 || end == -1) return _getBasicAnalysis(attempts);
      final data = jsonDecode(response.substring(start, end + 1));
      return AIPlayerAnalysis(
        avgVariablesChanged: _calculateAvgChanges(attempts),
        impulsiveMoves: _countImpulsiveMoves(attempts),
        repeatedMistakes: _countRepeatedMistakes(attempts),
        progressRate: _calculateProgressRate(attempts),
        suggestions: List<String>.from(data['suggestions'] ?? []),
        moveEfficiencies: _calculateMoveEfficiencies(attempts),
        strengths: List<String>.from(data['strengths'] ?? []),
        weaknesses: List<String>.from(data['weaknesses'] ?? []),
        cognitiveProfile: data['cognitiveProfile'] ?? '',
        estimatedSkillLevel: (data['estimatedSkillLevel'] as num?)?.toInt() ?? 5,
        efficiencyScore: (data['efficiencyScore'] as num?)?.toDouble() ?? 50.0,
      );
    } catch (e) {
      return _getBasicAnalysis(attempts);
    }
  }

  // ─── Router ────────────────────────────────────────────────────────────────

  Future<String> _dispatch(String prompt) {
    switch (_currentProvider) {
      case AIProvider.openAI:      return _callOpenAI(prompt);
      case AIProvider.anthropic:   return _callAnthropic(prompt);
      case AIProvider.googleGemini: return _callGemini(prompt);
      case AIProvider.customAPI:   return _callCustomAPI(prompt);
    }
  }

  // ─── Provider calls ────────────────────────────────────────────────────────

  Future<String> _callOpenAI(String prompt) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }
    final response = await http.post(
      Uri.parse(_apiEndpoints[AIProvider.openAI]!),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a cognitive training expert. Provide concise, actionable feedback for a puzzle game.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 200,
        'temperature': 0.7,
      }),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['choices'][0]['message']['content'] as String).trim();
    }
    throw Exception('OpenAI error ${response.statusCode}: ${response.body}');
  }

  Future<String> _callAnthropic(String prompt) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('Anthropic API key not configured');
    }
    final response = await http.post(
      Uri.parse(_apiEndpoints[AIProvider.anthropic]!),
      headers: {
        'x-api-key': _apiKey!,
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'claude-haiku-4-5-20251001', // fast & affordable
        'max_tokens': 200,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['content'][0]['text'] as String).trim();
    }
    throw Exception('Anthropic error ${response.statusCode}: ${response.body}');
  }

  Future<String> _callGemini(String prompt) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('Gemini API key not configured. Get a free key from Google AI Studio');
    }
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
          'maxOutputTokens': 200,
          'temperature': 0.7,
        },
      }),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['candidates'][0]['content']['parts'][0]['text'] as String).trim();
    }
    throw Exception('Gemini error ${response.statusCode}: ${response.body}');
  }

  Future<String> _callCustomAPI(String prompt) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('Custom API key not configured');
    }
    final response = await http.post(
      Uri.parse('https://your-backend.com/api/ai-hint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt, 'apiKey': _apiKey}),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['hint'] as String;
    }
    throw Exception('Custom API error ${response.statusCode}');
  }

  // ─── Prompt builders ───────────────────────────────────────────────────────

  int _sequenceLengthFromAttempts(List<Attempt> attempts) {
    if (attempts.isEmpty) return 8;
    return attempts.first.guess.length;
  }

  String _buildCompletionPrompt(List<Attempt> attempts, int score, int moves, int timeSpent) {
    final sequenceLength = _sequenceLengthFromAttempts(attempts);
    return '''You are a cognitive coach analyzing a player's puzzle-solving strategy in "Match or Miss" (a $sequenceLength-bottle color sequence puzzle).

PLAYER PERFORMANCE:
- Final Score: $score
- Moves Used: $moves
- Time Spent: ${timeSpent ~/ 60}m ${timeSpent % 60}s
- Total Attempts: ${attempts.length}

MOVE ANALYSIS:
${_formatAttemptHistory(attempts)}

STRATEGY METRICS:
- Average bottles changed per move: ${_calculateAvgChanges(attempts).toStringAsFixed(1)}
- Impulsive moves (>3 changes with no improvement): ${_countImpulsiveMoves(attempts)}
- Progress rate: ${_calculateProgressRate(attempts).toStringAsFixed(2)} matches per move
- Peak performance: ${attempts.isEmpty ? 0 : attempts.map((a) => a.matches).reduce((a, b) => a > b ? a : b)}/$sequenceLength matches

FEEDBACK FOCUS: Analyze their decision-making patterns and how they can improve.

Write 4-5 sentences covering:
1. What their move pattern reveals about their thinking strategy (methodical vs impulsive)
2. One specific strength they demonstrated
3. One area to improve in their approach
4. A concrete, actionable tip for better performance next time

Write as flowing sentences, no bullet points. Be encouraging but honest.''';
  }

  String _buildHintPrompt(List<Attempt> attempts, int currentMatches, int movesLeft, int timeRemaining, String? playerId) {
    final sequenceLength = _sequenceLengthFromAttempts(attempts);
    return '''
You are a cognitive training AI for "Match or Miss" ($sequenceLength-bottle color sequence puzzle, each color used exactly once).

State: $movesLeft moves left, $timeRemaining seconds, $currentMatches/$sequenceLength matches.

Recent moves:
${_formatAttemptHistory(attempts)}

Avg bottles changed: ${_calculateAvgChanges(attempts).toStringAsFixed(1)}, impulsive moves: ${_countImpulsiveMoves(attempts)}.

Write ONE tactical hint, max 100 characters. Be specific, not generic.

HINT:''';
  }

  // ─── Analytics helpers ─────────────────────────────────────────────────────

  String _formatAttemptHistory(List<Attempt> attempts) {
    if (attempts.isEmpty) return 'No attempts yet.';
    final sequenceLength = _sequenceLengthFromAttempts(attempts);
    final buf = StringBuffer();
    for (int i = max(0, attempts.length - 5); i < attempts.length; i++) {
      final a = attempts[i];
      buf.writeln(
          'Move ${a.attemptNumber}: ${a.matches}/$sequenceLength matches, '
          'changed ${a.variablesChanged} bottles, '
          '${a.wasImpulsive ? 'IMPULSIVE' : 'methodical'}');
    }
    return buf.toString();
  }

  double _calculateAvgChanges(List<Attempt> attempts) {
    if (attempts.isEmpty) return 0;
    return attempts.map((a) => a.variablesChanged.toDouble()).reduce((a, b) => a + b) /
        attempts.length;
  }

  double _calculateProgressRate(List<Attempt> attempts) {
    if (attempts.length < 2) return 0;
    return (attempts.last.matches - attempts.first.matches) / attempts.length;
  }

  int _countImpulsiveMoves(List<Attempt> attempts) => attempts.where((a) => a.wasImpulsive).length;

  int _countRepeatedMistakes(List<Attempt> attempts) {
    int repeats = 0;
    for (int i = 1; i < attempts.length; i++) {
      if (attempts[i].matches == attempts[i - 1].matches &&
          attempts[i].guess != attempts[i - 1].guess) {
        repeats++;
      }
    }
    return repeats;
  }

  List<MoveEfficiency> _calculateMoveEfficiencies(List<Attempt> attempts) {
    final sequenceLength = _sequenceLengthFromAttempts(attempts);
    return List.generate(attempts.length, (i) {
      final eff = i == 0
          ? attempts[i].matches / sequenceLength
          : (attempts[i].matches - attempts[i - 1].matches) / sequenceLength;
      return MoveEfficiency(
        moveNumber: i + 1,
        efficiency: eff,
        feedback: eff > 0 ? 'Improved by ${(eff * sequenceLength).round()} match(es)' : 'No improvement',
      );
    });
  }

  double _calculateEfficiencyScore(List<Attempt> attempts) {
    if (attempts.isEmpty) return 0;
    return (_calculateProgressRate(attempts) * 100) - (_calculateAvgChanges(attempts) * 5);
  }

  // ─── Local fallbacks ───────────────────────────────────────────────────────

  String _getFallbackHint(List<Attempt> attempts, int currentMatches) {
    if (attempts.isEmpty) {
      return '🎮 Each color is used exactly once. Try locking in colors you know.';
    }
    final last = attempts.last;
    if (last.variablesChanged > 3) {
      return '🎯 You changed ${last.variablesChanged} bottles. Try 1–2 at a time for cleaner data.';
    }
    if (currentMatches == 0 && attempts.length > 2) {
      return '💡 Zero matches — every color is wrong. Rotate all bottles to a fresh pattern.';
    }
    if (currentMatches > 0 && currentMatches < 4) {
      return '👍 Keep your $currentMatches matches fixed and swap the remaining ones.';
    }
    return '🧠 Systematic swaps reveal the answer. What\'s your hypothesis?';
  }

  String _buildLocalFeedback(List<Attempt> attempts, int score, int moves, int timeSpent) {
    if (attempts.isEmpty) return 'Complete a game to see your analysis!';
    final sequenceLength = _sequenceLengthFromAttempts(attempts);
    final best = attempts.reduce((a, b) => a.matches > b.matches ? a : b);
    final avgChanged = attempts.map((a) => a.variablesChanged).reduce((a, b) => a + b) / attempts.length;
    final impulsive = attempts.where((a) => a.wasImpulsive).length;
    final buf = StringBuffer();
    buf.write('Your best move was move ${best.attemptNumber} with ${best.matches}/$sequenceLength matches. ');
    buf.write(impulsive == 0
        ? 'Great discipline — no impulsive moves detected! '
        : '$impulsive impulsive move(s) detected; slowing down helps isolate variables. ');
    buf.write(avgChanged > 2.5
        ? 'Try swapping only 1–2 bottles per move for cleaner feedback each round.'
        : 'Your methodical approach is working — keep isolating one variable at a time.');
    return buf.toString();
  }

  AIPlayerAnalysis _getBasicAnalysis(List<Attempt> attempts) {
    return AIPlayerAnalysis(
      avgVariablesChanged: _calculateAvgChanges(attempts),
      impulsiveMoves: _countImpulsiveMoves(attempts),
      repeatedMistakes: _countRepeatedMistakes(attempts),
      progressRate: _calculateProgressRate(attempts),
      suggestions: [
        'Try changing only 1–2 bottles per move',
        'Keep successful matches in place',
        'Use a systematic testing strategy',
      ],
      moveEfficiencies: _calculateMoveEfficiencies(attempts),
      strengths: [],
      weaknesses: [],
      cognitiveProfile: 'Analyzing...',
      estimatedSkillLevel: 5,
      efficiencyScore: _calculateEfficiencyScore(attempts),
    );
  }
}
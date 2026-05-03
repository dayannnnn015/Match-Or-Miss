// lib/services/openai_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/game_models.dart';

enum AIProvider {
  openAI,
  anthropic, // Claude
  googleGemini,
  grok,       // xAI Grok
  customAPI,
}

class OpenAIService {
  String? _apiKey;
  String? _geminiKey; // For dual-key fallback
  String? _openaiKey; // For dual-key fallback
  AIProvider _currentProvider = AIProvider.openAI;

  final Map<AIProvider, String> _apiEndpoints = {
    AIProvider.openAI: 'https://api.openai.com/v1/chat/completions',
    AIProvider.anthropic: 'https://api.anthropic.com/v1/messages',
    AIProvider.googleGemini:
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent',
    AIProvider.grok: 'https://api.x.ai/v1/chat/completions',
  };

  static const Duration _timeout = Duration(seconds: 15);

  void setApiKey(String key, {AIProvider provider = AIProvider.openAI}) {
    _apiKey = key.trim();
    _currentProvider = provider;
  }

  bool get hasValidKey {
    return (_apiKey != null && _apiKey!.isNotEmpty) ||
           (_geminiKey != null && _geminiKey!.isNotEmpty) ||
           (_openaiKey != null && _openaiKey!.isNotEmpty);
  }

  /// Set both Gemini and OpenAI keys for automatic fallback
  void setDualKeys({String? geminiKey, String? openaiKey}) {
    if (geminiKey != null && geminiKey.isNotEmpty) _geminiKey = geminiKey.trim();
    if (openaiKey != null && openaiKey.isNotEmpty) _openaiKey = openaiKey.trim();
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

  Future<String> _dispatch(String prompt) async {
    // Single-provider mode (key set via setApiKey)
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      switch (_currentProvider) {
        case AIProvider.openAI:       return _callOpenAI(prompt);
        case AIProvider.anthropic:    return _callAnthropic(prompt);
        case AIProvider.googleGemini: return _callGemini(prompt);
        case AIProvider.grok:         return _callGrok(prompt);
        case AIProvider.customAPI:    return _callCustomAPI(prompt);
      }
    }

    // Dual-key fallback mode: Gemini first, then OpenAI
    if (_geminiKey != null && _geminiKey!.isNotEmpty) {
      try {
        final saved = _apiKey;
        _apiKey = _geminiKey;
        _currentProvider = AIProvider.googleGemini;
        final result = await _callGemini(prompt);
        _apiKey = saved;
        return result;
      } catch (_) {
        // Gemini failed — try OpenAI
      }
    }
    if (_openaiKey != null && _openaiKey!.isNotEmpty) {
      final saved = _apiKey;
      _apiKey = _openaiKey;
      _currentProvider = AIProvider.openAI;
      final result = await _callOpenAI(prompt);
      _apiKey = saved;
      return result;
    }

    throw Exception('No valid AI keys configured');
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
        'model': 'claude-haiku-4-5-20251001',
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
    // On web, route through local proxy to avoid CORS
    if (kIsWeb) return _callGeminiViaProxy(prompt);

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
          'maxOutputTokens': 400,
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

  Future<String> _callGeminiViaProxy(String prompt) async {
    const proxyUrl = 'http://localhost:3000/ai';
    final response = await http.post(
      Uri.parse(proxyUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    ).timeout(_timeout);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['insight'] as String).trim();
    }
    throw Exception('Gemini proxy error ${response.statusCode}: ${response.body}');
  }


  Future<String> _callGrok(String prompt) async {
    // On web: call local proxy to avoid CORS restrictions
    // On mobile/desktop: call Grok directly
    if (kIsWeb) {
      return _callGrokViaProxy(prompt);
    }

    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('Grok API key not configured. Get one at console.x.ai');
    }
    final response = await http.post(
      Uri.parse(_apiEndpoints[AIProvider.grok]!),
      headers: {
        'Authorization': 'Bearer \$_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'grok-3',
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
    throw Exception('Grok error \${response.statusCode}: \${response.body}');
  }

  Future<String> _callGrokViaProxy(String prompt) async {
    // Calls the local Node.js proxy server which forwards to Gemini
    // Start proxy: GEMINI_API_KEY=your-key node server.js
    const proxyUrl = 'http://localhost:3000/ai';
    final response = await http.post(
      Uri.parse(proxyUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['insight'] as String).trim();
    }
    throw Exception('Proxy error \${response.statusCode}: \${response.body}');
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
    final avgChanges = _calculateAvgChanges(attempts).toStringAsFixed(1);
    final impulsive = _countImpulsiveMoves(attempts);
    final progressRate = _calculateProgressRate(attempts).toStringAsFixed(2);
    final peak = attempts.isEmpty ? 0 : attempts.map((a) => a.matches).reduce((a, b) => a > b ? a : b);
    final won = attempts.isNotEmpty && attempts.last.matches == sequenceLength;
    return 'Game coach feedback for Match or Miss puzzle. Stats: ${won ? "WON" : "LOST"}, $score pts, $moves swaps, best $peak/$sequenceLength, $impulsive impulsive moves, avg $avgChanges changed/swap. Write exactly 2 sentences under 30 words total using their exact numbers. Be casual, end with a tip.';
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
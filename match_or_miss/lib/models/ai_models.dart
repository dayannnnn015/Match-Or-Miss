enum AiDifficulty { easy, medium, hard }

class AiHint {
  const AiHint({
    required this.message,
    this.confidence = 0.5,
  });

  final String message;
  final double confidence;
}

class AiAnalysisResult {
  const AiAnalysisResult({
    required this.summary,
    this.recommendedNextGuess = const [],
  });

  final String summary;
  final List<int> recommendedNextGuess;
}

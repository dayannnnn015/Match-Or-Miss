class Player {
  const Player({
    required this.id,
    required this.name,
    this.score = 0,
  });

  final String id;
  final String name;
  final int score;
}

class PlayerStats {
  const PlayerStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.bestTimeSeconds,
  });

  final int gamesPlayed;
  final int gamesWon;
  final int? bestTimeSeconds;
}

import 'package:flutter/foundation.dart';

import '../models/game_models.dart';
import '../models/player_models.dart';

class MultiplayerProvider extends ChangeNotifier {
  final List<Player> _players = [];
  String? _currentRoomId;
  GameMode? _currentMode;

  List<Player> get players => List.unmodifiable(_players);
  String? get currentRoomId => _currentRoomId;
  GameMode? get currentMode => _currentMode;

  void setPlayers(List<Player> players) {
    _players
      ..clear()
      ..addAll(players);
    notifyListeners();
  }

  void clearPlayers() {
    _players.clear();
    notifyListeners();
  }

  Future<void> createRoom(GameMode mode) async {
    _currentMode = mode;
    _currentRoomId = DateTime.now().millisecondsSinceEpoch.toString();
    notifyListeners();
  }

  Future<void> joinRoom(String roomId) async {
    if (roomId.trim().isEmpty) return;
    _currentRoomId = roomId.trim();
    notifyListeners();
  }

  void leaveRoom() {
    _currentRoomId = null;
    _currentMode = null;
    notifyListeners();
  }
}

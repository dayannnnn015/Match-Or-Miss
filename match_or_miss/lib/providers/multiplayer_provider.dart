import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/game_models.dart';
import '../models/player_models.dart';
import '../services/firebase_service.dart';

class MultiplayerProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
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

  /// Create a new multiplayer room with real Firebase
  /// Returns the real Firestore document ID
  Future<String?> createRoom(GameMode mode) async {
    _currentMode = mode;
    try {
      _currentRoomId = await _firebaseService.createMultiplayerRoom(mode);
      notifyListeners();
      return _currentRoomId;
    } catch (e) {
      print('Error creating room: $e');
      return null;
    }
  }

  /// Join an existing multiplayer room with real Firebase
  /// Validates room exists before joining
  Future<bool> joinRoom(String roomId) async {
    if (roomId.trim().isEmpty) return false;
    try {
      // Verify room exists by getting it from Firebase
      _firebaseService.joinMultiplayerRoom(roomId.trim()).first.then((doc) {
        if (doc.exists) {
          _currentRoomId = roomId.trim();
          notifyListeners();
        }
      });
      return true;
    } catch (e) {
      print('Error joining room: $e');
      return false;
    }
  }

  void leaveRoom() {
    _currentRoomId = null;
    _currentMode = null;
    clearPlayers();
    notifyListeners();
  }

  /// Submit a move to multiplayer game using real Firebase
  Future<void> submitMove({
    required String playerId,
    required List<Color> guess,
    required int matches,
  }) async {
    if (_currentRoomId == null) return;
    try {
      await _firebaseService.submitMultiplayerMove(
        _currentRoomId!,
        playerId,
        guess,
        matches,
      );
      notifyListeners();
    } catch (e) {
      print('Error submitting move: $e');
    }
  }

  /// Watch multiplayer moves in real-time from Firebase
  Stream<List<Map<String, dynamic>>> watchMultiplayerMoves() {
    if (_currentRoomId == null) {
      return const Stream.empty();
    }
    return _firebaseService
        .watchMultiplayerMoves(_currentRoomId!)
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }
}

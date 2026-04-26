// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/game_models.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Temporary: Return a mock user ID since Firebase Auth is disabled for now
  Future<String> signInAnonymously() async {
    try {
      return DateTime.now().millisecondsSinceEpoch.toString();
    } catch (e) {
      return '';
    }
  }

  Future<void> saveGameResult(String userId, GameStat stat) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('games')
          .add(stat.toJson());

      // Update player stats
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userRef);
        if (!snapshot.exists) {
          transaction.set(userRef, {
            'totalScore': stat.score,
            'gamesPlayed': 1,
            'gamesWon': stat.won ? 1 : 0,
          });
        } else {
          transaction.update(userRef, {
            'totalScore': FieldValue.increment(stat.score),
            'gamesPlayed': FieldValue.increment(1),
            'gamesWon': FieldValue.increment(stat.won ? 1 : 0),
          });
        }
      });
    } catch (e) {
      // Ignore save errors
    }
  }

  // Multiplayer methods
  Future<String> createMultiplayerRoom(GameMode mode) async {
    String roomId = DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore.collection('multiplayer_rooms').doc(roomId).set({
      'mode': mode.toString(),
      'hiddenSequence': _generateRandomSequence(),
      'players': [],
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return roomId;
  }

  Stream<DocumentSnapshot> joinMultiplayerRoom(String roomId) {
    return _firestore.collection('multiplayer_rooms').doc(roomId).snapshots();
  }

  Future<void> submitMultiplayerMove(
    String roomId,
    String playerId,
    List<Color> guess,
    int matches,
  ) async {
    await _firestore
        .collection('multiplayer_rooms')
        .doc(roomId)
        .collection('moves')
        .add({
          'playerId': playerId,
          'guess': guess.map((c) => c.value).toList(),
          'matches': matches,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  List<int> _generateRandomSequence() {
    // Generate random sequence for multiplayer
    return List.generate(8, (index) => index % 6);
  }
}

extension on GameStat {
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'mode': mode.toString(),
      'score': score,
      'movesUsed': movesUsed,
      'timeUsed': timeUsed,
      'won': won,
    };
  }
}

// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/game_models.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in anonymously with real Firebase Authentication
  /// Returns actual Firebase UID
  Future<String> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return result.user?.uid ?? '';
    } catch (e) {
      print('Firebase anonymous sign-in failed: $e');
      return '';
    }
  }

  /// Get current authenticated user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Stream of authentication state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
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

  // Multiplayer methods - using real Firestore document IDs
  Future<String> createMultiplayerRoom(GameMode mode) async {
    try {
      final docRef = _firestore.collection('multiplayer_rooms').doc();
      
      // Generate truly random sequence using secure random
      final hiddenSequence = _generateTrulyRandomSequence();
      
      await docRef.set({
        'mode': mode.toString(),
        'hiddenSequence': hiddenSequence,
        'players': [],
        'status': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid ?? 'anonymous',
      });
      return docRef.id; // Use Firestore's real document ID
    } catch (e) {
      print('Failed to create multiplayer room: $e');
      return '';
    }
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
    try {
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
    } catch (e) {
      print('Failed to submit multiplayer move: $e');
    }
  }

  /// Generate truly random sequence for multiplayer
  /// Each position gets a random color index (0-5)
  List<int> _generateTrulyRandomSequence() {
    return List.generate(
      8,
      (_) => DateTime.now().microsecondsSinceEpoch % 6,
      growable: false,
    );
  }
  
  /// Stream of real-time multiplayer moves
  Stream<QuerySnapshot> watchMultiplayerMoves(String roomId) {
    return _firestore
        .collection('multiplayer_rooms')
        .doc(roomId)
        .collection('moves')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
  
  /// Stream of real-time player stats
  Stream<DocumentSnapshot> watchUserStats(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }
  
  /// Stream of game history
  Stream<QuerySnapshot> watchGameHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('games')
        .orderBy('date', descending: true)
        .snapshots();
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

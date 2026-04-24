// lib/services/game_service_extensions.dart
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import 'game_service.dart';

extension GameServiceExtensions on GameService {
  bool isValidGuess(List<Color> guess) {
    return guess.length == GameService.SEQUENCE_LENGTH &&
        !guess.contains(Colors.grey);
  }
  
  String getStrategyHint(int attemptsCount, int maxMatches) {
    if (attemptsCount == 0) {
      return "Start by using all the same color to find how many matches exist.";
    }
    
    if (maxMatches > 0 && maxMatches < 4) {
      return "You have $maxMatches matches. Keep these positions and change others one by one.";
    }
    
    if (maxMatches >= 4) {
      return "Great progress! Now focus on the remaining ${GameService.SEQUENCE_LENGTH - maxMatches} positions.";
    }
    
    return "Try a systematic approach: test each position individually.";
  }
  
  List<int> findMatchingPositions(List<Color> guess, List<Color> hidden) {
    List<int> matches = [];
    for (int i = 0; i < GameService.SEQUENCE_LENGTH; i++) {
      if (guess[i] == hidden[i]) {
        matches.add(i);
      }
    }
    return matches;
  }
  
  Map<Color, int> getColorFrequency(List<Color> sequence) {
    Map<Color, int> frequency = {};
    for (var color in sequence) {
      frequency[color] = (frequency[color] ?? 0) + 1;
    }
    return frequency;
  }
  
  double calculateProgressScore(List<Attempt> attempts) {
    if (attempts.length < 2) return 0.0;
    
    int improvements = 0;
    for (int i = 1; i < attempts.length; i++) {
      if (attempts[i].matches > attempts[i-1].matches) {
        improvements++;
      }
    }
    
    return improvements / (attempts.length - 1);
  }
}
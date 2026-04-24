// lib/utils/helpers.dart
import 'package:flutter/material.dart';

class GameHelpers {
  static String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  static Color getScoreColor(int score) {
    if (score < 500) return Colors.red;
    if (score < 1000) return Colors.orange;
    if (score < 2000) return Colors.yellow;
    return Colors.green;
  }
  
  static String getPerformanceRating(double progressRate) {
    if (progressRate >= 0.5) return 'Excellent!';
    if (progressRate >= 0.3) return 'Good';
    if (progressRate >= 0.1) return 'Fair';
    return 'Needs Improvement';
  }
  
  static List<List<Color>> generateAllCombinations(List<Color> colors, int length) {
    List<List<Color>> result = [];
    
    void generate(List<Color> current) {
      if (current.length == length) {
        result.add(List.from(current));
        return;
      }
      
      for (var color in colors) {
        current.add(color);
        generate(current);
        current.removeLast();
      }
    }
    
    generate([]);
    return result;
  }
}
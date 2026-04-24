// lib/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();
  
  final AudioPlayer _player = AudioPlayer();
  bool _isSoundEnabled = true;
  
  Future<void> playSound(String soundName) async {
    if (!_isSoundEnabled) return;
    
    try {
      await _player.play(AssetSource('sounds/$soundName.mp3'));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }
  
  Future<void> playMatchSound() async {
    await playSound('match');
  }
  
  Future<void> playSubmitSound() async {
    await playSound('submit');
  }
  
  Future<void> playWinSound() async {
    await playSound('win');
  }
  
  Future<void> playTimeoutSound() async {
    await playSound('timeout');
  }
  
  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
  }
  
  void dispose() {
    _player.dispose();
  }
}
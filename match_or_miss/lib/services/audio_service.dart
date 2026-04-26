// lib/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Separate players so SFX never interrupts background music
  final AudioPlayer _bgPlayer  = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _sfxEnabled   = true;
  bool _musicEnabled = false;
  double _volume     = 0.8;

  void setSfxEnabled(bool v)  { _sfxEnabled = v; }
  void setMusicEnabled(bool v){ _musicEnabled = v; }
  void setVolume(double v) {
    _volume = v.clamp(0.0, 1.0);
    _sfxPlayer.setVolume(_volume);
    _bgPlayer.setVolume(_volume * 0.4); // music a bit quieter than SFX
  }

  // ── Background music ────────────────────────────────────────────────────────

  Future<void> startBackgroundMusic() async {
    try {
      await _bgPlayer.setVolume(_volume * 0.4);
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource('sounds/background.mp3'));
    } catch (e) {
<<<<<<< HEAD
      // File may not exist yet — fail silently
      debugPrint('AudioService: background music not found ($e)');
=======
      // Ignore audio playback errors
>>>>>>> 8d87ab68c965739798a3c6e1013055dcba777fb8
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _bgPlayer.stop();
  }

  Future<void> pauseBackgroundMusic() async {
    await _bgPlayer.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    if (_musicEnabled) await _bgPlayer.resume();
  }

  // ── Sound effects ───────────────────────────────────────────────────────────

  Future<void> _playSfx(String name) async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.setVolume(_volume);
      await _sfxPlayer.play(AssetSource('sounds/$name.mp3'));
    } catch (e) {
      debugPrint('AudioService: sfx "$name" not found ($e)');
    }
  }

  Future<void> playSubmitSound()  => _playSfx('submit');
  Future<void> playMatchSound()   => _playSfx('match');
  Future<void> playWinSound()     => _playSfx('win');
  Future<void> playTimeoutSound() => _playSfx('timeout');
  Future<void> playSwapSound()    => _playSfx('swap');
  Future<void> playErrorSound()   => _playSfx('error');

  // Legacy toggle kept for compatibility
  void toggleSound() {
    _sfxEnabled = !_sfxEnabled;
  }

  void dispose() {
    _bgPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
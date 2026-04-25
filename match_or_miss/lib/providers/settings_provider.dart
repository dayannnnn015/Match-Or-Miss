// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_service.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keySfx     = 'settings_sfx';
  static const _keyMusic   = 'settings_music';
  static const _keyHints   = 'settings_hints';
  static const _keyVolume  = 'settings_volume';

  bool _sfxEnabled    = true;
  bool _musicEnabled  = false;
  bool _hintsEnabled  = true;
  double _volume      = 0.8;
  bool _loaded        = false;

  bool   get sfxEnabled   => _sfxEnabled;
  bool   get musicEnabled => _musicEnabled;
  bool   get hintsEnabled => _hintsEnabled;
  double get volume       => _volume;
  bool   get loaded       => _loaded;

  final AudioService _audio = AudioService();

  /// Call once at app startup (from main.dart after runApp).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _sfxEnabled   = prefs.getBool(_keySfx)    ?? true;
    _musicEnabled = prefs.getBool(_keyMusic)  ?? false;
    _hintsEnabled = prefs.getBool(_keyHints)  ?? true;
    _volume       = prefs.getDouble(_keyVolume) ?? 0.8;
    _loaded = true;

    // Apply to audio service immediately
    _audio.setSfxEnabled(_sfxEnabled);
    _audio.setVolume(_volume);
    if (_musicEnabled) {
      _audio.startBackgroundMusic();
    }
    notifyListeners();
  }

  Future<void> setSfx(bool value) async {
    _sfxEnabled = value;
    _audio.setSfxEnabled(value);
    await _persist();
    notifyListeners();
  }

  Future<void> setMusic(bool value) async {
    _musicEnabled = value;
    if (value) {
      _audio.startBackgroundMusic();
    } else {
      _audio.stopBackgroundMusic();
    }
    await _persist();
    notifyListeners();
  }

  Future<void> setHints(bool value) async {
    _hintsEnabled = value;
    await _persist();
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    _volume = value;
    _audio.setVolume(value);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySfx,    _sfxEnabled);
    await prefs.setBool(_keyMusic,  _musicEnabled);
    await prefs.setBool(_keyHints,  _hintsEnabled);
    await prefs.setDouble(_keyVolume, _volume);
  }
}
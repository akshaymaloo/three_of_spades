import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  bool get _isTesting => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  bool enabled = true;
  bool musicEnabled = true;
  final Map<String, AudioPlayer> _players = {};
  AudioPlayer? _musicPlayer;

  void setEnabled(bool isEnabled) {
    enabled = isEnabled;
    if (_isTesting) return;
    if (!enabled) {
      stopBackgroundMusic();
    } else if (musicEnabled) {
      playBackgroundMusic();
    }
  }

  void setMusicEnabled(bool isEnabled) {
    musicEnabled = isEnabled;
    if (_isTesting) return;
    if (!musicEnabled) {
      stopBackgroundMusic();
    } else {
      playBackgroundMusic();
    }
  }

  Future<void> playBackgroundMusic() async {
    if (_isTesting) return;
    if (!musicEnabled || !enabled) return;
    try {
      if (_musicPlayer == null) {
        _musicPlayer = AudioPlayer();
        await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      }
      await _musicPlayer!.play(AssetSource('sounds/music.mp3'));
    } catch (e) {
      debugPrint('Music playback error: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (_isTesting) return;
    try {
      await _musicPlayer?.stop();
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
  }

  Future<void> setMusicVolume(double volume) async {
    if (_isTesting) return;
    try {
      await _musicPlayer?.setVolume(volume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  Future<void> playSound(String soundPath) async {
    if (_isTesting) return;
    if (!enabled) return;
    try {
      // Sound path should be relative to assets, e.g. "sounds/card_played.mp3"
      final player = _players.putIfAbsent(soundPath, () => AudioPlayer());
      await player.stop();
      await player.play(AssetSource(soundPath));
    } catch (e) {
      // Ignore audio errors to prevent game crash
      debugPrint('Audio playback error: $e');
    }
  }

  void dispose() {
    if (_isTesting) return;
    _musicPlayer?.dispose();
    _musicPlayer = null;
    for (var player in _players.values) {
      player.dispose();
    }
    _players.clear();
  }
}

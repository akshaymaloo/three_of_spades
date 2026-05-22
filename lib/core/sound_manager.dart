import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  bool enabled = true;
  final Map<String, AudioPlayer> _players = {};

  void setEnabled(bool isEnabled) {
    enabled = isEnabled;
  }

  Future<void> playSound(String soundPath) async {
    if (!enabled) return;
    try {
      // Sound path should be relative to assets, e.g. "sounds/card_played.mp3"
      final player = _players.putIfAbsent(soundPath, () => AudioPlayer());
      await player.stop();
      await player.play(AssetSource(soundPath));
    } catch (e) {
      // Ignore audio errors to prevent game crash
      print('Audio playback error: $e');
    }
  }

  void dispose() {
    for (var player in _players.values) {
      player.dispose();
    }
    _players.clear();
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsManager {
  static final TtsManager _instance = TtsManager._internal();
  factory TtsManager() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  TtsManager._internal() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      if (!kIsWeb) {
        await _flutterTts.awaitSpeakCompletion(true);
      }
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
    }
  }

  Future<void> speak(String text, {bool enabled = false}) async {
    if (!enabled || !_isInitialized || text.isEmpty) return;
    
    // Clean up text for speech (e.g. remove emojis, markdown, or shorten)
    String cleanText = text.replaceAll(RegExp(r'[^\w\s.,!?]'), '');
    
    try {
      await _flutterTts.speak(cleanText);
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  Future<void> stop() async {
    if (!_isInitialized) return;
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }
}

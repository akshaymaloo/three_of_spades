import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigState {
  final bool onlineMode;
  final bool isFirebaseAvailable;

  const ConfigState({
    required this.onlineMode,
    required this.isFirebaseAvailable,
  });

  factory ConfigState.initial() {
    return const ConfigState(
      onlineMode: false,
      isFirebaseAvailable: false,
    );
  }

  ConfigState copyWith({
    bool? onlineMode,
    bool? isFirebaseAvailable,
  }) {
    return ConfigState(
      onlineMode: onlineMode ?? this.onlineMode,
      isFirebaseAvailable: isFirebaseAvailable ?? this.isFirebaseAvailable,
    );
  }

  bool get effectiveOnlineMode => onlineMode && isFirebaseAvailable;
}

class ConfigNotifier extends Notifier<ConfigState> {
  @override
  ConfigState build() {
    _loadFromPrefs();
    return ConfigState.initial();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final onlineMode = prefs.getBool('online_mode') ?? false;
      state = state.copyWith(onlineMode: onlineMode);
    } catch (e, stack) {
      debugPrint('Failed to load config: $e\n$stack');
    }
  }

  Future<void> toggleOnlineMode() async {
    final newValue = !state.onlineMode;
    state = state.copyWith(onlineMode: newValue);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('online_mode', newValue);
    } catch (e, stack) {
      debugPrint('Failed to save online_mode: $e\n$stack');
    }
  }

  void setFirebaseAvailable(bool value) {
    state = state.copyWith(isFirebaseAvailable: value);
  }

  /// Returns true only if the user has opted into online mode
  /// AND Firebase services are actually available.
  bool get effectiveOnlineMode =>
      state.onlineMode && state.isFirebaseAvailable;
}

final configProvider = NotifierProvider<ConfigNotifier, ConfigState>(() {
  return ConfigNotifier();
});

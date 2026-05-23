import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config_provider.dart';
import '../services/auth_service.dart';
import '../services/multiplayer_sync_service.dart';
import '../services/leaderboard_service.dart';
import '../services/ad_service.dart';
import '../services/notification_service.dart';

final authServiceProvider = Provider<BaseAuthService>((ref) {
  final config = ref.watch(configProvider);
  if (config.effectiveOnlineMode) {
    return LiveAuthService();
  } else {
    return MockAuthService();
  }
});

final multiplayerSyncServiceProvider = Provider<BaseMultiplayerSyncService>((ref) {
  final config = ref.watch(configProvider);
  if (config.effectiveOnlineMode) {
    return LiveMultiplayerSyncService();
  } else {
    return MockMultiplayerSyncService();
  }
});

final leaderboardServiceProvider = Provider<BaseLeaderboardService>((ref) {
  final config = ref.watch(configProvider);
  if (config.effectiveOnlineMode) {
    return LiveLeaderboardService();
  } else {
    return MockLeaderboardService();
  }
});

final adServiceProvider = Provider<BaseAdService>((ref) {
  final config = ref.watch(configProvider);
  if (config.effectiveOnlineMode) {
    return LiveAdService();
  } else {
    return MockAdService();
  }
});

final notificationServiceProvider = Provider<BaseNotificationService>((ref) {
  final config = ref.watch(configProvider);
  if (config.effectiveOnlineMode) {
    return LiveNotificationService();
  } else {
    return MockNotificationService();
  }
});

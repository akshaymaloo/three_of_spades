import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// BaseNotificationService – abstract contract for push notifications.
// ---------------------------------------------------------------------------

abstract class BaseNotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<String?> getToken();
  Stream<String> get onTokenRefresh;
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  void dispose();
}

// ---------------------------------------------------------------------------
// MockNotificationService – no-op implementation for offline / dev mode.
// ---------------------------------------------------------------------------

class MockNotificationService implements BaseNotificationService {
  @override
  Future<void> initialize() async {
    // No-op – no FCM SDK in offline mode.
  }

  @override
  Future<bool> requestPermission() async {
    return true;
  }

  @override
  Future<String?> getToken() async {
    return 'mock-fcm-token-001';
  }

  @override
  Stream<String> get onTokenRefresh => const Stream<String>.empty();

  @override
  Future<void> subscribeToTopic(String topic) async {
    // No-op.
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    // No-op.
  }

  @override
  void dispose() {
    // No-op.
  }
}



// ---------------------------------------------------------------------------
// LiveNotificationService – Firebase Cloud Messaging integration.
// ---------------------------------------------------------------------------

class LiveNotificationService implements BaseNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  Future<void> initialize() async {
    // Configure foreground presentation options
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[LiveNotificationService] Foreground message: ${message.notification?.title}');
    });

    // Listen to messages that open the app from background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[LiveNotificationService] Message opened app: ${message.data}');
    });
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      debugPrint('FCM requestPermission error: $e');
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('FCM getToken error: $e');
      return null;
    }
  }

  @override
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('FCM subscribeToTopic error: $e');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('FCM unsubscribeFromTopic error: $e');
    }
  }

  @override
  void dispose() {
    // Clean up if needed
  }
}

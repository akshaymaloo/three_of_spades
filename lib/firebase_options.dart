import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'mock-api-key-android',
          appId: '1:1234567890:android:mockappid',
          messagingSenderId: '1234567890',
          projectId: 'mock-project-id',
          storageBucket: 'mock-project-id.appspot.com',
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: 'mock-api-key-ios',
          appId: '1:1234567890:ios:mockappid',
          messagingSenderId: '1234567890',
          projectId: 'mock-project-id',
          storageBucket: 'mock-project-id.appspot.com',
          iosBundleId: 'com.kaalikiteeggi.threeofspades',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}

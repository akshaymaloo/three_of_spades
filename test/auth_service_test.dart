import 'package:flutter_test/flutter_test.dart';
import 'package:three_of_spades_flutter/services/auth_service.dart';

void main() {
  test('MockAuthService anonymous sign in', () async {
    final service = MockAuthService();
    expect(service.currentUser, isNull);

    final user = await service.signInAnonymously();
    expect(user, isNotNull);
    expect(user!.uid, equals('mock-user-001'));
    expect(user.displayName, equals('Guest Player'));
    expect(user.isAnonymous, isTrue);
    expect(service.currentUser, isNotNull);
  });

  test('MockAuthService Facebook sign in', () async {
    final service = MockAuthService();
    final user = await service.signInWithFacebook();
    expect(user, isNotNull);
    expect(user!.uid, equals('mock-fb-user-001'));
    expect(user.displayName, equals('FB User'));
    expect(user.isAnonymous, isFalse);
  });

  test('MockAuthService sign out', () async {
    final service = MockAuthService();
    await service.signInAnonymously();
    expect(service.currentUser, isNotNull);

    await service.signOut();
    expect(service.currentUser, isNull);
  });
}

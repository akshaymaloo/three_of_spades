import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

// ---------------------------------------------------------------------------
// AuthUser – lightweight user model for both mock and live auth flows.
// ---------------------------------------------------------------------------

class AuthUser {
  final String? uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isAnonymous;

  const AuthUser({
    this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.isAnonymous = true,
  });
}

// ---------------------------------------------------------------------------
// BaseAuthService – abstract contract for authentication.
// ---------------------------------------------------------------------------

abstract class BaseAuthService {
  Future<AuthUser?> signInAnonymously();
  Future<AuthUser?> signInWithFacebook();
  Future<void> signOut();
  AuthUser? get currentUser;
  Stream<AuthUser?> get authStateChanges;
}

// ---------------------------------------------------------------------------
// MockAuthService – offline / development implementation.
// ---------------------------------------------------------------------------

class MockAuthService implements BaseAuthService {
  AuthUser? _currentUser;

  @override
  Future<AuthUser?> signInAnonymously() async {
    _currentUser = const AuthUser(
      uid: 'mock-user-001',
      displayName: 'Guest Player',
      isAnonymous: true,
    );
    return _currentUser;
  }

  @override
  Future<AuthUser?> signInWithFacebook() async {
    _currentUser = const AuthUser(
      uid: 'mock-fb-user-001',
      displayName: 'FB User',
      email: 'fbuser@mock.dev',
      isAnonymous: false,
    );
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> get authStateChanges =>
      Stream<AuthUser?>.value(_currentUser);
}



// ---------------------------------------------------------------------------
// LiveAuthService – real Firebase Auth integration.
// ---------------------------------------------------------------------------

class LiveAuthService implements BaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthUser? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      displayName: user.displayName ?? (user.isAnonymous ? 'Guest Player' : 'Player'),
      email: user.email,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
    );
  }

  @override
  Future<AuthUser?> signInAnonymously() async {
    final userCredential = await _auth.signInAnonymously();
    return _mapFirebaseUser(userCredential.user);
  }

  @override
  Future<AuthUser?> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['public_profile', 'email'],
    );
    if (result.status == LoginStatus.success) {
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);
      final userCredential = await _auth.signInWithCredential(credential);
      return _mapFirebaseUser(userCredential.user);
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await FacebookAuth.instance.logOut();
  }

  @override
  AuthUser? get currentUser => _mapFirebaseUser(_auth.currentUser);

  @override
  Stream<AuthUser?> get authStateChanges =>
      _auth.authStateChanges().map(_mapFirebaseUser);
}

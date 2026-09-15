import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;

/// Scopes required for Gmail and Sheets API access.
const _gmailSheetScopes = [
  'https://www.googleapis.com/auth/gmail.send',
  'https://www.googleapis.com/auth/gmail.readonly',
  'https://www.googleapis.com/auth/spreadsheets',
];

class AuthService {
  FirebaseAuth? _firebaseAuth;

  /// Cached Google OAuth access token obtained during sign-in.
  /// Used to create authenticated HTTP clients for Gmail / Sheets.
  String? _cachedAccessToken;

  AuthService({FirebaseAuth? firebaseAuth}) : _firebaseAuth = firebaseAuth;

  FirebaseAuth? get _auth {
    if (_firebaseAuth != null) return _firebaseAuth;
    try {
      _firebaseAuth = FirebaseAuth.instance;
      return _firebaseAuth;
    } catch (e) {
      debugPrint('[AuthService] Firebase not initialized: $e');
      return null;
    }
  }

  User? get currentUser => _auth?.currentUser;
  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? const Stream.empty();
  bool get isAuthenticated => currentUser != null;

  /// Signs in with Google using [FirebaseAuth.signInWithProvider].
  ///
  /// This opens a Chrome Custom Tab (browser-based OAuth) instead of the
  /// native Google Play Services account picker, which avoids
  /// [ApiException: 10 DEVELOPER_ERROR] caused by signing-certificate
  /// mismatches in the GMS SDK.
  ///
  /// All required Google API scopes (Gmail + Sheets) are requested upfront
  /// so [getAuthenticatedHttpClient] can work immediately after sign-in.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final authInstance = _auth;
      if (authInstance == null) return null;

      final googleProvider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile')
        ..addScope('https://www.googleapis.com/auth/gmail.send')
        ..addScope('https://www.googleapis.com/auth/gmail.readonly')
        ..addScope('https://www.googleapis.com/auth/spreadsheets');

      final userCredential =
          await authInstance.signInWithProvider(googleProvider);

      // Cache the Google OAuth access token for downstream API calls.
      final oauthCred = userCredential.credential as OAuthCredential?;
      _cachedAccessToken = oauthCred?.accessToken;

      debugPrint(
          '[AuthService] Signed in as: ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint(
          '[AuthService] FirebaseAuthException: ${e.code} — ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[AuthService] Sign-in error: $e');
      rethrow;
    }
  }

  /// Returns an authenticated HTTP client scoped for Gmail and Sheets APIs.
  ///
  /// Requires that [signInWithGoogle] has been called first in this session.
  /// If the access token has expired (> 1 h since sign-in), the user will
  /// need to sign in again.
  Future<auth.AuthClient?> getAuthenticatedHttpClient() async {
    try {
      final token = _cachedAccessToken;
      if (token == null) {
        debugPrint(
            '[AuthService] No cached access token — sign in first.');
        return null;
      }

      final credentials = auth.AccessCredentials(
        auth.AccessToken(
          'Bearer',
          token,
          // Access tokens last ~1 h; we use a conservative estimate.
          DateTime.now().toUtc().add(const Duration(minutes: 55)),
        ),
        null, // No refresh token — user re-authenticates when token expires.
        _gmailSheetScopes,
      );

      return auth.authenticatedClient(http.Client(), credentials);
    } catch (e) {
      debugPrint('[AuthService] Error creating authenticated client: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      _cachedAccessToken = null;
      await _auth?.signOut();
      debugPrint('[AuthService] Signed out.');
    } catch (e) {
      debugPrint('[AuthService] Error during signOut: $e');
    }
  }
}
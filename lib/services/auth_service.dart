import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

class AuthService {
  FirebaseAuth? _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              // Web client ID from google-services.json (client_type: 3)
              // Required for Firebase Auth to receive a valid ID token on Android
              serverClientId: '770770436971-f410eig19uk4a1rievb28d9gut7gp6n7.apps.googleusercontent.com',
              scopes: [
                'email',
                'https://www.googleapis.com/auth/gmail.send',
                'https://www.googleapis.com/auth/gmail.readonly',
                'https://www.googleapis.com/auth/spreadsheets',
              ],
            );

  FirebaseAuth? get _auth {
    if (_firebaseAuth != null) return _firebaseAuth;
    try {
      _firebaseAuth = FirebaseAuth.instance;
      return _firebaseAuth;
    } catch (e) {
      debugPrint('[AuthService] Firebase not initialized in current runner: $e');
      return null;
    }
  }

  User? get currentUser => _auth?.currentUser;
  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? const Stream.empty();
  bool get isAuthenticated => currentUser != null;

  GoogleSignInAccount? get currentGoogleUser => _googleSignIn.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authInstance = _auth;
      if (authInstance != null) {
        final userCredential = await authInstance.signInWithCredential(credential);
        return userCredential;
      }
      return null;
    } catch (e) {
      debugPrint('[AuthService] Error during Google Sign-In: $e');
      rethrow;
    }
  }

  Future<auth.AuthClient?> getAuthenticatedHttpClient() async {
    try {
      final client = await _googleSignIn.authenticatedClient();
      return client;
    } catch (e) {
      debugPrint('[AuthService] Error getting authenticated client: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth?.signOut();
    } catch (e) {
      debugPrint('[AuthService] Error during signOut: $e');
    }
  }
}
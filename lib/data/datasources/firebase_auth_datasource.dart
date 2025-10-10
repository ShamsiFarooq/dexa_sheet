import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthDataSource {
  final fb.FirebaseAuth _auth;
  final GoogleSignIn _google;

  FirebaseAuthDataSource({
    fb.FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _google = googleSignIn ??
            GoogleSignIn(
              scopes: const ['email', 'profile'],
            );

  Stream<fb.User?> authStateChanges() => _auth.authStateChanges();

  Future<fb.User> signInWithGoogle() async {
    // Trigger Google sign-in
    final googleUser = await _google.signIn();
    if (googleUser == null) {
      throw Exception('Sign-in aborted by user');
    }

    final googleAuth = await googleUser.authentication;

    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) {
      throw Exception('Firebase returned null user');
    }
    return user;
  }

  Future<void> signOut() async {
    // Sign out from both Google and Firebase
    try {
      await _google.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  fb.User? currentUser() => _auth.currentUser;
}

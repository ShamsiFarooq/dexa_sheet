import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();
  Future<User?> signInWithGoogle();
  Future<void> signOut();
}

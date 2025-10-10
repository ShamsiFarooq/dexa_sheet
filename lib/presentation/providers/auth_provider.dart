import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repo;
  final SignInWithGoogleUseCase _signInUC;
  final SignOutUseCase _signOutUC;

  User? user;
  bool isLoading = false;
  String? error;

  AuthProvider(this.repo)
      : _signInUC = SignInWithGoogleUseCase(repo),
        _signOutUC = SignOutUseCase(repo) {
    // listen to auth changes
    repo.authStateChanges().listen((u) {
      user = u;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    isLoading = true; error = null; notifyListeners();
    try {
      user = await _signInUC();
      if (user == null) {
        error = 'Sign-in cancelled';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    isLoading = true; notifyListeners();
    try {
      await _signOutUC();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

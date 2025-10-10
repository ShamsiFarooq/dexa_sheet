import '../repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repo;
  SignInWithGoogleUseCase(this.repo);
  Future<User?> call() => repo.signInWithGoogle();
}

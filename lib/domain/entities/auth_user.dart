class AuthUser {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  const AuthUser({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
  });
}

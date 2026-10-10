enum UserRole { user, admin }

class AuthUser {
  const AuthUser({
    required this.id,
    required this.usernameOrEmail,
    required this.displayName,
    required this.role,
    this.isGuest = false,
  });

  final String id;
  final String usernameOrEmail;
  final String displayName;
  final UserRole role;
  final bool isGuest;

  bool get isAdmin => role == UserRole.admin;
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

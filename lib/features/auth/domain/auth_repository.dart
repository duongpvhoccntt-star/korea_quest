import 'package:korea_quest/features/auth/domain/auth_models.dart';

abstract class AuthRepository {
  AuthUser? get currentUser;

  Stream<AuthUser?> watchCurrentUser();

  Future<AuthUser> signIn({required String identity, required String password});

  Future<AuthUser> register({
    required String fullName,
    required String displayName,
    required String email,
    required String password,
  });

  Future<void> signOut();
}

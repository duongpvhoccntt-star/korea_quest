import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/features/auth/data/mock_auth_repository.dart';
import 'package:korea_quest/features/auth/domain/auth_models.dart';
import 'package:korea_quest/features/auth/domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repository = MockAuthRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final authUserStreamProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).watchCurrentUser();
});

final currentUserRoleProvider = Provider<UserRole?>((ref) {
  final user = ref.watch(authUserStreamProvider).value;
  return user?.role;
});

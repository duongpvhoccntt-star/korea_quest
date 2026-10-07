import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/auth/data/mock_auth_repository.dart';
import 'package:korea_quest/features/auth/domain/auth_models.dart';

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
  });

  test('changePassword fails when no user is signed in', () async {
    expect(
      () => repo.changePassword(
        currentPassword: 'any',
        newPassword: 'newpassword123',
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('changePassword fails with incorrect current password', () async {
    await repo.signIn(identity: 'duong@example.com', password: 'user123');
    expect(
      () => repo.changePassword(
        currentPassword: 'wrongpassword',
        newPassword: 'newpassword123',
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('changePassword fails if new password is too short', () async {
    await repo.signIn(identity: 'duong@example.com', password: 'user123');
    expect(
      () =>
          repo.changePassword(currentPassword: 'user123', newPassword: 'short'),
      throwsA(isA<AuthException>()),
    );
  });

  test('changePassword succeeds and allows login with new password', () async {
    await repo.signIn(identity: 'duong@example.com', password: 'user123');
    await repo.changePassword(
      currentPassword: 'user123',
      newPassword: 'newuser1234',
    );
    await repo.signOut();
    final user = await repo.signIn(
      identity: 'duong@example.com',
      password: 'newuser1234',
    );
    expect(user.displayName, 'Phạm Văn Dương');
  });
}

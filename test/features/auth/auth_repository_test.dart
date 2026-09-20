import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/auth/data/mock_auth_repository.dart';
import 'package:korea_quest/features/auth/domain/auth_models.dart';

void main() {
  group('MockAuthRepository', () {
    late MockAuthRepository repository;

    setUp(() {
      repository = MockAuthRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    test(
      'sign in with admin credentials succeeds and returns admin role',
      () async {
        final user = await repository.signIn(
          identity: 'admin',
          password: 'admin123',
        );

        expect(user.role, equals(UserRole.admin));
        expect(user.isAdmin, isTrue);
        expect(user.usernameOrEmail, equals('admin'));
        expect(repository.currentUser, isNotNull);
        expect(repository.currentUser!.isAdmin, isTrue);
      },
    );

    test(
      'sign in with student credentials succeeds and returns user role',
      () async {
        final user = await repository.signIn(
          identity: 'duong@example.com',
          password: 'user123',
        );

        expect(user.role, equals(UserRole.user));
        expect(user.isAdmin, isFalse);
        expect(user.usernameOrEmail, equals('duong@example.com'));
      },
    );

    test('sign in with wrong password throws AuthException', () async {
      expect(
        () => repository.signIn(identity: 'admin', password: 'wrongpassword'),
        throwsA(isA<AuthException>()),
      );
    });

    test('sign in with non-existent user throws AuthException', () async {
      expect(
        () => repository.signIn(
          identity: 'unknown@example.com',
          password: 'password',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('register new user succeeds and allows subsequent sign in', () async {
      final newUser = await repository.register(
        fullName: 'Nguyễn Văn A',
        displayName: 'Văn A',
        email: 'vana@example.com',
        password: 'password123',
      );

      expect(newUser.role, equals(UserRole.user));
      expect(newUser.usernameOrEmail, equals('vana@example.com'));
      expect(newUser.displayName, equals('Văn A'));

      // Sign out
      await repository.signOut();
      expect(repository.currentUser, isNull);

      // Sign in with new credentials
      final signedIn = await repository.signIn(
        identity: 'vana@example.com',
        password: 'password123',
      );
      expect(signedIn.id, equals(newUser.id));
    });

    test('register with existing email throws AuthException', () async {
      expect(
        () => repository.register(
          fullName: 'Trùng Email',
          displayName: 'Dương',
          email: 'duong@example.com',
          password: 'password',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/auth/data/mock_auth_repository.dart';

void main() {
  test('upgrades a guest while preserving its identity', () async {
    final repository = MockAuthRepository();
    addTearDown(repository.dispose);

    final guest = await repository.signInAsGuest(name: 'Minji');
    final upgraded = await repository.register(
      fullName: 'Kim Minji',
      displayName: 'Minji',
      email: 'minji@example.com',
      password: 'password123',
    );

    expect(upgraded.id, guest.id);
    expect(upgraded.isGuest, isFalse);

    await repository.signOut();
    final signedIn = await repository.signIn(
      identity: 'minji@example.com',
      password: 'password123',
    );
    expect(signedIn.id, guest.id);
  });
}

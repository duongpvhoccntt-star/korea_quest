import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/auth/data/supabase_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

void main() {
  test('keeps the Guest identity when the auth stream starts', () async {
    final repository = SupabaseAuthRepository(
      SupabaseClient('https://example.supabase.co', 'test-anon-key'),
    );

    await repository.signInAsGuest(name: 'Minh Anh');

    final user = await repository.watchCurrentUser().first;

    expect(user?.isGuest, isTrue);
    expect(user?.displayName, 'Minh Anh');
  });

  test(
    'emits the Guest identity to an existing auth stream listener',
    () async {
      final repository = SupabaseAuthRepository(
        SupabaseClient('https://example.supabase.co', 'test-anon-key'),
      );
      final emittedUsers = <Object?>[];
      final subscription = repository.watchCurrentUser().listen(
        emittedUsers.add,
      );
      addTearDown(subscription.cancel);

      await Future<void>.delayed(Duration.zero);
      await repository.signInAsGuest(name: 'Minh Anh');
      await Future<void>.delayed(Duration.zero);

      expect(emittedUsers, hasLength(2));
      expect((emittedUsers.last as dynamic).displayName, 'Minh Anh');
    },
  );
}

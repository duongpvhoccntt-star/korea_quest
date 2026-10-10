import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/features/auth/presentation/providers/auth_providers.dart';

void main() {
  test('guestModeProvider initial value is false and can be toggled', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(guestModeProvider), isFalse);

    container.read(guestModeProvider.notifier).enableGuestMode();
    expect(container.read(guestModeProvider), isTrue);

    container.read(guestModeProvider.notifier).disableGuestMode();
    expect(container.read(guestModeProvider), isFalse);
  });
}

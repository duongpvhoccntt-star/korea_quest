import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/app/app.dart';
import 'package:korea_quest/app/app_router.dart';
import 'package:korea_quest/features/auth/data/mock_auth_repository.dart';
import 'package:korea_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';
import 'package:korea_quest/features/explore/presentation/providers/location_content_providers.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';

void main() {
  testWidgets('app router renders landing route', (tester) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('vi');
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    await tester.pumpWidget(const ProviderScope(child: KoreaQuestApp()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Mỗi điểm đến'), findsOneWidget);
    expect(find.text('Bắt đầu hành trình'), findsOneWidget);
  });

  testWidgets('/home redirects authenticated users to /explore', (
    tester,
  ) async {
    final authRepository = MockAuthRepository();
    await authRepository.signIn(
      identity: 'duong@example.com',
      password: 'user123',
    );
    addTearDown(authRepository.dispose);

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        publishedLocationsProvider.overrideWith(
          (ref) async => const <PublishedLocationSummary>[],
        ),
        earnedAchievementsProvider.overrideWith(
          (ref) async => const <Achievement>[],
        ),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    router.go('/home');
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/explore');
  });
}

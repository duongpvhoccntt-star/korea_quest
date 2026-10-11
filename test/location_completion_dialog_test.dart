import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/app/app_theme.dart';
import 'package:korea_quest/features/auth/data/mock_auth_repository.dart';
import 'package:korea_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:korea_quest/features/explore/domain/location_content_repository.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';
import 'package:korea_quest/features/explore/presentation/pages/published_location_page.dart';
import 'package:korea_quest/features/explore/presentation/providers/location_content_providers.dart';
import 'package:korea_quest/features/journey/presentation/widgets/location_completion_dialog.dart';

void main() {
  Widget buildDialog({
    required bool isGuest,
    required bool reduceMotion,
    required VoidCallback onContinue,
    VoidCallback? onRegister,
  }) => MaterialApp(
    theme: AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(
        body: LocationCompletionDialog(
          locationName: 'Gyeongbokgung',
          playerName: 'Minji',
          awardedXp: 50,
          alreadyAwarded: false,
          stampAwarded: true,
          achievementTitles: const ['Người khám phá'],
          isGuest: isGuest,
          onContinue: onContinue,
          onRegister: onRegister,
          playSound: false,
        ),
      ),
    ),
  );

  testWidgets('shows rewards and returns a signed-in player to the map', (
    tester,
  ) async {
    var continued = false;

    await tester.pumpWidget(
      buildDialog(
        isGuest: false,
        reduceMotion: false,
        onContinue: () => continued = true,
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.byKey(const ValueKey('location-completion-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('celebration-animated-backdrop')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('close-location-completion')),
      findsOneWidget,
    );
    expect(find.textContaining('Gyeongbokgung'), findsAtLeastNWidgets(1));
    expect(find.byKey(const ValueKey('new-passport-stamp')), findsOneWidget);
    expect(find.text('+50 XP'), findsOneWidget);
    expect(find.text('Người khám phá'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.map_outlined));
    expect(continued, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gives guests a registration action and honors reduced motion', (
    tester,
  ) async {
    var registered = false;
    var continued = false;

    await tester.pumpWidget(
      buildDialog(
        isGuest: true,
        reduceMotion: true,
        onContinue: () => continued = true,
        onRegister: () => registered = true,
      ),
    );

    expect(
      find.byKey(const ValueKey('celebration-static-backdrop')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.card_membership_rounded), findsOneWidget);
    expect(find.byIcon(Icons.map_outlined), findsNothing);

    await tester.tap(find.byIcon(Icons.card_membership_rounded));
    expect(registered, isTrue);
    expect(continued, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'shows the celebration again for a completed location without new rewards',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final authRepository = MockAuthRepository();
      await authRepository.signIn(
        identity: 'duong@example.com',
        password: 'user123',
      );
      addTearDown(authRepository.dispose);
      final repository = _AlreadyAwardedLocationRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          locationContentRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final router = GoRouter(
        initialLocation: '/locations/sample/stages/9',
        routes: [
          GoRoute(
            path: '/locations/:slug/stages/:stage',
            builder: (_, state) => Scaffold(
              body: PublishedLocationPage(
                slug: state.pathParameters['slug']!,
                stageNumber: int.parse(state.pathParameters['stage']!),
              ),
            ),
          ),
          GoRoute(
            path: '/explore',
            builder: (_, _) => const Scaffold(body: Text('Explore map')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Trở về bản đồ Hàn Quốc'), findsNothing);
      expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);

      final finishButton = find.byKey(const ValueKey('stage-navigation-9'));
      await tester.ensureVisible(finishButton);
      await tester.tap(finishButton);
      await tester.pumpAndSettle();

      expect(find.text('Explore map'), findsNothing);
      expect(
        find.byKey(const ValueKey('location-completion-card')),
        findsOneWidget,
      );
      expect(
        find.textContaining('Phần thưởng của địa điểm này'),
        findsOneWidget,
      );
    },
  );
}

class _AlreadyAwardedLocationRepository implements LocationContentRepository {
  static const _location = PublishedLocationDetail({
    'id': 'sample',
    'slug': 'sample',
    'name': 'Gyeongbokgung',
    'city': 'Seoul',
  });

  @override
  Future<GameplayReward> completeStage({
    required String slug,
    required int stageNumber,
    String locale = 'vi',
  }) async => const GameplayReward(
    awardedXp: 0,
    alreadyAwarded: true,
    stampAwarded: false,
    newAchievementTitles: [],
  );

  @override
  Future<PublishedLocationDetail?> getPublishedLocation(
    String slug, {
    String locale = 'vi',
  }) async => _location;

  @override
  Future<List<PublishedLocationSummary>> listPublishedLocations({
    String locale = 'vi',
  }) async => const [];

  @override
  Future<QuizAnswerResult> submitQuizAnswer({
    required String questionId,
    required JsonMap answer,
    String locale = 'vi',
  }) async => const QuizAnswerResult(isCorrect: false, explanation: '');
}

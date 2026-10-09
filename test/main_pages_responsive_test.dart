import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/app/app_theme.dart';
import 'package:korea_quest/features/achievements/presentation/pages/achievements_page.dart';
import 'package:korea_quest/features/passport/presentation/pages/passport_page.dart';
import 'package:korea_quest/features/profile/presentation/pages/profile_page.dart';
import 'package:korea_quest/features/settings/presentation/pages/settings_page.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';
import 'package:korea_quest/shared/repositories/mock_korea_quest_repository.dart';

void main() {
  final pages = <String, Widget Function()>{
    'profile': () => const ProfilePage(),
    'passport': () => const PassportPage(),
    'achievements': () => const AchievementsPage(),
    'settings': () => const SettingsPage(),
  };
  const viewports = <String, Size>{
    'laptop': Size(1280, 900),
    'tablet': Size(800, 1000),
    'mobile': Size(390, 844),
  };

  for (final page in pages.entries) {
    for (final viewport in viewports.entries) {
      testWidgets(
        '${page.key} renders without layout errors on ${viewport.key}',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = viewport.value;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                theme: AppTheme.light,
                home: Scaffold(body: page.value()),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('empty collections do not render unearned reward placeholders', (
    tester,
  ) async {
    final repository = MockKoreaQuestRepository();
    await repository.resetUserProgress();

    Widget buildPage(Widget page) => ProviderScope(
      overrides: [koreaQuestRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: page),
      ),
    );

    await tester.pumpWidget(buildPage(const AchievementsPage()));
    await tester.pumpAndSettle();
    expect(find.text('Chưa nhận huy hiệu nào'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsNothing);

    await tester.pumpWidget(buildPage(const PassportPage()));
    await tester.pumpAndSettle();
    expect(find.text('Chưa nhận dấu mộc nào'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsNothing);
  });
}

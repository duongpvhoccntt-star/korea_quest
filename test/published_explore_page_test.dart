import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/app/app_theme.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';
import 'package:korea_quest/features/explore/presentation/pages/published_explore_page.dart';
import 'package:korea_quest/features/explore/presentation/providers/location_content_providers.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';

void main() {
  for (final viewport in <String, Size>{
    'desktop': const Size(1920, 1080),
    'laptop': const Size(1280, 900),
    'tablet': const Size(800, 1000),
    'mobile': const Size(390, 844),
  }.entries) {
    testWidgets('explore renders without layout errors on ${viewport.key}', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = viewport.value;
      addTearDown(tester.view.reset);

      final bundle = _buildApp();
      addTearDown(bundle.router.dispose);
      await tester.pumpWidget(bundle.app);
      await tester.pumpAndSettle();

      expect(find.text('Bạn muốn bắt đầu từ đâu?'), findsOneWidget);
    });
  }

  testWidgets('shows personal progress and continues the active journey', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.reset);

    final bundle = _buildApp();
    addTearDown(bundle.router.dispose);
    await tester.pumpWidget(bundle.app);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Khám phá văn hóa Hàn Quốc qua từng địa danh. Dương, hành trình của bạn đang chờ đón!',
      ),
      findsOneWidget,
    );
    expect(find.text('1/2 địa điểm'), findsOneWidget);
    expect(find.text('1250 XP'), findsOneWidget);

    final continueButton = find.widgetWithText(
      FilledButton,
      'Tiếp tục hành trình',
    );
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Location: bukchon-hanok'), findsOneWidget);
  });

  testWidgets('personal provider errors do not block exploration', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.reset);

    final bundle = _buildApp(personalFails: true);
    addTearDown(bundle.router.dispose);
    await tester.pumpWidget(bundle.app);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Chọn một điểm trên bản đồ để mở hành trình khám phá hình ảnh, lịch sử, văn hóa, ẩm thực và những thử thách thú vị.',
      ),
      findsOneWidget,
    );
    expect(find.text('2 địa điểm'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Bắt đầu khám phá'),
      findsOneWidget,
    );
    expect(find.text('Không thể đọc dữ liệu hành trình.'), findsNothing);
  });
}

({Widget app, GoRouter router}) _buildApp({bool personalFails = false}) {
  final router = GoRouter(
    initialLocation: '/explore',
    routes: [
      GoRoute(
        path: '/explore',
        builder: (context, state) =>
            const Scaffold(body: PublishedExplorePage()),
      ),
      GoRoute(
        path: '/locations/:slug',
        builder: (context, state) =>
            Scaffold(body: Text('Location: ${state.pathParameters['slug']}')),
      ),
    ],
  );

  return (
    router: router,
    app: ProviderScope(
      overrides: [
        publishedLocationsProvider.overrideWith(
          (ref) async => _publishedLocations,
        ),
        earnedAchievementsProvider.overrideWith(
          (ref) async => const <Achievement>[],
        ),
        currentUserProvider.overrideWith(
          (ref) => personalFails
              ? Future<AppUser>.error(StateError('personal error'))
              : Future.value(_user),
        ),
        userProgressProvider.overrideWith(
          (ref) => personalFails
              ? Future<UserProgress>.error(StateError('personal error'))
              : Future.value(_progress),
        ),
        locationsProvider.overrideWith(
          (ref) => personalFails
              ? Future<List<Location>>.error(StateError('personal error'))
              : Future.value(_personalLocations),
        ),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
}

final _user = AppUser(
  id: 'user-duong',
  fullName: 'Phạm Văn Dương',
  displayName: 'Dương',
  handle: 'duong.kq',
  joinedDate: DateTime(2026, 8, 2),
);

const _progress = UserProgress(
  level: 5,
  currentXp: 1250,
  nextLevelXp: 1500,
  streakDays: 7,
);

const _publishedLocations = [
  PublishedLocationSummary(
    id: 'location-1',
    slug: 'gyeongbokgung',
    name: 'Cung điện Gyeongbokgung',
    koreanName: '경복궁',
    city: 'Seoul',
    shortDescription: 'Trung tâm lịch sử của triều đại Joseon.',
    thumbnailUrl: '',
    thumbnailAlt: '',
    releaseStatus: LocationReleaseStatus.released,
    categories: ['Lịch sử'],
  ),
  PublishedLocationSummary(
    id: 'location-2',
    slug: 'bukchon-hanok',
    name: 'Làng Bukchon Hanok',
    koreanName: '북촌한옥마을',
    city: 'Seoul',
    shortDescription: 'Nếp sống truyền thống giữa lòng Seoul.',
    thumbnailUrl: '',
    thumbnailAlt: '',
    releaseStatus: LocationReleaseStatus.released,
    categories: ['Văn hóa'],
  ),
  PublishedLocationSummary(
    id: 'location-3',
    slug: 'jeju',
    name: 'Đảo Jeju',
    koreanName: '제주도',
    city: 'Jeju',
    shortDescription: 'Thiên nhiên và văn hóa hải đảo.',
    thumbnailUrl: '',
    thumbnailAlt: '',
    releaseStatus: LocationReleaseStatus.comingSoon,
    categories: ['Thiên nhiên'],
  ),
];

const _personalLocations = [
  Location(
    id: 'gyeongbokgung',
    name: 'Cung điện Gyeongbokgung',
    koreanName: '경복궁',
    city: 'Seoul',
    description: 'Trung tâm lịch sử của triều đại Joseon.',
    status: LocationStatus.completed,
    releaseStatus: LocationReleaseStatus.released,
    rewardXp: 450,
  ),
  Location(
    id: 'bukchon-hanok',
    name: 'Làng Bukchon Hanok',
    koreanName: '북촌한옥마을',
    city: 'Seoul',
    description: 'Nếp sống truyền thống giữa lòng Seoul.',
    status: LocationStatus.inProgress,
    releaseStatus: LocationReleaseStatus.released,
    rewardXp: 380,
  ),
  Location(
    id: 'jeju',
    name: 'Đảo Jeju',
    koreanName: '제주도',
    city: 'Jeju',
    description: 'Thiên nhiên và văn hóa hải đảo.',
    status: LocationStatus.available,
    releaseStatus: LocationReleaseStatus.comingSoon,
    rewardXp: 600,
  ),
];

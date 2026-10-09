import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/app/app_theme.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';
import 'package:korea_quest/features/explore/presentation/pages/published_location_page.dart';
import 'package:korea_quest/features/explore/presentation/providers/location_content_providers.dart';
import 'package:korea_quest/features/explore/presentation/widgets/location_content_view.dart';

void main() {
  const location = PublishedLocationDetail({
    'id': 'sample',
    'slug': 'sample',
    'name': 'Địa điểm mẫu',
    'korean_name': '샘플',
    'english_name': 'Sample Place',
    'city': 'Seoul',
    'short_description': 'Mô tả ngắn.',
    'foods': <Object?>[],
  });

  const historyLocation = PublishedLocationDetail({
    'id': 'history-sample',
    'slug': 'history-sample',
    'name': 'Cung điện Gyeongbokgung',
    'city': 'Seoul',
    'history': <Object?>[
      <String, Object?>{
        'id': 'history-1',
        'period_label': 'Năm 1395',
        'title': 'Khởi dựng cung điện',
        'short_description': 'Gyeongbokgung được xây dựng đầu triều Joseon.',
        'long_description':
            'Cung điện trở thành trung tâm chính trị và nghi lễ của vương triều.',
        'related_people': 'Vua Taejo',
        'categories': <Object?>['Văn hóa', 'Kiến trúc'],
        'fun_fact': 'Tên cung điện mang ý nghĩa phúc lành lâu dài.',
        'media': <String, Object?>{
          'kind': 'image',
          'url': 'https://example.com/gyeongbokgung.jpg',
          'credit': 'KoreaQuest',
          'source_url': 'https://example.com/source',
          'alt': 'Cung điện Gyeongbokgung',
        },
      },
      <String, Object?>{
        'id': 'history-2',
        'period_label': 'Năm 1867',
        'title': 'Công cuộc trùng tu',
        'short_description': 'Quần thể cung điện được xây dựng lại.',
        'long_description':
            'Đợt trùng tu quy mô lớn khôi phục hàng trăm công trình.',
        'categories': <Object?>['Di sản'],
        'media': <String, Object?>{
          'kind': 'image',
          'url': 'https://example.com/restoration.jpg',
          'alt': 'Công trình được trùng tu',
        },
      },
      <String, Object?>{
        'id': 'history-3',
        'period_label': 'Ngày nay',
        'title': 'Di sản được bảo tồn',
        'short_description': 'Di sản tiếp tục được gìn giữ cho tương lai.',
        'media': <String, Object?>{},
      },
    ],
  });

  const funFactLocation = PublishedLocationDetail({
    'id': 'fun-fact-sample',
    'slug': 'fun-fact-sample',
    'name': 'Địa điểm Fun Fact',
    'city': 'Seoul',
    'fun_facts': <Object?>[
      <String, Object?>{
        'id': 'fact-1',
        'title': 'Fact 1',
        'fact': 'Nội dung 1',
      },
      <String, Object?>{
        'id': 'fact-2',
        'title': 'Fact 2',
        'fact': 'Nội dung 2',
      },
      <String, Object?>{
        'id': 'fact-3',
        'title': 'Fact 3',
        'fact': 'Nội dung 3',
      },
    ],
  });

  Widget buildApp({
    required int stage,
    required ValueChanged<int> onStage,
    PublishedLocationDetail currentLocation = location,
    bool disableAnimations = false,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(
          body: SingleChildScrollView(
            child: LocationContentView(
              location: currentLocation,
              currentStage: stage,
              onStageSelected: onStage,
              onSubmitQuizAnswer: (_, _) async =>
                  const QuizAnswerResult(isCorrect: false, explanation: ''),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders one selected stage and continues to the next stage', (
    tester,
  ) async {
    var selectedStage = -1;

    await tester.pumpWidget(
      buildApp(stage: 6, onStage: (stage) => selectedStage = stage),
    );

    expect(find.text('Chặng 6/9'), findsOneWidget);
    expect(find.text('Ẩm thực'), findsWidgets);
    expect(find.text('Chưa có nội dung ẩm thực để hiển thị.'), findsOneWidget);

    await tester.ensureVisible(find.text('Tiếp tục đến Fun Facts'));
    await tester.tap(find.text('Tiếp tục đến Fun Facts'));
    expect(selectedStage, 7);
  });

  testWidgets('starts the journey from the hero into the overview stage', (
    tester,
  ) async {
    var selectedStage = -1;

    await tester.pumpWidget(
      buildApp(stage: 1, onStage: (stage) => selectedStage = stage),
    );

    await tester.ensureVisible(find.text('Bắt đầu khám phá'));
    await tester.tap(find.text('Bắt đầu khám phá'));
    expect(selectedStage, 2);
  });

  testWidgets('allows selecting any stage directly', (tester) async {
    var selectedStage = -1;

    await tester.pumpWidget(
      buildApp(stage: 1, onStage: (stage) => selectedStage = stage),
    );

    final travelStage = find.textContaining('Du lịch').last;
    await tester.ensureVisible(travelStage);
    await tester.tap(travelStage);

    expect(selectedStage, 9);
  });

  testWidgets('shows every fun fact without lock styling', (tester) async {
    await tester.pumpWidget(
      buildApp(stage: 7, currentLocation: funFactLocation, onStage: (_) {}),
    );

    expect(find.byIcon(Icons.auto_awesome_rounded), findsNWidgets(3));
    expect(find.byIcon(Icons.lock_rounded), findsNothing);
    expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    expect(find.text('Fact 3'), findsOneWidget);
  });

  testWidgets('does not render inactive detail action buttons', (tester) async {
    await tester.pumpWidget(buildApp(stage: 3, onStage: (_) {}));

    expect(find.text('Xem chi tiết'), findsNothing);
    expect(find.text('Khám phá'), findsNothing);
    expect(find.text('Tìm hiểu ý nghĩa'), findsNothing);
    expect(find.text('Mở bản đồ'), findsNothing);
  });

  testWidgets('renders the history heading and published milestone data', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(stage: 3, currentLocation: historyLocation, onStage: (_) {}),
    );

    expect(find.text('CHẶNG 03/09'), findsOneWidget);
    expect(find.text('Lịch sử & Di sản'), findsOneWidget);
    expect(find.text('Năm 1395'), findsOneWidget);
    expect(find.text('Khởi dựng cung điện'), findsOneWidget);
    expect(find.text('Văn hóa'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsNothing);
    expect(find.textContaining('bị khóa'), findsNothing);
  });

  testWidgets('opens one history milestone and remembers viewed markers', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(stage: 3, currentLocation: historyLocation, onStage: (_) {}),
    );

    expect(
      find.text(
        'Cung điện trở thành trung tâm chính trị và nghi lễ của vương triều.',
      ),
      findsNothing,
    );

    final firstToggle = find.byKey(const ValueKey('history-toggle-0'));
    await tester.ensureVisible(firstToggle);
    await tester.pumpAndSettle();
    await tester.tap(firstToggle);
    await tester.pumpAndSettle();
    expect(find.text('Thu gọn'), findsOneWidget);
    expect(
      find.text(
        'Cung điện trở thành trung tâm chính trị và nghi lễ của vương triều.',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Mốc lịch sử 1, đang mở'), findsOneWidget);

    final secondToggle = find.byKey(const ValueKey('history-toggle-1'));
    await tester.ensureVisible(secondToggle);
    await tester.pumpAndSettle();
    await tester.tap(secondToggle);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Cung điện trở thành trung tâm chính trị và nghi lễ của vương triều.',
      ),
      findsNothing,
    );
    expect(
      find.text('Đợt trùng tu quy mô lớn khôi phục hàng trăm công trình.'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Mốc lịch sử 1, đã xem'), findsOneWidget);
    expect(find.bySemanticsLabel('Mốc lịch sử 2, đang mở'), findsOneWidget);
  });

  testWidgets('alternates history cards and media on desktop', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildApp(stage: 3, currentLocation: historyLocation, onStage: (_) {}),
    );

    expect(
      tester.getCenter(find.byKey(const ValueKey('history-card-0'))).dx,
      lessThan(
        tester.getCenter(find.byKey(const ValueKey('history-media-0'))).dx,
      ),
    );
    expect(
      tester.getCenter(find.byKey(const ValueKey('history-card-1'))).dx,
      greaterThan(
        tester.getCenter(find.byKey(const ValueKey('history-media-1'))).dx,
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('stacks history media below its card on mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildApp(stage: 3, currentLocation: historyLocation, onStage: (_) {}),
    );

    final cardBottom = tester
        .getBottomLeft(find.byKey(const ValueKey('history-card-0')))
        .dy;
    final mediaTop = tester
        .getTopLeft(find.byKey(const ValueKey('history-media-0')))
        .dy;
    expect(mediaTop, greaterThan(cardBottom));
    expect(find.byKey(const ValueKey('history-media-2')), findsNothing);
    expect(find.byKey(const ValueKey('history-toggle-2')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disables history expansion animation for reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        stage: 3,
        currentLocation: historyLocation,
        disableAnimations: true,
        onStage: (_) {},
      ),
    );

    final firstToggle = find.byKey(const ValueKey('history-toggle-0'));
    await tester.ensureVisible(firstToggle);
    await tester.pump();
    await tester.tap(firstToggle);
    await tester.pump();
    expect(find.text('Thu gọn'), findsOneWidget);
    final cardFinder = find.byKey(const ValueKey('history-card-0'));
    expect(
      tester.widget<AnimatedContainer>(cardFinder).duration,
      Duration.zero,
    );
    expect(
      find.descendant(of: cardFinder, matching: find.byType(AnimatedSize)),
      findsNothing,
    );
  });

  testWidgets('pinned journey stepper fits its desktop header', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          publishedLocationProvider(
            'sample',
          ).overrideWith((ref) async => location),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: PublishedLocationPage(slug: 'sample', stageNumber: 3),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(JourneyStepper), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('returns to the map after the travel stage', (tester) async {
    var selectedStage = -1;

    await tester.pumpWidget(
      buildApp(stage: 9, onStage: (stage) => selectedStage = stage),
    );

    await tester.ensureVisible(find.text('Trở về bản đồ Hàn Quốc'));
    await tester.tap(find.text('Trở về bản đồ Hàn Quốc'));
    expect(selectedStage, 0);
  });
}

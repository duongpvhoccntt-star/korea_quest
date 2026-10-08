import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/app/app_theme.dart';
import 'package:korea_quest/features/admin/data/demo_admin_repository.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/presentation/providers/admin_providers.dart';
import 'package:korea_quest/features/admin/presentation/widgets/admin_editor_fields.dart';
import 'package:korea_quest/features/admin/presentation/widgets/location_editor.dart';

void main() {
  test('demo validation uses the relaxed MVP section thresholds', () async {
    final repository = DemoAdminRepository();
    addTearDown(repository.dispose);
    Map<String, dynamic> visibleItem() => {'is_visible': true};
    final draft = AdminLocationDraft(
      locationId: 'location-1',
      revisionId: 'revision-1',
      slug: 'dia-diem-test',
      overview: {
        ...AdminLocationDraft.emptyOverview(),
        'name': 'Địa điểm test',
      },
      history: List.generate(2, (_) => visibleItem()),
      highlights: List.generate(2, (_) => visibleItem()),
      experiences: [visibleItem()],
      foods: [visibleItem()],
      funFacts: List.generate(2, (_) => visibleItem()),
      quiz: List.generate(5, (_) => visibleItem()),
    );

    final errors = await repository.validateDraft(draft);

    expect(errors, isEmpty);
  });

  testWidgets('editor scrolls without overflowing a desktop viewport', (
    tester,
  ) async {
    await _pumpEditor(tester, const Size(1260, 940));

    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsWidgets);
  });

  testWidgets('overview uses the 10 to 200 word publication range', (
    tester,
  ) async {
    await _pumpEditor(tester, const Size(1260, 3000));
    await tester.tap(find.text('2. Tổng quan'));
    await tester.pumpAndSettle();

    final wordLimitedFields = tester
        .widgetList<AdminEditorTextField>(find.byType(AdminEditorTextField))
        .where((field) => field.maxWords == 200)
        .toList();

    expect(wordLimitedFields, isNotEmpty);
    expect(wordLimitedFields.every((field) => field.minWords == 10), isTrue);
  });

  testWidgets('an unsaved draft can skip directly to another section', (
    tester,
  ) async {
    await _pumpEditor(tester, const Size(1260, 3000));

    await tester.enterText(find.byType(TextField).first, 'jeju');
    await tester.pump();
    await tester.tap(find.text('3. Lịch sử'));
    await tester.pumpAndSettle();

    expect(find.text('Lịch sử hình thành'), findsOneWidget);
  });

  testWidgets('editor only exposes the final quiz with a 30-question cap', (
    tester,
  ) async {
    await _pumpEditor(tester, const Size(1260, 3000));

    await tester.tap(find.text('8. Quiz tổng kết'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz tổng kết: 0/30 · tối thiểu 5'), findsOneWidget);
    expect(find.text('Nhóm quiz'), findsNothing);
    expect(find.text('Quiz Check-in'), findsNothing);
    expect(find.text('Quiz Văn hóa'), findsNothing);
  });

  testWidgets(
    'review step displays actionable error cards with jump-to-step buttons',
    (tester) async {
      tester.view.physicalSize = const Size(1260, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = DemoAdminRepository();
      addTearDown(repository.dispose);
      final draft = AdminLocationDraft(
        locationId: 'test-loc-1',
        revisionId: 'test-rev-1',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [adminRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: LocationEditor(draft: draft, onClose: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('10. Kiểm tra & Xuất bản'));
      await tester.pumpAndSettle();

      expect(find.textContaining('ADR 0011'), findsWidgets);

      await tester.tap(find.text('Kiểm tra điều kiện'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Chưa thể Xuất bản'), findsOneWidget);
      expect(find.text('Đi tới sửa'), findsWidgets);

      // Tap first "Đi tới sửa" button (which should jump to Step 2: Tổng quan or Step 3: Lịch sử)
      await tester.tap(find.text('Đi tới sửa').first);
      await tester.pumpAndSettle();

      // Verify it navigated away from review step to the error step
      expect(find.text('Slug công khai'), findsOneWidget);
    },
  );

  testWidgets('quiz error button scrolls to the exact invalid question', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1260, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _QuizErrorDemoRepository();
    addTearDown(repository.dispose);
    Map<String, dynamic> question(String prompt, {bool invalid = false}) => {
      'prompt': prompt,
      'kind': 'single_choice',
      'is_visible': true,
      'options': invalid
          ? [
              {'text': 'Chỉ một lựa chọn', 'is_correct': true},
            ]
          : [
              {'text': 'A', 'is_correct': true},
              {'text': 'B', 'is_correct': false},
            ],
    };
    final draft = AdminLocationDraft(
      locationId: 'test-loc-quiz',
      revisionId: 'test-rev-quiz',
      quiz: [
        question('Câu hợp lệ 1'),
        question('Câu hợp lệ 2'),
        question('Câu cần sửa', invalid: true),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: LocationEditor(draft: draft, onClose: () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('10. Kiểm tra & Xuất bản'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Kiểm tra điều kiện'));
    await tester.tap(find.text('Kiểm tra điều kiện'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Câu 3 “Câu cần sửa”'), findsOneWidget);
    await tester.ensureVisible(find.text('Đi tới sửa'));
    await tester.tap(find.text('Đi tới sửa'));
    await tester.pumpAndSettle();

    final questionCardTitle = find.text('câu hỏi 3');
    expect(questionCardTitle, findsOneWidget);
    final targetY = tester.getCenter(questionCardTitle).dy;
    expect(targetY, inInclusiveRange(0, 900));
  });
}

class _QuizErrorDemoRepository extends DemoAdminRepository {
  @override
  Future<List<String>> validateDraft(AdminLocationDraft draft) async => const [
    'Câu một đáp án cần 2–6 lựa chọn và đúng chính xác một đáp án.',
  ];
}

Future<void> _pumpEditor(WidgetTester tester, Size viewport) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final repository = DemoAdminRepository();
  addTearDown(repository.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [adminRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: LocationEditor(draft: AdminLocationDraft(), onClose: () {}),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

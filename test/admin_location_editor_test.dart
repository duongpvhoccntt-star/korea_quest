import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/app/app_theme.dart';
import 'package:korea_quest/features/admin/data/demo_admin_repository.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/presentation/providers/admin_providers.dart';
import 'package:korea_quest/features/admin/presentation/widgets/location_editor.dart';

void main() {
  testWidgets('editor scrolls without overflowing a desktop viewport', (
    tester,
  ) async {
    await _pumpEditor(tester, const Size(1260, 940));

    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsWidgets);
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

  testWidgets('editor only exposes the final quiz with a 20-question cap', (
    tester,
  ) async {
    await _pumpEditor(tester, const Size(1260, 3000));

    await tester.tap(find.text('8. Quiz tổng kết'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz tổng kết: 0/20 · tối thiểu 10'), findsOneWidget);
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

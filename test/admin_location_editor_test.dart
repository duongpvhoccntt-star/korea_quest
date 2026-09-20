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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/app/app_theme.dart';
import 'package:korea_quest/features/home/presentation/pages/home_page.dart';

void main() {
  for (final viewport in <String, Size>{
    'desktop': const Size(1920, 1080),
    'laptop': const Size(1280, 900),
    'tablet': const Size(800, 1000),
    'mobile': const Size(390, 844),
  }.entries) {
    testWidgets('home renders without layout errors on ${viewport.key}', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = viewport.value;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: HomePage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bạn muốn bắt đầu từ đâu?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

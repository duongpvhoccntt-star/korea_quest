import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/app/app.dart';

void main() {
  for (final viewport in <String, Size>{
    'desktop': const Size(1280, 900),
    'tablet': const Size(800, 1000),
    'mobile': const Size(390, 844),
  }.entries) {
    testWidgets('landing renders without layout errors on ${viewport.key}', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = viewport.value;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const ProviderScope(child: KoreaQuestApp()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Mỗi điểm đến'), findsOneWidget);
      expect(find.text('Bản đồ phiêu lưu'), findsOneWidget);
      expect(find.text('Chọn nơi câu chuyện bắt đầu'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

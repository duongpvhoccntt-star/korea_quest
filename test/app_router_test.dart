import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/app/app.dart';

void main() {
  testWidgets('app router renders landing route', (tester) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('vi');
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    await tester.pumpWidget(const ProviderScope(child: KoreaQuestApp()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Mỗi điểm đến'), findsOneWidget);
    expect(find.text('Bắt đầu hành trình'), findsOneWidget);
  });
}

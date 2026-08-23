import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/app/app_theme.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';

void main() {
  testWidgets('PrimaryButton exposes label and handles tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PrimaryButton(label: 'Bắt đầu', onPressed: () => taps += 1),
        ),
      ),
    );

    expect(find.text('Bắt đầu'), findsOneWidget);
    await tester.tap(find.text('Bắt đầu'));
    expect(taps, 1);
  });

  testWidgets('PrimaryButton displays loading state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: PrimaryButton(label: 'Lưu', isLoading: true),
        ),
      ),
    );

    expect(find.text('Đang xử lý…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

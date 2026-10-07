import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/settings/presentation/pages/settings_page.dart';
import 'package:korea_quest/features/settings/presentation/widgets/change_password_dialog.dart';

void main() {
  testWidgets('SettingsPage renders all 4 grouped cards', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: SettingsPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tài khoản & Bảo mật'), findsOneWidget);
    expect(find.text('Tùy chọn trải nghiệm'), findsOneWidget);
    expect(find.text('Quản lý dữ liệu & Lưu trữ'), findsOneWidget);
    expect(find.text('Đăng xuất tài khoản'), findsOneWidget);
    expect(find.text('Đổi mật khẩu'), findsOneWidget);
    expect(find.text('Đặt lại tiến trình học tập'), findsWidgets);
  });

  testWidgets('ChangePasswordDialog validates input fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ChangePasswordDialog.show(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Đổi mật khẩu'), findsOneWidget);
    // Tap confirm without typing
    await tester.tap(find.text('Cập nhật mật khẩu'));
    await tester.pumpAndSettle();

    expect(find.text('Vui lòng điền đầy đủ các thông tin.'), findsOneWidget);
  });
}

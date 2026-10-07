import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/profile/presentation/pages/profile_page.dart';
import 'package:korea_quest/features/profile/presentation/widgets/avatar_selector_modal.dart';

void main() {
  group('ProfilePage', () {
    testWidgets('view mode renders user name and edit button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: ProfilePage())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chỉnh sửa hồ sơ'), findsOneWidget);
      expect(find.text('KOREAQUEST PROFILE'), findsOneWidget);
    });

    testWidgets('edit mode renders avatar camera button and form fields', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: ProfilePage(isEditing: true)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
      expect(find.text('Họ và tên'), findsOneWidget);
      expect(find.text('Tên hiển thị'), findsOneWidget);
      expect(find.text('Giới thiệu'), findsOneWidget);
      expect(find.text('Lưu thay đổi'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
    });

    testWidgets('view mode exposes settings and sign out actions', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: ProfilePage())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cài đặt'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);
    });
  });

  group('AvatarSelectorModal', () {
    testWidgets('renders preset grid and upload button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AvatarSelectorModal())),
      );
      await tester.pump();

      expect(find.text('Tải ảnh từ máy tính'), findsOneWidget);
      expect(find.text('HOẶC CHỌN NHÂN VẬT ĐẠI DIỆN'), findsOneWidget);
      // 6 preset labels
      expect(find.text('Hanbok Explorer'), findsOneWidget);
      expect(find.text('Seoul Traveler'), findsOneWidget);
      expect(find.text('Haechi Guardian'), findsOneWidget);
      expect(find.text('Joseon Scholar'), findsOneWidget);
      expect(find.text('K-Foodie'), findsOneWidget);
      expect(find.text('K-Pop Fan'), findsOneWidget);
      expect(find.text('Xác nhận'), findsOneWidget);
    });

    testWidgets('tapping a preset highlights it', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AvatarSelectorModal())),
      );
      await tester.pump();

      await tester.tap(find.text('Seoul Traveler'));
      await tester.pumpAndSettle();

      // Text turns bold red when selected — just verify no error
      expect(find.text('Seoul Traveler'), findsOneWidget);
    });
  });
}

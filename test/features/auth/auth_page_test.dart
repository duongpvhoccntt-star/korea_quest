import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/features/admin/presentation/pages/admin_database_page.dart';
import 'package:korea_quest/features/auth/presentation/pages/auth_page.dart';

void main() {
  Widget buildTestApp({AuthPageMode mode = AuthPageMode.login}) {
    final testRouter = GoRouter(
      initialLocation: mode == AuthPageMode.login ? '/login' : '/register',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const AuthPage(mode: AuthPageMode.login),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) =>
              const AuthPage(mode: AuthPageMode.register),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDatabasePage(),
        ),
        GoRoute(
          path: '/explore',
          builder: (context, state) =>
              const Scaffold(body: Text('Explore Screen')),
        ),
      ],
    );

    return ProviderScope(child: MaterialApp.router(routerConfig: testRouter));
  }

  group('AuthPage Widget Tests', () {
    testWidgets('renders login form and quick test accounts card', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Đăng nhập'), findsWidgets);
      expect(find.text('Đăng ký'), findsWidgets);
      expect(find.text('Tài khoản thử nghiệm nhanh'), findsOneWidget);
      expect(find.text('admin / admin123'), findsOneWidget);
      expect(find.text('duong@example.com'), findsOneWidget);
      expect(find.text('Khám phá với tư cách Khách'), findsOneWidget);
      expect(find.byKey(const ValueKey('auth-korea-scenery')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('auth-koreaquest-logo')),
        findsOneWidget,
      );
    });

    testWidgets('uses a compact scenic banner on mobile', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('auth-korea-scenery')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('auth-koreaquest-logo')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('switches between Login and Register tabs', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Initially on Login - no "Họ và tên"
      expect(find.text('Họ và tên'), findsNothing);

      // Tap Register tab in SegmentedButton
      await tester.tap(find.text('Đăng ký').first);
      await tester.pumpAndSettle();

      // Now on Register - shows "Họ và tên" and "Tên hiển thị"
      expect(find.text('Họ và tên'), findsOneWidget);
      expect(find.text('Tên hiển thị'), findsOneWidget);
      expect(find.text('Xác nhận mật khẩu'), findsOneWidget);
    });

    testWidgets('register form validates matching secure passwords', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp(mode: AuthPageMode.register));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tạo tài khoản'));
      await tester.pump();

      expect(find.text('Vui lòng nhập email.'), findsOneWidget);
    });

    testWidgets('tapping quick admin button navigates to /admin', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final adminQuickButton = find.text('admin / admin123');
      expect(adminQuickButton, findsOneWidget);

      await tester.ensureVisible(adminQuickButton);
      await tester.tap(adminQuickButton);
      await tester.pumpAndSettle();

      // Navigated to /admin (shows KoreaQuest Admin title or missing-config card)
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data?.contains('KoreaQuest Admin') == true ||
                  w.data?.contains('cấu hình Supabase') == true ||
                  w.data?.contains('Đăng nhập') == true),
        ),
        findsWidgets,
      );
    });

    testWidgets('tapping quick student button navigates to /explore', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final studentQuickButton = find.text('duong@example.com');
      expect(studentQuickButton, findsOneWidget);

      await tester.ensureVisible(studentQuickButton);
      await tester.tap(studentQuickButton);
      await tester.pumpAndSettle();

      // Navigated to /explore
      expect(find.text('Explore Screen'), findsOneWidget);
    });

    testWidgets('tapping guest mode button navigates to /explore', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final guestButton = find.text('Khám phá với tư cách Khách');
      expect(guestButton, findsOneWidget);

      await tester.ensureVisible(guestButton);
      await tester.tap(guestButton);
      await tester.pumpAndSettle();

      // Navigated to /explore
      expect(find.text('Explore Screen'), findsOneWidget);
    });
  });
}

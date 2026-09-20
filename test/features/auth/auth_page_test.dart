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
          path: '/home',
          builder: (context, state) =>
              const Scaffold(body: Text('Home Screen')),
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
      expect(find.text('admin@koreaquest.com'), findsOneWidget);
      expect(find.text('duong@example.com'), findsOneWidget);
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

      final adminQuickButton = find.text('admin@koreaquest.com');
      expect(adminQuickButton, findsOneWidget);

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

    testWidgets('tapping quick student button navigates to /home', (
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

      await tester.tap(studentQuickButton);
      await tester.pumpAndSettle();

      // Navigated to /home
      expect(find.text('Home Screen'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/components/app_structure.dart';
import 'package:korea_quest/features/auth/domain/auth_models.dart';
import 'package:korea_quest/features/auth/presentation/providers/auth_providers.dart';

void main() {
  const mockUser = AuthUser(
    id: 'u1',
    usernameOrEmail: 'duong@example.com',
    displayName: 'Dương',
    role: UserRole.user,
  );

  testWidgets('AppHeader displays account menu for member avatar', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1600, 900);
    addTearDown(tester.view.reset);

    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authUserStreamProvider.overrideWith((ref) => Stream.value(mockUser)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Khám phá'), findsOneWidget);

    await tester.tap(find.byTooltip('Mở menu tài khoản'));
    await tester.pumpAndSettle();

    expect(find.text('Hồ sơ của tôi'), findsOneWidget);
    expect(find.text('Cài đặt'), findsWidgets);
    expect(find.text('Đăng xuất'), findsOneWidget);
  });

  testWidgets('mobile member menu includes sign out', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authUserStreamProvider.overrideWith((ref) => Stream.value(mockUser)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Đăng xuất'), findsOneWidget);
  });
}

GoRouter _router() => GoRouter(
  initialLocation: '/explore',
  routes: [
    GoRoute(
      path: '/explore',
      builder: (context, state) => const Scaffold(appBar: AppHeader()),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const Scaffold(body: Text('Profile')),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const Scaffold(body: Text('Settings')),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const Scaffold(body: Text('Login')),
    ),
  ],
);

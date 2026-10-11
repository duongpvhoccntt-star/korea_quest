import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/features/auth/presentation/widgets/guest_access_prompt_dialog.dart';
import 'package:korea_quest/l10n/app_localizations.dart';

void main() {
  testWidgets('shows the Guest access choices and entered name', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        home: const GuestAccessPromptDialog(
          guestName: 'Minh Anh',
          targetPath: '/passport',
        ),
      ),
    );

    expect(find.text('Sign in to unlock this feature'), findsOneWidget);
    expect(find.textContaining('Minh Anh'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Maybe Later / Continue as Guest'), findsOneWidget);
  });

  testWidgets('sign in preserves the requested member screen', (tester) async {
    final router = _dialogRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/login');
    expect(
      router.routeInformationProvider.value.uri.queryParameters['redirect'],
      '/passport',
    );
  });

  testWidgets('registration preserves the Guest name and requested screen', (
    tester,
  ) async {
    final router = _dialogRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/register');
    expect(
      router.routeInformationProvider.value.uri.queryParameters['name'],
      'Minh Anh',
    );
    expect(
      router.routeInformationProvider.value.uri.queryParameters['redirect'],
      '/passport',
    );
  });

  testWidgets('continue as Guest returns to Explore', (tester) async {
    final router = _dialogRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Maybe Later / Continue as Guest'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/explore');
  });
}

Widget _app({Widget? home, GoRouter? router}) {
  return MaterialApp.router(
    routerConfig:
        router ??
        GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(body: home),
            ),
          ],
        ),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
  );
}

GoRouter _dialogRouter() => GoRouter(
  initialLocation: '/dialog',
  routes: [
    GoRoute(
      path: '/dialog',
      builder: (context, state) => const _GuestDialogLauncher(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const Scaffold(body: Text('Login')),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const Scaffold(body: Text('Register')),
    ),
    GoRoute(
      path: '/explore',
      builder: (context, state) => const Scaffold(body: Text('Explore')),
    ),
  ],
);

class _GuestDialogLauncher extends StatefulWidget {
  const _GuestDialogLauncher();

  @override
  State<_GuestDialogLauncher> createState() => _GuestDialogLauncherState();
}

class _GuestDialogLauncherState extends State<_GuestDialogLauncher> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showGuestAccessPromptDialog(
        context,
        guestName: 'Minh Anh',
        targetPath: '/passport',
      );
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Dialog'));
}

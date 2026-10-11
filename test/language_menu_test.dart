import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/app/app_theme.dart';
import 'package:korea_quest/design_system/components/app_structure.dart';
import 'package:korea_quest/l10n/app_localizations.dart';
import 'package:korea_quest/l10n/locale_controller.dart';

void main() {
  testWidgets('globe language menu changes the selected locale', (tester) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('vi');
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);

    await tester.pumpWidget(const ProviderScope(child: _LanguageTestApp()));
    await tester.tap(find.byIcon(Icons.public_rounded));
    await tester.pumpAndSettle();

    expect(find.text('EN · English'), findsOneWidget);
    await tester.tap(find.text('EN · English'));
    await tester.pumpAndSettle();

    expect(find.text('EN'), findsOneWidget);
  });
}

class _LanguageTestApp extends ConsumerWidget {
  const _LanguageTestApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    theme: AppTheme.light,
    locale: ref.watch(localeProvider),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const Scaffold(body: Center(child: LanguageMenu())),
  );
}

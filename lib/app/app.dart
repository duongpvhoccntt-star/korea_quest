import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/app/app_config.dart';
import 'package:korea_quest/app/app_router.dart';
import 'package:korea_quest/app/app_theme.dart';
import 'package:korea_quest/l10n/app_localizations.dart';
import 'package:korea_quest/l10n/app_strings.dart';
import 'package:korea_quest/l10n/locale_controller.dart';

class KoreaQuestApp extends ConsumerWidget {
  const KoreaQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: AppConfig.appName,
      onGenerateTitle: (context) => appStrings(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

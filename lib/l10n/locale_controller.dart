import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/core/services/locale_storage.dart';

const supportedLanguageCodes = {'vi', 'en', 'ko'};

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale> {
  late final LocaleStorage _storage;

  @override
  Locale build() {
    _storage = createLocaleStorage();
    final saved = _storage.read();
    if (saved != null && supportedLanguageCodes.contains(saved)) {
      return Locale(saved);
    }
    final deviceCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return Locale(
      supportedLanguageCodes.contains(deviceCode) ? deviceCode : 'vi',
    );
  }

  void setLocale(Locale locale) {
    final code = supportedLanguageCodes.contains(locale.languageCode)
        ? locale.languageCode
        : 'vi';
    _storage.write(code);
    state = Locale(code);
  }
}

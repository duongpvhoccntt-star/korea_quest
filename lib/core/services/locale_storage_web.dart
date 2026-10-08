import 'package:web/web.dart' as web;

import 'locale_storage.dart';

LocaleStorage createPlatformLocaleStorage() => _WebLocaleStorage();

class _WebLocaleStorage implements LocaleStorage {
  static const _key = 'koreaquest.locale';

  @override
  String? read() => web.window.localStorage.getItem(_key);

  @override
  void write(String languageCode) {
    web.window.localStorage.setItem(_key, languageCode);
  }
}

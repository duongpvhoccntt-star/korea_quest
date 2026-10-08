import 'locale_storage_stub.dart'
    if (dart.library.js_interop) 'locale_storage_web.dart';

abstract interface class LocaleStorage {
  String? read();
  void write(String languageCode);
}

LocaleStorage createLocaleStorage() => createPlatformLocaleStorage();

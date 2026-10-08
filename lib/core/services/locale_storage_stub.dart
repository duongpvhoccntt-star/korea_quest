import 'locale_storage.dart';

LocaleStorage createPlatformLocaleStorage() => _MemoryLocaleStorage();

class _MemoryLocaleStorage implements LocaleStorage {
  String? _value;

  @override
  String? read() => _value;

  @override
  void write(String languageCode) => _value = languageCode;
}

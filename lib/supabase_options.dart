import 'package:korea_quest/app/app_config.dart';

/// Compatibility wrapper. Configure values with Flutter `--dart-define` flags.
abstract final class SupabaseOptions {
  static const url = AppConfig.supabaseUrl;
  static const anonKey = AppConfig.supabasePublishableKey;
}

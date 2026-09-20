abstract final class AppConfig {
  static const appName = 'KoreaQuest';
  static const defaultLocationId = 'gyeongbokgung';

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const adminDemoMode = bool.fromEnvironment('ADMIN_DEMO_MODE');

  static bool get hasSupabaseConfiguration =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static bool get hasAdminBackend => adminDemoMode || hasSupabaseConfiguration;
}

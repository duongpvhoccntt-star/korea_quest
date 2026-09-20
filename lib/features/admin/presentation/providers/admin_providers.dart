import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/app/app_config.dart';
import 'package:korea_quest/features/admin/data/demo_admin_repository.dart';
import 'package:korea_quest/features/admin/data/supabase_admin_repository.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/domain/admin_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDemoModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void enable() => state = true;
  void disable() => state = false;
}

final adminDemoOverrideProvider = NotifierProvider<AdminDemoModeNotifier, bool>(
  AdminDemoModeNotifier.new,
);

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final demoOverride = ref.watch(adminDemoOverrideProvider);
  if (AppConfig.adminDemoMode || demoOverride) {
    final repository = DemoAdminRepository();
    ref.onDispose(repository.dispose);
    return repository;
  }
  if (!AppConfig.hasSupabaseConfiguration) {
    throw const AdminConfigurationException(
      'Thiếu SUPABASE_URL hoặc SUPABASE_PUBLISHABLE_KEY.',
    );
  }
  return SupabaseAdminRepository(Supabase.instance.client);
});

final adminSessionProvider = StreamProvider<AdminSession>((ref) {
  return ref.watch(adminRepositoryProvider).watchSession();
});

final adminAccessProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(adminRepositoryProvider).isCurrentUserAdmin();
});

final adminLocationsProvider =
    FutureProvider.autoDispose<List<AdminLocationSummary>>((ref) {
      return ref.watch(adminRepositoryProvider).listLocations();
    });

final adminGameConfigProvider = FutureProvider.autoDispose<AdminGameConfig>((
  ref,
) {
  return ref.watch(adminRepositoryProvider).getGameConfig();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/app/app_config.dart';
import 'package:korea_quest/core/services/location_completion_cache.dart';
import 'package:korea_quest/features/explore/data/mock_location_content_repository.dart';
import 'package:korea_quest/features/explore/data/supabase_location_content_repository.dart';
import 'package:korea_quest/features/explore/domain/location_content_repository.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';
import 'package:korea_quest/l10n/locale_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final locationContentRepositoryProvider = Provider<LocationContentRepository>(
  (ref) => AppConfig.hasSupabaseConfiguration
      ? SupabaseLocationContentRepository(Supabase.instance.client)
      : const MockLocationContentRepository(),
);

final locationCompletionCacheProvider = Provider<LocationCompletionCache>(
  (ref) => LocationCompletionCache(),
);

/// Persistent local completion data complements passport stamps while they
/// are being refreshed and keeps the unconfigured demo useful after reload.
final cachedCompletedLocationSlugsProvider =
    FutureProvider.family<Set<String>, String>((ref, userId) {
      return ref.watch(locationCompletionCacheProvider).read(userId);
    });

/// Makes the completion marker visible immediately while persistent passport
/// stamps refresh after a journey is finished.
final recentlyCompletedLocationSlugsProvider =
    NotifierProvider<RecentlyCompletedLocationSlugs, Set<String>>(
      RecentlyCompletedLocationSlugs.new,
    );

class RecentlyCompletedLocationSlugs extends Notifier<Set<String>> {
  @override
  Set<String> build() => const <String>{};

  void add(String slug) {
    state = {...state, slug};
  }
}

final publishedLocationsProvider =
    FutureProvider<List<PublishedLocationSummary>>((ref) {
      final locale = ref.watch(localeProvider).languageCode;
      return ref
          .watch(locationContentRepositoryProvider)
          .listPublishedLocations(locale: locale);
    });

final publishedLocationProvider =
    FutureProvider.family<PublishedLocationDetail?, String>((ref, slug) {
      final locale = ref.watch(localeProvider).languageCode;
      return ref
          .watch(locationContentRepositoryProvider)
          .getPublishedLocation(slug, locale: locale);
    });

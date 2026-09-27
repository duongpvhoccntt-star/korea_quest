import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/app/app_config.dart';
import 'package:korea_quest/features/explore/data/supabase_location_content_repository.dart';
import 'package:korea_quest/features/explore/domain/location_content_repository.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final locationContentRepositoryProvider = Provider<LocationContentRepository>(
  (ref) => AppConfig.hasSupabaseConfiguration
      ? SupabaseLocationContentRepository(Supabase.instance.client)
      : const UnconfiguredLocationContentRepository(),
);

final publishedLocationsProvider =
    FutureProvider<List<PublishedLocationSummary>>(
      (ref) =>
          ref.watch(locationContentRepositoryProvider).listPublishedLocations(),
    );

final publishedLocationProvider =
    FutureProvider.family<PublishedLocationDetail?, String>(
      (ref, slug) => ref
          .watch(locationContentRepositoryProvider)
          .getPublishedLocation(slug),
    );

import 'package:flutter/foundation.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/repositories/korea_quest_repository.dart';
import 'package:korea_quest/shared/repositories/mock_korea_quest_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseKoreaQuestRepository implements KoreaQuestRepository {
  SupabaseKoreaQuestRepository({
    SupabaseClient? client,
    KoreaQuestRepository? fallbackRepository,
  }) : _client = client ?? Supabase.instance.client,
       _fallback = fallbackRepository ?? MockKoreaQuestRepository();

  final SupabaseClient _client;
  final KoreaQuestRepository _fallback;

  @override
  Future<AppUser> getCurrentUser() => _fallback.getCurrentUser();

  @override
  Future<UserProgress> getUserProgress() => _fallback.getUserProgress();

  @override
  Future<List<Location>> getLocations() async {
    try {
      final rows = await _client
          .from('location_revisions')
          .select(
            'id, location_id, name, korean_name, city, short_description, status, display_order, tags',
          )
          .eq('status', 'published')
          .order('display_order', ascending: true);

      final supabaseLocations = <Location>[];
      for (final raw in rows as List<dynamic>) {
        if (raw is! Map<String, dynamic>) continue;
        final name = raw['name'] as String? ?? '';
        final city = raw['city'] as String? ?? '';
        final koreanName = raw['korean_name'] as String? ?? '';
        final description = raw['short_description'] as String? ?? '';
        final tags =
            (raw['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        // Determine slug identifier
        String id = raw['location_id'] as String? ?? raw['id'] as String? ?? '';
        if (tags.contains('jeju') ||
            name.toLowerCase().contains('jeju') ||
            city.toLowerCase() == 'jeju') {
          id = 'jeju';
        }

        supabaseLocations.add(
          Location(
            id: id,
            name: name,
            koreanName: koreanName,
            city: city,
            description: description,
            status: LocationStatus.available,
            rewardXp: 600,
          ),
        );
      }

      // Merge with base locations from fallback so all places are available
      final fallbackLocations = await _fallback.getLocations();
      final merged = <Location>[...supabaseLocations];
      final existingIds = supabaseLocations.map((l) => l.id).toSet();

      for (final loc in fallbackLocations) {
        if (!existingIds.contains(loc.id)) {
          merged.add(loc);
        }
      }

      return merged;
    } catch (e) {
      debugPrint('Lỗi lấy locations từ Supabase, chuyển sang fallback: $e');
      return _fallback.getLocations();
    }
  }

  @override
  Future<Location?> getLocation(String id) async {
    final locations = await getLocations();
    for (final loc in locations) {
      if (loc.id == id) return loc;
    }
    return null;
  }

  @override
  Future<JourneyProgress> getJourney(String locationId) async {
    if (locationId == 'jeju') {
      return JourneyProgress(
        locationId: locationId,
        stage: JourneyStage.checkIn,
        completedMissions: 0,
        totalMissions: 9,
      );
    }
    return _fallback.getJourney(locationId);
  }

  @override
  Future<List<Mission>> getMissions(String locationId) =>
      _fallback.getMissions(locationId);

  @override
  Future<List<Achievement>> getAchievements() => _fallback.getAchievements();

  @override
  Future<List<PassportStamp>> getPassportStamps() =>
      _fallback.getPassportStamps();
}

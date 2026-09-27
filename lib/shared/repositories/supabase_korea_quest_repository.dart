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

  /// Only exposes locations returned by the public published read model.
  /// The admin editor is the source of this data; no local location is merged.
  @override
  Future<List<Location>> getLocations() async {
    final response = await _client.rpc('list_published_locations');
    if (response is! List) return const [];

    return response
        .whereType<Map>()
        .map((raw) {
          final item = Map<String, dynamic>.from(
            raw.map((key, value) => MapEntry('$key', value)),
          );
          final releaseStatus = item['release_status']?.toString();
          return Location(
            id: item['slug']?.toString() ?? '',
            name: item['name']?.toString() ?? '',
            koreanName: item['korean_name']?.toString() ?? '',
            city: item['city']?.toString() ?? '',
            description: item['short_description']?.toString() ?? '',
            status: releaseStatus == 'released'
                ? LocationStatus.available
                : LocationStatus.locked,
            rewardXp: 0,
          );
        })
        .where((location) => location.id.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<Location?> getLocation(String id) async {
    final locations = await getLocations();
    for (final location in locations) {
      if (location.id == id) return location;
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

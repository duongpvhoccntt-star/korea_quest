import 'dart:typed_data';

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
  Future<AppUser> getCurrentUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw StateError('Authentication required.');
    final raw = await _client
        .from('explorer_profiles')
        .select()
        .eq('user_id', authUser.id)
        .maybeSingle();
    final profile = raw == null ? const <String, dynamic>{} : _map(raw);
    final metadata = authUser.userMetadata ?? const <String, dynamic>{};
    final joinedAt = DateTime.tryParse(
      profile['joined_at']?.toString() ?? authUser.createdAt,
    );
    return AppUser(
      id: authUser.id,
      fullName:
          profile['full_name']?.toString() ??
          metadata['full_name']?.toString() ??
          '',
      displayName:
          profile['display_name']?.toString() ??
          metadata['display_name']?.toString() ??
          authUser.email?.split('@').first ??
          '',
      handle: profile['handle']?.toString() ?? '',
      joinedDate: joinedAt ?? DateTime.now(),
      bio: profile['bio']?.toString(),
      avatarPreset: profile['avatar_path']?.toString(),
    );
  }

  @override
  Future<AppUser> updateUserProfile({
    String? fullName,
    String? displayName,
    String? bio,
    String? avatarPreset,
    Uint8List? avatarBytes,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Authentication required.');
    final changes = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (fullName != null) changes['full_name'] = fullName;
    if (displayName != null) changes['display_name'] = displayName;
    if (bio != null) changes['bio'] = bio;
    if (avatarPreset != null) changes['avatar_path'] = avatarPreset;
    if (changes.length > 1) {
      await _client
          .from('explorer_profiles')
          .update(changes)
          .eq('user_id', user.id);
    }
    return getCurrentUser();
  }

  @override
  Future<UserProgress> getUserProgress({String locale = 'vi'}) async {
    await _client.rpc('record_daily_visit');
    final response = await _client.rpc(
      'get_my_progress',
      params: {'requested_locale': locale},
    );
    return UserProgress.fromJson(_map(response));
  }

  @override
  Future<void> resetUserProgress({String locale = 'vi'}) async {
    await _client.rpc(
      'reset_my_progress',
      params: {'requested_locale': locale},
    );
  }

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
          return Location(
            id: item['slug']?.toString() ?? '',
            name: item['name']?.toString() ?? '',
            koreanName: item['korean_name']?.toString() ?? '',
            city: item['city']?.toString() ?? '',
            description: item['short_description']?.toString() ?? '',
            status: LocationStatus.available,
            releaseStatus: LocationReleaseStatus.fromWire(
              item['release_status'],
            ),
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
  Future<List<Achievement>> getEarnedAchievements({
    String locale = 'vi',
  }) async {
    final response = await _client.rpc(
      'get_my_achievements',
      params: {'requested_locale': locale},
    );
    return _list(response).map(Achievement.fromJson).toList(growable: false);
  }

  @override
  Future<List<PassportStamp>> getEarnedPassportStamps({
    String locale = 'vi',
  }) async {
    final response = await _client.rpc(
      'get_my_passport',
      params: {'requested_locale': locale},
    );
    return _list(
      _map(response)['stamps'],
    ).map(PassportStamp.fromJson).toList(growable: false);
  }

  @override
  Future<String> regeneratePassportShareLink() async {
    final response = await _client.rpc(
      'regenerate_passport_share_link',
      params: {
        'settings': {
          'include_level_xp': true,
          'include_stamps': true,
          'include_badges': true,
        },
      },
    );
    return response?.toString() ?? '';
  }

  @override
  Future<void> revokePassportShareLink() async {
    await _client.rpc('revoke_passport_share_link');
  }

  @override
  Future<SharedPassport?> getSharedPassport(
    String token, {
    String locale = 'vi',
  }) async {
    final response = await _client.rpc(
      'resolve_shared_passport',
      params: {'raw_token': token, 'requested_locale': locale},
    );
    if (response == null) return null;
    final json = _map(response);
    return json.isEmpty ? null : SharedPassport.fromJson(json);
  }

  static Map<String, dynamic> _map(Object? value) => value is Map
      ? value.map((key, item) => MapEntry(key.toString(), item))
      : const {};

  static List<Map<String, dynamic>> _list(Object? value) => value is List
      ? value.whereType<Map>().map(_map).toList(growable: false)
      : const [];
}

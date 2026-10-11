import 'dart:typed_data';

import 'package:korea_quest/core/services/local_guest_gameplay.dart';
import 'package:korea_quest/core/services/location_completion_cache.dart';
import 'package:korea_quest/core/services/local_guest_store.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/repositories/korea_quest_repository.dart';
import 'package:korea_quest/shared/repositories/mock_korea_quest_repository.dart';

class LocalGuestKoreaQuestRepository implements KoreaQuestRepository {
  LocalGuestKoreaQuestRepository({
    LocalGuestStore? store,
    KoreaQuestRepository? contentRepository,
  }) : _store = store ?? LocalGuestStore(),
       _contentRepository = contentRepository ?? MockKoreaQuestRepository();

  final LocalGuestStore _store;
  final KoreaQuestRepository _contentRepository;

  LocalGuestGameplay get _gameplay => LocalGuestGameplay(_store);

  @override
  Future<AppUser> getCurrentUser() async {
    final snapshot = await _snapshot();
    return AppUser(
      id: snapshot.id,
      fullName: snapshot.displayName,
      displayName: snapshot.displayName,
      handle: 'guest',
      joinedDate: snapshot.createdAt,
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
    final snapshot = await _snapshot();
    final name = (displayName ?? fullName ?? snapshot.displayName).trim();
    final updated = snapshot.copyWith(
      displayName: name.isEmpty ? snapshot.displayName : name,
    );
    await _store.write(updated);
    return getCurrentUser();
  }

  @override
  Future<UserProgress> getUserProgress({String locale = 'vi'}) async {
    final snapshot = await _snapshot();
    const thresholds = [0, 150, 350, 650, 1000, 1500, 2200, 3000];
    var index = 0;
    while (index + 1 < thresholds.length &&
        snapshot.xp >= thresholds[index + 1]) {
      index += 1;
    }
    final isMax = index == thresholds.length - 1;
    return UserProgress(
      level: index + 1,
      currentXp: snapshot.xp,
      nextLevelXp: isMax ? snapshot.xp : thresholds[index + 1],
      streakDays: _streak(snapshot.activeDays),
      isMaxLevel: isMax,
    );
  }

  @override
  Future<void> resetUserProgress({String locale = 'vi'}) async {
    final snapshot = await _snapshot();
    await _gameplay.reset();
    await LocationCompletionCache().clear(snapshot.id);
  }

  @override
  Future<List<Location>> getLocations() => _contentRepository.getLocations();

  @override
  Future<Location?> getLocation(String id) =>
      _contentRepository.getLocation(id);

  @override
  Future<JourneyProgress> getJourney(String locationId) =>
      _contentRepository.getJourney(locationId);

  @override
  Future<List<Mission>> getMissions(String locationId) =>
      _contentRepository.getMissions(locationId);

  @override
  Future<List<Achievement>> getEarnedAchievements({
    String locale = 'vi',
  }) async => LocalGuestGameplay.achievementsFor(await _snapshot(), locale);

  @override
  Future<List<PassportStamp>> getEarnedPassportStamps({
    String locale = 'vi',
  }) async => LocalGuestGameplay.stampsFor(await _snapshot());

  @override
  Future<String> regeneratePassportShareLink() async =>
      throw StateError('Hộ chiếu của tài khoản khách không thể chia sẻ.');

  @override
  Future<void> revokePassportShareLink() async {}

  @override
  Future<SharedPassport?> getSharedPassport(
    String token, {
    String locale = 'vi',
  }) async => null;

  Future<LocalGuestSnapshot> _snapshot() async {
    final snapshot = await _store.read();
    if (snapshot == null) throw StateError('Guest session is unavailable.');
    return snapshot;
  }
}

int _streak(Set<String> activeDays) {
  var cursor = DateTime.now();
  var result = 0;
  while (activeDays.contains(_dayKey(cursor))) {
    result += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return result;
}

String _dayKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

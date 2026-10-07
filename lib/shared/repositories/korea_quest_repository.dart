import 'dart:typed_data';

import 'package:korea_quest/shared/models/domain_models.dart';

abstract interface class KoreaQuestRepository {
  Future<AppUser> getCurrentUser();
  Future<AppUser> updateUserProfile({
    String? fullName,
    String? displayName,
    String? bio,
    String? avatarPreset,
    Uint8List? avatarBytes,
  });
  Future<UserProgress> getUserProgress();
  Future<void> resetUserProgress();
  Future<List<Location>> getLocations();
  Future<Location?> getLocation(String id);
  Future<JourneyProgress> getJourney(String locationId);
  Future<List<Mission>> getMissions(String locationId);
  Future<List<Achievement>> getAchievements();
  Future<List<PassportStamp>> getPassportStamps();
}

import 'package:korea_quest/features/admin/domain/admin_models.dart';

abstract interface class AdminRepository {
  AdminSession get currentSession;

  Stream<AdminSession> watchSession();

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<bool> isCurrentUserAdmin();

  Future<List<AdminLocationSummary>> listLocations();

  Future<AdminLocationDraft> createDraft(AdminLocationDraft draft);

  Future<AdminLocationDraft> openDraft(String locationId);

  Future<int> saveOverview(AdminLocationDraft draft);

  Future<int> saveSection({
    required AdminLocationDraft draft,
    required String sectionName,
    required List<Map<String, dynamic>> items,
  });

  Future<int> saveExperienceGuide(AdminLocationDraft draft);

  Future<int> saveTravel(AdminLocationDraft draft);

  Future<List<String>> validateDraft(AdminLocationDraft draft);

  Future<void> publish(AdminLocationDraft draft);

  Future<void> archive(String locationId);

  Future<AdminGameConfig> getGameConfig();

  Future<void> saveLevel(AdminLevelDefinition level);

  Future<void> saveAchievement(AdminAchievementDefinition achievement);

  Future<void> saveChallenge(AdminChallengeDefinition challenge);
}

abstract interface class AdminRegistrationRepository {
  Future<void> register({required String username, required String password});
}

class AdminConfigurationException implements Exception {
  const AdminConfigurationException(this.message);

  final String message;

  @override
  String toString() => message;
}

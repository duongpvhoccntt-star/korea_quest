import 'dart:typed_data';

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

  Future<AdminContentTranslation> generateTranslation({
    required AdminLocationDraft draft,
    required ContentLocale locale,
    String? section,
  });

  Future<AdminContentTranslation> saveTranslation({
    required AdminLocationDraft draft,
    required ContentLocale locale,
    required Map<String, dynamic> content,
  });

  Future<AdminContentTranslation> approveTranslation({
    required AdminLocationDraft draft,
    required ContentLocale locale,
  });

  Future<AdminUploadedImage> uploadContentImage({
    required String locationId,
    required String revisionId,
    required String filename,
    required Uint8List bytes,
    required String contentType,
  });
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

class AdminUploadedImage {
  const AdminUploadedImage({
    required this.storagePath,
    required this.publicUrl,
  });

  final String storagePath;
  final String publicUrl;
}

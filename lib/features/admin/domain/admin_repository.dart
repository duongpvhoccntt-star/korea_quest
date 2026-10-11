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

  Future<List<LocationCoordinateSuggestion>> suggestLocationCoordinates(
    AdminLocationDraft draft,
  );
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

class LocationCoordinateSuggestion {
  const LocationCoordinateSuggestion({
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.address,
    required this.source,
    required this.confidence,
    required this.reason,
  });

  factory LocationCoordinateSuggestion.fromJson(Map<String, dynamic> json) {
    double? number(Object? value) => switch (value) {
      num n => n.toDouble(),
      String s => double.tryParse(s),
      _ => null,
    };
    final latitude = number(json['latitude']);
    final longitude = number(json['longitude']);
    if (latitude == null ||
        longitude == null ||
        !latitude.isFinite ||
        !longitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw const FormatException('Tọa độ gợi ý không hợp lệ.');
    }
    return LocationCoordinateSuggestion(
      latitude: latitude,
      longitude: longitude,
      label: json['label']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      source: json['source']?.toString() ?? 'maptiler',
      confidence: (number(json['confidence']) ?? 0).isFinite
          ? (number(json['confidence']) ?? 0).clamp(0, 1).toDouble()
          : 0,
      reason: json['reason']?.toString() ?? '',
    );
  }

  final double latitude;
  final double longitude;
  final String label;
  final String address;
  final String source;
  final double confidence;
  final String reason;
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

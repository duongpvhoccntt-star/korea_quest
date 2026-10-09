import 'dart:math';
import 'dart:typed_data';

import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/domain/admin_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAdminRepository implements AdminRepository {
  const SupabaseAdminRepository(this._client);

  final SupabaseClient _client;

  @override
  AdminSession get currentSession => _toSession(_client.auth.currentUser);

  @override
  Stream<AdminSession> watchSession() async* {
    yield currentSession;
    yield* _client.auth.onAuthStateChange.map(
      (event) => _toSession(event.session?.user),
    );
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<bool> isCurrentUserAdmin() async {
    final result = await _client.rpc('is_admin');
    return result == true;
  }

  @override
  Future<List<AdminLocationSummary>> listLocations() async {
    final result = await _client.rpc('admin_list_locations');
    return _jsonList(result).map(AdminLocationSummary.fromJson).toList();
  }

  @override
  Future<AdminLocationDraft> createDraft(AdminLocationDraft draft) async {
    final result = await _client.rpc(
      'create_location_draft',
      params: {'slug': draft.slug, 'payload': draft.overview},
    );
    final locationId = _jsonMap(result)['location_id'];
    if (locationId is! String) {
      throw const FormatException('RPC không trả về location_id hợp lệ.');
    }
    return _loadDraft(locationId);
  }

  @override
  Future<AdminLocationDraft> openDraft(String locationId) async {
    await _client.rpc(
      'create_location_draft_from_current',
      params: {'location_id': locationId},
    );
    return _loadDraft(locationId);
  }

  Future<AdminLocationDraft> _loadDraft(String locationId) async {
    final result = await _client.rpc(
      'get_admin_location',
      params: {'location_id': locationId},
    );
    final draft = AdminLocationDraft.fromJson(_jsonMap(result));
    final translations = await _client.rpc(
      'admin_list_location_translations',
      params: {'target_revision_id': draft.revisionId},
    );
    for (final json in _jsonList(translations)) {
      final translation = AdminContentTranslation.fromJson(json);
      draft.translations[translation.locale] = translation;
    }
    return draft;
  }

  @override
  Future<int> saveOverview(AdminLocationDraft draft) async {
    final result = await _client.rpc(
      'save_location_overview',
      params: {
        'revision_id': draft.revisionId,
        'expected_lock_version': draft.lockVersion,
        'slug': draft.slug,
        'payload': draft.overview,
      },
    );
    return _lockVersion(result);
  }

  @override
  Future<int> saveSection({
    required AdminLocationDraft draft,
    required String sectionName,
    required List<Map<String, dynamic>> items,
  }) async {
    final result = await _client.rpc(
      'save_location_section_with_galleries',
      params: {
        'revision_id': draft.revisionId,
        'expected_lock_version': draft.lockVersion,
        'section_name': sectionName,
        'items': items,
      },
    );
    return _lockVersion(result);
  }

  @override
  Future<int> saveTravel(AdminLocationDraft draft) async {
    final result = await _client.rpc(
      'save_location_travel',
      params: {
        'revision_id': draft.revisionId,
        'expected_lock_version': draft.lockVersion,
        'payload': draft.travel,
      },
    );
    return _lockVersion(result);
  }

  @override
  Future<int> saveExperienceGuide(AdminLocationDraft draft) async {
    final result = await _client.rpc(
      'save_location_experience_guide',
      params: {
        'revision_id': draft.revisionId,
        'expected_lock_version': draft.lockVersion,
        'payload': draft.experienceGuide,
      },
    );
    return _lockVersion(result);
  }

  @override
  Future<List<String>> validateDraft(AdminLocationDraft draft) async {
    final result = await _client.rpc(
      'validate_location_revision_with_galleries',
      params: {'revision_id': draft.revisionId},
    );
    return (result as List<dynamic>).map((item) => item.toString()).toList();
  }

  @override
  Future<void> publish(AdminLocationDraft draft) async {
    await _client.rpc(
      'publish_location_revision',
      params: {
        'revision_id': draft.revisionId,
        'expected_lock_version': draft.lockVersion,
      },
    );
  }

  @override
  Future<AdminContentTranslation> generateTranslation({
    required AdminLocationDraft draft,
    required ContentLocale locale,
    String? section,
  }) async {
    if (locale == ContentLocale.vi) {
      throw const FormatException(
        'Tiếng Việt là nội dung nguồn, không cần dịch.',
      );
    }
    final source = draft.toTranslationSource();
    final requestedContent = section == null
        ? source
        : <String, dynamic>{
            if (section == 'summary') 'summary': source['summary'],
            'detail': {section: (_jsonMap(source['detail']))[section]},
          };
    final response = await _client.functions.invoke(
      'translate-location',
      body: {'target_locale': locale.name, 'content': requestedContent},
    );
    if (response.status < 200 || response.status >= 300) {
      throw FormatException('Không thể tạo bản dịch: ${response.data}');
    }
    final translated = _jsonMap(_jsonMap(response.data)['content']);
    final current = draft.translations[locale]?.content ?? const {};
    final merged = _deepMerge(current, translated);
    return saveTranslation(draft: draft, locale: locale, content: merged);
  }

  @override
  Future<AdminContentTranslation> saveTranslation({
    required AdminLocationDraft draft,
    required ContentLocale locale,
    required Map<String, dynamic> content,
  }) async {
    final result = await _client.rpc(
      'admin_save_location_translation',
      params: {
        'target_revision_id': draft.revisionId,
        'target_locale': locale.name,
        'translated_content': content,
      },
    );
    return AdminContentTranslation.fromJson(_jsonMap(result));
  }

  @override
  Future<AdminContentTranslation> approveTranslation({
    required AdminLocationDraft draft,
    required ContentLocale locale,
  }) async {
    final result = await _client.rpc(
      'admin_approve_location_translation',
      params: {
        'target_revision_id': draft.revisionId,
        'target_locale': locale.name,
      },
    );
    return AdminContentTranslation.fromJson(_jsonMap(result));
  }

  @override
  Future<AdminUploadedImage> uploadContentImage({
    required String locationId,
    required String revisionId,
    required String filename,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final extension = switch (contentType) {
      'image/jpeg' => 'jpg',
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => throw const FormatException('Định dạng ảnh không được hỗ trợ.'),
    };
    final random = Random.secure().nextInt(1 << 32).toRadixString(16);
    final objectName =
        '${DateTime.now().microsecondsSinceEpoch}-$random.$extension';
    final storagePath =
        'locations/$locationId/revisions/$revisionId/$objectName';
    final storage = _client.storage.from('content-media');
    await storage.uploadBinary(
      storagePath,
      bytes,
      fileOptions: FileOptions(contentType: contentType, upsert: false),
    );
    return AdminUploadedImage(
      storagePath: storagePath,
      publicUrl: storage.getPublicUrl(storagePath),
    );
  }

  @override
  Future<void> archive(String locationId) async {
    await _client.rpc('archive_location', params: {'location_id': locationId});
  }

  @override
  Future<AdminGameConfig> getGameConfig() async {
    final result = await _client.rpc('admin_get_game_config');
    return AdminGameConfig.fromJson(_jsonMap(result));
  }

  @override
  Future<void> saveLevel(AdminLevelDefinition level) async {
    await _client.rpc('admin_save_level', params: {'payload': level.toJson()});
  }

  @override
  Future<void> saveAchievement(AdminAchievementDefinition achievement) async {
    await _client.rpc(
      'admin_save_achievement',
      params: {'payload': achievement.toJson()},
    );
  }

  @override
  Future<void> saveChallenge(AdminChallengeDefinition challenge) async {
    await _client.rpc(
      'admin_save_challenge',
      params: {'payload': challenge.toJson()},
    );
  }

  static AdminSession _toSession(User? user) {
    return AdminSession(userId: user?.id, email: user?.email);
  }

  static Map<String, dynamic> _jsonMap(Object? value) {
    if (value is! Map) {
      throw const FormatException('Supabase RPC không trả về object hợp lệ.');
    }
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  static List<Map<String, dynamic>> _jsonList(Object? value) {
    if (value is! List) {
      throw const FormatException(
        'Supabase RPC không trả về danh sách hợp lệ.',
      );
    }
    return value.map(_jsonMap).toList();
  }

  static int _lockVersion(Object? value) {
    final lockVersion = _jsonMap(value)['lock_version'];
    if (lockVersion is! int) {
      throw const FormatException('RPC không trả về lock_version hợp lệ.');
    }
    return lockVersion;
  }

  static Map<String, dynamic> _deepMerge(
    Map<String, dynamic> base,
    Map<String, dynamic> overlay,
  ) {
    final result = Map<String, dynamic>.from(base);
    for (final entry in overlay.entries) {
      final current = result[entry.key];
      if (current is Map && entry.value is Map) {
        result[entry.key] = _deepMerge(
          current.map((key, value) => MapEntry(key.toString(), value)),
          (entry.value as Map).map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        );
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }
}

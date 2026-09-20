import 'dart:async';
import 'dart:convert';

import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/domain/admin_repository.dart';

class DemoAdminRepository
    implements AdminRepository, AdminRegistrationRepository {
  DemoAdminRepository();

  final _sessionController = StreamController<AdminSession>.broadcast();
  final _credentials = <String, String>{'admin': 'admin123'};
  final _drafts = <String, AdminLocationDraft>{};
  final _updatedAt = <String, DateTime>{};
  final _levels = <AdminLevelDefinition>[];
  final _achievements = <AdminAchievementDefinition>[];
  final _challenges = <AdminChallengeDefinition>[];
  AdminSession _session = const AdminSession();
  var _nextId = 1;

  void dispose() => _sessionController.close();

  @override
  AdminSession get currentSession => _session;

  @override
  Stream<AdminSession> watchSession() async* {
    yield _session;
    yield* _sessionController.stream;
  }

  @override
  Future<void> register({
    required String username,
    required String password,
  }) async {
    final normalized = _validateCredentials(username, password);
    if (_credentials.containsKey(normalized)) {
      throw const FormatException('Tên đăng nhập đã tồn tại trong phiên demo.');
    }
    _credentials[normalized] = password;
    _setSession(normalized);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    final username = email.trim().toLowerCase();
    if (_credentials[username] != password) {
      throw const FormatException('Tên đăng nhập hoặc mật khẩu không đúng.');
    }
    _setSession(username);
  }

  @override
  Future<void> signOut() async {
    _session = const AdminSession();
    _sessionController.add(_session);
  }

  @override
  Future<bool> isCurrentUserAdmin() async => _session.isSignedIn;

  @override
  Future<List<AdminLocationSummary>> listLocations() async {
    final items = _drafts.values.map((draft) {
      final locationId = draft.locationId!;
      return AdminLocationSummary(
        locationId: locationId,
        slug: draft.slug,
        revisionId: draft.revisionId!,
        status: draft.status,
        versionNumber: draft.versionNumber,
        lockVersion: draft.lockVersion,
        name: draft.overview['name']?.toString() ?? '',
        koreanName: draft.overview['korean_name']?.toString() ?? '',
        updatedAt: _updatedAt[locationId] ?? DateTime.now(),
      );
    }).toList();
    items.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return items;
  }

  @override
  Future<AdminLocationDraft> createDraft(AdminLocationDraft draft) async {
    final id = 'demo-location-${_nextId++}';
    draft.locationId = id;
    draft.revisionId = 'demo-revision-${_nextId++}';
    draft.status = AdminRevisionStatus.draft;
    _drafts[id] = draft;
    _touch(draft);
    return draft;
  }

  @override
  Future<AdminLocationDraft> openDraft(String locationId) async {
    final current = _drafts[locationId];
    if (current == null) {
      throw const FormatException('Không tìm thấy Địa điểm demo.');
    }
    if (current.status == AdminRevisionStatus.draft) return current;
    final draft = _clone(current);
    draft.revisionId = 'demo-revision-${_nextId++}';
    draft.versionNumber++;
    draft.lockVersion = 1;
    draft.status = AdminRevisionStatus.draft;
    _drafts[locationId] = draft;
    _touch(draft);
    return draft;
  }

  @override
  Future<int> saveOverview(AdminLocationDraft draft) => _save(draft);

  @override
  Future<int> saveSection({
    required AdminLocationDraft draft,
    required String sectionName,
    required List<Map<String, dynamic>> items,
  }) => _save(draft);

  @override
  Future<int> saveTravel(AdminLocationDraft draft) => _save(draft);

  @override
  Future<int> saveExperienceGuide(AdminLocationDraft draft) => _save(draft);

  Future<int> _save(AdminLocationDraft draft) async {
    if (!draft.isPersisted) {
      throw const FormatException('Hãy tạo Bản nháp trước.');
    }
    draft.lockVersion++;
    _drafts[draft.locationId!] = draft;
    _touch(draft);
    return draft.lockVersion;
  }

  @override
  Future<List<String>> validateDraft(AdminLocationDraft draft) async {
    final errors = <String>[];
    if (draft.slug.trim().isEmpty ||
        (draft.overview['name']?.toString().trim().isEmpty ?? true)) {
      errors.add('Demo: cần slug và tên Địa điểm.');
    }
    int visibleCount(List<Map<String, dynamic>> items) =>
        items.where((item) => item['is_visible'] != false).length;
    if (visibleCount(draft.history) < 4) {
      errors.add('Demo: cần ít nhất 4 mốc lịch sử.');
    }
    if (visibleCount(draft.highlights) < 4) {
      errors.add('Demo: cần ít nhất 4 điểm nổi bật.');
    }
    if (visibleCount(draft.experiences) < 3) {
      errors.add('Demo: cần ít nhất 3 trải nghiệm.');
    }
    if (visibleCount(draft.foods) < 3) {
      errors.add('Demo: cần ít nhất 3 món ăn.');
    }
    if (visibleCount(draft.funFacts) < 4) {
      errors.add('Demo: cần ít nhất 4 fun facts.');
    }
    final quizCount = visibleCount(draft.quiz);
    if (draft.quiz.length > 20 || quizCount < 10) {
      errors.add('Demo: Quiz tổng kết cần từ 10 đến 20 câu hỏi hiển thị.');
    }
    return errors;
  }

  @override
  Future<void> publish(AdminLocationDraft draft) async {
    final errors = await validateDraft(draft);
    if (errors.isNotEmpty) throw FormatException(errors.join(' | '));
    draft.status = AdminRevisionStatus.published;
    _touch(draft);
  }

  @override
  Future<void> archive(String locationId) async {
    final draft = _drafts[locationId];
    if (draft == null) {
      throw const FormatException('Không tìm thấy Địa điểm demo.');
    }
    draft.status = AdminRevisionStatus.archived;
    _touch(draft);
  }

  @override
  Future<AdminGameConfig> getGameConfig() async => AdminGameConfig(
    levels: List.unmodifiable(_levels),
    achievements: List.unmodifiable(_achievements),
    challenges: List.unmodifiable(_challenges),
  );

  @override
  Future<void> saveLevel(AdminLevelDefinition level) async {
    _replace(
      _levels,
      level,
      (item) =>
          (level.id != null && item.id == level.id) ||
          item.levelNumber == level.levelNumber,
    );
  }

  @override
  Future<void> saveAchievement(AdminAchievementDefinition achievement) async {
    _replace(
      _achievements,
      achievement,
      (item) =>
          (achievement.id != null && item.id == achievement.id) ||
          item.slug == achievement.slug,
    );
  }

  @override
  Future<void> saveChallenge(AdminChallengeDefinition challenge) async {
    _replace(
      _challenges,
      challenge,
      (item) =>
          (challenge.id != null && item.id == challenge.id) ||
          item.slug == challenge.slug,
    );
  }

  void _replace<T>(List<T> items, T value, bool Function(T) matches) {
    final index = items.indexWhere(matches);
    if (index < 0) {
      items.add(value);
    } else {
      items[index] = value;
    }
  }

  String _validateCredentials(String username, String password) {
    final normalized = username.trim().toLowerCase();
    if (!RegExp(r'^[a-z0-9_.-]{3,30}$').hasMatch(normalized)) {
      throw const FormatException(
        'Tên đăng nhập cần 3–30 ký tự: chữ, số, _, . hoặc -.',
      );
    }
    if (password.length < 4) {
      throw const FormatException('Mật khẩu demo cần ít nhất 4 ký tự.');
    }
    return normalized;
  }

  void _setSession(String username) {
    _session = AdminSession(userId: 'demo-$username', email: username);
    _sessionController.add(_session);
  }

  void _touch(AdminLocationDraft draft) {
    _updatedAt[draft.locationId!] = DateTime.now();
  }

  AdminLocationDraft _clone(AdminLocationDraft source) {
    Map<String, dynamic> map(Map<String, dynamic> value) =>
        jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
    List<Map<String, dynamic>> list(List<Map<String, dynamic>> value) =>
        (jsonDecode(jsonEncode(value)) as List<dynamic>)
            .cast<Map<String, dynamic>>();

    return AdminLocationDraft(
      locationId: source.locationId,
      revisionId: source.revisionId,
      slug: source.slug,
      status: source.status,
      versionNumber: source.versionNumber,
      lockVersion: source.lockVersion,
      overview: map(source.overview),
      history: list(source.history),
      highlights: list(source.highlights),
      experiences: list(source.experiences),
      experienceGuide: map(source.experienceGuide),
      foods: list(source.foods),
      funFacts: list(source.funFacts),
      quiz: list(source.quiz),
      travel: map(source.travel),
      sources: list(source.sources),
    );
  }
}

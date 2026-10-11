import 'dart:convert';

import 'package:korea_quest/core/services/location_completion_cache.dart';
import 'package:korea_quest/features/auth/domain/auth_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalGuestSnapshot {
  const LocalGuestSnapshot({
    required this.id,
    required this.displayName,
    required this.createdAt,
    required this.xp,
    required this.completedStages,
    required this.completedQuestions,
    required this.correctQuestions,
    required this.completedLocations,
    required this.earnedBadges,
    required this.activeDays,
  });

  factory LocalGuestSnapshot.initial(String displayName) {
    final now = DateTime.now();
    return LocalGuestSnapshot(
      id: 'local-guest-${now.microsecondsSinceEpoch}',
      displayName: displayName,
      createdAt: now,
      xp: 0,
      completedStages: const {},
      completedQuestions: const {},
      correctQuestions: const {},
      completedLocations: const {},
      earnedBadges: const {},
      activeDays: {_dayKey(now)},
    );
  }

  factory LocalGuestSnapshot.fromJson(Map<String, dynamic> json) =>
      LocalGuestSnapshot(
        id: json['id']?.toString() ?? '',
        displayName: json['display_name']?.toString() ?? '',
        createdAt:
            DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.now(),
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        completedStages: _stringSet(json['completed_stages']),
        completedQuestions: _stringSet(json['completed_questions']),
        correctQuestions: _stringSet(json['correct_questions']),
        completedLocations: _stringSet(json['completed_locations']),
        earnedBadges: _stringSet(json['earned_badges']),
        activeDays: _stringSet(json['active_days']),
      );

  final String id;
  final String displayName;
  final DateTime createdAt;
  final int xp;
  final Set<String> completedStages;
  final Set<String> completedQuestions;
  final Set<String> correctQuestions;
  final Set<String> completedLocations;
  final Set<String> earnedBadges;
  final Set<String> activeDays;

  AuthUser get authUser => AuthUser(
    id: id,
    usernameOrEmail: 'guest@koreaquest.local',
    displayName: displayName,
    role: UserRole.user,
    isGuest: true,
  );

  LocalGuestSnapshot copyWith({
    String? displayName,
    int? xp,
    Set<String>? completedStages,
    Set<String>? completedQuestions,
    Set<String>? correctQuestions,
    Set<String>? completedLocations,
    Set<String>? earnedBadges,
    Set<String>? activeDays,
  }) => LocalGuestSnapshot(
    id: id,
    displayName: displayName ?? this.displayName,
    createdAt: createdAt,
    xp: xp ?? this.xp,
    completedStages: completedStages ?? this.completedStages,
    completedQuestions: completedQuestions ?? this.completedQuestions,
    correctQuestions: correctQuestions ?? this.correctQuestions,
    completedLocations: completedLocations ?? this.completedLocations,
    earnedBadges: earnedBadges ?? this.earnedBadges,
    activeDays: activeDays ?? this.activeDays,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
    'created_at': createdAt.toUtc().toIso8601String(),
    'xp': xp,
    'completed_stages': completedStages.toList()..sort(),
    'completed_questions': completedQuestions.toList()..sort(),
    'correct_questions': correctQuestions.toList()..sort(),
    'completed_locations': completedLocations.toList()..sort(),
    'earned_badges': earnedBadges.toList()..sort(),
    'active_days': activeDays.toList()..sort(),
  };
}

class LocalGuestStore {
  static const _key = 'koreaquest.local_guest.v1';

  Future<LocalGuestSnapshot?> read() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final snapshot = LocalGuestSnapshot.fromJson(
        decoded.map((key, value) => MapEntry('$key', value)),
      );
      return snapshot.id.isEmpty || snapshot.displayName.trim().isEmpty
          ? null
          : snapshot;
    } catch (_) {
      return null;
    }
  }

  Future<LocalGuestSnapshot> createOrUpdate(String name) async {
    final trimmed = name.trim();
    final existing = await read();
    final snapshot = existing == null
        ? LocalGuestSnapshot.initial(trimmed)
        : existing.copyWith(
            displayName: trimmed,
            activeDays: {...existing.activeDays, _dayKey(DateTime.now())},
          );
    await write(snapshot);
    return snapshot;
  }

  Future<void> write(LocalGuestSnapshot snapshot) async {
    try {
      await (await SharedPreferences.getInstance()).setString(
        _key,
        jsonEncode(snapshot.toJson()),
      );
    } catch (_) {
      // Device storage must not block a guest from exploring.
    }
  }

  Future<void> clear() async {
    final userId = (await read())?.id;
    try {
      await (await SharedPreferences.getInstance()).remove(_key);
    } catch (_) {}
    if (userId != null) await LocationCompletionCache().clear(userId);
  }
}

Set<String> _stringSet(Object? value) => value is List
    ? value
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toSet()
    : <String>{};

String _dayKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

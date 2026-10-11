import 'package:shared_preferences/shared_preferences.dart';

/// A small device cache used for instant completion markers and the offline
/// demo. The backend passport remains the source of truth whenever available.
class LocationCompletionCache {
  static const _keyPrefix = 'completed_location_slugs.';

  Future<Set<String>> read(String userId) async {
    if (userId.trim().isEmpty) return const <String>{};
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences
              .getStringList('$_keyPrefix$userId')
              ?.where((slug) => slug.trim().isNotEmpty)
              .toSet() ??
          const <String>{};
    } catch (_) {
      return const <String>{};
    }
  }

  Future<bool> contains(String userId, String slug) async =>
      (await read(userId)).contains(slug);

  Future<void> markCompleted(String userId, String slug) async {
    if (userId.trim().isEmpty || slug.trim().isEmpty) return;
    try {
      final completed = await read(userId);
      completed.add(slug);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(
        '$_keyPrefix$userId',
        completed.toList(growable: false)..sort(),
      );
    } catch (_) {
      // Local persistence is an immediate/offline aid, never a blocker for
      // server-side progression or for the completion celebration.
    }
  }

  Future<void> clear(String userId) async {
    if (userId.trim().isEmpty) return;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove('$_keyPrefix$userId');
    } catch (_) {
      // See markCompleted: storage availability must not affect gameplay.
    }
  }
}

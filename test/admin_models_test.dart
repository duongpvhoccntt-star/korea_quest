import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';

void main() {
  group('AdminLocationDraft', () {
    test('parses versioned location payload and nested lists', () {
      final draft = AdminLocationDraft.fromJson({
        'location_id': 'location-id',
        'revision_id': 'revision-id',
        'slug': 'gyeongbokgung',
        'status': 'draft',
        'version_number': 2,
        'lock_version': 7,
        'overview': {
          'name': 'Gyeongbokgung',
          'quick_facts': [
            {'label': 'Thành lập', 'value': '1395'},
          ],
        },
        'history': <Object?>[],
        'highlights': <Object?>[],
        'experiences': <Object?>[],
        'experience_guide': {
          'featured_fact': 'Nghi thức dùng hai tay',
          'dos': ['Dùng hai tay'],
          'donts': ['Không cắm đũa thẳng đứng'],
        },
        'foods': <Object?>[],
        'fun_facts': <Object?>[],
        'quiz': <Object?>[],
        'travel': {'opening_hours': '09:00–18:00'},
        'sources': <Object?>[],
      });

      expect(draft.isPersisted, isTrue);
      expect(draft.versionNumber, 2);
      expect(draft.lockVersion, 7);
      expect(draft.overview['name'], 'Gyeongbokgung');
      expect(draft.experienceGuide['dos'], ['Dùng hai tay']);

      final facts = AdminLocationDraft.fromJsonList(
        draft.overview['quick_facts'],
      );
      expect(facts.single['value'], '1395');
    });

    test('creates an empty, unsaved draft', () {
      final draft = AdminLocationDraft();

      expect(draft.isPersisted, isFalse);
      expect(draft.status, AdminRevisionStatus.draft);
      expect(draft.overview['quick_facts'], isA<List<Map<String, dynamic>>>());
      expect(draft.overview['release_status'], 'coming_soon');
      expect(draft.experienceGuide['dos'], isA<List<String>>());
      expect(
        draft.travel['transport_options'],
        isA<List<Map<String, dynamic>>>(),
      );
    });
  });

  test('countWords ignores repeated whitespace', () {
    expect(countWords('  một   hai\nba  '), 3);
    expect(countWords(''), 0);
  });

  test('parses game configuration returned by Supabase RPC', () {
    final config = AdminGameConfig.fromJson({
      'levels': [
        {
          'id': 'level-id',
          'level_number': 2,
          'min_xp': 500,
          'title': 'Người khám phá',
        },
      ],
      'achievements': [
        {
          'id': 'achievement-id',
          'slug': 'first-place',
          'title': 'Điểm đến đầu tiên',
          'metric': 'completed_locations',
          'target': 1,
          'criteria_filter': <String, dynamic>{},
        },
      ],
      'challenges': [
        {
          'id': 'challenge-id',
          'slug': 'weekly-explorer',
          'title': 'Khám phá tuần',
          'starts_at': '2026-09-20T00:00:00Z',
          'ends_at': '2026-09-27T00:00:00Z',
          'reward_xp': 100,
          'goals': [
            {
              'metric': 'content_views',
              'target': 5,
              'criteria_filter': {'kind': 'food'},
            },
          ],
        },
      ],
    });

    expect(config.levels.single.minXp, 500);
    expect(
      config.achievements.single.metric,
      AdminAchievementMetric.completedLocations,
    );
    expect(config.challenges.single.goals.single.target, 5);
    expect(config.challenges.single.toJson()['reward_xp'], 100);
  });
}

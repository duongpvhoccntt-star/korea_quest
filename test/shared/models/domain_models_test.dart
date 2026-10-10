import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/shared/models/domain_models.dart';

void main() {
  test('gameplay progress enums do not contain access lock states', () {
    expect(LocationStatus.values, <LocationStatus>[
      LocationStatus.completed,
      LocationStatus.inProgress,
      LocationStatus.available,
    ]);
    expect(MissionStatus.values, <MissionStatus>[
      MissionStatus.notStarted,
      MissionStatus.inProgress,
      MissionStatus.completed,
    ]);
    expect(
      LocationReleaseStatus.fromWire('released'),
      LocationReleaseStatus.released,
    );
    expect(
      LocationReleaseStatus.fromWire('coming_soon'),
      LocationReleaseStatus.comingSoon,
    );
  });

  test('AppUser supports bio, avatarPreset, avatarBytes and copyWith', () {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final user = AppUser(
      id: 'u1',
      fullName: 'Phạm Văn Dương',
      displayName: 'Dương',
      handle: 'duong.kq',
      joinedDate: DateTime(2026, 8, 2),
      bio: 'Người khám phá Seoul',
      avatarPreset: 'hanbok',
      avatarBytes: bytes,
    );

    expect(user.bio, 'Người khám phá Seoul');
    expect(user.avatarPreset, 'hanbok');
    expect(user.avatarBytes, bytes);

    final updated = user.copyWith(
      displayName: 'Dương Phạm',
      bio: 'Yêu văn hóa Hàn',
      avatarPreset: 'seoul',
    );
    expect(updated.displayName, 'Dương Phạm');
    expect(updated.bio, 'Yêu văn hóa Hàn');
    expect(updated.avatarPreset, 'seoul');
    expect(updated.fullName, 'Phạm Văn Dương');
  });

  test('parses server-authoritative progression and max level', () {
    final progress = UserProgress.fromJson({
      'level': 8,
      'title': 'Bậc thầy khám phá',
      'current_xp': 3200,
      'next_level_xp': 3200,
      'streak_days': 7,
      'is_max_level': true,
    });

    expect(progress.level, 8);
    expect(progress.title, 'Bậc thầy khám phá');
    expect(progress.xpPercentage, 1);
    expect(progress.xpRemaining, 0);
  });

  test('secret achievement can omit progress until earned', () {
    final achievement = Achievement.fromJson({
      'id': 'secret',
      'title': 'Thành tích bí mật',
      'description': 'Tiếp tục khám phá.',
      'is_secret': true,
      'is_earned': false,
      'current_value': null,
      'target_value': null,
    });

    expect(achievement.isSecret, isTrue);
    expect(achievement.isEarned, isFalse);
    expect(achievement.currentValue, isNull);
  });

  test('shared passport maps only public aggregate fields', () {
    final passport = SharedPassport.fromJson({
      'profile': {'display_name': 'Dương'},
      'progress': {
        'level': 2,
        'current_xp': 150,
        'next_level_xp': 350,
        'streak_days': 1,
      },
      'stamps': [
        {
          'location_id': 'location',
          'stamp_name': 'Seoul',
          'earned_at': '2026-10-10T00:00:00Z',
        },
      ],
      'achievements': [
        {
          'id': 'first-step',
          'title': 'Bước chân đầu tiên',
          'description': 'Hoàn thành địa điểm đầu tiên.',
          'is_earned': true,
        },
      ],
    });

    expect(passport.displayName, 'Dương');
    expect(passport.progress?.level, 2);
    expect(passport.stamps.single.name, 'Seoul');
    expect(passport.achievements.single.isEarned, isTrue);
  });
}

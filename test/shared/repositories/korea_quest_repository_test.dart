import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/repositories/mock_korea_quest_repository.dart';

void main() {
  late MockKoreaQuestRepository repo;

  setUp(() {
    repo = MockKoreaQuestRepository();
  });

  test('updateUserProfile updates currentUser', () async {
    final initial = await repo.getCurrentUser();
    expect(initial.displayName, 'Dương');

    final updated = await repo.updateUserProfile(
      displayName: 'Dương Pro',
      bio: 'Khám phá Seoul cổ kính',
      avatarPreset: 'seoul',
    );
    expect(updated.displayName, 'Dương Pro');
    expect(updated.bio, 'Khám phá Seoul cổ kính');
    expect(updated.avatarPreset, 'seoul');

    final fetched = await repo.getCurrentUser();
    expect(fetched.displayName, 'Dương Pro');
    expect(fetched.bio, 'Khám phá Seoul cổ kính');
    expect(fetched.avatarPreset, 'seoul');
  });

  test('switching avatar source clears the previous avatar source', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final withImage = await repo.updateUserProfile(avatarBytes: bytes);
    expect(withImage.avatarBytes, bytes);
    expect(withImage.avatarPreset, isNull);

    final withPreset = await repo.updateUserProfile(avatarPreset: 'hanbok');
    expect(withPreset.avatarPreset, 'hanbok');
    expect(withPreset.avatarBytes, isNull);
  });

  test('resetUserProgress resets progress without locking locations', () async {
    final releaseStatuses = [
      for (final location in await repo.getLocations()) location.releaseStatus,
    ];
    await repo.resetUserProgress();
    final progress = await repo.getUserProgress();
    expect(progress.level, 1);
    expect(progress.currentXp, 0);

    final locations = await repo.getLocations();
    expect(
      locations.every((item) => item.status == LocationStatus.available),
      isTrue,
    );
    expect(
      locations.map((item) => item.releaseStatus),
      orderedEquals(releaseStatuses),
    );

    final achievements = await repo.getEarnedAchievements();
    expect(achievements, isEmpty);
    final stamps = await repo.getEarnedPassportStamps();
    expect(stamps, isEmpty);
  });
}

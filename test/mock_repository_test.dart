import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/repositories/mock_korea_quest_repository.dart';

void main() {
  test(
    'mock repository returns consistent KoreaQuest foundation data',
    () async {
      final repository = MockKoreaQuestRepository();

      final user = await repository.getCurrentUser();
      final progress = await repository.getUserProgress();
      final locations = await repository.getLocations();
      final achievements = await repository.getAchievements();

      expect(user.fullName, 'Phạm Văn Dương');
      expect(progress.currentXp, 1250);
      expect(locations, hasLength(4));
      expect(locations.first.status, LocationStatus.completed);
      expect(locations.last.status, LocationStatus.locked);
      expect(
        achievements.map((item) => item.title),
        contains('Hành trình 7 ngày'),
      );
      expect(
        await repository.getLocation('gyeongbokgung'),
        same(locations.first),
      );
    },
  );
}

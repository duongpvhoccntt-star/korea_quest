import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/shared/models/domain_models.dart';

void main() {
  group('UserProgress', () {
    test('calculates XP percentage and remaining XP', () {
      const progress = UserProgress(
        level: 5,
        currentXp: 1250,
        nextLevelXp: 1500,
        streakDays: 7,
      );

      expect(progress.xpPercentage, closeTo(0.8333, 0.0001));
      expect(progress.xpRemaining, 250);
      expect(progress.reachedNextLevel, isFalse);
    });

    test('clamps completed level progress', () {
      const progress = UserProgress(
        level: 5,
        currentXp: 1700,
        nextLevelXp: 1500,
        streakDays: 7,
      );

      expect(progress.xpPercentage, 1);
      expect(progress.xpRemaining, 0);
      expect(progress.reachedNextLevel, isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/core/services/local_guest_gameplay.dart';
import 'package:korea_quest/core/services/local_guest_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('guest snapshot persists name and stable identity', () async {
    final store = LocalGuestStore();
    final first = await store.createOrUpdate('Min');
    final second = await store.createOrUpdate('Minh');
    final restored = await store.read();

    expect(second.id, first.id);
    expect(restored?.id, first.id);
    expect(restored?.displayName, 'Minh');
    expect(restored?.authUser.isGuest, isTrue);
  });

  test('local gameplay awards each stage and question only once', () async {
    final store = LocalGuestStore();
    await store.createOrUpdate('Min');
    final gameplay = LocalGuestGameplay(store);

    expect(
      (await gameplay.recordQuiz(
        questionId: 'q1',
        isCorrect: true,
        locale: 'vi',
      )).awardedXp,
      10,
    );
    expect(
      (await gameplay.recordQuiz(
        questionId: 'q1',
        isCorrect: true,
        locale: 'vi',
      )).alreadyAwarded,
      isTrue,
    );
    expect(
      (await gameplay.completeStage(
        slug: 'gyeongbokgung',
        stageNumber: 1,
        locale: 'vi',
      )).awardedXp,
      20,
    );
    expect(
      (await gameplay.completeStage(
        slug: 'gyeongbokgung',
        stageNumber: 9,
        locale: 'vi',
      )).awardedXp,
      70,
    );
    expect(
      (await gameplay.completeStage(
        slug: 'gyeongbokgung',
        stageNumber: 9,
        locale: 'vi',
      )).alreadyAwarded,
      isTrue,
    );

    final snapshot = await store.read();
    expect(snapshot?.xp, 100);
    expect(snapshot?.completedLocations, contains('gyeongbokgung'));
    expect(snapshot?.earnedBadges, contains('first-step'));
  });

  test('clearing the local guest removes the persisted session', () async {
    final store = LocalGuestStore();
    await store.createOrUpdate('Min');
    await store.clear();
    expect(await store.read(), isNull);
  });
}

import 'package:korea_quest/core/services/local_guest_store.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';
import 'package:korea_quest/shared/models/domain_models.dart';

class LocalGuestGameplay {
  LocalGuestGameplay(this._store);

  final LocalGuestStore _store;

  Future<GameplayReward> recordQuiz({
    required String questionId,
    required bool isCorrect,
    required String locale,
  }) async {
    final snapshot = await _requiredSnapshot();
    var xp = snapshot.xp;
    final questions = {...snapshot.completedQuestions};
    final correct = {...snapshot.correctQuestions};
    var awarded = 0;
    if (questions.add(questionId)) {
      xp += 2;
      awarded += 2;
    }
    if (isCorrect && correct.add(questionId)) {
      xp += 8;
      awarded += 8;
    }
    final updated = _withActivity(
      snapshot.copyWith(
        xp: xp,
        completedQuestions: questions,
        correctQuestions: correct,
      ),
    );
    final badges = _newBadges(updated);
    await _store.write(updated.copyWith(earnedBadges: badges.all));
    return GameplayReward(
      awardedXp: awarded,
      alreadyAwarded: awarded == 0,
      stampAwarded: false,
      newAchievementTitles: badges.newTitles(locale),
    );
  }

  Future<GameplayReward> completeStage({
    required String slug,
    required int stageNumber,
    required String locale,
  }) async {
    final snapshot = await _requiredSnapshot();
    final key = '$slug:$stageNumber';
    final stages = {...snapshot.completedStages};
    final locations = {...snapshot.completedLocations};
    var xp = snapshot.xp;
    var awarded = 0;
    var stampAwarded = false;
    if (stages.add(key)) {
      xp += 20;
      awarded += 20;
      if (stageNumber == 9 && locations.add(slug)) {
        xp += 50;
        awarded += 50;
        stampAwarded = true;
      }
    }
    final updated = _withActivity(
      snapshot.copyWith(
        xp: xp,
        completedStages: stages,
        completedLocations: locations,
      ),
    );
    final badges = _newBadges(updated);
    await _store.write(updated.copyWith(earnedBadges: badges.all));
    return GameplayReward(
      awardedXp: awarded,
      alreadyAwarded: awarded == 0,
      stampAwarded: stampAwarded,
      newAchievementTitles: badges.newTitles(locale),
    );
  }

  Future<LocalGuestSnapshot> snapshot() => _requiredSnapshot();

  Future<void> reset() async {
    final snapshot = await _requiredSnapshot();
    await _store.write(
      snapshot.copyWith(
        xp: 0,
        completedStages: const {},
        completedQuestions: const {},
        correctQuestions: const {},
        completedLocations: const {},
        earnedBadges: const {},
        activeDays: {_dayKey(DateTime.now())},
      ),
    );
  }

  Future<LocalGuestSnapshot> _requiredSnapshot() async {
    final snapshot = await _store.read();
    if (snapshot == null) throw StateError('Guest session is unavailable.');
    return snapshot;
  }

  LocalGuestSnapshot _withActivity(LocalGuestSnapshot snapshot) => snapshot
      .copyWith(activeDays: {...snapshot.activeDays, _dayKey(DateTime.now())});

  _BadgeResult _newBadges(LocalGuestSnapshot snapshot) {
    final all = {...snapshot.earnedBadges};
    final newIds = <String>[];
    for (final badge in _badges) {
      if (!all.contains(badge.id) && badge.isEarned(snapshot)) {
        all.add(badge.id);
        newIds.add(badge.id);
      }
    }
    return _BadgeResult(all, newIds);
  }

  static List<Achievement> achievementsFor(
    LocalGuestSnapshot snapshot,
    String locale,
  ) => _badges
      .where((badge) => snapshot.earnedBadges.contains(badge.id))
      .map((badge) => badge.toAchievement(snapshot, locale))
      .toList(growable: false);

  static List<PassportStamp> stampsFor(LocalGuestSnapshot snapshot) => snapshot
      .completedLocations
      .map(
        (slug) => PassportStamp(
          locationId: slug,
          name: _locationName(slug),
          koreanName: _locationKoreanName(slug),
          earnedDate: snapshot.createdAt,
        ),
      )
      .toList(growable: false);
}

class _BadgeResult {
  const _BadgeResult(this.all, this.newIds);
  final Set<String> all;
  final List<String> newIds;
  List<String> newTitles(String locale) => _badges
      .where((badge) => newIds.contains(badge.id))
      .map((badge) => badge.title(locale))
      .toList(growable: false);
}

class _LocalBadge {
  const _LocalBadge(
    this.id,
    this.metric,
    this.target,
    this.vi,
    this.en,
    this.ko,
  );
  final String id;
  final String metric;
  final int target;
  final String vi;
  final String en;
  final String ko;

  int value(LocalGuestSnapshot snapshot) => switch (metric) {
    'locations' => snapshot.completedLocations.length,
    'correct' => snapshot.correctQuestions.length,
    'content' =>
      snapshot.completedStages
          .where(
            (stage) =>
                stage.endsWith(':4') ||
                stage.endsWith(':5') ||
                stage.endsWith(':6') ||
                stage.endsWith(':7'),
          )
          .length,
    'streak' => _streak(snapshot.activeDays),
    _ => 0,
  };

  bool isEarned(LocalGuestSnapshot snapshot) => value(snapshot) >= target;
  String title(String locale) => locale == 'en'
      ? en
      : locale == 'ko'
      ? ko
      : vi;
  Achievement toAchievement(LocalGuestSnapshot snapshot, String locale) =>
      Achievement(
        id: id,
        title: title(locale),
        description:
            '$target ${metric == 'locations'
                ? 'địa điểm'
                : metric == 'correct'
                ? 'câu trả lời đúng'
                : metric == 'content'
                ? 'nội dung'
                : 'ngày liên tiếp'}',
        currentValue: value(snapshot).clamp(0, target),
        targetValue: target,
        isEarned: true,
      );
}

const _badges = <_LocalBadge>[
  _LocalBadge(
    'first-step',
    'locations',
    1,
    'Bước chân đầu tiên',
    'First Step',
    '첫걸음',
  ),
  _LocalBadge(
    'culture-explorer',
    'locations',
    3,
    'Nhà thám hiểm văn hóa',
    'Culture Explorer',
    '문화 탐험가',
  ),
  _LocalBadge(
    'wise-beginning',
    'correct',
    10,
    'Khởi đầu thông thái',
    'Wise Beginning',
    '지혜로운 시작',
  ),
  _LocalBadge(
    'challenge-master',
    'correct',
    50,
    'Bậc thầy thử thách',
    'Challenge Master',
    '도전의 달인',
  ),
  _LocalBadge(
    'curious-explorer',
    'content',
    10,
    'Người ham khám phá',
    'Curious Explorer',
    '호기심 많은 탐험가',
  ),
  _LocalBadge(
    'treasure-of-knowledge',
    'content',
    50,
    'Kho tàng tri thức',
    'Treasure of Knowledge',
    '지식의 보물창고',
  ),
  _LocalBadge(
    'steady-journey',
    'streak',
    3,
    'Hành trình bền bỉ',
    'Steady Journey',
    '꾸준한 여정',
  ),
  _LocalBadge(
    'koreaquest-secret',
    'streak',
    7,
    'Bí mật KoreaQuest',
    'KoreaQuest Secret',
    'KoreaQuest의 비밀',
  ),
];

int _streak(Set<String> activeDays) {
  var cursor = DateTime.now();
  var result = 0;
  while (activeDays.contains(_dayKey(cursor))) {
    result += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return result;
}

String _dayKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String _locationName(String slug) => switch (slug) {
  'gyeongbokgung' => 'Cung điện Gyeongbokgung',
  'bukchon-hanok' => 'Làng Bukchon Hanok',
  'namsan' => 'Tháp Namsan Seoul',
  'jeju' => 'Đảo Jeju',
  _ => slug,
};

String _locationKoreanName(String slug) => switch (slug) {
  'gyeongbokgung' => '경복궁',
  'bukchon-hanok' => '북촌한옥마을',
  'namsan' => '남산서울타워',
  'jeju' => '제주도',
  _ => '',
};

import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/repositories/korea_quest_repository.dart';

class MockKoreaQuestRepository implements KoreaQuestRepository {
  static final user = AppUser(
    id: 'user-duong',
    fullName: 'Phạm Văn Dương',
    displayName: 'Dương',
    handle: 'duong.kq',
    joinedDate: DateTime(2026, 8, 2),
  );

  static const progress = UserProgress(
    level: 5,
    currentXp: 1250,
    nextLevelXp: 1500,
    streakDays: 7,
  );

  static const locations = [
    Location(
      id: 'gyeongbokgung',
      name: 'Cung điện Gyeongbokgung',
      koreanName: '경복궁',
      city: 'Seoul',
      description: 'Bước vào trung tâm lịch sử của triều đại Joseon.',
      status: LocationStatus.completed,
      rewardXp: 450,
    ),
    Location(
      id: 'bukchon-hanok',
      name: 'Làng Bukchon Hanok',
      koreanName: '북촌한옥마을',
      city: 'Seoul',
      description: 'Nếp sống truyền thống giữa lòng thành phố hiện đại.',
      status: LocationStatus.inProgress,
      rewardXp: 380,
    ),
    Location(
      id: 'namsan',
      name: 'Tháp Namsan',
      koreanName: '남산서울타워',
      city: 'Seoul',
      description: 'Ngắm Seoul và khám phá biểu tượng tình yêu hiện đại.',
      status: LocationStatus.available,
      rewardXp: 420,
    ),
    Location(
      id: 'jeju',
      name: 'Đảo Jeju',
      koreanName: '제주도',
      city: 'Jeju',
      description: 'Thiên nhiên, truyền thuyết và những người phụ nữ biển.',
      status: LocationStatus.locked,
      rewardXp: 600,
    ),
  ];

  static const achievements = [
    Achievement(
      id: 'first-explorer',
      title: 'Nhà thám hiểm đầu tiên',
      description: 'Hoàn thành địa điểm đầu tiên',
      icon: '🧭',
      status: AchievementStatus.earned,
    ),
    Achievement(
      id: 'history-lover',
      title: 'Người yêu lịch sử',
      description: 'Hoàn thành 10 câu hỏi lịch sử',
      icon: '🏯',
      status: AchievementStatus.earned,
    ),
    Achievement(
      id: 'vocabulary-master',
      title: 'Cao thủ từ vựng',
      description: 'Ghi nhớ 30 từ mới',
      icon: '가',
      status: AchievementStatus.earned,
    ),
    Achievement(
      id: 'seven-day-journey',
      title: 'Hành trình 7 ngày',
      description: 'Duy trì chuỗi khám phá 7 ngày',
      icon: '🔥',
      status: AchievementStatus.earned,
    ),
  ];

  @override
  Future<AppUser> getCurrentUser() async => user;

  @override
  Future<UserProgress> getUserProgress() async => progress;

  @override
  Future<List<Location>> getLocations() async => locations;

  @override
  Future<Location?> getLocation(String id) async {
    for (final location in locations) {
      if (location.id == id) return location;
    }
    return null;
  }

  @override
  Future<JourneyProgress> getJourney(String locationId) async =>
      JourneyProgress(
        locationId: locationId,
        stage: JourneyStage.culture,
        completedMissions: 5,
        totalMissions: 8,
      );

  @override
  Future<List<Mission>> getMissions(String locationId) async => const [
    Mission(
      id: 'check-in',
      title: 'Check-in & lịch sử',
      stage: JourneyStage.checkIn,
      status: MissionStatus.completed,
      rewardXp: 100,
    ),
    Mission(
      id: 'culture',
      title: 'Khám phá văn hóa',
      stage: JourneyStage.culture,
      status: MissionStatus.inProgress,
      rewardXp: 150,
    ),
    Mission(
      id: 'vocabulary',
      title: 'Từ vựng tại chỗ',
      stage: JourneyStage.vocabulary,
      status: MissionStatus.locked,
      rewardXp: 200,
    ),
  ];

  @override
  Future<List<Achievement>> getAchievements() async => achievements;

  @override
  Future<List<PassportStamp>> getPassportStamps() async => [
    PassportStamp(
      locationId: 'gyeongbokgung',
      name: 'Gyeongbokgung',
      koreanName: '경복궁',
      seal: '宮',
      earnedDate: DateTime(2026, 8, 2),
    ),
    PassportStamp(
      locationId: 'bukchon-hanok',
      name: 'Bukchon Hanok',
      koreanName: '북촌',
      seal: '村',
      earnedDate: DateTime(2026, 8, 5),
    ),
    PassportStamp(
      locationId: 'namsan',
      name: 'Tháp Namsan',
      koreanName: '남산',
      seal: '山',
      earnedDate: DateTime(2026, 8, 9),
    ),
    const PassportStamp(
      locationId: 'jeju',
      name: 'Đảo Jeju',
      koreanName: '제주',
      seal: '島',
    ),
  ];
}

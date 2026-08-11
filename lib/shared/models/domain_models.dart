enum LocationStatus { completed, inProgress, available, locked }

enum MissionStatus { notStarted, inProgress, completed, locked }

enum JourneyStage { checkIn, culture, vocabulary, summary }

enum AchievementStatus { earned, locked }

class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.displayName,
    required this.handle,
    required this.joinedDate,
  });

  final String id;
  final String fullName;
  final String displayName;
  final String handle;
  final DateTime joinedDate;
}

class UserProgress {
  const UserProgress({
    required this.level,
    required this.currentXp,
    required this.nextLevelXp,
    required this.streakDays,
  });

  final int level;
  final int currentXp;
  final int nextLevelXp;
  final int streakDays;

  double get xpPercentage {
    if (nextLevelXp <= 0) return 0;
    return (currentXp / nextLevelXp).clamp(0, 1);
  }

  int get xpRemaining => (nextLevelXp - currentXp).clamp(0, nextLevelXp);
  bool get reachedNextLevel => currentXp >= nextLevelXp;
}

class Location {
  const Location({
    required this.id,
    required this.name,
    required this.koreanName,
    required this.city,
    required this.description,
    required this.status,
    required this.rewardXp,
  });

  final String id;
  final String name;
  final String koreanName;
  final String city;
  final String description;
  final LocationStatus status;
  final int rewardXp;
}

class JourneyProgress {
  const JourneyProgress({
    required this.locationId,
    required this.stage,
    required this.completedMissions,
    required this.totalMissions,
  });

  final String locationId;
  final JourneyStage stage;
  final int completedMissions;
  final int totalMissions;

  double get percentage =>
      totalMissions == 0 ? 0 : (completedMissions / totalMissions).clamp(0, 1);
}

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementStatus status;
}

class PassportStamp {
  const PassportStamp({
    required this.locationId,
    required this.name,
    required this.koreanName,
    required this.seal,
    this.earnedDate,
  });

  final String locationId;
  final String name;
  final String koreanName;
  final String seal;
  final DateTime? earnedDate;

  bool get isEarned => earnedDate != null;
}

class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.stage,
    required this.status,
    required this.rewardXp,
  });

  final String id;
  final String title;
  final JourneyStage stage;
  final MissionStatus status;
  final int rewardXp;
}

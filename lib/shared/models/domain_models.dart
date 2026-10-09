import 'dart:typed_data';

enum LocationStatus { completed, inProgress, available }

enum LocationReleaseStatus {
  comingSoon('coming_soon'),
  released('released');

  const LocationReleaseStatus(this.wireValue);

  final String wireValue;

  bool get isReleased => this == LocationReleaseStatus.released;

  static LocationReleaseStatus fromWire(Object? value) =>
      value?.toString() == LocationReleaseStatus.released.wireValue
      ? LocationReleaseStatus.released
      : LocationReleaseStatus.comingSoon;
}

enum MissionStatus { notStarted, inProgress, completed }

enum JourneyStage { checkIn, culture, vocabulary, summary }

class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.displayName,
    required this.handle,
    required this.joinedDate,
    this.bio,
    this.avatarPreset,
    this.avatarBytes,
  });

  final String id;
  final String fullName;
  final String displayName;
  final String handle;
  final DateTime joinedDate;
  final String? bio;
  final String? avatarPreset;
  final Uint8List? avatarBytes;

  AppUser copyWith({
    String? id,
    String? fullName,
    String? displayName,
    String? handle,
    DateTime? joinedDate,
    String? bio,
    String? avatarPreset,
    Uint8List? avatarBytes,
  }) => AppUser(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    displayName: displayName ?? this.displayName,
    handle: handle ?? this.handle,
    joinedDate: joinedDate ?? this.joinedDate,
    bio: bio ?? this.bio,
    avatarPreset: avatarPreset ?? this.avatarPreset,
    avatarBytes: avatarBytes ?? this.avatarBytes,
  );
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
    required this.releaseStatus,
    required this.rewardXp,
  });

  final String id;
  final String name;
  final String koreanName;
  final String city;
  final String description;
  final LocationStatus status;
  final LocationReleaseStatus releaseStatus;
  final int rewardXp;

  bool get isReleased => releaseStatus.isReleased;
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
  });

  final String id;
  final String title;
  final String description;
  final String icon;
}

class PassportStamp {
  const PassportStamp({
    required this.locationId,
    required this.name,
    required this.koreanName,
    required this.seal,
    required this.earnedDate,
  });

  final String locationId;
  final String name;
  final String koreanName;
  final String seal;
  final DateTime earnedDate;
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

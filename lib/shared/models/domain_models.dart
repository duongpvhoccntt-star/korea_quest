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
    this.title = '',
    this.isMaxLevel = false,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
    level: (json['level'] as num?)?.toInt() ?? 1,
    currentXp: (json['current_xp'] as num?)?.toInt() ?? 0,
    nextLevelXp: (json['next_level_xp'] as num?)?.toInt() ?? 0,
    streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
    title: json['title']?.toString() ?? '',
    isMaxLevel: json['is_max_level'] as bool? ?? false,
  );

  final int level;
  final int currentXp;
  final int nextLevelXp;
  final int streakDays;
  final String title;
  final bool isMaxLevel;

  double get xpPercentage {
    if (isMaxLevel) return 1;
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
    this.icon = '🏅',
    this.iconUrl = '',
    this.category = 'general',
    this.isSecret = false,
    this.isEarned = true,
    this.currentValue,
    this.targetValue,
    this.earnedDate,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    iconUrl: json['icon_url']?.toString() ?? '',
    category: json['category']?.toString() ?? 'general',
    isSecret: json['is_secret'] as bool? ?? false,
    isEarned: json['is_earned'] as bool? ?? false,
    currentValue: (json['current_value'] as num?)?.toInt(),
    targetValue: (json['target_value'] as num?)?.toInt(),
    earnedDate: DateTime.tryParse(json['earned_at']?.toString() ?? ''),
  );

  final String id;
  final String title;
  final String description;
  final String icon;
  final String iconUrl;
  final String category;
  final bool isSecret;
  final bool isEarned;
  final int? currentValue;
  final int? targetValue;
  final DateTime? earnedDate;

  double get progress {
    final target = targetValue;
    if (target == null || target <= 0) return isEarned ? 1 : 0;
    return ((currentValue ?? 0) / target).clamp(0, 1);
  }
}

class PassportStamp {
  const PassportStamp({
    required this.locationId,
    required this.name,
    required this.koreanName,
    required this.earnedDate,
    this.seal = '✦',
    this.description = '',
    this.imageUrl = '',
    this.imageAlt = '',
  });

  factory PassportStamp.fromJson(Map<String, dynamic> json) => PassportStamp(
    locationId: json['location_id']?.toString() ?? '',
    name: json['stamp_name']?.toString().isNotEmpty == true
        ? json['stamp_name'].toString()
        : json['name']?.toString() ?? '',
    koreanName: json['korean_name']?.toString() ?? '',
    description: json['stamp_description']?.toString() ?? '',
    imageUrl: json['stamp_image_url']?.toString() ?? '',
    imageAlt: json['stamp_image_alt']?.toString() ?? '',
    earnedDate:
        DateTime.tryParse(json['earned_at']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );

  final String locationId;
  final String name;
  final String koreanName;
  final String seal;
  final DateTime earnedDate;
  final String description;
  final String imageUrl;
  final String imageAlt;
}

class SharedPassport {
  const SharedPassport({
    required this.displayName,
    required this.progress,
    required this.stamps,
    required this.achievements,
  });

  factory SharedPassport.fromJson(Map<String, dynamic> json) {
    final profile = _jsonObject(json['profile']);
    final progressJson = _jsonObject(json['progress']);
    return SharedPassport(
      displayName: profile['display_name']?.toString() ?? '',
      progress: progressJson.isEmpty
          ? null
          : UserProgress.fromJson(progressJson),
      stamps: _jsonList(
        json['stamps'],
      ).map(PassportStamp.fromJson).toList(growable: false),
      achievements: _jsonList(
        json['achievements'],
      ).map(Achievement.fromJson).toList(growable: false),
    );
  }

  final String displayName;
  final UserProgress? progress;
  final List<PassportStamp> stamps;
  final List<Achievement> achievements;
}

Map<String, dynamic> _jsonObject(Object? value) => value is Map
    ? value.map((key, item) => MapEntry(key.toString(), item))
    : const {};

List<Map<String, dynamic>> _jsonList(Object? value) => value is List
    ? value.whereType<Map>().map(_jsonObject).toList(growable: false)
    : const [];

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

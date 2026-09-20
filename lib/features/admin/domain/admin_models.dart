enum AdminRevisionStatus {
  draft,
  published,
  archived;

  static AdminRevisionStatus fromJson(String value) => switch (value) {
    'published' => published,
    'archived' => archived,
    _ => draft,
  };
}

class AdminSession {
  const AdminSession({this.userId, this.email});

  final String? userId;
  final String? email;

  bool get isSignedIn => userId != null;
}

class AdminLocationSummary {
  const AdminLocationSummary({
    required this.locationId,
    required this.slug,
    required this.revisionId,
    required this.status,
    required this.versionNumber,
    required this.lockVersion,
    required this.name,
    required this.koreanName,
    required this.updatedAt,
  });

  factory AdminLocationSummary.fromJson(Map<String, dynamic> json) {
    return AdminLocationSummary(
      locationId: json['location_id'] as String,
      slug: json['slug'] as String,
      revisionId: json['revision_id'] as String,
      status: AdminRevisionStatus.fromJson(json['revision_status'] as String),
      versionNumber: json['version_number'] as int,
      lockVersion: json['lock_version'] as int,
      name: json['name'] as String? ?? '',
      koreanName: json['korean_name'] as String? ?? '',
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String locationId;
  final String slug;
  final String revisionId;
  final AdminRevisionStatus status;
  final int versionNumber;
  final int lockVersion;
  final String name;
  final String koreanName;
  final DateTime updatedAt;
}

class AdminLocationDraft {
  AdminLocationDraft({
    this.locationId,
    this.revisionId,
    this.slug = '',
    this.status = AdminRevisionStatus.draft,
    this.versionNumber = 1,
    this.lockVersion = 1,
    Map<String, dynamic>? overview,
    List<Map<String, dynamic>>? history,
    List<Map<String, dynamic>>? highlights,
    List<Map<String, dynamic>>? experiences,
    Map<String, dynamic>? experienceGuide,
    List<Map<String, dynamic>>? foods,
    List<Map<String, dynamic>>? funFacts,
    List<Map<String, dynamic>>? quiz,
    Map<String, dynamic>? travel,
    List<Map<String, dynamic>>? sources,
  }) : overview = overview ?? emptyOverview(),
       history = history ?? [],
       highlights = highlights ?? [],
       experiences = experiences ?? [],
       experienceGuide = experienceGuide ?? emptyExperienceGuide(),
       foods = foods ?? [],
       funFacts = funFacts ?? [],
       quiz = quiz ?? [],
       travel = travel ?? emptyTravel(),
       sources = sources ?? [];

  factory AdminLocationDraft.fromJson(Map<String, dynamic> json) {
    return AdminLocationDraft(
      locationId: json['location_id'] as String,
      revisionId: json['revision_id'] as String,
      slug: json['slug'] as String,
      status: AdminRevisionStatus.fromJson(json['status'] as String),
      versionNumber: json['version_number'] as int,
      lockVersion: json['lock_version'] as int,
      overview: _map(json['overview']),
      history: _list(json['history']),
      highlights: _list(json['highlights']),
      experiences: _list(json['experiences']),
      experienceGuide: _map(json['experience_guide']),
      foods: _list(json['foods']),
      funFacts: _list(json['fun_facts']),
      quiz: _list(json['quiz']),
      travel: _map(json['travel']),
      sources: _list(json['sources']),
    );
  }

  String? locationId;
  String? revisionId;
  String slug;
  AdminRevisionStatus status;
  int versionNumber;
  int lockVersion;
  final Map<String, dynamic> overview;
  final List<Map<String, dynamic>> history;
  final List<Map<String, dynamic>> highlights;
  final List<Map<String, dynamic>> experiences;
  final Map<String, dynamic> experienceGuide;
  final List<Map<String, dynamic>> foods;
  final List<Map<String, dynamic>> funFacts;
  final List<Map<String, dynamic>> quiz;
  final Map<String, dynamic> travel;
  final List<Map<String, dynamic>> sources;

  bool get isPersisted => locationId != null && revisionId != null;

  static Map<String, dynamic> emptyOverview() => {
    'name': '',
    'korean_name': '',
    'english_name': '',
    'region': '',
    'address': '',
    'city': '',
    'country': '',
    'latitude': '',
    'longitude': '',
    'location_type': '',
    'short_description': '',
    'long_description': '',
    'cover_image_url': '',
    'cover_image_credit': '',
    'cover_image_source_url': '',
    'cover_image_alt': '',
    'thumbnail_url': '',
    'thumbnail_credit': '',
    'thumbnail_source_url': '',
    'thumbnail_alt': '',
    'hook_media_kind': 'youtube',
    'hook_media_url': '',
    'hook_media_credit': '',
    'hook_media_source_url': '',
    'hook_media_alt': '',
    'hook_title': '',
    'hook_caption': '',
    'tags': <String>[],
    'categories': <String>[],
    'release_status': 'coming_soon',
    'estimated_duration_minutes': '',
    'display_order': 0,
    'prerequisite_location_id': '',
    'stamp_name': '',
    'stamp_description': '',
    'stamp_image_url': '',
    'stamp_image_credit': '',
    'stamp_image_source_url': '',
    'stamp_image_alt': '',
    'quick_facts': <Map<String, dynamic>>[],
  };

  static Map<String, dynamic> emptyExperienceGuide() => {
    'featured_fact': '',
    'dos': <String>[],
    'donts': <String>[],
  };

  static Map<String, dynamic> emptyTravel() => {
    'opening_hours': '',
    'ticket_price': '',
    'recommended_duration': '',
    'best_time_to_visit': '',
    'accessibility_info': '',
    'official_source_url': '',
    'last_verified_at': '',
    'transport_options': <Map<String, dynamic>>[],
    'visitor_notes': <Map<String, dynamic>>[],
  };

  static Map<String, dynamic> _map(Object? value) {
    if (value is! Map) return <String, dynamic>{};
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  static List<Map<String, dynamic>> _list(Object? value) {
    if (value is List<Map<String, dynamic>>) return value;
    if (value is! List) return <Map<String, dynamic>>[];
    return value.map(_map).toList();
  }

  static List<Map<String, dynamic>> fromJsonList(Object? value) => _list(value);
}

int countWords(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return 0;
  return normalized.split(RegExp(r'\s+')).length;
}

enum AdminAchievementMetric {
  completedLocations('completed_locations', 'Địa điểm hoàn thành'),
  correctAnswers('correct_answers', 'Câu trả lời đúng'),
  unlockedFunFacts('unlocked_fun_facts', 'Fun Fact đã mở'),
  streakDays('streak_days', 'Ngày duy trì chuỗi'),
  completedSpecificLocation(
    'completed_specific_location',
    'Hoàn thành địa điểm cụ thể',
  ),
  challengeCompletion('challenge_completion', 'Hoàn thành thử thách'),
  contentViews('content_views', 'Nội dung đã xem');

  const AdminAchievementMetric(this.value, this.label);
  final String value;
  final String label;

  static AdminAchievementMetric fromJson(String value) => values.firstWhere(
    (item) => item.value == value,
    orElse: () => completedLocations,
  );
}

class AdminLevelDefinition {
  const AdminLevelDefinition({
    this.id,
    required this.levelNumber,
    required this.minXp,
    required this.title,
    this.iconUrl = '',
    this.isActive = true,
  });

  factory AdminLevelDefinition.fromJson(Map<String, dynamic> json) =>
      AdminLevelDefinition(
        id: json['id'] as String?,
        levelNumber: json['level_number'] as int,
        minXp: json['min_xp'] as int,
        title: json['title'] as String,
        iconUrl: json['icon_url'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? true,
      );

  final String? id;
  final int levelNumber;
  final int minXp;
  final String title;
  final String iconUrl;
  final bool isActive;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'level_number': levelNumber,
    'min_xp': minXp,
    'title': title,
    'icon_url': iconUrl,
    'is_active': isActive,
  };
}

class AdminAchievementDefinition {
  const AdminAchievementDefinition({
    this.id,
    required this.slug,
    required this.title,
    required this.metric,
    required this.target,
    this.koreanTitle = '',
    this.description = '',
    this.category = 'general',
    this.iconUrl = '',
    this.criteriaFilter = const {},
    this.isSecret = false,
    this.isLimited = false,
    this.isActive = true,
    this.availableFrom,
    this.availableUntil,
    this.displayOrder = 0,
    this.criteriaLockedAt,
  });

  factory AdminAchievementDefinition.fromJson(Map<String, dynamic> json) =>
      AdminAchievementDefinition(
        id: json['id'] as String?,
        slug: json['slug'] as String,
        title: json['title'] as String,
        koreanTitle: json['korean_title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? 'general',
        iconUrl: json['icon_url'] as String? ?? '',
        metric: AdminAchievementMetric.fromJson(json['metric'] as String),
        target: json['target'] as int,
        criteriaFilter: AdminLocationDraft._map(json['criteria_filter']),
        isSecret: json['is_secret'] as bool? ?? false,
        isLimited: json['is_limited'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        availableFrom: _date(json['available_from']),
        availableUntil: _date(json['available_until']),
        displayOrder: json['display_order'] as int? ?? 0,
        criteriaLockedAt: _date(json['criteria_locked_at']),
      );

  final String? id;
  final String slug;
  final String title;
  final String koreanTitle;
  final String description;
  final String category;
  final String iconUrl;
  final AdminAchievementMetric metric;
  final int target;
  final Map<String, dynamic> criteriaFilter;
  final bool isSecret;
  final bool isLimited;
  final bool isActive;
  final DateTime? availableFrom;
  final DateTime? availableUntil;
  final int displayOrder;
  final DateTime? criteriaLockedAt;

  bool get isCriteriaLocked => criteriaLockedAt != null;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'slug': slug,
    'title': title,
    'korean_title': koreanTitle,
    'description': description,
    'category': category,
    'icon_url': iconUrl,
    'metric': metric.value,
    'target': target,
    'criteria_filter': criteriaFilter,
    'is_secret': isSecret,
    'is_limited': isLimited,
    'is_active': isActive,
    'available_from': availableFrom?.toUtc().toIso8601String(),
    'available_until': availableUntil?.toUtc().toIso8601String(),
    'display_order': displayOrder,
  };
}

class AdminChallengeGoal {
  const AdminChallengeGoal({
    required this.metric,
    required this.target,
    this.criteriaFilter = const {},
  });

  factory AdminChallengeGoal.fromJson(Map<String, dynamic> json) =>
      AdminChallengeGoal(
        metric: AdminAchievementMetric.fromJson(json['metric'] as String),
        target: json['target'] as int,
        criteriaFilter: AdminLocationDraft._map(json['criteria_filter']),
      );

  final AdminAchievementMetric metric;
  final int target;
  final Map<String, dynamic> criteriaFilter;

  Map<String, dynamic> toJson() => {
    'metric': metric.value,
    'target': target,
    'criteria_filter': criteriaFilter,
  };
}

class AdminChallengeDefinition {
  const AdminChallengeDefinition({
    this.id,
    required this.slug,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    this.description = '',
    this.rewardXp = 0,
    this.rewardAchievementId,
    this.status = 'draft',
    this.goals = const [],
  });

  factory AdminChallengeDefinition.fromJson(Map<String, dynamic> json) =>
      AdminChallengeDefinition(
        id: json['id'] as String?,
        slug: json['slug'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        startsAt: DateTime.parse(json['starts_at'] as String),
        endsAt: DateTime.parse(json['ends_at'] as String),
        rewardXp: json['reward_xp'] as int? ?? 0,
        rewardAchievementId: json['reward_achievement_id'] as String?,
        status: json['status'] as String? ?? 'draft',
        goals: AdminLocationDraft._list(
          json['goals'],
        ).map(AdminChallengeGoal.fromJson).toList(),
      );

  final String? id;
  final String slug;
  final String title;
  final String description;
  final DateTime startsAt;
  final DateTime endsAt;
  final int rewardXp;
  final String? rewardAchievementId;
  final String status;
  final List<AdminChallengeGoal> goals;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'slug': slug,
    'title': title,
    'description': description,
    'starts_at': startsAt.toUtc().toIso8601String(),
    'ends_at': endsAt.toUtc().toIso8601String(),
    'reward_xp': rewardXp,
    'reward_achievement_id': rewardAchievementId,
    'status': status,
    'goals': goals.map((item) => item.toJson()).toList(),
  };
}

class AdminGameConfig {
  const AdminGameConfig({
    this.levels = const [],
    this.achievements = const [],
    this.challenges = const [],
  });

  factory AdminGameConfig.fromJson(Map<String, dynamic> json) =>
      AdminGameConfig(
        levels: AdminLocationDraft._list(
          json['levels'],
        ).map(AdminLevelDefinition.fromJson).toList(),
        achievements: AdminLocationDraft._list(
          json['achievements'],
        ).map(AdminAchievementDefinition.fromJson).toList(),
        challenges: AdminLocationDraft._list(
          json['challenges'],
        ).map(AdminChallengeDefinition.fromJson).toList(),
      );

  final List<AdminLevelDefinition> levels;
  final List<AdminAchievementDefinition> achievements;
  final List<AdminChallengeDefinition> challenges;
}

DateTime? _date(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

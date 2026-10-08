import 'dart:convert';

enum ContentLocale {
  vi,
  en,
  ko;

  String get label => switch (this) {
    vi => 'Tiếng Việt',
    en => 'English',
    ko => '한국어',
  };

  static ContentLocale fromJson(String value) => switch (value) {
    'en' => en,
    'ko' => ko,
    _ => vi,
  };
}

enum TranslationReviewStatus {
  draft,
  needsReview,
  approved;

  static TranslationReviewStatus fromJson(String value) => switch (value) {
    'needs_review' => needsReview,
    'approved' => approved,
    _ => draft,
  };

  String get jsonValue => switch (this) {
    draft => 'draft',
    needsReview => 'needs_review',
    approved => 'approved',
  };
}

class AdminContentTranslation {
  const AdminContentTranslation({
    required this.locale,
    required this.status,
    required this.content,
    required this.sourceLockVersion,
    this.updatedAt,
    this.approvedAt,
  });

  factory AdminContentTranslation.fromJson(Map<String, dynamic> json) =>
      AdminContentTranslation(
        locale: ContentLocale.fromJson(json['locale']?.toString() ?? 'vi'),
        status: TranslationReviewStatus.fromJson(
          json['status']?.toString() ?? 'draft',
        ),
        content: AdminLocationDraft._map(json['content']),
        sourceLockVersion: json['source_lock_version'] as int? ?? 1,
        updatedAt: _date(json['updated_at']),
        approvedAt: _date(json['approved_at']),
      );

  final ContentLocale locale;
  final TranslationReviewStatus status;
  final Map<String, dynamic> content;
  final int sourceLockVersion;
  final DateTime? updatedAt;
  final DateTime? approvedAt;
}

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
    Map<ContentLocale, AdminContentTranslation>? translations,
  }) : overview = overview ?? emptyOverview(),
       history = history ?? [],
       highlights = highlights ?? [],
       experiences = experiences ?? [],
       experienceGuide = experienceGuide ?? emptyExperienceGuide(),
       foods = foods ?? [],
       funFacts = funFacts ?? [],
       quiz = quiz ?? [],
       travel = travel ?? emptyTravel(),
       sources = sources ?? [],
       translations = translations ?? {};

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
  final Map<ContentLocale, AdminContentTranslation> translations;

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

  Map<String, dynamic> toTranslationSource() {
    dynamic copy(Object? value) => jsonDecode(jsonEncode(value));
    dynamic translatableShape(Object? value, [String key = '']) {
      const excluded = {
        'id',
        'kind',
        'media_kind',
        'release_status',
        'categories',
        'tags',
        'icon_name',
        'unlock_after_stage',
        'is_visible',
        'is_recommended',
        'display_order',
        'last_verified_at',
      };
      if (excluded.contains(key) ||
          key.endsWith('_url') ||
          key.endsWith('_id') ||
          key.endsWith('_credit') ||
          key.endsWith('_source_url')) {
        return null;
      }
      if (value is String) return value;
      if (value is List) {
        return [for (final item in value) translatableShape(item)];
      }
      if (value is Map) {
        final result = <String, dynamic>{};
        for (final entry in value.entries) {
          final localized = translatableShape(
            entry.value,
            entry.key.toString(),
          );
          if (localized != null) result[entry.key.toString()] = localized;
        }
        return result;
      }
      return null;
    }

    final o = overview;
    final summary = <String, dynamic>{
      for (final key in const [
        'name',
        'korean_name',
        'english_name',
        'city',
        'region',
        'country',
        'short_description',
        'thumbnail_alt',
      ])
        key: copy(o[key]),
    };
    final localizedQuiz = <Map<String, dynamic>>[
      for (final question in quiz)
        {
          'prompt': copy(question['prompt']),
          'explanation': copy(question['explanation']),
          'options': [
            for (final option in _list(question['options']))
              {'text': copy(option['text'])},
          ],
          'matching_left': [
            for (final pair in _list(question['pairs']))
              {'text': copy(pair['left'])},
          ],
          'matching_right': [
            for (final pair in _list(question['pairs']))
              {'text': copy(pair['right'])},
          ],
          'ordering_items': [
            for (final item in _list(question['items']))
              {'text': copy(item['text'])},
          ],
        },
    ];
    final detail = <String, dynamic>{
      for (final key in const [
        'name',
        'korean_name',
        'english_name',
        'city',
        'region',
        'country',
        'location_type',
        'short_description',
        'long_description',
      ])
        key: copy(o[key]),
      'cover_media': {'alt': copy(o['cover_image_alt'])},
      'hook_media': {
        'alt': copy(o['hook_media_alt']),
        'title': copy(o['hook_title']),
        'caption': copy(o['hook_caption']),
      },
      'quick_facts': translatableShape(o['quick_facts'] ?? const []),
      'history': translatableShape(history),
      'highlights': translatableShape(highlights),
      'experiences': translatableShape(experiences),
      'culture_guidelines': [
        for (final value in (experienceGuide['dos'] as List? ?? const []))
          {'kind': 'do', 'content': copy(value)},
        for (final value in (experienceGuide['donts'] as List? ?? const []))
          {'kind': 'dont', 'content': copy(value)},
      ],
      'foods': translatableShape(foods),
      'fun_facts': translatableShape(funFacts),
      'quiz': localizedQuiz,
      'travel': translatableShape(travel),
    };
    return {'summary': summary, 'detail': detail};
  }
}

int countWords(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return 0;
  return normalized.split(RegExp(r'\s+')).length;
}

List<String> expandAdminValidationErrors(
  List<String> rawErrors,
  AdminLocationDraft draft,
) {
  final expanded = <String>[];
  for (final rawError in rawErrors) {
    final lower = rawError.trim().toLowerCase();
    final matcher = switch (lower) {
      final value when value.contains('câu một đáp án') =>
        _singleChoiceProblems,
      final value when value.contains('câu đúng/sai') => _trueFalseProblems,
      final value when value.contains('câu nối cặp') => _matchingProblems,
      final value when value.contains('câu sắp xếp') => _orderingProblems,
      final value
          when value.contains('câu hỏi cần nội dung') &&
              value.contains('giải thích') =>
        _questionContentProblems,
      _ => null,
    };
    if (matcher == null) {
      expanded.add(rawError);
      continue;
    }

    var matchedQuestion = false;
    for (var index = 0; index < draft.quiz.length; index++) {
      final question = draft.quiz[index];
      if (question['is_visible'] == false) continue;
      final problems = matcher(question);
      if (problems.isEmpty) continue;
      matchedQuestion = true;
      expanded.add(_quizDiagnostic(index, question, problems));
    }
    if (!matchedQuestion) expanded.add(rawError);
  }
  return expanded;
}

List<String> _questionContentProblems(Map<String, dynamic> question) {
  final problems = <String>[];
  if (_isBlank(question['prompt'])) {
    problems.add('chưa nhập nội dung câu hỏi');
  }
  final explanationWords = countWords(
    question['explanation']?.toString() ?? '',
  );
  if (explanationWords < 10 || explanationWords > 200) {
    problems.add(
      'phần giải thích có $explanationWords từ; cần từ 10 đến 200 từ',
    );
  }
  return problems;
}

List<String> _singleChoiceProblems(Map<String, dynamic> question) {
  if (_diagnosticText(question, 'kind') != 'single_choice') return const [];
  final options = AdminLocationDraft.fromJsonList(question['options']);
  final problems = <String>[];
  if (options.length < 2 || options.length > 6) {
    problems.add('có ${options.length} lựa chọn; cần từ 2 đến 6');
  }
  final correctCount = options
      .where((option) => option['is_correct'] == true)
      .length;
  if (correctCount != 1) {
    problems.add('có $correctCount đáp án đúng; cần đúng 1');
  }
  final blankOptions = <int>[
    for (var index = 0; index < options.length; index++)
      if (_isBlank(options[index]['text'])) index + 1,
  ];
  if (blankOptions.isNotEmpty) {
    problems.add('lựa chọn ${blankOptions.join(', ')} đang để trống');
  }
  return problems;
}

List<String> _trueFalseProblems(Map<String, dynamic> question) {
  if (_diagnosticText(question, 'kind') != 'true_false') return const [];
  final options = AdminLocationDraft.fromJsonList(question['options']);
  final problems = <String>[];
  if (options.length != 2) {
    problems.add('có ${options.length} lựa chọn; cần đúng 2');
  }
  final correctCount = options
      .where((option) => option['is_correct'] == true)
      .length;
  if (correctCount != 1) {
    problems.add('có $correctCount đáp án đúng; cần đúng 1');
  }
  return problems;
}

List<String> _matchingProblems(Map<String, dynamic> question) {
  if (_diagnosticText(question, 'kind') != 'matching') return const [];
  final pairs = AdminLocationDraft.fromJsonList(question['pairs']);
  final problems = <String>[];
  if (pairs.length < 2 || pairs.length > 8) {
    problems.add('có ${pairs.length} cặp nối; cần từ 2 đến 8');
  }
  final blankPairs = <int>[
    for (var index = 0; index < pairs.length; index++)
      if (_isBlank(pairs[index]['left']) || _isBlank(pairs[index]['right']))
        index + 1,
  ];
  if (blankPairs.isNotEmpty) {
    problems.add('cặp ${blankPairs.join(', ')} đang để trống');
  }
  return problems;
}

List<String> _orderingProblems(Map<String, dynamic> question) {
  if (_diagnosticText(question, 'kind') != 'ordering') return const [];
  final items = AdminLocationDraft.fromJsonList(question['items']);
  final problems = <String>[];
  if (items.length < 2 || items.length > 8) {
    problems.add('có ${items.length} mục sắp xếp; cần từ 2 đến 8');
  }
  final blankItems = <int>[
    for (var index = 0; index < items.length; index++)
      if (_isBlank(items[index]['text'])) index + 1,
  ];
  if (blankItems.isNotEmpty) {
    problems.add('mục ${blankItems.join(', ')} đang để trống');
  }
  return problems;
}

String _quizDiagnostic(
  int index,
  Map<String, dynamic> question,
  List<String> problems,
) {
  final prompt = _diagnosticText(question, 'prompt').trim();
  final shortenedPrompt = prompt.length > 80
      ? '${prompt.substring(0, 77)}…'
      : prompt;
  final label = shortenedPrompt.isEmpty ? '' : ' “$shortenedPrompt”';
  return '[quiz:$index] Câu ${index + 1}$label: ${problems.join('. ')}.';
}

bool _isBlank(Object? value) => value?.toString().trim().isEmpty ?? true;

String _diagnosticText(Map<String, dynamic> data, String key) =>
    data[key]?.toString() ?? '';

enum AdminDiagnosticSeverity { error, warning }

class AdminDiagnostic {
  const AdminDiagnostic({
    required this.message,
    required this.stepIndex,
    this.severity = AdminDiagnosticSeverity.error,
    this.stepName = '',
    this.itemIndex,
  });

  final String message;
  final int stepIndex;
  final AdminDiagnosticSeverity severity;
  final String stepName;
  final int? itemIndex;

  bool get isBlocking => severity == AdminDiagnosticSeverity.error;
}

AdminDiagnostic parseAdminDiagnostic(String rawMessage) {
  final raw = rawMessage.trim();
  final locator = RegExp(r'^\[quiz:(\d+)\]\s*').firstMatch(raw);
  final itemIndex = locator == null
      ? null
      : int.tryParse(locator.group(1) ?? '');
  final msg = locator == null ? raw : raw.substring(locator.end).trim();
  final lower = msg.toLowerCase();

  const stepNames = [
    'Mở đầu',
    'Tổng quan',
    'Lịch sử',
    'Điểm đến',
    'Trải nghiệm',
    'Ẩm thực',
    'Fun Facts',
    'Quiz tổng kết',
    'Du lịch',
    'Kiểm tra & Xuất bản',
  ];

  // ADR 0011: Nguồn tham khảo nội dung là tùy chọn. Thiếu nguồn kiểm chứng là cảnh báo, KHÔNG chặn xuất bản.
  if (lower.contains('nguồn') &&
      (lower.contains('kiểm chứng') ||
          lower.contains('cần ít nhất một nguồn') ||
          lower.contains('ít nhất 1 nguồn'))) {
    return AdminDiagnostic(
      message:
          '$msg (Theo ADR 0011: Không bắt buộc có nguồn tham khảo để Xuất bản, nhưng khuyến khích bổ sung).',
      stepIndex: 9,
      stepName: stepNames[9],
      severity: AdminDiagnosticSeverity.warning,
    );
  }

  // Step 0: Mở đầu
  if (lower.contains('mở đầu') || lower.contains('hook')) {
    return AdminDiagnostic(message: msg, stepIndex: 0, stepName: stepNames[0]);
  }

  // Step 2: Lịch sử
  if (lower.contains('lịch sử') || lower.contains('mốc lịch sử')) {
    return AdminDiagnostic(message: msg, stepIndex: 2, stepName: stepNames[2]);
  }

  // Step 3: Điểm đến (Highlights)
  if (lower.contains('điểm nổi bật') || lower.contains('điểm đến')) {
    return AdminDiagnostic(message: msg, stepIndex: 3, stepName: stepNames[3]);
  }

  // Step 4: Trải nghiệm
  if (lower.contains('trải nghiệm') ||
      lower.contains('hướng dẫn trải nghiệm')) {
    return AdminDiagnostic(message: msg, stepIndex: 4, stepName: stepNames[4]);
  }

  // Step 5: Ẩm thực
  if (lower.contains('món ăn') || lower.contains('ẩm thực')) {
    return AdminDiagnostic(message: msg, stepIndex: 5, stepName: stepNames[5]);
  }

  // Step 6: Fun Facts
  if (lower.contains('fun fact') || lower.contains('fun facts')) {
    return AdminDiagnostic(message: msg, stepIndex: 6, stepName: stepNames[6]);
  }

  // Step 7: Quiz tổng kết
  if (itemIndex != null ||
      lower.contains('quiz') ||
      lower.contains('câu hỏi') ||
      lower.contains('đáp án') ||
      lower.contains('lựa chọn') ||
      lower.contains('đúng/sai') ||
      lower.contains('nối cặp') ||
      lower.contains('sắp xếp') ||
      lower.contains('ordering') ||
      lower.contains('matching') ||
      lower.contains('single_choice') ||
      lower.contains('single-choice')) {
    return AdminDiagnostic(
      message: msg,
      stepIndex: 7,
      stepName: stepNames[7],
      itemIndex: itemIndex,
    );
  }

  // Step 8: Du lịch
  if (lower.contains('du lịch') ||
      lower.contains('thông tin du lịch') ||
      lower.contains('giờ mở cửa') ||
      lower.contains('giá vé') ||
      lower.contains('thời gian tham quan') ||
      lower.contains('phương tiện') ||
      lower.contains('lưu ý du khách') ||
      lower.contains('visitor_notes') ||
      lower.contains('transport')) {
    return AdminDiagnostic(message: msg, stepIndex: 8, stepName: stepNames[8]);
  }

  // Step 1: Tổng quan
  if (lower.contains('tổng quan') ||
      lower.contains('tọa độ') ||
      lower.contains('latitude') ||
      lower.contains('longitude') ||
      lower.contains('thời lượng dự kiến') ||
      lower.contains('ảnh bìa') ||
      lower.contains('cover_image') ||
      lower.contains('thumbnail') ||
      lower.contains('dấu mộc') ||
      lower.contains('thông tin nhanh') ||
      lower.contains('quick_fact') ||
      lower.contains('quick fact') ||
      lower.contains('slug') ||
      lower.contains('tên địa điểm') ||
      lower.contains('danh mục bản đồ')) {
    return AdminDiagnostic(message: msg, stepIndex: 1, stepName: stepNames[1]);
  }

  // Step 9: Nguồn, xem trước & Xuất bản (sources, prerequisite, revision, draft)
  if (lower.contains('nguồn') ||
      lower.contains('tiên quyết') ||
      lower.contains('phiên bản') ||
      lower.contains('bản nháp')) {
    return AdminDiagnostic(message: msg, stepIndex: 9, stepName: stepNames[9]);
  }

  return AdminDiagnostic(message: msg, stepIndex: 9, stepName: stepNames[9]);
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

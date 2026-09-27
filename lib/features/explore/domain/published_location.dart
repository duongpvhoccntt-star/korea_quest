typedef JsonMap = Map<String, dynamic>;

class PublishedLocationSummary {
  const PublishedLocationSummary({
    required this.id,
    required this.slug,
    required this.name,
    required this.koreanName,
    required this.city,
    required this.shortDescription,
    required this.thumbnailUrl,
    required this.thumbnailAlt,
    required this.releaseStatus,
    required this.categories,
    this.estimatedDurationMinutes,
  });

  factory PublishedLocationSummary.fromJson(JsonMap json) =>
      PublishedLocationSummary(
        id: json.string('id'),
        slug: json.string('slug'),
        name: json.string('name'),
        koreanName: json.string('korean_name'),
        city: json.string('city'),
        shortDescription: json.string('short_description'),
        thumbnailUrl: json.string('thumbnail_url'),
        thumbnailAlt: json.string('thumbnail_alt'),
        releaseStatus: json.string('release_status'),
        categories: json.stringList('categories'),
        estimatedDurationMinutes: json.intOrNull('estimated_duration_minutes'),
      );

  final String id;
  final String slug;
  final String name;
  final String koreanName;
  final String city;
  final String shortDescription;
  final String thumbnailUrl;
  final String thumbnailAlt;
  final String releaseStatus;
  final List<String> categories;
  final int? estimatedDurationMinutes;

  bool get isReleased => releaseStatus == 'released';
}

class PublishedLocationDetail {
  const PublishedLocationDetail(this.data);

  factory PublishedLocationDetail.fromJson(JsonMap json) =>
      PublishedLocationDetail(json.deepCopy());

  final JsonMap data;

  String get id => data.string('id');
  String get slug => data.string('slug');
  String get name => data.string('name');
  String get koreanName => data.string('korean_name');
  String get englishName => data.string('english_name');
  String get city => data.string('city');
  String get region => data.string('region');
  String get country => data.string('country');
  String get locationType => data.string('location_type');
  String get shortDescription => data.string('short_description');
  String get longDescription => data.string('long_description');
  String get releaseStatus => data.string('release_status');
  int? get estimatedDurationMinutes =>
      data.intOrNull('estimated_duration_minutes');
  List<String> get tags => data.stringList('tags');
  List<String> get categories => data.stringList('categories');
  JsonMap get coverMedia => data.jsonObject('cover_media');
  JsonMap get hookMedia => data.jsonObject('hook_media');
  List<JsonMap> get quickFacts => data.mapList('quick_facts');
  List<JsonMap> get history => data.mapList('history');
  List<JsonMap> get highlights => data.mapList('highlights');
  List<JsonMap> get experiences => data.mapList('experiences');
  List<JsonMap> get cultureGuidelines => data.mapList('culture_guidelines');
  List<JsonMap> get foods => data.mapList('foods');
  List<JsonMap> get funFacts => data.mapList('fun_facts');
  List<JsonMap> get quiz => data.mapList('quiz');
  JsonMap get travel => data.jsonObject('travel');
}

class QuizAnswerResult {
  const QuizAnswerResult({required this.isCorrect, required this.explanation});

  factory QuizAnswerResult.fromJson(JsonMap json) => QuizAnswerResult(
    isCorrect: json['is_correct'] == true,
    explanation: json.string('explanation'),
  );

  final bool isCorrect;
  final String explanation;
}

extension JsonMapRead on JsonMap {
  String string(String key) => this[key]?.toString() ?? '';

  int? intOrNull(String key) => switch (this[key]) {
    int value => value,
    num value => value.toInt(),
    String value => int.tryParse(value),
    _ => null,
  };

  JsonMap jsonObject(String key) => jsonMap(this[key]);

  List<JsonMap> mapList(String key) => jsonMapList(this[key]);

  List<String> stringList(String key) => jsonStringList(this[key]);

  JsonMap deepCopy() => Map<String, dynamic>.from(this);
}

JsonMap jsonMap(Object? value) => value is Map
    ? Map<String, dynamic>.from(
        value.map((key, item) => MapEntry('$key', item)),
      )
    : <String, dynamic>{};

List<JsonMap> jsonMapList(Object? value) => value is List
    ? value.map(jsonMap).toList(growable: false)
    : const <JsonMap>[];

List<String> jsonStringList(Object? value) => value is List
    ? value.map((item) => item.toString()).toList(growable: false)
    : const <String>[];

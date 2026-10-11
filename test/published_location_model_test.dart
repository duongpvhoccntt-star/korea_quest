import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';
import 'package:korea_quest/shared/models/domain_models.dart';

void main() {
  test('published location keeps ordered public content from read model', () {
    final location = PublishedLocationDetail.fromJson({
      'id': 'location-1',
      'slug': 'gyeongbokgung',
      'name': 'Gyeongbokgung',
      'korean_name': '경복궁',
      'tags': ['cung điện'],
      'cover_media': {'url': 'https://example.com/cover.jpg'},
      'quick_facts': [
        {'label': 'Xây dựng', 'value': '1395'},
      ],
      'history': [
        {'title': 'Triều Joseon', 'long_description': 'Nội dung lịch sử'},
      ],
      'highlights': [],
      'experiences': [],
      'culture_guidelines': [],
      'foods': [],
      'fun_facts': [],
      'quiz': [
        {
          'id': 'question-1',
          'kind': 'single_choice',
          'prompt': 'Câu hỏi?',
          'options': [
            {'id': 'option-1', 'text': 'Lựa chọn'},
          ],
        },
      ],
      'travel': {'transport_options': [], 'visitor_notes': []},
    });

    expect(location.slug, 'gyeongbokgung');
    expect(location.tags, ['cung điện']);
    expect(location.quickFacts.single.string('value'), '1395');
    expect(location.history.single.string('title'), 'Triều Joseon');
    expect(
      location.quiz.single.mapList('options').single.string('id'),
      'option-1',
    );
  });

  test('summary reads release information without unsafe defaults', () {
    final summary = PublishedLocationSummary.fromJson({
      'id': 'location-1',
      'slug': 'gyeongbokgung',
      'name': 'Gyeongbokgung',
      'korean_name': '경복궁',
      'city': 'Seoul',
      'short_description': 'Cung điện hoàng gia.',
      'thumbnail_url': '',
      'thumbnail_alt': '',
      'release_status': 'coming_soon',
      'categories': ['history'],
      'latitude': '37.579600',
      'longitude': 126.977,
    });

    expect(summary.isReleased, isFalse);
    expect(summary.releaseStatus, LocationReleaseStatus.comingSoon);
    expect(summary.estimatedDurationMinutes, isNull);
    expect(summary.latitude, 37.5796);
    expect(summary.longitude, 126.977);
    expect(summary.hasValidCoordinates, isTrue);
  });

  test('summary ignores missing, incomplete, and out-of-range coordinates', () {
    PublishedLocationSummary parse(Object? latitude, Object? longitude) =>
        PublishedLocationSummary.fromJson({
          'id': 'location-1',
          'slug': 'gyeongbokgung',
          'name': 'Gyeongbokgung',
          'release_status': 'released',
          'latitude': latitude,
          'longitude': longitude,
        });

    expect(parse(null, null).hasValidCoordinates, isFalse);
    expect(parse(37.5, null).hasValidCoordinates, isFalse);
    expect(parse('not-a-number', '126.9').hasValidCoordinates, isFalse);
    expect(parse(double.nan, 126.9).hasValidCoordinates, isFalse);
    expect(parse(91, 126.9).hasValidCoordinates, isFalse);
    expect(parse(37.5, 181).hasValidCoordinates, isFalse);
  });
}

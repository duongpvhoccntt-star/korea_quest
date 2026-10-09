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
    });

    expect(summary.isReleased, isFalse);
    expect(summary.releaseStatus, LocationReleaseStatus.comingSoon);
    expect(summary.estimatedDurationMinutes, isNull);
  });
}

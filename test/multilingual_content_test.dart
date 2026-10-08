import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';
import 'package:korea_quest/l10n/app_localizations_en.dart';
import 'package:korea_quest/l10n/app_localizations_ko.dart';
import 'package:korea_quest/l10n/app_localizations_vi.dart';

void main() {
  test(
    'translation source excludes answer keys but preserves quiz text shape',
    () {
      final draft = AdminLocationDraft(
        overview: {
          ...AdminLocationDraft.emptyOverview(),
          'name': 'Cung điện',
          'short_description': 'Mô tả',
        },
        quiz: [
          {
            'prompt': 'Câu hỏi?',
            'explanation': 'Giải thích',
            'options': [
              {'text': 'Đáp án', 'is_correct': true},
            ],
            'pairs': <Map<String, dynamic>>[],
            'items': <Map<String, dynamic>>[],
          },
        ],
      );

      final source = draft.toTranslationSource();
      final detail = source['detail']! as Map<String, dynamic>;
      final quiz = (detail['quiz']! as List).single as Map<String, dynamic>;
      final option = (quiz['options']! as List).single as Map<String, dynamic>;

      expect(option['text'], 'Đáp án');
      expect(option, isNot(contains('is_correct')));
    },
  );

  test('published summary exposes locale fallback metadata', () {
    final summary = PublishedLocationSummary.fromJson({
      'id': 'location-1',
      'slug': 'gyeongbokgung',
      'name': 'Cung điện Gyeongbokgung',
      'is_fallback': true,
      'requested_locale': 'en',
      'resolved_locale': 'vi',
    });

    expect(summary.isFallback, isTrue);
    expect(summary.requestedLocale, 'en');
    expect(summary.resolvedLocale, 'vi');
  });

  test(
    'static interface copy is available in Vietnamese, English, and Korean',
    () {
      final vi = AppLocalizationsVi();
      final en = AppLocalizationsEn();
      final ko = AppLocalizationsKo();

      expect(vi.whereStart, 'Bạn muốn bắt đầu từ đâu?');
      expect(en.whereStart, 'Where would you like to start?');
      expect(ko.whereStart, '어디에서 시작할까요?');
      expect(en.stageProgress(3), 'Stage 3/9');
      expect(ko.levelWithXp(2, 150), '레벨 2 · 150 XP');
    },
  );
}

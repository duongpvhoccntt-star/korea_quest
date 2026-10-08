import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/app/app_theme.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/presentation/widgets/location_editor_overview.dart';

void main() {
  test('expands every quiz error category with a question locator', () {
    final validExplanation = List.filled(10, 'từ').join(' ');
    final draft = AdminLocationDraft(
      quiz: [
        {
          'prompt': 'Một đáp án lỗi',
          'explanation': validExplanation,
          'kind': 'single_choice',
          'is_visible': true,
          'options': [
            {'text': 'A', 'is_correct': true},
          ],
        },
        {
          'prompt': 'Đúng sai lỗi',
          'explanation': validExplanation,
          'kind': 'true_false',
          'is_visible': true,
          'options': [
            {'text': 'Đúng', 'is_correct': true},
          ],
        },
        {
          'prompt': 'Nối cặp lỗi',
          'explanation': validExplanation,
          'kind': 'matching',
          'is_visible': true,
          'pairs': [
            {'left': 'A', 'right': ''},
          ],
        },
        {
          'prompt': 'Sắp xếp lỗi',
          'explanation': validExplanation,
          'kind': 'ordering',
          'is_visible': true,
          'items': [
            {'text': 'A'},
          ],
        },
        {
          'prompt': 'Thiếu giải thích',
          'explanation': '',
          'kind': 'single_choice',
          'is_visible': true,
          'options': [
            {'text': 'A', 'is_correct': true},
            {'text': 'B', 'is_correct': false},
          ],
        },
      ],
    );

    final expanded = expandAdminValidationErrors(const [
      'Câu một đáp án cần 2–6 lựa chọn và đúng chính xác một đáp án.',
      'Câu Đúng/Sai phải có hai lựa chọn.',
      'Câu nối cặp cần 2–8 cặp hợp lệ.',
      'Câu sắp xếp cần 2–8 mục hợp lệ.',
      'Câu hỏi cần nội dung và giải thích đúng giới hạn từ.',
    ], draft);

    expect(expanded, hasLength(5));
    for (var index = 0; index < expanded.length; index++) {
      final diagnostic = parseAdminDiagnostic(expanded[index]);
      expect(diagnostic.stepIndex, 7);
      expect(diagnostic.itemIndex, index);
      expect(diagnostic.message, contains('Câu ${index + 1}'));
    }
  });

  testWidgets('quiz validation identifies the exact invalid question', (
    tester,
  ) async {
    AdminDiagnostic? selectedDiagnostic;
    final draft = AdminLocationDraft(
      quiz: [
        {
          'prompt': 'Câu hợp lệ',
          'kind': 'single_choice',
          'is_visible': true,
          'options': [
            {'text': 'A', 'is_correct': true},
            {'text': 'B', 'is_correct': false},
          ],
        },
        {
          'prompt': 'Câu bị lỗi',
          'kind': 'single_choice',
          'is_visible': true,
          'options': [
            {'text': 'Chỉ một lựa chọn', 'is_correct': true},
          ],
        },
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: LocationReviewEditor(
              draft: draft,
              validationErrors: const [
                'Câu một đáp án cần 2–6 lựa chọn và đúng chính xác một đáp án.',
              ],
              onChanged: () {},
              onGoToDiagnostic: (diagnostic) {
                selectedDiagnostic = diagnostic;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Câu 2'), findsOneWidget);
    expect(find.textContaining('Câu bị lỗi'), findsOneWidget);

    await tester.ensureVisible(find.text('Đi tới sửa'));
    await tester.tap(find.text('Đi tới sửa'));
    expect(selectedDiagnostic?.stepIndex, 7);
    expect(selectedDiagnostic?.itemIndex, 1);
  });
}

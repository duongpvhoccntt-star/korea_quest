import 'package:flutter/material.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/presentation/widgets/admin_editor_fields.dart';

class LocationQuizEditor extends StatelessWidget {
  const LocationQuizEditor({
    required this.draft,
    required this.onChanged,
    super.key,
  });

  final AdminLocationDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final visibleCount = draft.quiz
        .where((question) => question['is_visible'] != false)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [_CountChip(count: visibleCount)],
        ),
        const SizedBox(height: AppSpacing.lg),
        AdminRepeatableSection(
          title: 'Quiz tổng kết',
          items: draft.quiz,
          itemLabel: 'câu hỏi',
          minimum: 10,
          maximum: 20,
          createItem: _newQuestion,
          onChanged: onChanged,
          itemBuilder: (context, question, index) =>
              _QuestionEditor(question: question, onChanged: onChanged),
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(
      count >= 10 && count <= 20
          ? Icons.check_circle_outline
          : Icons.warning_amber_rounded,
      color: count >= 10 && count <= 20 ? AppColors.green : AppColors.coralDark,
    ),
    label: Text('Quiz tổng kết: $count/20 · tối thiểu 10'),
  );
}

class _QuestionEditor extends StatelessWidget {
  const _QuestionEditor({required this.question, required this.onChanged});

  final Map<String, dynamic> question;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final kind = adminText(question, 'kind');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminFieldGrid(
          children: [
            AdminEditorDropdown(
              key: ValueKey('${identityHashCode(question)}-kind'),
              label: 'Dạng câu hỏi',
              value: kind,
              items: const {
                'single_choice': 'Trắc nghiệm một đáp án',
                'true_false': 'Đúng / Sai',
                'matching': 'Nối cặp',
                'ordering': 'Sắp xếp thứ tự',
              },
              onChanged: (value) {
                question['kind'] = value;
                _ensureAnswerData(question);
                onChanged();
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _field(
          question,
          'prompt',
          'Câu hỏi / nhiệm vụ',
          onChanged,
          maxLines: 4,
        ),
        const SizedBox(height: AppSpacing.md),
        _field(
          question,
          'explanation',
          'Giải thích đáp án',
          onChanged,
          maxLines: 4,
          minWords: 25,
          maxWords: 50,
        ),
        const SizedBox(height: AppSpacing.md),
        _MediaEditor(question: question, onChanged: onChanged),
        const SizedBox(height: AppSpacing.lg),
        switch (kind) {
          'true_false' => _TrueFalseEditor(
            question: question,
            onChanged: onChanged,
          ),
          'matching' => _MatchingEditor(
            question: question,
            onChanged: onChanged,
          ),
          'ordering' => _OrderingEditor(
            question: question,
            onChanged: onChanged,
          ),
          _ => _SingleChoiceEditor(question: question, onChanged: onChanged),
        },
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Hiển thị câu hỏi này'),
          value: question['is_visible'] != false,
          onChanged: (value) {
            question['is_visible'] = value;
            onChanged();
          },
        ),
      ],
    );
  }
}

class _MediaEditor extends StatelessWidget {
  const _MediaEditor({required this.question, required this.onChanged});

  final Map<String, dynamic> question;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final kind = adminText(question, 'media_kind');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminEditorDropdown(
          key: ValueKey('${identityHashCode(question)}-media-kind'),
          label: 'Media câu hỏi (không bắt buộc)',
          value: kind,
          items: const {'': 'Không có', 'image': 'Ảnh', 'youtube': 'YouTube'},
          onChanged: (value) {
            question['media_kind'] = value;
            if (value.isEmpty) {
              question['media_url'] = '';
              question['media_credit'] = '';
              question['media_source_url'] = '';
            }
            onChanged();
          },
        ),
        if (kind.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          AdminFieldGrid(
            children: [
              _field(question, 'media_url', 'URL media', onChanged),
              _field(question, 'media_credit', 'Credit media', onChanged),
              _field(
                question,
                'media_source_url',
                'URL nguồn media',
                onChanged,
              ),
              _field(question, 'media_alt', 'Mô tả thay thế media', onChanged),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AdminMediaPreview(kind: kind, url: adminText(question, 'media_url')),
        ],
      ],
    );
  }
}

class _SingleChoiceEditor extends StatelessWidget {
  const _SingleChoiceEditor({required this.question, required this.onChanged});

  final Map<String, dynamic> question;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final options = _mapList(question, 'options');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Đáp án (3–4, chọn đúng một)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        RadioGroup<int>(
          groupValue: options.indexWhere((item) => item['is_correct'] == true),
          onChanged: (selectedIndex) {
            if (selectedIndex == null) return;
            for (var itemIndex = 0; itemIndex < options.length; itemIndex++) {
              options[itemIndex]['is_correct'] = itemIndex == selectedIndex;
            }
            onChanged();
          },
          child: Column(
            children: [
              for (var index = 0; index < options.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Radio<int>(value: index),
                      Expanded(
                        child: _field(
                          options[index],
                          'text',
                          'Đáp án ${index + 1}',
                          onChanged,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Xóa đáp án',
                        onPressed: options.length > 3
                            ? () {
                                final removedCorrect =
                                    options[index]['is_correct'] == true;
                                options.removeAt(index);
                                if (removedCorrect && options.isNotEmpty) {
                                  options.first['is_correct'] = true;
                                }
                                onChanged();
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: SecondaryButton(
            label: 'Thêm đáp án',
            icon: Icons.add_rounded,
            onPressed: options.length < 4
                ? () {
                    options.add({'text': '', 'is_correct': false});
                    onChanged();
                  }
                : null,
          ),
        ),
      ],
    );
  }
}

class _TrueFalseEditor extends StatelessWidget {
  const _TrueFalseEditor({required this.question, required this.onChanged});

  final Map<String, dynamic> question;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final options = _mapList(question, 'options');
    final correctIndex = options.indexWhere(
      (item) => item['is_correct'] == true,
    );
    return AdminEditorDropdown(
      label: 'Đáp án đúng',
      value: correctIndex == 1 ? 'false' : 'true',
      items: const {'true': 'Đúng', 'false': 'Sai'},
      onChanged: (value) {
        options[0]['is_correct'] = value == 'true';
        options[1]['is_correct'] = value == 'false';
        onChanged();
      },
    );
  }
}

class _MatchingEditor extends StatelessWidget {
  const _MatchingEditor({required this.question, required this.onChanged});

  final Map<String, dynamic> question;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final pairs = _mapList(question, 'pairs');
    return _NestedAnswerList(
      title: 'Cặp nối (3–6 cặp, mỗi vế không trùng)',
      items: pairs,
      minimum: 3,
      maximum: 6,
      createItem: () => {'left': '', 'right': ''},
      onChanged: onChanged,
      itemBuilder: (item, index) => AdminFieldGrid(
        children: [
          _field(item, 'left', 'Vế trái ${index + 1}', onChanged),
          _field(item, 'right', 'Vế phải ${index + 1}', onChanged),
        ],
      ),
    );
  }
}

class _OrderingEditor extends StatelessWidget {
  const _OrderingEditor({required this.question, required this.onChanged});

  final Map<String, dynamic> question;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final items = _mapList(question, 'items');
    return _NestedAnswerList(
      title: 'Thứ tự đúng (3–6 mục)',
      items: items,
      minimum: 3,
      maximum: 6,
      createItem: () => {'text': ''},
      onChanged: onChanged,
      itemBuilder: (item, index) =>
          _field(item, 'text', 'Vị trí ${index + 1}', onChanged),
    );
  }
}

class _NestedAnswerList extends StatelessWidget {
  const _NestedAnswerList({
    required this.title,
    required this.items,
    required this.minimum,
    required this.maximum,
    required this.createItem,
    required this.onChanged,
    required this.itemBuilder,
  });

  final String title;
  final List<Map<String, dynamic>> items;
  final int minimum;
  final int maximum;
  final Map<String, dynamic> Function() createItem;
  final VoidCallback onChanged;
  final Widget Function(Map<String, dynamic> item, int index) itemBuilder;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: AppSpacing.sm),
      for (var index = 0; index < items.length; index++)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: itemBuilder(items[index], index)),
              IconButton(
                tooltip: 'Đưa lên',
                onPressed: index > 0
                    ? () {
                        final item = items.removeAt(index);
                        items.insert(index - 1, item);
                        onChanged();
                      }
                    : null,
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
              IconButton(
                tooltip: 'Đưa xuống',
                onPressed: index < items.length - 1
                    ? () {
                        final item = items.removeAt(index);
                        items.insert(index + 1, item);
                        onChanged();
                      }
                    : null,
                icon: const Icon(Icons.arrow_downward_rounded),
              ),
              IconButton(
                tooltip: 'Xóa',
                onPressed: items.length > minimum
                    ? () {
                        items.removeAt(index);
                        onChanged();
                      }
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
            ],
          ),
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: SecondaryButton(
          label: 'Thêm mục',
          icon: Icons.add_rounded,
          onPressed: items.length < maximum
              ? () {
                  items.add(createItem());
                  onChanged();
                }
              : null,
        ),
      ),
    ],
  );
}

Map<String, dynamic> _newQuestion() => {
  'kind': 'single_choice',
  'prompt': '',
  'explanation': '',
  'media_kind': '',
  'media_url': '',
  'media_credit': '',
  'media_source_url': '',
  'media_alt': '',
  'is_visible': true,
  'options': [
    {'text': '', 'is_correct': true},
    {'text': '', 'is_correct': false},
    {'text': '', 'is_correct': false},
  ],
  'pairs': <Map<String, dynamic>>[],
  'items': <Map<String, dynamic>>[],
};

void _ensureAnswerData(Map<String, dynamic> question) {
  switch (adminText(question, 'kind')) {
    case 'true_false':
      question['options'] = [
        {'text': 'Đúng', 'is_correct': true},
        {'text': 'Sai', 'is_correct': false},
      ];
      return;
    case 'matching':
      question['pairs'] = List.generate(3, (_) => {'left': '', 'right': ''});
      return;
    case 'ordering':
      question['items'] = List.generate(3, (_) => {'text': ''});
      return;
    default:
      question['options'] = [
        {'text': '', 'is_correct': true},
        {'text': '', 'is_correct': false},
        {'text': '', 'is_correct': false},
      ];
      return;
  }
}

List<Map<String, dynamic>> _mapList(Map<String, dynamic> owner, String key) {
  final normalized = AdminLocationDraft.fromJsonList(owner[key]);
  owner[key] = normalized;
  return normalized;
}

AdminEditorTextField _field(
  Map<String, dynamic> data,
  String key,
  String label,
  VoidCallback onChanged, {
  int maxLines = 1,
  int? minWords,
  int? maxWords,
}) {
  return AdminEditorTextField(
    key: ValueKey('${identityHashCode(data)}-$key'),
    label: label,
    value: adminText(data, key),
    maxLines: maxLines,
    minWords: minWords,
    maxWords: maxWords,
    onChanged: (value) {
      data[key] = value;
      onChanged();
    },
  );
}

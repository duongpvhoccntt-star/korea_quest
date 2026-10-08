import 'package:flutter/material.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';

class LocationTranslationEditor extends StatelessWidget {
  const LocationTranslationEditor({
    required this.locale,
    required this.translation,
    required this.busy,
    required this.onTranslateSection,
    required this.onTranslateAll,
    required this.onChanged,
    required this.onSave,
    required this.onApprove,
    super.key,
  });

  final ContentLocale locale;
  final AdminContentTranslation? translation;
  final bool busy;
  final VoidCallback onTranslateSection;
  final VoidCallback onTranslateAll;
  final VoidCallback onChanged;
  final VoidCallback onSave;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    final current = translation;
    if (current == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Icon(
                Icons.translate_rounded,
                size: 40,
                color: AppColors.teal,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Chưa có bản ${locale.label}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'AI sẽ tạo bản nháp từ nội dung tiếng Việt. Bạn cần kiểm tra trước khi duyệt.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Dịch tất cả nội dung còn thiếu',
                icon: Icons.auto_awesome_rounded,
                isLoading: busy,
                onPressed: onTranslateAll,
              ),
            ],
          ),
        ),
      );
    }

    final fields = _collectFields(current.content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StatusChip(status: current.status),
            SecondaryButton(
              label: 'Dịch phần này',
              icon: Icons.auto_fix_high_rounded,
              onPressed: busy ? null : onTranslateSection,
            ),
            SecondaryButton(
              label: 'Dịch tất cả',
              icon: Icons.auto_awesome_rounded,
              onPressed: busy ? null : onTranslateAll,
            ),
            PrimaryButton(
              label: 'Lưu bản dịch',
              icon: Icons.save_outlined,
              isLoading: busy,
              onPressed: onSave,
            ),
            SecondaryButton(
              label: 'Duyệt bản dịch',
              icon: Icons.verified_rounded,
              onPressed: busy ? null : onApprove,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Chỉ sửa phần chữ dành cho người học. ID, media, XP và đáp án đúng vẫn dùng chung với bản tiếng Việt.',
          style: TextStyle(color: AppColors.stitchMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final field in fields) ...[
          TextFormField(
            key: ValueKey('${locale.name}:${field.path}'),
            initialValue: field.value,
            minLines: field.value.length > 90 ? 3 : 1,
            maxLines: field.value.length > 90 ? 8 : 3,
            decoration: InputDecoration(labelText: _label(field.path)),
            onChanged: (value) {
              field.write(value);
              onChanged();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  static List<_TranslationField> _collectFields(Map<String, dynamic> root) {
    final fields = <_TranslationField>[];
    void visit(dynamic value, String path) {
      if (value is Map<String, dynamic>) {
        for (final entry in value.entries) {
          final childPath = path.isEmpty ? entry.key : '$path.${entry.key}';
          if (entry.value is String && _isTranslatable(entry.key)) {
            fields.add(
              _TranslationField(
                path: childPath,
                value: entry.value as String,
                write: (text) => value[entry.key] = text,
              ),
            );
          } else {
            visit(entry.value, childPath);
          }
        }
      } else if (value is List) {
        for (var index = 0; index < value.length; index++) {
          visit(value[index], '$path.${index + 1}');
        }
      }
    }

    visit(root, '');
    return fields;
  }

  static bool _isTranslatable(String key) {
    if (key == 'id' || key == 'kind' || key == 'slug' || key == 'locale') {
      return false;
    }
    if (key.endsWith('_url') || key.endsWith('_id')) return false;
    return !const {
      'release_status',
      'icon_name',
      'media_kind',
      'last_verified_at',
    }.contains(key);
  }

  static String _label(String path) =>
      path.split('.').map((part) => part.replaceAll('_', ' ')).join(' › ');
}

class _TranslationField {
  const _TranslationField({
    required this.path,
    required this.value,
    required this.write,
  });

  final String path;
  final String value;
  final ValueChanged<String> write;
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TranslationReviewStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TranslationReviewStatus.draft => ('Bản nháp', AppColors.stitchMuted),
      TranslationReviewStatus.needsReview => ('Cần duyệt', AppColors.gold),
      TranslationReviewStatus.approved => ('Đã duyệt', AppColors.teal),
    };
    return Chip(
      avatar: Icon(Icons.circle, size: 10, color: color),
      label: Text(label),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:korea_quest/core/utils/optimized_image_url.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/shared/widgets/youtube_player.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';

class AdminEditorTextField extends StatelessWidget {
  const AdminEditorTextField({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.hint,
    this.maxLines = 1,
    this.minWords,
    this.maxWords,
    this.keyboardType,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final int maxLines;
  final int? minWords;
  final int? maxWords;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final words = countWords(value);
    final hasWordGuide = minWords != null || maxWords != null;
    final rangeLabel = switch ((minWords, maxWords)) {
      (final int min, final int max) => '$min–$max từ',
      (final int min, null) => 'từ $min từ',
      (null, final int max) => 'tối đa $max từ',
      _ => '',
    };

    final String? helper;
    final TextStyle? helperStyle;
    if (hasWordGuide) {
      if (minWords != null && words < minWords!) {
        helper =
            '$words từ · thiếu ${minWords! - words} từ (yêu cầu $rangeLabel)';
        helperStyle = const TextStyle(
          color: AppColors.coralDark,
          fontWeight: FontWeight.w600,
        );
      } else if (maxWords != null && words > maxWords!) {
        helper =
            '$words từ · vượt ${words - maxWords!} từ (yêu cầu $rangeLabel)';
        helperStyle = const TextStyle(
          color: AppColors.coralDark,
          fontWeight: FontWeight.w600,
        );
      } else {
        helper = '$words từ · hợp lệ ($rangeLabel)';
        helperStyle = const TextStyle(
          color: AppColors.green,
          fontWeight: FontWeight.w500,
        );
      }
    } else {
      helper = null;
      helperStyle = null;
    }

    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        helperText: helper,
        helperStyle: helperStyle,
      ),
    );
  }
}

class AdminEditorDropdown extends StatelessWidget {
  const AdminEditorDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: items.containsKey(value) ? value : items.keys.first,
    decoration: InputDecoration(labelText: label),
    items: items.entries
        .map(
          (entry) =>
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        )
        .toList(),
    onChanged: (next) {
      if (next != null) onChanged(next);
    },
  );
}

class AdminStringListField extends StatelessWidget {
  const AdminStringListField({
    required this.label,
    required this.values,
    required this.onChanged,
    super.key,
    this.hint = 'Mỗi dòng một mục',
  });

  final String label;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: values.join('\n'),
    maxLines: 4,
    onChanged: (raw) => onChanged(
      raw
          .split('\n')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
    ),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: true,
    ),
  );
}

class AdminFieldGrid extends StatelessWidget {
  const AdminFieldGrid({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 760 ? 2 : 1;
      final fieldWidth = columns == 1
          ? constraints.maxWidth
          : (constraints.maxWidth - AppSpacing.md) / 2;
      return Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: [
          for (final child in children)
            SizedBox(width: fieldWidth, child: child),
        ],
      );
    },
  );
}

void applyUploadedImage(
  Map<String, dynamic> data,
  String publicUrl, {
  required String urlKey,
}) {
  data[urlKey] = publicUrl;
  final keyPrefix = urlKey.substring(0, urlKey.length - '_url'.length);
  final creditKey = '${keyPrefix}_credit';
  final sourceKey = '${keyPrefix}_source_url';
  final altKey = '${keyPrefix}_alt';
  if (adminText(data, creditKey).isEmpty) data[creditKey] = 'KoreaQuest';
  if (adminText(data, sourceKey).isEmpty) data[sourceKey] = publicUrl;
  if (adminText(data, altKey).isEmpty) data[altKey] = 'Ảnh tải lên KoreaQuest';
}

class AdminMediaPreview extends StatelessWidget {
  const AdminMediaPreview({required this.kind, required this.url, super.key});

  final String kind;
  final String url;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) return const SizedBox.shrink();

    if (kind == 'youtube') {
      return YoutubePlayer(url: trimmedUrl, label: 'xem trước');
    }

    final previewUrl = _isHttpUrl(trimmedUrl) ? trimmedUrl : null;
    if (previewUrl == null) {
      return const Text(
        'Không thể xem trước: URL chưa đúng định dạng HTTP(S)/YouTube.',
        style: TextStyle(color: AppColors.coralDark),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Xem trước media'),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      optimizedImageUrl(previewUrl, maxWidth: 960),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(
                            color: AppColors.creamDark,
                            child: Center(
                              child: Text(
                                'Không tải được ảnh xem trước.',
                                style: TextStyle(color: AppColors.coralDark),
                              ),
                            ),
                          ),
                    ),
                    if (kind == 'youtube')
                      const Center(
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          size: 56,
                          color: AppColors.paper,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}

class AdminRepeatableSection extends StatelessWidget {
  const AdminRepeatableSection({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.createItem,
    required this.itemBuilder,
    required this.onChanged,
    super.key,
    this.minimum,
    this.maximumGuide,
    this.maximum,
  });

  final String title;
  final List<Map<String, dynamic>> items;
  final String itemLabel;
  final Map<String, dynamic> Function() createItem;
  final Widget Function(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
  )
  itemBuilder;
  final VoidCallback onChanged;
  final int? minimum;
  final int? maximumGuide;
  final int? maximum;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                if (minimum != null)
                  Text(
                    'Hiện có ${items.length} · tối thiểu $minimum'
                    '${maximumGuide == null ? '' : ' · gợi ý tối đa $maximumGuide'}'
                    '${maximum == null ? '' : ' · tối đa $maximum'}',
                    style: TextStyle(
                      color: items.length < minimum!
                          ? AppColors.coralDark
                          : AppColors.muted,
                    ),
                  ),
              ],
            ),
          ),
          SecondaryButton(
            label: 'Thêm $itemLabel',
            icon: Icons.add_rounded,
            onPressed: maximum != null && items.length >= maximum!
                ? null
                : () {
                    items.add(createItem());
                    onChanged();
                  },
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      if (items.isEmpty)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Chưa có $itemLabel.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
        ),
      for (var index = 0; index < items.length; index++) ...[
        _RepeatableCard(
          key: ObjectKey(items[index]),
          title: '$itemLabel ${index + 1}',
          canMoveUp: index > 0,
          canMoveDown: index < items.length - 1,
          onMoveUp: () {
            final item = items.removeAt(index);
            items.insert(index - 1, item);
            onChanged();
          },
          onMoveDown: () {
            final item = items.removeAt(index);
            items.insert(index + 1, item);
            onChanged();
          },
          onRemove: () {
            items.removeAt(index);
            onChanged();
          },
          child: itemBuilder(context, items[index], index),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    ],
  );
}

class _RepeatableCard extends StatelessWidget {
  const _RepeatableCard({
    required this.title,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemove,
    required this.child,
    super.key,
  });

  final String title;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onRemove;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Đưa lên',
                onPressed: canMoveUp ? onMoveUp : null,
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
              IconButton(
                tooltip: 'Đưa xuống',
                onPressed: canMoveDown ? onMoveDown : null,
                icon: const Icon(Icons.arrow_downward_rounded),
              ),
              IconButton(
                tooltip: 'Xóa mục',
                onPressed: onRemove,
                color: AppColors.danger,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const Divider(),
          child,
        ],
      ),
    ),
  );
}

List<String> adminStringList(Object? value) {
  if (value is! List) return <String>[];
  return value.map((item) => item.toString()).toList();
}

String adminText(Map<String, dynamic> data, String key) {
  return data[key]?.toString() ?? '';
}

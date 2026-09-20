import 'package:flutter/material.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/presentation/widgets/admin_editor_fields.dart';

class LocationHistoryEditor extends StatelessWidget {
  const LocationHistoryEditor({
    required this.draft,
    required this.onChanged,
    super.key,
  });

  final AdminLocationDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => AdminRepeatableSection(
    title: 'Lịch sử hình thành',
    items: draft.history,
    itemLabel: 'mốc lịch sử',
    minimum: 4,
    maximumGuide: 6,
    createItem: () => {
      'period_label': '',
      'title': '',
      'short_description': '',
      'long_description': '',
      'related_people': '',
      'categories': <String>[],
      'media_kind': 'image',
      'media_url': '',
      'media_credit': '',
      'media_source_url': '',
      'media_alt': '',
      'fun_fact': '',
      'is_visible': true,
    },
    onChanged: onChanged,
    itemBuilder: (context, item, index) => Column(
      children: [
        AdminFieldGrid(
          children: [
            _field(item, 'period_label', 'Năm / giai đoạn', onChanged),
            _field(
              item,
              'title',
              'Tiêu đề',
              onChanged,
              minWords: 4,
              maxWords: 10,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AdminStringListField(
          label: 'Danh mục / tag lịch sử',
          values: adminStringList(item['categories']),
          onChanged: (value) {
            item['categories'] = value;
            onChanged();
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _field(
          item,
          'short_description',
          'Mô tả ngắn',
          onChanged,
          maxLines: 3,
          minWords: 20,
          maxWords: 35,
        ),
        const SizedBox(height: AppSpacing.md),
        _field(
          item,
          'long_description',
          'Mô tả chi tiết',
          onChanged,
          maxLines: 6,
          minWords: 70,
          maxWords: 120,
        ),
        const SizedBox(height: AppSpacing.md),
        _field(
          item,
          'related_people',
          'Nhân vật liên quan (không bắt buộc)',
          onChanged,
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.md),
        _mediaFields(item, onChanged),
        const SizedBox(height: AppSpacing.sm),
        AdminMediaPreview(
          kind: adminText(item, 'media_kind'),
          url: adminText(item, 'media_url'),
        ),
        const SizedBox(height: AppSpacing.md),
        _field(item, 'fun_fact', 'Fun fact', onChanged, maxLines: 3),
        _visibilityToggle(item, onChanged),
      ],
    ),
  );
}

class LocationHighlightsEditor extends StatelessWidget {
  const LocationHighlightsEditor({
    required this.draft,
    required this.onChanged,
    super.key,
  });

  final AdminLocationDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => AdminRepeatableSection(
    title: 'Điểm đến đáng chú ý',
    items: draft.highlights,
    itemLabel: 'điểm nổi bật',
    minimum: 4,
    maximumGuide: 6,
    createItem: () => {
      'name': '',
      'korean_name': '',
      'tagline': '',
      'short_description': '',
      'long_description': '',
      'address': '',
      'activities': <String>[],
      'categories': <String>[],
      'fun_fact': '',
      'media_kind': 'image',
      'media_url': '',
      'media_credit': '',
      'media_source_url': '',
      'media_alt': '',
      'is_visible': true,
    },
    onChanged: onChanged,
    itemBuilder: (context, item, index) => Column(
      children: [
        AdminFieldGrid(
          children: [
            _field(item, 'name', 'Tên', onChanged),
            _field(item, 'korean_name', 'Tên tiếng Hàn', onChanged),
            _field(item, 'tagline', 'Tagline', onChanged),
            _field(item, 'address', 'Vị trí / địa chỉ', onChanged),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _field(
          item,
          'short_description',
          'Mô tả ngắn',
          onChanged,
          maxLines: 3,
          minWords: 25,
          maxWords: 40,
        ),
        const SizedBox(height: AppSpacing.md),
        _field(
          item,
          'long_description',
          'Mô tả chi tiết',
          onChanged,
          maxLines: 6,
          minWords: 70,
          maxWords: 110,
        ),
        const SizedBox(height: AppSpacing.md),
        AdminStringListField(
          label: 'Hoạt động nổi bật',
          values: adminStringList(item['activities']),
          onChanged: (value) {
            item['activities'] = value;
            onChanged();
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AdminStringListField(
          label: 'Danh mục dùng cho bộ lọc',
          values: adminStringList(item['categories']),
          onChanged: (value) {
            item['categories'] = value;
            onChanged();
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _mediaFields(item, onChanged),
        const SizedBox(height: AppSpacing.sm),
        AdminMediaPreview(
          kind: adminText(item, 'media_kind'),
          url: adminText(item, 'media_url'),
        ),
        const SizedBox(height: AppSpacing.md),
        _field(item, 'fun_fact', 'Fun fact', onChanged, maxLines: 3),
        _visibilityToggle(item, onChanged),
      ],
    ),
  );
}

class LocationExperiencesEditor extends StatelessWidget {
  const LocationExperiencesEditor({
    required this.draft,
    required this.onChanged,
    super.key,
  });

  final AdminLocationDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hướng dẫn trải nghiệm chung',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              _field(
                draft.experienceGuide,
                'featured_fact',
                'Fun fact nổi bật',
                onChanged,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.md),
              AdminFieldGrid(
                children: [
                  AdminStringListField(
                    label: 'Điều nên làm',
                    values: adminStringList(draft.experienceGuide['dos']),
                    onChanged: (value) {
                      draft.experienceGuide['dos'] = value;
                      onChanged();
                    },
                  ),
                  AdminStringListField(
                    label: 'Điều không nên làm',
                    values: adminStringList(draft.experienceGuide['donts']),
                    onChanged: (value) {
                      draft.experienceGuide['donts'] = value;
                      onChanged();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      AdminRepeatableSection(
        title: 'Văn hóa / trải nghiệm độc đáo',
        items: draft.experiences,
        itemLabel: 'trải nghiệm',
        minimum: 3,
        maximumGuide: 5,
        createItem: () => {
          'name': '',
          'korean_name': '',
          'short_description': '',
          'long_description': '',
          'origin_meaning': '',
          'recognizable_features': <String>[],
          'related_experience': '',
          'media_kind': 'image',
          'media_url': '',
          'media_credit': '',
          'media_source_url': '',
          'media_alt': '',
          'is_visible': true,
        },
        onChanged: onChanged,
        itemBuilder: (context, item, index) => Column(
          children: [
            AdminFieldGrid(
              children: [
                _field(item, 'name', 'Tên', onChanged),
                _field(item, 'korean_name', 'Tên tiếng Hàn', onChanged),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _field(
              item,
              'short_description',
              'Mô tả ngắn',
              onChanged,
              maxLines: 3,
              minWords: 25,
              maxWords: 40,
            ),
            const SizedBox(height: AppSpacing.md),
            _field(
              item,
              'long_description',
              'Mô tả chi tiết',
              onChanged,
              maxLines: 6,
              minWords: 70,
              maxWords: 120,
            ),
            const SizedBox(height: AppSpacing.md),
            _field(
              item,
              'origin_meaning',
              'Nguồn gốc / ý nghĩa',
              onChanged,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.md),
            AdminFieldGrid(
              children: [
                AdminStringListField(
                  label: 'Đặc điểm dễ nhận biết',
                  values: adminStringList(item['recognizable_features']),
                  onChanged: (value) {
                    item['recognizable_features'] = value;
                    onChanged();
                  },
                ),
                _field(
                  item,
                  'related_experience',
                  'Trải nghiệm thực tế liên quan',
                  onChanged,
                  maxLines: 4,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _mediaFields(item, onChanged),
            const SizedBox(height: AppSpacing.sm),
            AdminMediaPreview(
              kind: adminText(item, 'media_kind'),
              url: adminText(item, 'media_url'),
            ),
            _visibilityToggle(item, onChanged),
          ],
        ),
      ),
    ],
  );
}

class LocationFoodsEditor extends StatelessWidget {
  const LocationFoodsEditor({
    required this.draft,
    required this.onChanged,
    super.key,
  });

  final AdminLocationDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => AdminRepeatableSection(
    title: 'Ẩm thực',
    items: draft.foods,
    itemLabel: 'món ăn',
    minimum: 3,
    maximumGuide: 6,
    createItem: () => {
      'name': '',
      'korean_name': '',
      'short_description': '',
      'long_description': '',
      'ingredients': <String>[],
      'flavors': <String>[],
      'special_feature': '',
      'experience_places': <String>[],
      'image_url': '',
      'image_credit': '',
      'image_source_url': '',
      'image_alt': '',
      'is_visible': true,
    },
    onChanged: onChanged,
    itemBuilder: (context, item, index) => Column(
      children: [
        AdminFieldGrid(
          children: [
            _field(item, 'name', 'Tên món', onChanged),
            _field(item, 'korean_name', 'Tên tiếng Hàn', onChanged),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _field(
          item,
          'short_description',
          'Mô tả ngắn',
          onChanged,
          maxLines: 3,
          minWords: 20,
          maxWords: 30,
        ),
        const SizedBox(height: AppSpacing.md),
        _field(
          item,
          'long_description',
          'Mô tả chi tiết',
          onChanged,
          maxLines: 5,
          minWords: 50,
          maxWords: 80,
        ),
        const SizedBox(height: AppSpacing.md),
        AdminFieldGrid(
          children: [
            AdminStringListField(
              label: 'Nguyên liệu',
              values: adminStringList(item['ingredients']),
              onChanged: (value) {
                item['ingredients'] = value;
                onChanged();
              },
            ),
            AdminStringListField(
              label: 'Hương vị',
              values: adminStringList(item['flavors']),
              onChanged: (value) {
                item['flavors'] = value;
                onChanged();
              },
            ),
            AdminStringListField(
              label: 'Nơi có thể trải nghiệm',
              values: adminStringList(item['experience_places']),
              onChanged: (value) {
                item['experience_places'] = value;
                onChanged();
              },
            ),
            _field(
              item,
              'special_feature',
              'Điểm đặc biệt',
              onChanged,
              maxLines: 4,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AdminFieldGrid(
          children: [
            _field(item, 'image_url', 'URL ảnh', onChanged),
            _field(item, 'image_credit', 'Credit ảnh', onChanged),
            _field(item, 'image_source_url', 'URL nguồn ảnh', onChanged),
            _field(item, 'image_alt', 'Mô tả thay thế ảnh', onChanged),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AdminMediaPreview(kind: 'image', url: adminText(item, 'image_url')),
        _visibilityToggle(item, onChanged),
      ],
    ),
  );
}

class LocationFunFactsEditor extends StatelessWidget {
  const LocationFunFactsEditor({
    required this.draft,
    required this.onChanged,
    super.key,
  });

  final AdminLocationDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => AdminRepeatableSection(
    title: 'Fun Facts',
    items: draft.funFacts,
    itemLabel: 'fact',
    minimum: 4,
    maximumGuide: 6,
    createItem: () => {
      'title': '',
      'fact': '',
      'category': '',
      'icon_name': '',
      'media_kind': 'image',
      'media_url': '',
      'media_credit': '',
      'media_source_url': '',
      'media_alt': '',
      'unlock_after_stage': 1,
      'is_visible': true,
    },
    onChanged: onChanged,
    itemBuilder: (context, item, index) => Column(
      children: [
        AdminFieldGrid(
          children: [
            _field(item, 'title', 'Tiêu đề', onChanged),
            _field(item, 'category', 'Danh mục', onChanged),
            _field(item, 'icon_name', 'Tên icon (không bắt buộc)', onChanged),
            AdminEditorDropdown(
              key: ValueKey('${identityHashCode(item)}-unlock-stage'),
              label: 'Mở khóa sau chặng',
              value: adminText(item, 'unlock_after_stage').isEmpty
                  ? '1'
                  : adminText(item, 'unlock_after_stage'),
              items: const {
                '1': '1. Mở đầu',
                '2': '2. Tổng quan',
                '3': '3. Lịch sử',
                '4': '4. Điểm đến',
                '5': '5. Trải nghiệm',
                '6': '6. Ẩm thực',
                '7': '7. Fun Facts',
              },
              onChanged: (value) {
                item['unlock_after_stage'] = int.parse(value);
                onChanged();
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _field(
          item,
          'fact',
          'Nội dung bất ngờ, dễ nhớ',
          onChanged,
          maxLines: 3,
          minWords: 15,
          maxWords: 35,
        ),
        const SizedBox(height: AppSpacing.md),
        _mediaFields(item, onChanged),
        const SizedBox(height: AppSpacing.sm),
        AdminMediaPreview(
          kind: adminText(item, 'media_kind'),
          url: adminText(item, 'media_url'),
        ),
        _visibilityToggle(item, onChanged),
      ],
    ),
  );
}

Widget _mediaFields(Map<String, dynamic> item, VoidCallback onChanged) {
  return AdminFieldGrid(
    children: [
      AdminEditorDropdown(
        key: ValueKey('${identityHashCode(item)}-media-kind'),
        label: 'Loại media',
        value: adminText(item, 'media_kind'),
        items: const {'image': 'Ảnh', 'youtube': 'YouTube'},
        onChanged: (value) {
          item['media_kind'] = value;
          onChanged();
        },
      ),
      _field(item, 'media_url', 'URL media', onChanged),
      _field(item, 'media_credit', 'Credit media', onChanged),
      _field(item, 'media_source_url', 'URL nguồn media', onChanged),
      _field(item, 'media_alt', 'Mô tả thay thế media', onChanged),
    ],
  );
}

Widget _visibilityToggle(Map<String, dynamic> item, VoidCallback onChanged) =>
    SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: const Text('Hiển thị nội dung này'),
      value: item['is_visible'] != false,
      onChanged: (value) {
        item['is_visible'] = value;
        onChanged();
      },
    );

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

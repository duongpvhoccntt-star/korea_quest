import 'package:flutter/material.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/presentation/widgets/admin_editor_fields.dart';

class LocationOpeningEditor extends StatelessWidget {
  const LocationOpeningEditor({
    required this.draft,
    required this.onChanged,
    super.key,
  });

  final AdminLocationDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final data = draft.overview;
    final mediaKind = adminText(data, 'hook_media_kind');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Chặng 1 · Mở đầu', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Media thu hút đầu Hành trình. Đây không phải Quiz Check-in.',
        ),
        const SizedBox(height: AppSpacing.md),
        AdminFieldGrid(
          children: [
            AdminEditorDropdown(
              label: 'Loại media',
              value: mediaKind,
              items: const {'image': 'Ảnh', 'youtube': 'YouTube'},
              onChanged: (value) {
                data['hook_media_kind'] = value;
                onChanged();
              },
            ),
            _field(
              data,
              'hook_media_url',
              mediaKind == 'image' ? 'URL ảnh' : 'URL YouTube',
              onChanged,
            ),
            _field(data, 'hook_media_credit', 'Credit media', onChanged),
            _field(data, 'hook_media_source_url', 'URL nguồn media', onChanged),
            _field(
              data,
              'hook_media_alt',
              'Mô tả thay thế cho media',
              onChanged,
              maxLines: 2,
            ),
            _field(data, 'hook_title', 'Tagline ngắn', onChanged),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _field(data, 'hook_caption', 'Caption mở đầu', onChanged, maxLines: 3),
        const SizedBox(height: AppSpacing.sm),
        AdminMediaPreview(
          kind: mediaKind,
          url: adminText(data, 'hook_media_url'),
        ),
      ],
    );
  }
}

class LocationOverviewEditor extends StatelessWidget {
  const LocationOverviewEditor({
    required this.draft,
    required this.availableLocations,
    required this.onChanged,
    super.key,
  });

  final AdminLocationDraft draft;
  final List<AdminLocationSummary> availableLocations;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final data = draft.overview;
    final quickFacts = AdminLocationDraft.fromJsonList(data['quick_facts']);
    data['quick_facts'] = quickFacts;
    final prerequisiteItems = <String, String>{
      '': 'Không có — Địa điểm bắt đầu',
      for (final location in availableLocations)
        if (location.locationId != draft.locationId)
          location.locationId: location.name.isEmpty
              ? location.slug
              : location.name,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tổng quan & metadata bản đồ',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        AdminFieldGrid(
          children: [
            AdminEditorTextField(
              label: 'Slug công khai',
              value: draft.slug,
              hint: 'gyeongbokgung',
              onChanged: (value) {
                draft.slug = value.trim().toLowerCase();
                onChanged();
              },
            ),
            _field(data, 'name', 'Tên Địa điểm', onChanged),
            _field(data, 'korean_name', 'Tên tiếng Hàn', onChanged),
            _field(data, 'english_name', 'Tên tiếng Anh', onChanged),
            _field(data, 'location_type', 'Loại Địa điểm', onChanged),
            _field(data, 'address', 'Địa chỉ hiển thị', onChanged),
            _field(data, 'city', 'Thành phố / tỉnh', onChanged),
            _field(data, 'region', 'Vùng dùng cho bộ lọc', onChanged),
            _field(data, 'country', 'Quốc gia', onChanged),
            AdminEditorDropdown(
              label: 'Tình trạng ra mắt',
              value: adminText(data, 'release_status'),
              items: const {
                'coming_soon': 'Sắp ra mắt',
                'released': 'Đã phát hành',
              },
              onChanged: (value) {
                data['release_status'] = value;
                onChanged();
              },
            ),
            _field(
              data,
              'estimated_duration_minutes',
              'Thời lượng khám phá dự kiến (phút)',
              onChanged,
              keyboardType: TextInputType.number,
            ),
            _field(
              data,
              'display_order',
              'Thứ tự hiển thị',
              onChanged,
              keyboardType: TextInputType.number,
            ),
            _field(
              data,
              'latitude',
              'Latitude',
              onChanged,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
            ),
            _field(
              data,
              'longitude',
              'Longitude',
              onChanged,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
            ),
            AdminEditorDropdown(
              label: 'Địa điểm tiên quyết',
              value: adminText(data, 'prerequisite_location_id'),
              items: prerequisiteItems,
              onChanged: (value) {
                data['prerequisite_location_id'] = value;
                onChanged();
              },
            ),
            AdminStringListField(
              label: 'Tag nổi bật',
              values: adminStringList(data['tags']),
              onChanged: (values) {
                data['tags'] = values;
                onChanged();
              },
            ),
            AdminStringListField(
              label: 'Danh mục bản đồ',
              values: adminStringList(data['categories']),
              onChanged: (values) {
                data['categories'] = values;
                onChanged();
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AdminEditorTextField(
          label: 'Mô tả ngắn',
          value: adminText(data, 'short_description'),
          minWords: 20,
          maxWords: 40,
          maxLines: 3,
          onChanged: (value) {
            data['short_description'] = value;
            onChanged();
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AdminEditorTextField(
          label: 'Mô tả chi tiết',
          value: adminText(data, 'long_description'),
          minWords: 80,
          maxWords: 120,
          maxLines: 7,
          onChanged: (value) {
            data['long_description'] = value;
            onChanged();
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Ảnh bìa', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        AdminFieldGrid(
          children: [
            _field(data, 'cover_image_url', 'URL ảnh bìa', onChanged),
            _field(data, 'cover_image_credit', 'Credit ảnh bìa', onChanged),
            _field(
              data,
              'cover_image_source_url',
              'URL nguồn ảnh bìa',
              onChanged,
            ),
            _field(
              data,
              'cover_image_alt',
              'Mô tả thay thế ảnh bìa',
              onChanged,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AdminMediaPreview(
          kind: 'image',
          url: adminText(data, 'cover_image_url'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Thumbnail bản đồ (không bắt buộc)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        AdminFieldGrid(
          children: [
            _field(data, 'thumbnail_url', 'URL thumbnail', onChanged),
            _field(data, 'thumbnail_credit', 'Credit thumbnail', onChanged),
            _field(
              data,
              'thumbnail_source_url',
              'URL nguồn thumbnail',
              onChanged,
            ),
            _field(data, 'thumbnail_alt', 'Mô tả thay thế', onChanged),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Dấu mộc', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        AdminFieldGrid(
          children: [
            _field(data, 'stamp_name', 'Tên Dấu mộc', onChanged),
            _field(
              data,
              'stamp_description',
              'Mô tả Dấu mộc',
              onChanged,
              maxLines: 2,
            ),
            _field(data, 'stamp_image_url', 'URL ảnh Dấu mộc', onChanged),
            _field(data, 'stamp_image_credit', 'Credit ảnh Dấu mộc', onChanged),
            _field(
              data,
              'stamp_image_source_url',
              'URL nguồn ảnh Dấu mộc',
              onChanged,
            ),
            _field(
              data,
              'stamp_image_alt',
              'Mô tả thay thế ảnh Dấu mộc',
              onChanged,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AdminRepeatableSection(
          title: 'Thông tin nhanh',
          items: quickFacts,
          itemLabel: 'thông tin',
          minimum: 3,
          maximumGuide: 5,
          createItem: () => {'label': '', 'value': '', 'is_visible': true},
          onChanged: onChanged,
          itemBuilder: (context, item, index) => Column(
            children: [
              AdminFieldGrid(
                children: [
                  _field(item, 'label', 'Nhãn', onChanged),
                  _field(item, 'value', 'Giá trị', onChanged),
                ],
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hiển thị thông tin này'),
                value: item['is_visible'] != false,
                onChanged: (value) {
                  item['is_visible'] = value;
                  onChanged();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LocationTravelEditor extends StatelessWidget {
  const LocationTravelEditor({
    required this.draft,
    required this.onChanged,
    super.key,
  });

  final AdminLocationDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final data = draft.travel;
    final transportOptions = AdminLocationDraft.fromJsonList(
      data['transport_options'],
    );
    final visitorNotes = AdminLocationDraft.fromJsonList(data['visitor_notes']);
    data['transport_options'] = transportOptions;
    data['visitor_notes'] = visitorNotes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Thông tin du lịch thực tế',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        AdminFieldGrid(
          children: [
            _field(data, 'opening_hours', 'Giờ mở cửa', onChanged, maxLines: 3),
            _field(data, 'ticket_price', 'Giá vé', onChanged, maxLines: 3),
            _field(
              data,
              'recommended_duration',
              'Thời gian tham quan gợi ý',
              onChanged,
            ),
            _field(
              data,
              'last_verified_at',
              'Ngày kiểm chứng (YYYY-MM-DD)',
              onChanged,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _field(
          data,
          'best_time_to_visit',
          'Thời điểm đẹp nhất',
          onChanged,
          maxLines: 4,
        ),
        const SizedBox(height: AppSpacing.md),
        _field(
          data,
          'accessibility_info',
          'Khả năng tiếp cận & tiện ích',
          onChanged,
          maxLines: 5,
        ),
        const SizedBox(height: AppSpacing.md),
        _field(data, 'official_source_url', 'URL nguồn chính thức', onChanged),
        const SizedBox(height: AppSpacing.lg),
        AdminRepeatableSection(
          title: 'Phương án di chuyển',
          items: transportOptions,
          itemLabel: 'phương án',
          minimum: 1,
          maximumGuide: 6,
          createItem: () => {
            'mode': 'metro',
            'title': '',
            'instructions': '',
            'tip': '',
            'is_recommended': false,
            'is_visible': true,
          },
          onChanged: onChanged,
          itemBuilder: (context, item, index) => Column(
            children: [
              AdminFieldGrid(
                children: [
                  AdminEditorDropdown(
                    label: 'Phương tiện',
                    value: adminText(item, 'mode'),
                    items: const {
                      'metro': 'Metro',
                      'bus': 'Xe buýt',
                      'taxi': 'Taxi',
                      'walk': 'Đi bộ',
                      'other': 'Khác',
                    },
                    onChanged: (value) {
                      item['mode'] = value;
                      onChanged();
                    },
                  ),
                  _field(item, 'title', 'Tiêu đề', onChanged),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _field(
                item,
                'instructions',
                'Hướng dẫn chi tiết',
                onChanged,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.sm),
              _field(item, 'tip', 'Mẹo di chuyển', onChanged, maxLines: 2),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Gợi ý tốt nhất'),
                value: item['is_recommended'] == true,
                onChanged: (value) {
                  item['is_recommended'] = value;
                  onChanged();
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hiển thị phương án'),
                value: item['is_visible'] != false,
                onChanged: (value) {
                  item['is_visible'] = value;
                  onChanged();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AdminRepeatableSection(
          title: 'Lưu ý khi tham quan',
          items: visitorNotes,
          itemLabel: 'lưu ý',
          minimum: 1,
          maximumGuide: 8,
          createItem: () => {'content': '', 'is_visible': true},
          onChanged: onChanged,
          itemBuilder: (context, item, index) => Column(
            children: [
              _field(item, 'content', 'Nội dung lưu ý', onChanged, maxLines: 2),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hiển thị lưu ý'),
                value: item['is_visible'] != false,
                onChanged: (value) {
                  item['is_visible'] = value;
                  onChanged();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LocationReviewEditor extends StatelessWidget {
  const LocationReviewEditor({
    required this.draft,
    required this.validationErrors,
    required this.onChanged,
    super.key,
  });

  final AdminLocationDraft draft;
  final List<String> validationErrors;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Nguồn, xem trước & Xuất bản',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        _PreviewSummary(draft: draft),
        const SizedBox(height: AppSpacing.lg),
        AdminRepeatableSection(
          title: 'Nguồn tham khảo',
          items: draft.sources,
          itemLabel: 'nguồn',
          minimum: 1,
          createItem: () => {
            'title': '',
            'publisher': '',
            'url': '',
            'accessed_at': '',
            'verification_status': 'unverified',
            'verified_at': '',
            'is_official': false,
            'is_visible': true,
          },
          onChanged: onChanged,
          itemBuilder: (context, item, index) => Column(
            children: [
              AdminFieldGrid(
                children: [
                  _field(item, 'title', 'Tên nguồn', onChanged),
                  _field(
                    item,
                    'publisher',
                    'Nhà xuất bản / tổ chức',
                    onChanged,
                  ),
                  _field(item, 'url', 'URL nguồn', onChanged),
                  _field(
                    item,
                    'accessed_at',
                    'Ngày truy cập (YYYY-MM-DD)',
                    onChanged,
                  ),
                  AdminEditorDropdown(
                    label: 'Trạng thái kiểm chứng',
                    value: adminText(item, 'verification_status'),
                    items: const {
                      'unverified': 'Chưa kiểm chứng',
                      'verified': 'Đã kiểm chứng',
                      'needs_review': 'Cần kiểm tra lại',
                    },
                    onChanged: (value) {
                      item['verification_status'] = value;
                      onChanged();
                    },
                  ),
                  _field(
                    item,
                    'verified_at',
                    'Ngày kiểm chứng (YYYY-MM-DD)',
                    onChanged,
                  ),
                ],
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Nguồn chính thức'),
                value: item['is_official'] == true,
                onChanged: (value) {
                  item['is_official'] = value;
                  onChanged();
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hiển thị nguồn này'),
                value: item['is_visible'] != false,
                onChanged: (value) {
                  item['is_visible'] = value;
                  onChanged();
                },
              ),
            ],
          ),
        ),
        if (validationErrors.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chưa thể Xuất bản',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: AppColors.danger),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  for (final error in validationErrors)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text('• $error'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PreviewSummary extends StatelessWidget {
  const _PreviewSummary({required this.draft});

  final AdminLocationDraft draft;

  @override
  Widget build(BuildContext context) {
    int visibleCount(List<Map<String, dynamic>> items) =>
        items.where((item) => item['is_visible'] != false).length;
    final finalQuiz = visibleCount(draft.quiz);
    final counts = <(String, int, int)>[
      ('Mốc lịch sử', visibleCount(draft.history), 4),
      ('Điểm nổi bật', visibleCount(draft.highlights), 4),
      ('Trải nghiệm', visibleCount(draft.experiences), 3),
      ('Món ăn', visibleCount(draft.foods), 3),
      ('Fun facts', visibleCount(draft.funFacts), 4),
      ('Quiz tổng kết', finalQuiz, 10),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              adminText(draft.overview, 'name').isEmpty
                  ? 'Địa điểm chưa đặt tên'
                  : adminText(draft.overview, 'name'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text('/${draft.slug} · phiên bản ${draft.versionNumber}'),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final count in counts)
                  Chip(
                    avatar: Icon(
                      count.$2 >= count.$3
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_rounded,
                      color: count.$2 >= count.$3
                          ? AppColors.green
                          : AppColors.coralDark,
                    ),
                    label: Text(
                      count.$1 == 'Quiz tổng kết'
                          ? '${count.$1}: ${count.$2}/20 (tối thiểu 10)'
                          : '${count.$1}: ${count.$2}/${count.$3}+',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

AdminEditorTextField _field(
  Map<String, dynamic> data,
  String key,
  String label,
  VoidCallback onChanged, {
  int maxLines = 1,
  TextInputType? keyboardType,
}) {
  return AdminEditorTextField(
    key: ValueKey('${identityHashCode(data)}-$key'),
    label: label,
    value: adminText(data, key),
    maxLines: maxLines,
    keyboardType: keyboardType,
    onChanged: (value) {
      data[key] = value;
      onChanged();
    },
  );
}

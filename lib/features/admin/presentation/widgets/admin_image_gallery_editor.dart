import 'package:flutter/material.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/presentation/widgets/admin_editor_fields.dart';
import 'package:korea_quest/features/admin/presentation/widgets/admin_image_upload_button.dart';

class AdminImageGalleryEditor extends StatelessWidget {
  const AdminImageGalleryEditor({
    required this.draft,
    required this.item,
    required this.legacyPrefix,
    required this.onChanged,
    super.key,
  });

  final AdminLocationDraft draft;
  final Map<String, dynamic> item;
  final String legacyPrefix;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final images = adminImageGallery(item, legacyPrefix: legacyPrefix);
    return AdminRepeatableSection(
      title: 'Thư viện ảnh',
      items: images,
      itemLabel: 'ảnh',
      minimum: 0,
      maximum: adminImageGalleryLimit,
      createItem: emptyAdminGalleryImage,
      onChanged: onChanged,
      itemBuilder: (context, image, index) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminFieldGrid(
            children: [
              _field(image, 'url', 'URL ảnh', onChanged),
              _field(image, 'credit', 'Credit ảnh', onChanged),
              _field(image, 'source_url', 'URL nguồn ảnh', onChanged),
              _field(
                image,
                'alt',
                'Mô tả thay thế ảnh',
                onChanged,
                maxLines: 2,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AdminImageUploadButton(
            draft: draft,
            onUploaded: (url) {
              applyUploadedGalleryImage(image, url);
              onChanged();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          AdminMediaPreview(kind: 'image', url: adminText(image, 'url')),
        ],
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
}) => AdminEditorTextField(
  key: ValueKey('${identityHashCode(data)}-$key'),
  label: label,
  value: adminText(data, key),
  maxLines: maxLines,
  onChanged: (value) {
    data[key] = value;
    onChanged();
  },
);

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/app/app_config.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/presentation/providers/admin_providers.dart';

class AdminImageUploadButton extends ConsumerStatefulWidget {
  const AdminImageUploadButton({
    required this.draft,
    required this.onUploaded,
    super.key,
  });

  final AdminLocationDraft draft;
  final ValueChanged<String> onUploaded;

  @override
  ConsumerState<AdminImageUploadButton> createState() =>
      _AdminImageUploadButtonState();
}

class _AdminImageUploadButtonState
    extends ConsumerState<AdminImageUploadButton> {
  static const _maxBytes = 5 * 1024 * 1024;
  var _isUploading = false;

  Future<void> _pickAndUpload() async {
    if (!widget.draft.isPersisted) {
      _showMessage('Hãy lưu Bản nháp trước khi tải ảnh.');
      return;
    }
    if (!AppConfig.hasSupabaseConfiguration) {
      _showMessage('Tải ảnh chỉ khả dụng khi Admin được kết nối Supabase.');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );
    if (result == null) return;

    final file = result.files.single;
    final bytes = file.bytes;
    final contentType = _contentType(file.extension);
    if (bytes == null || contentType == null) {
      _showMessage('Không thể đọc ảnh đã chọn.');
      return;
    }
    if (bytes.lengthInBytes > _maxBytes) {
      _showMessage('Ảnh phải có dung lượng tối đa 5 MiB.');
      return;
    }

    setState(() => _isUploading = true);
    try {
      final uploaded = await ref
          .read(adminRepositoryProvider)
          .uploadContentImage(
            locationId: widget.draft.locationId!,
            revisionId: widget.draft.revisionId!,
            filename: file.name,
            bytes: bytes,
            contentType: contentType,
          );
      widget.onUploaded(uploaded.publicUrl);
      _showMessage('Đã tải ảnh. Hãy lưu Bản nháp để ghi URL vào nội dung.');
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  String? _contentType(String? extension) => switch (extension?.toLowerCase()) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => null,
  };

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      OutlinedButton.icon(
        onPressed: _isUploading ? null : _pickAndUpload,
        icon: _isUploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.upload_file_rounded),
        label: Text(_isUploading ? 'Đang tải ảnh...' : 'Tải ảnh từ máy'),
      ),
      const SizedBox(width: AppSpacing.sm),
      const Expanded(
        child: Text(
          'JPEG, PNG hoặc WebP · tối đa 5 MiB',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ),
    ],
  );
}

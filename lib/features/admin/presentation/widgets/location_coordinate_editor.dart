import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/domain/admin_repository.dart';
import 'package:korea_quest/features/admin/presentation/providers/admin_providers.dart';
import 'package:korea_quest/features/admin/presentation/widgets/admin_editor_fields.dart';
import 'package:korea_quest/shared/widgets/korea_map.dart';

class LocationCoordinateEditor extends ConsumerStatefulWidget {
  const LocationCoordinateEditor({
    required this.draft,
    required this.onChanged,
    super.key,
  });

  final AdminLocationDraft draft;
  final VoidCallback onChanged;

  @override
  ConsumerState<LocationCoordinateEditor> createState() =>
      _LocationCoordinateEditorState();
}

class _LocationCoordinateEditorState
    extends ConsumerState<LocationCoordinateEditor> {
  List<LocationCoordinateSuggestion>? _suggestions;
  LocationCoordinateSuggestion? _preview;
  String? _message;
  var _loading = false;

  bool get _hasSearchMetadata {
    final data = widget.draft.overview;
    return [
      widget.draft.slug,
      data['name'],
      data['korean_name'],
      data['english_name'],
      data['address'],
      data['city'],
      data['region'],
      data['country'],
    ].any((value) => value?.toString().trim().isNotEmpty ?? false);
  }

  Future<void> _suggest() async {
    if (!_hasSearchMetadata) {
      setState(() {
        _suggestions = const [];
        _preview = null;
        _message = 'Nhập tên hoặc địa chỉ trước khi yêu cầu gợi ý vị trí.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
      _preview = null;
    });
    try {
      final suggestions = await ref
          .read(adminRepositoryProvider)
          .suggestLocationCoordinates(widget.draft);
      if (!mounted) return;
      setState(() {
        _suggestions = suggestions.take(5).toList(growable: false);
        _message = suggestions.isEmpty
            ? 'Không tìm thấy vị trí phù hợp. Bạn vẫn có thể chọn trên bản đồ hoặc nhập tọa độ thủ công.'
            : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = const [];
        _message =
            'Không thể lấy gợi ý vị trí lúc này. Hãy thử lại hoặc chọn vị trí thủ công.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _previewSuggestion(LocationCoordinateSuggestion suggestion) {
    setState(() => _preview = suggestion);
  }

  void _applySuggestion(LocationCoordinateSuggestion suggestion) {
    final data = widget.draft.overview;
    data['latitude'] = suggestion.latitude.toStringAsFixed(6);
    data['longitude'] = suggestion.longitude.toStringAsFixed(6);
    widget.onChanged();
    setState(() {
      _preview = null;
      _message =
          'Đã áp dụng tọa độ vào Bản nháp. Hãy lưu Bản nháp khi bạn đã kiểm tra xong.';
    });
  }

  void _setCoordinates(double latitude, double longitude) {
    final data = widget.draft.overview;
    data['latitude'] = latitude.toStringAsFixed(6);
    data['longitude'] = longitude.toStringAsFixed(6);
    widget.onChanged();
    if (_preview != null) setState(() => _preview = null);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.draft.overview;
    final latitude = double.tryParse(adminText(data, 'latitude'));
    final longitude = double.tryParse(adminText(data, 'longitude'));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.skyLight.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Vị trí trên bản đồ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Gemini chỉ hỗ trợ chuẩn hóa truy vấn. Hãy xem trước kết quả và tự áp dụng tọa độ vào Bản nháp.',
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: PrimaryButton(
                label: 'AI gợi ý vị trí',
                icon: Icons.auto_awesome_outlined,
                isLoading: _loading,
                onPressed: _loading ? null : _suggest,
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _message!,
                style: const TextStyle(color: AppColors.stitchMuted),
              ),
            ],
            if (_suggestions != null && _suggestions!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Ứng viên cần duyệt',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final suggestion in _suggestions!) ...[
                _CoordinateSuggestionCard(
                  suggestion: suggestion,
                  isPreviewed: _preview == suggestion,
                  onPreview: () => _previewSuggestion(suggestion),
                  onApply: () => _applySuggestion(suggestion),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
            if (_preview != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Đang xem trước “${_preview!.label.isEmpty ? 'Ứng viên bản đồ' : _preview!.label}”. Ghim vàng chưa được lưu.',
                style: const TextStyle(color: AppColors.locationClay),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            LocationCoordinateMap(
              latitude: latitude,
              longitude: longitude,
              previewLatitude: _preview?.latitude,
              previewLongitude: _preview?.longitude,
              onChanged: _setCoordinates,
              resetLabel: 'Xem toàn Hàn Quốc',
              unavailableBuilder: (context) => const Text(
                'Bản đồ chưa khả dụng. Vui lòng nhập tọa độ thủ công.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoordinateSuggestionCard extends StatelessWidget {
  const _CoordinateSuggestionCard({
    required this.suggestion,
    required this.isPreviewed,
    required this.onPreview,
    required this.onApply,
  });

  final LocationCoordinateSuggestion suggestion;
  final bool isPreviewed;
  final VoidCallback onPreview;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final confidence = (suggestion.confidence.clamp(0, 1) * 100)
        .toStringAsFixed(0);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: isPreviewed ? AppColors.koreanBlue : AppColors.borderSoft,
          width: isPreviewed ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              suggestion.label.isEmpty ? 'Ứng viên bản đồ' : suggestion.label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (suggestion.address.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(suggestion.address),
            ],
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${suggestion.source} · Độ tin cậy $confidence%',
              style: const TextStyle(
                color: AppColors.stitchMuted,
                fontSize: 12,
              ),
            ),
            if (suggestion.reason.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                suggestion.reason,
                style: const TextStyle(
                  color: AppColors.stitchMuted,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                SecondaryButton(
                  label: isPreviewed ? 'Đang xem trước' : 'Xem trước',
                  icon: Icons.map_outlined,
                  onPressed: onPreview,
                ),
                PrimaryButton(
                  label: 'Áp dụng',
                  icon: Icons.check_rounded,
                  onPressed: onApply,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

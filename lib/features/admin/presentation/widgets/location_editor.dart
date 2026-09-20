import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/domain/admin_repository.dart';
import 'package:korea_quest/features/admin/presentation/providers/admin_providers.dart';
import 'package:korea_quest/features/admin/presentation/widgets/location_editor_content.dart';
import 'package:korea_quest/features/admin/presentation/widgets/location_editor_overview.dart';
import 'package:korea_quest/features/admin/presentation/widgets/location_editor_quiz.dart';

class LocationEditor extends ConsumerStatefulWidget {
  const LocationEditor({required this.draft, required this.onClose, super.key});

  final AdminLocationDraft draft;
  final VoidCallback onClose;

  @override
  ConsumerState<LocationEditor> createState() => _LocationEditorState();
}

class _LocationEditorState extends ConsumerState<LocationEditor> {
  static const _steps = [
    'Mở đầu',
    'Tổng quan',
    'Lịch sử',
    'Điểm đến',
    'Trải nghiệm',
    'Ẩm thực',
    'Fun Facts',
    'Quiz tổng kết',
    'Du lịch',
    'Kiểm tra & Xuất bản',
  ];

  late AdminLocationDraft _draft;
  var _currentStep = 0;
  final _dirtySteps = <int>{};
  var _saving = false;
  var _validationErrors = <String>[];

  bool get _dirty => _dirtySteps.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
  }

  void _markDirty() {
    setState(() {
      _dirtySteps.add(_currentStep);
      _validationErrors = [];
    });
  }

  Future<void> _selectStep(int nextStep) async {
    if (nextStep == _currentStep || _saving) return;
    setState(() {
      _currentStep = nextStep;
      _validationErrors = [];
    });
  }

  Future<void> _requestClose() async {
    if (_dirty) {
      final discard = await ConfirmationDialog.show(
        context,
        title: 'Đóng editor?',
        message: 'Các thay đổi trong bước hiện tại chưa được lưu vào database.',
        confirmLabel: 'Đóng và bỏ thay đổi',
      );
      if (!discard || !mounted) return;
    }
    widget.onClose();
  }

  Future<bool> _saveCurrent({bool advance = false}) async {
    if (_saving) return false;
    setState(() => _saving = true);
    try {
      final repository = ref.read(adminRepositoryProvider);
      final wasPersisted = await _ensurePersisted(repository);
      if (wasPersisted || _currentStep > 1) {
        await _persistStep(repository, _currentStep);
      }
      ref.invalidate(adminLocationsProvider);
      if (!mounted) return true;
      setState(() {
        _dirtySteps.remove(_currentStep);
        if (!wasPersisted) {
          _dirtySteps
            ..remove(0)
            ..remove(1);
        }
        if (advance && _currentStep < _steps.length - 1) _currentStep++;
      });
      AppToast.show(context, 'Đã lưu Bản nháp.');
      return true;
    } catch (error) {
      if (mounted) AppToast.show(context, error.toString());
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _ensurePersisted(AdminRepository repository) async {
    if (_draft.isPersisted) return true;
    final persisted = await repository.createDraft(_draft);
    _draft
      ..locationId = persisted.locationId
      ..revisionId = persisted.revisionId
      ..status = persisted.status
      ..versionNumber = persisted.versionNumber
      ..lockVersion = persisted.lockVersion;
    return false;
  }

  Future<void> _persistStep(AdminRepository repository, int step) async {
    if (step <= 1) {
      _draft.lockVersion = await repository.saveOverview(_draft);
    } else if (step == 4) {
      _draft.lockVersion = await repository.saveSection(
        draft: _draft,
        sectionName: 'experiences',
        items: _draft.experiences,
      );
      _draft.lockVersion = await repository.saveExperienceGuide(_draft);
    } else if (step == 8) {
      _draft.lockVersion = await repository.saveTravel(_draft);
    } else {
      final (sectionName, items) = switch (step) {
        2 => ('history', _draft.history),
        3 => ('highlights', _draft.highlights),
        5 => ('foods', _draft.foods),
        6 => ('fun_facts', _draft.funFacts),
        7 => ('quiz', _draft.quiz),
        _ => ('sources', _draft.sources),
      };
      _draft.lockVersion = await repository.saveSection(
        draft: _draft,
        sectionName: sectionName,
        items: items,
      );
    }
  }

  Future<bool> _saveAllDirty() async {
    if (_saving || !_dirty) return !_dirty;
    setState(() => _saving = true);
    try {
      final repository = ref.read(adminRepositoryProvider);
      final wasPersisted = await _ensurePersisted(repository);
      final steps = _dirtySteps.map((step) => step <= 1 ? 1 : step).toSet()
        ..removeWhere((step) => !wasPersisted && step == 1);
      for (final step in steps.toList()..sort()) {
        await _persistStep(repository, step);
      }
      ref.invalidate(adminLocationsProvider);
      if (!mounted) return true;
      setState(() => _dirtySteps.clear());
      AppToast.show(context, 'Đã lưu tất cả thay đổi vào Bản nháp.');
      return true;
    } catch (error) {
      if (mounted) AppToast.show(context, error.toString());
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<List<String>?> _validate() async {
    if (!_draft.isPersisted) {
      AppToast.show(context, 'Hãy lưu Bản nháp trước khi kiểm tra.');
      return null;
    }
    if (_dirty && !await _saveAllDirty()) return null;
    setState(() => _saving = true);
    try {
      final errors = await ref
          .read(adminRepositoryProvider)
          .validateDraft(_draft);
      if (!mounted) return errors;
      setState(() => _validationErrors = errors);
      AppToast.show(
        context,
        errors.isEmpty
            ? 'Bản nháp đã sẵn sàng để Xuất bản.'
            : 'Còn ${errors.length} lỗi cần xử lý.',
      );
      return errors;
    } catch (error) {
      if (mounted) AppToast.show(context, error.toString());
      return null;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _publish() async {
    final errors = await _validate();
    if (!mounted || errors == null || errors.isNotEmpty) return;
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Xuất bản Địa điểm?',
      message:
          'Phiên bản này sẽ thay thế nội dung công khai hiện tại. Bản cũ được lưu trữ để bảo toàn lịch sử.',
      confirmLabel: 'Xuất bản',
    );
    if (!confirmed || !mounted) return;
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).publish(_draft);
      ref.invalidate(adminLocationsProvider);
      if (!mounted) return;
      AppToast.show(context, 'Đã Xuất bản Địa điểm.');
      widget.onClose();
    } catch (error) {
      if (mounted) AppToast.show(context, error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableLocations =
        ref.watch(adminLocationsProvider).value ?? const [];
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestClose();
      },
      child: ResponsiveContent(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _EditorHeader(
                draft: _draft,
                dirty: _dirty,
                onClose: _saving ? null : _requestClose,
              ),
              const SizedBox(height: AppSpacing.md),
              _StepNavigation(
                steps: _steps,
                currentStep: _currentStep,
                onSelected: _selectStep,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_dirty)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: _UnsavedNotice(),
                ),
              _buildStep(availableLocations),
              const SizedBox(height: AppSpacing.xl),
              _EditorActions(
                currentStep: _currentStep,
                lastStep: _steps.length - 1,
                saving: _saving,
                canGoBack: _currentStep > 0,
                onBack: () => _selectStep(_currentStep - 1),
                onSave: () => _saveCurrent(advance: true),
                onValidate: _validate,
                onPublish: _publish,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(List<AdminLocationSummary> availableLocations) {
    return switch (_currentStep) {
      0 => LocationOpeningEditor(draft: _draft, onChanged: _markDirty),
      1 => LocationOverviewEditor(
        draft: _draft,
        availableLocations: availableLocations,
        onChanged: _markDirty,
      ),
      2 => LocationHistoryEditor(draft: _draft, onChanged: _markDirty),
      3 => LocationHighlightsEditor(draft: _draft, onChanged: _markDirty),
      4 => LocationExperiencesEditor(draft: _draft, onChanged: _markDirty),
      5 => LocationFoodsEditor(draft: _draft, onChanged: _markDirty),
      6 => LocationFunFactsEditor(draft: _draft, onChanged: _markDirty),
      7 => LocationQuizEditor(draft: _draft, onChanged: _markDirty),
      8 => LocationTravelEditor(draft: _draft, onChanged: _markDirty),
      _ => LocationReviewEditor(
        draft: _draft,
        validationErrors: _validationErrors,
        onChanged: _markDirty,
      ),
    };
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({
    required this.draft,
    required this.dirty,
    required this.onClose,
  });

  final AdminLocationDraft draft;
  final bool dirty;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: 'Quay lại danh sách',
        onPressed: onClose,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              adminName(draft),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Bản nháp v${draft.versionNumber}'
              '${draft.slug.isEmpty ? '' : ' · /${draft.slug}'}'
              '${dirty ? ' · chưa lưu' : ''}',
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    ],
  );
}

class _StepNavigation extends StatelessWidget {
  const _StepNavigation({
    required this.steps,
    required this.currentStep,
    required this.onSelected,
  });

  final List<String> steps;
  final int currentStep;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.xs,
    runSpacing: AppSpacing.xs,
    children: [
      for (var index = 0; index < steps.length; index++)
        ChoiceChip(
          label: Text('${index + 1}. ${steps[index]}'),
          selected: index == currentStep,
          onSelected: (_) => onSelected(index),
        ),
    ],
  );
}

class _UnsavedNotice extends StatelessWidget {
  const _UnsavedNotice();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.edit_note_rounded, color: AppColors.coralDark),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text('Bước hiện tại có thay đổi chưa lưu vào database.'),
          ),
        ],
      ),
    ),
  );
}

class _EditorActions extends StatelessWidget {
  const _EditorActions({
    required this.currentStep,
    required this.lastStep,
    required this.saving,
    required this.canGoBack,
    required this.onBack,
    required this.onSave,
    required this.onValidate,
    required this.onPublish,
  });

  final int currentStep;
  final int lastStep;
  final bool saving;
  final bool canGoBack;
  final VoidCallback onBack;
  final VoidCallback onSave;
  final VoidCallback onValidate;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    alignment: WrapAlignment.end,
    children: [
      if (canGoBack)
        SecondaryButton(
          label: 'Bước trước',
          icon: Icons.arrow_back_rounded,
          onPressed: saving ? null : onBack,
        ),
      if (currentStep < lastStep)
        PrimaryButton(
          label: 'Lưu nháp & tiếp tục',
          icon: Icons.save_outlined,
          isLoading: saving,
          onPressed: onSave,
        )
      else ...[
        SecondaryButton(
          label: 'Kiểm tra điều kiện',
          icon: Icons.fact_check_outlined,
          onPressed: saving ? null : onValidate,
        ),
        PrimaryButton(
          label: 'Xuất bản',
          icon: Icons.publish_rounded,
          isLoading: saving,
          onPressed: onPublish,
        ),
      ],
    ],
  );
}

String adminName(AdminLocationDraft draft) {
  final name = draft.overview['name']?.toString().trim() ?? '';
  return name.isEmpty ? 'Địa điểm mới' : name;
}

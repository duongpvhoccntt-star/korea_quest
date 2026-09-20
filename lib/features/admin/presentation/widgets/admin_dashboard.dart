import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/presentation/providers/admin_providers.dart';
import 'package:korea_quest/features/admin/presentation/widgets/game_config_admin.dart';
import 'package:korea_quest/features/admin/presentation/widgets/location_editor.dart';

enum _AdminArea { locations, levels, achievements, challenges }

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  AdminLocationDraft? _editingDraft;
  bool _isOpening = false;
  _AdminArea _area = _AdminArea.locations;

  Future<void> _open(AdminLocationSummary summary) async {
    setState(() => _isOpening = true);
    try {
      final draft = await ref
          .read(adminRepositoryProvider)
          .openDraft(summary.locationId);
      if (mounted) setState(() => _editingDraft = draft);
    } catch (error) {
      if (mounted) AppToast.show(context, error.toString());
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  Future<void> _archive(AdminLocationSummary summary) async {
    final name = summary.name.isEmpty ? summary.slug : summary.name;
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Lưu trữ $name?',
      message:
          'Địa điểm sẽ được rút khỏi danh mục công khai. Dữ liệu không bị xóa.',
      confirmLabel: 'Lưu trữ',
    );
    if (!confirmed) return;
    try {
      await ref.read(adminRepositoryProvider).archive(summary.locationId);
      ref.invalidate(adminLocationsProvider);
    } catch (error) {
      if (mounted) AppToast.show(context, error.toString());
    }
  }

  void _closeEditor() {
    setState(() => _editingDraft = null);
    ref.invalidate(adminLocationsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final editingDraft = _editingDraft;
    if (editingDraft != null) {
      return LocationEditor(draft: editingDraft, onClose: _closeEditor);
    }
    if (_isOpening) {
      return const LoadingIndicator(label: 'Đang tạo hoặc mở bản nháp…');
    }

    return ResponsiveContent(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AdminHero(
              selected: _area,
              onSelected: (value) => setState(() => _area = value),
            ),
            const SizedBox(height: AppSpacing.xl),
            switch (_area) {
              _AdminArea.locations => _LocationsPanel(
                onOpen: _open,
                onArchive: _archive,
                onCreate: () =>
                    setState(() => _editingDraft = AdminLocationDraft()),
              ),
              _AdminArea.levels => const GameConfigAdmin(
                section: GameConfigSection.levels,
              ),
              _AdminArea.achievements => const GameConfigAdmin(
                section: GameConfigSection.achievements,
              ),
              _AdminArea.challenges => const GameConfigAdmin(
                section: GameConfigSection.challenges,
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _AdminHero extends StatelessWidget {
  const _AdminHero({required this.selected, required this.onSelected});

  final _AdminArea selected;
  final ValueChanged<_AdminArea> onSelected;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.navy,
      borderRadius: BorderRadius.circular(AppRadius.large),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trung tâm nội dung KoreaQuest',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.paper),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Biên tập hành trình và cấu hình cơ chế trò chơi. Dữ liệu cá nhân của Nhà thám hiểm không thể sửa tại đây.',
            style: TextStyle(color: AppColors.creamDark),
          ),
          const SizedBox(height: AppSpacing.lg),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<_AdminArea>(
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.paper,
                selectedForegroundColor: AppColors.navy,
                foregroundColor: AppColors.paper,
                side: const BorderSide(color: AppColors.creamDark),
              ),
              segments: const [
                ButtonSegment(
                  value: _AdminArea.locations,
                  icon: Icon(Icons.place_outlined),
                  label: Text('Địa điểm'),
                ),
                ButtonSegment(
                  value: _AdminArea.levels,
                  icon: Icon(Icons.trending_up_rounded),
                  label: Text('Cấp độ'),
                ),
                ButtonSegment(
                  value: _AdminArea.achievements,
                  icon: Icon(Icons.workspace_premium_outlined),
                  label: Text('Huy hiệu'),
                ),
                ButtonSegment(
                  value: _AdminArea.challenges,
                  icon: Icon(Icons.flag_outlined),
                  label: Text('Thử thách'),
                ),
              ],
              selected: {selected},
              onSelectionChanged: (value) => onSelected(value.first),
            ),
          ),
        ],
      ),
    ),
  );
}

class _LocationsPanel extends ConsumerWidget {
  const _LocationsPanel({
    required this.onOpen,
    required this.onArchive,
    required this.onCreate,
  });

  final ValueChanged<AdminLocationSummary> onOpen;
  final ValueChanged<AdminLocationSummary> onArchive;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(adminLocationsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Địa điểm',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Quản lý bản nháp, nội dung đã xuất bản và lưu trữ.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            PrimaryButton(
              label: 'Tạo địa điểm',
              icon: Icons.add_location_alt_outlined,
              onPressed: onCreate,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        locations.when(
          loading: () => const LoadingIndicator(),
          error: (error, _) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(adminLocationsProvider),
          ),
          data: (items) => items.isEmpty
              ? const _EmptyLocations()
              : _LocationList(
                  items: items,
                  onEdit: onOpen,
                  onArchive: onArchive,
                ),
        ),
      ],
    );
  }
}

class _EmptyLocations extends StatelessWidget {
  const _EmptyLocations();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Text(
        'Database chưa có địa điểm. Chọn “Tạo địa điểm” để bắt đầu.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _LocationList extends StatelessWidget {
  const _LocationList({
    required this.items,
    required this.onEdit,
    required this.onArchive,
  });

  final List<AdminLocationSummary> items;
  final ValueChanged<AdminLocationSummary> onEdit;
  final ValueChanged<AdminLocationSummary> onArchive;

  @override
  Widget build(BuildContext context) => ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: items.length,
    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
    itemBuilder: (context, index) {
      final item = items[index];
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 420,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.isEmpty ? 'Bản nháp chưa đặt tên' : item.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${item.koreanName} · /${item.slug} · v${item.versionNumber}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    Text(
                      'Cập nhật ${DateFormat('dd/MM/yyyy HH:mm').format(item.updatedAt.toLocal())}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _StatusChip(status: item.status),
              SecondaryButton(
                label: item.status == AdminRevisionStatus.draft
                    ? 'Tiếp tục sửa'
                    : 'Tạo bản chỉnh sửa',
                icon: Icons.edit_outlined,
                onPressed: () => onEdit(item),
              ),
              if (item.status == AdminRevisionStatus.published)
                OutlinedButton.icon(
                  onPressed: () => onArchive(item),
                  icon: const Icon(Icons.archive_outlined),
                  label: const Text('Lưu trữ'),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final AdminRevisionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      AdminRevisionStatus.draft => ('Bản nháp', AppColors.gold),
      AdminRevisionStatus.published => ('Đã xuất bản', AppColors.green),
      AdminRevisionStatus.archived => ('Đã lưu trữ', AppColors.disabled),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(label, style: TextStyle(color: color)),
      ),
    );
  }
}

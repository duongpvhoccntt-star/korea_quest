import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/progress_components.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';
import 'package:korea_quest/shared/widgets/module_page.dart';

class LocationDetailPage extends ConsumerWidget {
  const LocationDetailPage({required this.locationId, super.key});

  final String locationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider(locationId));
    return location.when(
      loading: LoadingIndicator.new,
      error: (error, stack) => ErrorState(message: 'Không thể tải địa điểm.'),
      data: (item) {
        if (item == null) {
          return EmptyState(
            title: 'Không tìm thấy địa điểm',
            message: 'Mã địa điểm không tồn tại trong dữ liệu mock.',
            onAction: () => context.go('/explore'),
          );
        }
        return ModulePage(
          eyebrow: '${item.city} · ${item.koreanName}',
          title: item.name,
          description: item.description,
          actionLabel: 'Bắt đầu hành trình',
          onAction: () => context.go('/journey/${item.id}'),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusChip(status: item.status),
                  Text('Phần thưởng tối đa: ${item.rewardXp} XP'),
                  const Text('3 chặng · Check-in · Văn hóa · Từ vựng'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

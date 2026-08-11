import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';
import 'package:korea_quest/shared/widgets/module_page.dart';

class JourneyPage extends ConsumerWidget {
  const JourneyPage({required this.locationId, super.key, this.stage});

  final String locationId;
  final JourneyStage? stage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationProvider(locationId));
    final missionsAsync = ref.watch(missionsProvider(locationId));
    if (locationAsync.isLoading || missionsAsync.isLoading) {
      return const LoadingIndicator();
    }
    if (locationAsync.hasError || missionsAsync.hasError) {
      return const ErrorState(message: 'Không thể tải hành trình mock.');
    }
    final location = locationAsync.requireValue;
    if (location == null) {
      return EmptyState(
        title: 'Hành trình không tồn tại',
        message: 'Hãy chọn một địa điểm trong trang Khám phá.',
        onAction: () => context.go('/explore'),
      );
    }
    final missions = missionsAsync.requireValue;
    final stageName = switch (stage) {
      null => 'Tổng quan hành trình',
      JourneyStage.checkIn => 'Check-in & lịch sử',
      JourneyStage.culture => 'Khám phá văn hóa',
      JourneyStage.vocabulary => 'Từ vựng tại chỗ',
      JourneyStage.summary => 'Tổng kết hành trình',
    };
    return ModulePage(
      eyebrow: location.koreanName,
      title: stageName,
      description:
          'Khung nhiệm vụ cho ${location.name}. Logic trả lời và chấm điểm sẽ được hoàn thiện ở phase feature.',
      actionLabel: stage == null ? 'Bắt đầu Check-in' : 'Đi chặng tiếp theo',
      onAction: () => context.go(_nextPath(stage)),
      child: Column(
        children: [
          for (final mission in missions)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                child: ListTile(
                  minTileHeight: 72,
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(mission.status),
                    foregroundColor: Colors.white,
                    child: Icon(_statusIcon(mission.status)),
                  ),
                  title: Text(mission.title),
                  subtitle: Text(
                    mission.status == MissionStatus.locked
                        ? 'Mở sau khi hoàn thành chặng trước'
                        : '+${mission.rewardXp} XP',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              SecondaryButton(
                label: 'Check-in',
                onPressed: () => context.go('/journey/$locationId/check-in'),
              ),
              SecondaryButton(
                label: 'Văn hóa',
                onPressed: () => context.go('/journey/$locationId/culture'),
              ),
              SecondaryButton(
                label: 'Từ vựng',
                onPressed: () => context.go('/journey/$locationId/vocabulary'),
              ),
              SecondaryButton(
                label: 'Tổng kết',
                onPressed: () => context.go('/journey/$locationId/summary'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _nextPath(JourneyStage? current) => switch (current) {
    null => '/journey/$locationId/check-in',
    JourneyStage.checkIn => '/journey/$locationId/culture',
    JourneyStage.culture => '/journey/$locationId/vocabulary',
    JourneyStage.vocabulary => '/journey/$locationId/summary',
    JourneyStage.summary => '/passport',
  };

  Color _statusColor(MissionStatus status) => switch (status) {
    MissionStatus.completed => AppColors.green,
    MissionStatus.inProgress => AppColors.coral,
    MissionStatus.notStarted => AppColors.teal,
    MissionStatus.locked => AppColors.disabled,
  };

  IconData _statusIcon(MissionStatus status) => switch (status) {
    MissionStatus.completed => Icons.check_rounded,
    MissionStatus.inProgress => Icons.play_arrow_rounded,
    MissionStatus.notStarted => Icons.flag_outlined,
    MissionStatus.locked => Icons.lock_outline_rounded,
  };
}

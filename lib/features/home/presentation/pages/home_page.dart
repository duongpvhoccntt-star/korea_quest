import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/progress_components.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';
import 'package:korea_quest/shared/widgets/module_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final progressAsync = ref.watch(userProgressProvider);
    final locationsAsync = ref.watch(locationsProvider);
    if (userAsync.isLoading ||
        progressAsync.isLoading ||
        locationsAsync.isLoading) {
      return const LoadingIndicator();
    }
    if (userAsync.hasError ||
        progressAsync.hasError ||
        locationsAsync.hasError) {
      return ErrorState(
        message: 'Không thể đọc dữ liệu mock dùng chung.',
        onRetry: () => ref.invalidate(koreaQuestRepositoryProvider),
      );
    }
    final user = userAsync.requireValue;
    final progress = progressAsync.requireValue;
    final locations = locationsAsync.requireValue;
    final active = locations.firstWhere(
      (location) => location.id == 'bukchon-hanok',
      orElse: () => locations.first,
    );
    return ModulePage(
      eyebrow: 'Hành trình của tôi',
      title: 'Chào Dương, một chương mới đang chờ!',
      description:
          'Trang chủ tổng hợp tiến độ dùng chung từ mock repository để các module không tự sao chép dữ liệu.',
      actionLabel: 'Mở hộ chiếu',
      onAction: () => context.go('/passport'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cards = [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.navy,
                          AppColors.navyLight,
                          AppColors.teal,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NHÀ THÁM HIỂM CẤP ${progress.level}',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Chỉ còn ${progress.xpRemaining} XP để lên cấp!',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        XPProgressBar(progress: progress),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.coral,
                            child: Icon(
                              Icons.map_outlined,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hành trình đang tiếp diễn',
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  active.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(active.description),
                              ],
                            ),
                          ),
                          PrimaryButton(
                            label: 'Tiếp tục',
                            onPressed: () =>
                                context.go('/journey/${active.id}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg, height: AppSpacing.lg),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      UserAvatar(displayName: user.displayName, radius: 42),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('@${user.handle} · Thành viên từ 02/08/2026'),
                      const SizedBox(height: AppSpacing.md),
                      LevelBadge(level: progress.level),
                      const SizedBox(height: AppSpacing.md),
                      Text('🔥 Chuỗi khám phá ${progress.streakDays} ngày'),
                      const SizedBox(height: AppSpacing.lg),
                      SecondaryButton(
                        label: 'Xem hồ sơ',
                        onPressed: () => context.go('/profile'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
          return constraints.maxWidth < 820
              ? Column(children: [cards[0], cards[2]])
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cards,
                );
        },
      ),
    );
  }
}

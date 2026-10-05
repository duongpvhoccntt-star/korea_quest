import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/app_fields.dart';
import 'package:korea_quest/design_system/components/progress_components.dart';
import 'package:korea_quest/design_system/components/app_scroll_view.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/shadows/app_shadows.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key, this.isEditing = false});

  final bool isEditing;

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
        message: 'Không thể tải hồ sơ mock.',
        onRetry: () => ref.invalidate(koreaQuestRepositoryProvider),
      );
    }

    final user = userAsync.requireValue;
    final progress = progressAsync.requireValue;
    final locations = locationsAsync.requireValue;

    return ColoredBox(
      color: AppColors.pageBg,
      child: AppScrollView(
        child: ResponsiveContent(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileHero(
                  user: user,
                  progress: progress,
                  isEditing: isEditing,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (isEditing)
                  _EditProfileForm(
                    user: user,
                    onSave: () {
                      AppToast.show(context, 'Đã lưu thay đổi bản mẫu.');
                      context.go('/profile');
                    },
                    onCancel: () => context.go('/profile'),
                  )
                else
                  _ProfileDashboard(
                    user: user,
                    progress: progress,
                    locations: locations,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.user,
    required this.progress,
    required this.isEditing,
  });

  final AppUser user;
  final UserProgress progress;
  final bool isEditing;

  @override
  Widget build(BuildContext context) => _Surface(
    color: Colors.white,
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1200;
        final identity = Row(
          children: [
            UserAvatar(displayName: user.displayName, radius: 46),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Eyebrow('KOREAQUEST PROFILE'),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    isEditing
                        ? 'Chỉnh sửa hồ sơ'
                        : 'Hồ sơ của ${user.displayName}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.stitchText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '@${user.handle} · Hà Nội, Việt Nam',
                    style: const TextStyle(color: AppColors.stitchMuted),
                  ),
                ],
              ),
            ),
          ],
        );
        final action = isEditing
            ? SecondaryButton(
                label: 'Quay lại hồ sơ',
                icon: Icons.arrow_back_rounded,
                onPressed: () => context.go('/profile'),
              )
            : PrimaryButton(
                label: 'Chỉnh sửa hồ sơ',
                icon: Icons.edit_rounded,
                onPressed: () => context.go('/profile/edit'),
              );
        final xp = _Surface(
          color: AppColors.skyLight.withValues(alpha: .52),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LevelBadge(level: progress.level),
              const SizedBox(height: AppSpacing.md),
              XPProgressBar(progress: progress),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Còn ${progress.xpRemaining} XP để lên cấp tiếp theo',
                style: const TextStyle(color: AppColors.stitchMuted),
              ),
            ],
          ),
        );
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              identity,
              const SizedBox(height: AppSpacing.lg),
              xp,
              const SizedBox(height: AppSpacing.lg),
              action,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 6, child: identity),
            const SizedBox(width: AppSpacing.lg),
            Expanded(flex: 4, child: xp),
            const SizedBox(width: AppSpacing.lg),
            action,
          ],
        );
      },
    ),
  );
}

class _ProfileDashboard extends StatelessWidget {
  const _ProfileDashboard({
    required this.user,
    required this.progress,
    required this.locations,
  });

  final AppUser user;
  final UserProgress progress;
  final List<Location> locations;

  @override
  Widget build(BuildContext context) {
    final completed = locations
        .where((item) => item.status == LocationStatus.completed)
        .length;
    final available = locations
        .where((item) => item.status == LocationStatus.available)
        .length;
    final active = locations
        .where((item) => item.status == LocationStatus.inProgress)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final overview = _Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                title: 'Tổng quan hành trình',
                icon: Icons.insights_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  _StatCard(
                    label: 'Đã hoàn thành',
                    value: '$completed',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.completedGreen,
                  ),
                  _StatCard(
                    label: 'Có thể khám phá',
                    value: '$available',
                    icon: Icons.explore_rounded,
                    color: AppColors.koreanBlue,
                  ),
                  _StatCard(
                    label: 'Chuỗi ngày học',
                    value: '${progress.streakDays}',
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.koreanRed,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const _SectionTitle(
                title: 'Đang tiếp tục',
                icon: Icons.route_rounded,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (active.isEmpty)
                const Text(
                  'Chưa có địa điểm đang thực hiện.',
                  style: TextStyle(color: AppColors.stitchMuted),
                )
              else
                for (final location in active) _JourneyTile(location: location),
            ],
          ),
        );

        final profileInfo = _Surface(
          color: AppColors.palePink.withValues(alpha: .35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                title: 'Thông tin cá nhân',
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoRow(
                icon: Icons.badge_outlined,
                label: 'Tên hiển thị',
                value: user.displayName,
              ),
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: 'duong@example.com',
              ),
              _InfoRow(
                icon: Icons.language_rounded,
                label: 'Ngôn ngữ',
                value: 'Tiếng Việt',
              ),
              _InfoRow(
                icon: Icons.calendar_month_rounded,
                label: 'Tham gia',
                value:
                    '${user.joinedDate.day}/${user.joinedDate.month}/${user.joinedDate.year}',
              ),
              const SizedBox(height: AppSpacing.lg),
              SecondaryButton(
                label: 'Mở hộ chiếu',
                icon: Icons.card_travel_rounded,
                onPressed: () => context.go('/passport'),
              ),
            ],
          ),
        );

        if (!wide) {
          return Column(
            children: [
              profileInfo,
              const SizedBox(height: AppSpacing.lg),
              overview,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: profileInfo),
            const SizedBox(width: AppSpacing.lg),
            Expanded(flex: 7, child: overview),
          ],
        );
      },
    );
  }
}

class _EditProfileForm extends StatelessWidget {
  const _EditProfileForm({
    required this.user,
    required this.onSave,
    required this.onCancel,
  });

  final AppUser user;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => _Surface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Thông tin hiển thị',
          icon: Icons.edit_note_rounded,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Họ và tên',
          hint: user.fullName,
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Tên hiển thị',
          hint: user.displayName,
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        const AppTextField(
          label: 'Giới thiệu',
          hint: 'Câu chuyện khám phá của bạn…',
          prefixIcon: Icons.auto_stories_outlined,
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            PrimaryButton(
              label: 'Lưu thay đổi',
              icon: Icons.save_rounded,
              onPressed: onSave,
            ),
            SecondaryButton(
              label: 'Hủy',
              icon: Icons.close_rounded,
              onPressed: onCancel,
            ),
          ],
        ),
      ],
    ),
  );
}

class _JourneyTile extends StatelessWidget {
  const _JourneyTile({required this.location});

  final Location location;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Material(
      color: AppColors.skyLight.withValues(alpha: .42),
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            Icons.temple_buddhist_rounded,
            color: AppColors.koreanRed,
          ),
        ),
        title: Text(
          location.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(location.city),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.go('/journey/${location.id}'),
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 170,
    child: _Surface(
      color: color.withValues(alpha: .12),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(label, style: const TextStyle(color: AppColors.stitchMuted)),
        ],
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white,
          child: Icon(icon, size: 18, color: AppColors.koreanBlue),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.stitchMuted,
                  fontSize: 12,
                ),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColors.koreanRed),
      const SizedBox(width: AppSpacing.xs),
      Expanded(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    ],
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      color: AppColors.koreanRed,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.2,
      fontSize: 12,
    ),
  );
}

class _Surface extends StatelessWidget {
  const _Surface({
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.borderSoft),
      boxShadow: AppShadows.small,
    ),
    child: Padding(padding: padding, child: child),
  );
}

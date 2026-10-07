import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/auth/domain/auth_models.dart';
import 'package:korea_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:korea_quest/features/auth/presentation/widgets/sign_out_action.dart';
import 'package:korea_quest/features/settings/presentation/widgets/change_password_dialog.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';
import 'package:korea_quest/shared/widgets/module_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notifications = true;
  bool _reducedMotion = false;

  Future<void> _handleResetProgress() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Đặt lại tiến trình học tập?',
      message:
          'Hành động này sẽ đưa cấp độ về 1, 0 XP và khóa lại các địa điểm đã hoàn thành.',
      confirmLabel: 'Đặt lại',
    );
    if (!confirmed || !mounted) return;

    try {
      await ref.read(koreaQuestRepositoryProvider).resetUserProgress();
      ref.invalidate(userProgressProvider);
      ref.invalidate(locationsProvider);
      ref.invalidate(achievementsProvider);
      ref.invalidate(passportStampsProvider);

      if (mounted) {
        AppToast.show(context, 'Đã đặt lại tiến trình học tập về ban đầu.');
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(
          context,
          'Không thể đặt lại tiến trình. Vui lòng thử lại.',
        );
      }
    }
  }

  Future<void> _handleSignOut() => confirmAndSignOut(context, ref);

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authUserStreamProvider).value;
    final email = authUser?.usernameOrEmail ?? 'duong@example.com';
    final role = authUser?.role == UserRole.admin
        ? 'Quản trị viên'
        : 'Học viên';

    return ModulePage(
      eyebrow: 'Tùy chỉnh hệ thống',
      title: 'Cài đặt',
      description:
          'Quản lý tài khoản, bảo mật, thông báo và dữ liệu khám phá của bạn.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Card 1: Tài khoản & Bảo mật ────────────────────────────
          _SettingsGroupCard(
            title: 'Tài khoản & Bảo mật',
            icon: Icons.security_rounded,
            iconColor: AppColors.koreanBlue,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.skyLight,
                    child: Icon(
                      Icons.person_rounded,
                      color: AppColors.koreanBlue,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${authUser?.displayName ?? '[CẦN XÁC NHẬN]'} · Vai trò: $role',
                          style: const TextStyle(
                            color: AppColors.stitchMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.koreanBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.round),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        color: AppColors.koreanBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: AppSpacing.xl),
              _ActionTile(
                icon: Icons.lock_outline_rounded,
                iconBg: AppColors.cream,
                iconColor: AppColors.stitchText,
                title: 'Mật khẩu tài khoản',
                subtitle: '••••••••••••',
                action: SecondaryButton(
                  label: 'Đổi mật khẩu',
                  icon: Icons.lock_reset_rounded,
                  onPressed: () => ChangePasswordDialog.show(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Card 2: Tùy chọn trải nghiệm ───────────────────────────
          _SettingsGroupCard(
            title: 'Tùy chọn trải nghiệm',
            icon: Icons.tune_rounded,
            iconColor: AppColors.stitchMuted,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _notifications,
                activeThumbColor: AppColors.coral,
                onChanged: (val) => setState(() => _notifications = val),
                title: const Text(
                  'Thông báo hành trình',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Nhắc khi có nhiệm vụ, cấp độ và phần thưởng mới',
                ),
              ),
              const Divider(height: AppSpacing.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _reducedMotion,
                activeThumbColor: AppColors.coral,
                onChanged: (val) => setState(() => _reducedMotion = val),
                title: const Text(
                  'Giảm hiệu ứng chuyển động',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Hỗ trợ trải nghiệm mượt mà, dễ tiếp cận hơn',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Card 3: Quản lý dữ liệu & Lưu trữ ──────────────────────
          _SettingsGroupCard(
            title: 'Quản lý dữ liệu & Lưu trữ',
            icon: Icons.storage_rounded,
            iconColor: AppColors.gold,
            children: [
              _ActionTile(
                icon: Icons.cleaning_services_rounded,
                iconBg: AppColors.skyLight,
                iconColor: AppColors.koreanBlue,
                title: 'Xóa bộ nhớ đệm',
                subtitle: 'Giải phóng các tài nguyên tạm thời được lưu cục bộ',
                action: SecondaryButton(
                  label: 'Dọn dẹp',
                  icon: Icons.refresh_rounded,
                  onPressed: () =>
                      AppToast.show(context, 'Đã dọn dẹp bộ nhớ đệm mô phỏng.'),
                ),
              ),
              const Divider(height: AppSpacing.xl),
              _ActionTile(
                icon: Icons.history_rounded,
                iconBg: AppColors.palePink,
                iconColor: AppColors.koreanRed,
                title: 'Đặt lại tiến trình học tập',
                subtitle: 'Đưa cấp độ về 1, 0 XP để trải nghiệm lại hành trình',
                action: FilledButton.tonal(
                  onPressed: _handleResetProgress,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.koreanRed.withValues(alpha: 0.1),
                    foregroundColor: AppColors.koreanRed,
                  ),
                  child: const Text('Đặt lại tiến trình học tập'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Card 4: Đăng xuất tài khoản ────────────────────────────
          _SettingsGroupCard(
            title: 'Phiên đăng nhập',
            icon: Icons.logout_rounded,
            iconColor: AppColors.koreanRed,
            children: [
              const Text(
                'Đăng xuất sẽ kết thúc phiên làm việc hiện tại trên thiết bị này.',
                style: TextStyle(color: AppColors.stitchMuted),
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: DangerButton(
                  label: 'Đăng xuất tài khoản',
                  icon: Icons.logout_rounded,
                  onPressed: _handleSignOut,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsGroupCard extends StatelessWidget {
  const _SettingsGroupCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: const BorderSide(color: AppColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.stitchText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.action,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 460;
        final info = Row(
          children: [
            CircleAvatar(
              backgroundColor: iconBg,
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.stitchMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              info,
              const SizedBox(height: AppSpacing.sm),
              Align(alignment: Alignment.centerRight, child: action),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: info),
            const SizedBox(width: AppSpacing.md),
            action,
          ],
        );
      },
    );
  }
}

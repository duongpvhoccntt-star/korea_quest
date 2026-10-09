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
import 'package:korea_quest/l10n/app_strings.dart';
import 'package:korea_quest/l10n/locale_controller.dart';
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
    final strings = appStrings(context);
    final confirmed = await ConfirmationDialog.show(
      context,
      title: strings.resetProgressQuestion,
      message: strings.resetProgressMessage,
      confirmLabel: strings.reset,
    );
    if (!confirmed || !mounted) return;

    try {
      await ref.read(koreaQuestRepositoryProvider).resetUserProgress();
      ref.invalidate(userProgressProvider);
      ref.invalidate(locationsProvider);
      ref.invalidate(earnedAchievementsProvider);
      ref.invalidate(earnedPassportStampsProvider);

      if (mounted) {
        AppToast.show(context, strings.resetProgressSuccess);
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(context, strings.resetProgressError);
      }
    }
  }

  Future<void> _handleSignOut() => confirmAndSignOut(context, ref);

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    final locale = ref.watch(localeProvider);
    final authUser = ref.watch(authUserStreamProvider).value;
    final email = authUser?.usernameOrEmail ?? 'duong@example.com';
    final role = authUser?.role == UserRole.admin
        ? strings.administrator
        : strings.student;

    return ModulePage(
      eyebrow: strings.customizeSystem,
      title: strings.settings,
      description: strings.settingsDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SettingsGroupCard(
            title: strings.language,
            icon: Icons.language_rounded,
            iconColor: AppColors.teal,
            children: [
              Text(
                strings.languageDescription,
                style: const TextStyle(color: AppColors.stitchMuted),
              ),
              const SizedBox(height: AppSpacing.md),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'vi', label: Text(strings.vietnamese)),
                  ButtonSegment(value: 'en', label: Text(strings.english)),
                  ButtonSegment(value: 'ko', label: Text(strings.korean)),
                ],
                selected: {locale.languageCode},
                onSelectionChanged: (selected) => ref
                    .read(localeProvider.notifier)
                    .setLocale(Locale(selected.first)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // ── Card 1: Tài khoản & Bảo mật ────────────────────────────
          _SettingsGroupCard(
            title: strings.accountSecurity,
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
                          strings.roleLine(
                            authUser?.displayName ?? '[CẦN XÁC NHẬN]',
                            role,
                          ),
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
                title: strings.accountPassword,
                subtitle: '••••••••••••',
                action: SecondaryButton(
                  label: strings.changePassword,
                  icon: Icons.lock_reset_rounded,
                  onPressed: () => ChangePasswordDialog.show(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Card 2: Tùy chọn trải nghiệm ───────────────────────────
          _SettingsGroupCard(
            title: strings.experienceOptions,
            icon: Icons.tune_rounded,
            iconColor: AppColors.stitchMuted,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _notifications,
                activeThumbColor: AppColors.coral,
                onChanged: (val) => setState(() => _notifications = val),
                title: Text(
                  strings.notifications,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(strings.notificationsDescription),
              ),
              const Divider(height: AppSpacing.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _reducedMotion,
                activeThumbColor: AppColors.coral,
                onChanged: (val) => setState(() => _reducedMotion = val),
                title: Text(
                  strings.reducedMotion,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(strings.reducedMotionDescription),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Card 3: Quản lý dữ liệu & Lưu trữ ──────────────────────
          _SettingsGroupCard(
            title: strings.dataStorage,
            icon: Icons.storage_rounded,
            iconColor: AppColors.gold,
            children: [
              _ActionTile(
                icon: Icons.cleaning_services_rounded,
                iconBg: AppColors.skyLight,
                iconColor: AppColors.koreanBlue,
                title: strings.clearCache,
                subtitle: strings.clearCacheDescription,
                action: SecondaryButton(
                  label: strings.cleanUp,
                  icon: Icons.refresh_rounded,
                  onPressed: () => AppToast.show(context, strings.cacheCleaned),
                ),
              ),
              const Divider(height: AppSpacing.xl),
              _ActionTile(
                icon: Icons.history_rounded,
                iconBg: AppColors.palePink,
                iconColor: AppColors.koreanRed,
                title: strings.resetProgress,
                subtitle: strings.resetProgressDescription,
                action: FilledButton.tonal(
                  onPressed: _handleResetProgress,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.koreanRed.withValues(alpha: 0.1),
                    foregroundColor: AppColors.koreanRed,
                  ),
                  child: Text(strings.resetProgress),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Card 4: Đăng xuất tài khoản ────────────────────────────
          _SettingsGroupCard(
            title: strings.session,
            icon: Icons.logout_rounded,
            iconColor: AppColors.koreanRed,
            children: [
              Text(
                strings.sessionDescription,
                style: const TextStyle(color: AppColors.stitchMuted),
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: DangerButton(
                  label: strings.signOutAccount,
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

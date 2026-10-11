import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/shadows/app_shadows.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/l10n/app_strings.dart';

const guestAccessTargetParameter = 'guestAccess';

bool isGuestRestrictedPath(String path) =>
    path == '/passport' ||
    path == '/achievements' ||
    path == '/settings' ||
    path == '/profile' ||
    path.startsWith('/profile/');

String guestAccessRouteFor(Uri target) => Uri(
  path: '/explore',
  queryParameters: {guestAccessTargetParameter: target.toString()},
).toString();

String? validGuestAccessTarget(String? rawTarget) {
  if (rawTarget == null || rawTarget.isEmpty) return null;
  final target = Uri.tryParse(rawTarget);
  if (target == null ||
      target.hasScheme ||
      !isGuestRestrictedPath(target.path)) {
    return null;
  }
  return target.toString();
}

Future<void> showGuestAccessPromptDialog(
  BuildContext context, {
  required String guestName,
  required String targetPath,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        GuestAccessPromptDialog(guestName: guestName, targetPath: targetPath),
  );
}

class GuestAccessPromptDialog extends StatelessWidget {
  const GuestAccessPromptDialog({
    required this.guestName,
    required this.targetPath,
    this.onSignIn,
    this.onRegister,
    this.onContinueExploring,
    super.key,
  });

  final String guestName;
  final String targetPath;
  final VoidCallback? onSignIn;
  final VoidCallback? onRegister;
  final VoidCallback? onContinueExploring;

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.large),
            boxShadow: AppShadows.large,
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.coral, width: 2),
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    color: AppColors.coral,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                strings.guestAccessTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.stitchText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                strings.guestAccessMessage(guestName),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.stitchMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: strings.signIn,
                icon: Icons.login_rounded,
                onPressed: onSignIn ?? () => _openSignIn(context),
              ),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                label: strings.register,
                icon: Icons.person_add_alt_1_rounded,
                onPressed: onRegister ?? () => _openRegister(context),
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: TextButton(
                  onPressed:
                      onContinueExploring ?? () => _continueExploring(context),
                  child: Text(strings.continueAsGuest),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSignIn(BuildContext context) {
    _navigateTo(
      context,
      Uri(
        path: '/login',
        queryParameters: {'redirect': _safeTargetPath},
      ).toString(),
    );
  }

  void _openRegister(BuildContext context) {
    _navigateTo(
      context,
      Uri(
        path: '/register',
        queryParameters: {'name': guestName, 'redirect': _safeTargetPath},
      ).toString(),
    );
  }

  void _continueExploring(BuildContext context) {
    _navigateTo(context, '/explore');
  }

  String get _safeTargetPath =>
      validGuestAccessTarget(targetPath) ?? '/explore';

  void _navigateTo(BuildContext context, String destination) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) navigator.pop();
    context.go(destination);
  }
}

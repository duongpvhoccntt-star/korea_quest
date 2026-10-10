import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/shadows/app_shadows.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/l10n/app_strings.dart';

Future<void> showGuestRegistrationPromptDialog(
  BuildContext context, {
  required String locationName,
  required String guestName,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => GuestRegistrationPromptDialog(
      locationName: locationName,
      guestName: guestName,
    ),
  );
}

class GuestRegistrationPromptDialog extends StatelessWidget {
  const GuestRegistrationPromptDialog({
    required this.locationName,
    required this.guestName,
    this.onRegister,
    this.onDismiss,
    super.key,
  });

  final String locationName;
  final String guestName;
  final VoidCallback? onRegister;
  final VoidCallback? onDismiss;

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
                    color: AppColors.gold.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.gold,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                strings.guestCelebrationTitle(guestName, locationName),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.stitchText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                strings.guestCelebrationMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.stitchMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: strings.registerAndSaveProgress,
                icon: Icons.card_membership_rounded,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  if (onRegister != null) {
                    onRegister!();
                  } else {
                    try {
                      final uri = Uri(
                        path: '/register',
                        queryParameters: {'name': guestName},
                      );
                      context.go(uri.toString());
                    } catch (_) {}
                  }
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    if (onDismiss != null) {
                      onDismiss!();
                    } else {
                      try {
                        context.go('/explore');
                      } catch (_) {}
                    }
                  },
                  child: Text(strings.continueAsGuest),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

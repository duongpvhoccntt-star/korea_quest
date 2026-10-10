import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_structure.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/l10n/app_strings.dart';

enum SystemStateKind { forbidden, offline, error, notFound }

class SystemStatePage extends StatelessWidget {
  const SystemStatePage({required this.kind, super.key});

  final SystemStateKind kind;

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    final (code, title, message, icon) = switch (kind) {
      SystemStateKind.forbidden => (
        '403',
        strings.forbiddenTitle,
        strings.forbiddenMessage,
        Icons.lock_outline_rounded,
      ),
      SystemStateKind.offline => (
        'OFFLINE',
        strings.offlineTitle,
        strings.offlineMessage,
        Icons.cloud_off_outlined,
      ),
      SystemStateKind.error => (
        '500',
        strings.errorTitle,
        strings.errorMessage,
        Icons.error_outline_rounded,
      ),
      SystemStateKind.notFound => (
        '404',
        strings.notFoundTitle,
        strings.notFoundMessage,
        Icons.explore_off_outlined,
      ),
    };
    return AppScaffold(
      body: ResponsiveContent(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 72),
                const SizedBox(height: AppSpacing.md),
                Text(code, style: Theme.of(context).textTheme.displaySmall),
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: strings.backExplore,
                  icon: Icons.explore_outlined,
                  onPressed: () => context.go('/explore'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';

class ModulePage extends StatelessWidget {
  const ModulePage({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.child,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: ResponsiveContent(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow.toUpperCase(),
              style: const TextStyle(
                color: AppColors.coral,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.md,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        description,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                if (actionLabel != null)
                  PrimaryButton(label: actionLabel!, onPressed: onAction),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            child,
          ],
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/progress_components.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/l10n/app_strings.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';
import 'package:korea_quest/shared/widgets/module_page.dart';

class PassportPage extends ConsumerWidget {
  const PassportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = appStrings(context);
    final user = ref.watch(currentUserProvider);
    final progress = ref.watch(userProgressProvider);
    final stamps = ref.watch(earnedPassportStampsProvider);
    if (user.isLoading || progress.isLoading || stamps.isLoading) {
      return const LoadingIndicator();
    }
    if (user.hasError || progress.hasError || stamps.hasError) {
      return ErrorState(message: strings.loadPassportError);
    }
    final profile = user.requireValue;
    final xp = progress.requireValue;
    final items = stamps.requireValue;
    return ModulePage(
      eyebrow: strings.collection,
      title: strings.passportTitle,
      description: strings.passportDescription,
      actionLabel: strings.continueJourney,
      onAction: () => context.go('/explore'),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.navy,
              border: Border.all(color: AppColors.gold, width: 4),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.lg,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                UserAvatar(displayName: profile.displayName, radius: 48),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KOREAQUEST PASSPORT · 대한민국 문화여권',
                      style: TextStyle(color: AppColors.gold),
                    ),
                    Text(
                      profile.fullName.toUpperCase(),
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                    ),
                    Text(
                      'KQ-2026-0802 · LEVEL ${xp.level}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                Text(
                  '${xp.currentXp} XP',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: AppColors.gold),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (items.isEmpty)
            const EmptyState(
              title: 'Chưa nhận dấu mộc nào',
              message: 'Dấu mộc đã nhận sẽ xuất hiện tại đây.',
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisExtent: 245,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemBuilder: (context, index) {
                final stamp = items[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 105,
                          height: 105,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.coral,
                              width: 4,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            stamp.seal,
                            style: const TextStyle(
                              fontSize: 34,
                              color: AppColors.coral,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          stamp.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy',
                            Localizations.localeOf(context).toLanguageTag(),
                          ).format(stamp.earnedDate),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

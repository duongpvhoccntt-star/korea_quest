import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/l10n/app_strings.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';
import 'package:korea_quest/shared/widgets/module_page.dart';

enum _AchievementFilter { all, earned, locked }

class AchievementsPage extends ConsumerStatefulWidget {
  const AchievementsPage({super.key});

  @override
  ConsumerState<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends ConsumerState<AchievementsPage> {
  _AchievementFilter _filter = _AchievementFilter.all;

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    final achievements = ref.watch(earnedAchievementsProvider);
    return ModulePage(
      eyebrow: strings.milestones,
      title: strings.yourAchievements,
      description: strings.achievementsDescription,
      child: achievements.when(
        loading: LoadingIndicator.new,
        error: (error, stack) => ErrorState(
          message: strings.loadBadgesError,
          onRetry: () => ref.invalidate(earnedAchievementsProvider),
        ),
        data: (items) {
          final visible = items
              .where(
                (item) => switch (_filter) {
                  _AchievementFilter.all => true,
                  _AchievementFilter.earned => item.isEarned,
                  _AchievementFilter.locked => !item.isEarned,
                },
              )
              .toList(growable: false);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<_AchievementFilter>(
                segments: [
                  ButtonSegment(
                    value: _AchievementFilter.all,
                    label: Text(strings.allAchievements),
                  ),
                  ButtonSegment(
                    value: _AchievementFilter.earned,
                    label: Text(strings.earnedAchievements),
                  ),
                  ButtonSegment(
                    value: _AchievementFilter.locked,
                    label: Text(strings.lockedAchievements),
                  ),
                ],
                selected: {_filter},
                onSelectionChanged: (selection) =>
                    setState(() => _filter = selection.single),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (visible.isEmpty)
                EmptyState(
                  title: strings.noAchievements,
                  message: strings.noAchievementsDescription,
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visible.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 390,
                    mainAxisExtent: 230,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemBuilder: (context, index) =>
                      _AchievementCard(item: visible[index]),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.item});

  final Achievement item;

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (item.iconUrl.isNotEmpty)
                  ClipOval(
                    child: Image.network(
                      item.iconUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.emoji_events_rounded, size: 42),
                    ),
                  )
                else
                  Icon(
                    item.isEarned
                        ? Icons.emoji_events_rounded
                        : Icons.lock_outline_rounded,
                    size: 42,
                  ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(item.title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (item.currentValue != null && item.targetValue != null) ...[
              LinearProgressIndicator(value: item.progress),
              const SizedBox(height: AppSpacing.xs),
              Text(
                strings.achievementProgress(
                  item.currentValue!,
                  item.targetValue!,
                ),
              ),
            ],
            if (item.earnedDate != null)
              Text(
                strings.earnedOn(
                  DateFormat.yMMMd(
                    Localizations.localeOf(context).toLanguageTag(),
                  ).format(item.earnedDate!),
                ),
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

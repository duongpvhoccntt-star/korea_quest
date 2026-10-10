import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/progress_components.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/l10n/app_strings.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';
import 'package:korea_quest/shared/widgets/module_page.dart';

class PassportPage extends ConsumerStatefulWidget {
  const PassportPage({super.key});

  @override
  ConsumerState<PassportPage> createState() => _PassportPageState();
}

class _PassportPageState extends ConsumerState<PassportPage> {
  bool _sharing = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final token = await ref
          .read(koreaQuestRepositoryProvider)
          .regeneratePassportShareLink();
      if (!mounted || token.isEmpty) return;
      final link = Uri.base.resolve('/passport/shared/$token').toString();
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(appStrings(context).passportLinkCreated),
          content: SelectableText(link),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: link));
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(appStrings(context).copyLink),
            ),
          ],
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appStrings(context).loadPassportError)),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _revoke() async {
    setState(() => _sharing = true);
    try {
      await ref.read(koreaQuestRepositoryProvider).revokePassportShareLink();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appStrings(context).loadPassportError)),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    final user = ref.watch(currentUserProvider);
    final progress = ref.watch(userProgressProvider);
    final stamps = ref.watch(earnedPassportStampsProvider);
    if (user.isLoading || progress.isLoading || stamps.isLoading) {
      return const LoadingIndicator();
    }
    if (user.hasError || progress.hasError || stamps.hasError) {
      return ErrorState(
        message: strings.loadPassportError,
        onRetry: () {
          ref.invalidate(currentUserProvider);
          ref.invalidate(userProgressProvider);
          ref.invalidate(earnedPassportStampsProvider);
        },
      );
    }
    final profile = user.requireValue;
    final xp = progress.requireValue;
    final items = stamps.requireValue;
    final passportCode = profile.id
        .replaceAll('-', '')
        .padRight(8, '0')
        .substring(0, 8)
        .toUpperCase();
    return ModulePage(
      eyebrow: strings.collection,
      title: strings.passportTitle,
      description: strings.passportDescription,
      actionLabel: strings.continueJourney,
      onAction: () => context.go('/explore'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.navy,
              border: Border.all(color: AppColors.gold, width: 4),
              borderRadius: BorderRadius.circular(AppRadius.large),
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
                    Text(
                      strings.passportTitle.toUpperCase(),
                      style: const TextStyle(color: AppColors.gold),
                    ),
                    Text(
                      (profile.fullName.isEmpty
                              ? profile.displayName
                              : profile.fullName)
                          .toUpperCase(),
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                    ),
                    Text(
                      'KQ-$passportCode · LEVEL ${xp.level}',
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
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                onPressed: _sharing ? null : _share,
                icon: const Icon(Icons.share_rounded),
                label: Text(strings.sharePassport),
              ),
              OutlinedButton.icon(
                onPressed: _sharing ? null : _revoke,
                icon: const Icon(Icons.link_off_rounded),
                label: Text(strings.revokePassportLink),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (items.isEmpty)
            EmptyState(
              title: strings.noPassportStamps,
              message: strings.noPassportStampsDescription,
            )
          else
            _StampGrid(items: items),
        ],
      ),
    );
  }
}

class _StampGrid extends StatelessWidget {
  const _StampGrid({required this.items});

  final List<PassportStamp> items;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: items.length,
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 300,
      mainAxisExtent: 290,
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
              if (stamp.imageUrl.isNotEmpty)
                ClipOval(
                  child: Image.network(
                    stamp.imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    semanticLabel: stamp.imageAlt,
                    errorBuilder: (_, _, _) => _SealFallback(stamp.seal),
                  ),
                )
              else
                _SealFallback(stamp.seal),
              const SizedBox(height: AppSpacing.sm),
              Text(
                stamp.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (stamp.description.isNotEmpty)
                Text(
                  stamp.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              Text(
                DateFormat.yMMMd(
                  Localizations.localeOf(context).toLanguageTag(),
                ).format(stamp.earnedDate),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SealFallback extends StatelessWidget {
  const _SealFallback(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    width: 120,
    height: 120,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.coral, width: 4),
    ),
    alignment: Alignment.center,
    child: Text(
      label,
      style: const TextStyle(fontSize: 34, color: AppColors.coral),
    ),
  );
}

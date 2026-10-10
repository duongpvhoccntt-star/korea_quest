import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/progress_components.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/l10n/app_strings.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';
import 'package:korea_quest/shared/widgets/module_page.dart';

class SharedPassportPage extends ConsumerWidget {
  const SharedPassportPage({required this.token, super.key});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = appStrings(context);
    final passport = ref.watch(sharedPassportProvider(token));
    return Scaffold(
      body: passport.when(
        loading: LoadingIndicator.new,
        error: (error, stack) => ErrorState(message: strings.loadPassportError),
        data: (data) {
          if (data == null) {
            return EmptyState(
              title: strings.passportTitle,
              message: strings.sharedPassportNotFound,
            );
          }
          return ModulePage(
            eyebrow: strings.collection,
            title: strings.sharedPassportTitle(data.displayName),
            description: strings.passportDescription,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (data.progress case final progress?)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LevelBadge(level: progress.level),
                          const SizedBox(height: AppSpacing.md),
                          XPProgressBar(progress: progress),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final stamp in data.stamps)
                      Chip(
                        avatar: const Icon(Icons.approval_rounded),
                        label: Text(stamp.name),
                      ),
                    for (final achievement in data.achievements)
                      Chip(
                        avatar: const Icon(Icons.emoji_events_rounded),
                        label: Text(achievement.title),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

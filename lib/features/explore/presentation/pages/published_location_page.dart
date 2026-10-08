import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/app_scroll_view.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/explore/presentation/providers/location_content_providers.dart';
import 'package:korea_quest/features/explore/presentation/widgets/location_content_view.dart';
import 'package:korea_quest/l10n/app_strings.dart';

class PublishedLocationPage extends ConsumerStatefulWidget {
  const PublishedLocationPage({
    required this.slug,
    this.stageNumber = 1,
    super.key,
  });

  final String slug;
  final int stageNumber;

  @override
  ConsumerState<PublishedLocationPage> createState() =>
      _PublishedLocationPageState();
}

class _PublishedLocationPageState extends ConsumerState<PublishedLocationPage> {
  final AppScrollController _scrollController = AppScrollController(
    keepScrollOffset: false,
  );

  @override
  void didUpdateWidget(covariant PublishedLocationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug ||
        oldWidget.stageNumber != widget.stageNumber) {
      _scrollToTop();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _openStage(int nextStage) {
    _scrollToTop();
    if (nextStage == 0) {
      context.go('/explore');
      return;
    }
    context.go('/locations/${widget.slug}/stages/$nextStage');
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.stageNumber.clamp(1, 9).toInt();
    final location = ref.watch(publishedLocationProvider(widget.slug));
    return location.when(
      loading: LoadingIndicator.new,
      error: (error, stack) => ErrorState(
        message: appStrings(context).loadLocationContentError(error.toString()),
        onRetry: () => ref.invalidate(publishedLocationProvider(widget.slug)),
      ),
      data: (item) {
        if (item == null) {
          return EmptyState(
            title: appStrings(context).locationNotFound,
            message: appStrings(context).locationNotPublished,
            onAction: () => context.go('/explore'),
          );
        }
        return ColoredBox(
          color: AppColors.pageBg,
          child: Scrollbar(
            controller: _scrollController,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                if (item.isFallback)
                  SliverToBoxAdapter(
                    child: ResponsiveContent(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: MaterialBanner(
                          content: Text(
                            appStrings(context).translationUnavailable,
                          ),
                          leading: const Icon(Icons.translate_rounded),
                          actions: [
                            TextButton(
                              onPressed: () {},
                              child: Text(appStrings(context).fallbackBadge),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: ResponsiveContent(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xl),
                      child: LocationContentView(
                        location: item,
                        currentStage: stage,
                        onStageSelected: _openStage,
                        onSubmitQuizAnswer: (questionId, answer) => ref
                            .read(locationContentRepositoryProvider)
                            .submitQuizAnswer(
                              questionId: questionId,
                              answer: answer,
                              locale: Localizations.localeOf(
                                context,
                              ).languageCode,
                            ),
                        showJourneyStepper: false,
                        showStageBody: false,
                        showStageNavigation: false,
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _JourneyStepperHeaderDelegate(
                    currentStage: stage,
                    onStageSelected: _openStage,
                  ),
                ),
                SliverToBoxAdapter(
                  child: ResponsiveContent(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.lg,
                        bottom: AppSpacing.xl,
                      ),
                      child: LocationContentView(
                        location: item,
                        currentStage: stage,
                        onStageSelected: _openStage,
                        onSubmitQuizAnswer: (questionId, answer) => ref
                            .read(locationContentRepositoryProvider)
                            .submitQuizAnswer(
                              questionId: questionId,
                              answer: answer,
                              locale: Localizations.localeOf(
                                context,
                              ).languageCode,
                            ),
                        showLocationHeader: false,
                        showJourneyStepper: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _JourneyStepperHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _JourneyStepperHeaderDelegate({
    required this.currentStage,
    required this.onStageSelected,
  });

  final int currentStage;
  final ValueChanged<int> onStageSelected;

  static const _extent = 116.0;

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ColoredBox(
    color: AppColors.pageBg,
    child: ResponsiveContent(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: JourneyStepper(
          currentStage: currentStage,
          onStageSelected: onStageSelected,
        ),
      ),
    ),
  );

  @override
  bool shouldRebuild(_JourneyStepperHeaderDelegate oldDelegate) =>
      currentStage != oldDelegate.currentStage;
}

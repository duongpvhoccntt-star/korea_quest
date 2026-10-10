import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/app_scroll_view.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';
import 'package:korea_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:korea_quest/features/explore/presentation/providers/location_content_providers.dart';
import 'package:korea_quest/features/explore/presentation/widgets/guest_registration_prompt_dialog.dart';
import 'package:korea_quest/features/explore/presentation/widgets/location_content_view.dart';
import 'package:korea_quest/l10n/app_strings.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';

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

  void _openStage(int nextStage, [String locationName = '']) {
    _scrollToTop();
    if (nextStage == 0) {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user?.isGuest == true) {
        showGuestRegistrationPromptDialog(
          context,
          locationName: locationName,
          guestName: user!.displayName,
        );
        return;
      }
      context.go('/explore');
      return;
    }
    context.go('/locations/${widget.slug}/stages/$nextStage');
  }

  Future<QuizAnswerResult> _submitQuiz(
    String questionId,
    JsonMap answer,
  ) async {
    if (ref.read(authRepositoryProvider).currentUser == null) {
      _openLogin();
      return const QuizAnswerResult(isCorrect: false, explanation: '');
    }
    final result = await ref
        .read(locationContentRepositoryProvider)
        .submitQuizAnswer(
          questionId: questionId,
          answer: answer,
          locale: Localizations.localeOf(context).languageCode,
        );
    _refreshGameplay();
    _showReward(result.reward);
    return result;
  }

  Future<void> _completeStage(int stageNumber, String locationName) async {
    if (ref.read(authRepositoryProvider).currentUser == null) {
      _openLogin();
      return;
    }
    final reward = await ref
        .read(locationContentRepositoryProvider)
        .completeStage(
          slug: widget.slug,
          stageNumber: stageNumber,
          locale: Localizations.localeOf(context).languageCode,
        );
    if (!mounted) return;
    _refreshGameplay();
    _showReward(reward);
    _openStage(stageNumber == 9 ? 0 : stageNumber + 1, locationName);
  }

  void _openLogin() {
    context.go(
      Uri(
        path: '/login',
        queryParameters: {
          'redirect': '/locations/${widget.slug}/stages/${widget.stageNumber}',
        },
      ).toString(),
    );
  }

  void _refreshGameplay() {
    ref.invalidate(userProgressProvider);
    ref.invalidate(earnedAchievementsProvider);
    ref.invalidate(earnedPassportStampsProvider);
  }

  void _showReward(GameplayReward? reward) {
    if (!mounted || reward == null || reward.alreadyAwarded) return;
    final parts = <String>[
      if (reward.awardedXp > 0) '+${reward.awardedXp} XP',
      ...reward.newAchievementTitles,
      if (reward.stampAwarded) appStrings(context).passport,
    ];
    if (parts.isEmpty) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(parts.join(' · '))));
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
                        onStageSelected: (next) => _openStage(next, item.name),
                        onSubmitQuizAnswer: _submitQuiz,
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
                    onStageSelected: (next) => _openStage(next, item.name),
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
                        onStageSelected: (next) => _openStage(next, item.name),
                        onStageCompleted: (nextStage) =>
                            _completeStage(nextStage, item.name),
                        onSubmitQuizAnswer: _submitQuiz,
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

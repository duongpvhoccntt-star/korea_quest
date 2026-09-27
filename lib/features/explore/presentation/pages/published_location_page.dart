import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/explore/presentation/providers/location_content_providers.dart';
import 'package:korea_quest/features/explore/presentation/widgets/location_content_view.dart';

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
  final ScrollController _scrollController = ScrollController(
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
        message: 'Không thể tải nội dung địa điểm: $error',
        onRetry: () => ref.invalidate(publishedLocationProvider(widget.slug)),
      ),
      data: (item) {
        if (item == null) {
          return EmptyState(
            title: 'Không tìm thấy địa điểm',
            message: 'Địa điểm này chưa được xuất bản hoặc đang được cập nhật.',
            onAction: () => context.go('/explore'),
          );
        }
        return ColoredBox(
          color: AppColors.pageBg,
          child: Scrollbar(
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: ResponsiveContent(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: LocationContentView(
                    location: item,
                    currentStage: stage,
                    onStageSelected: _openStage,
                    onSubmitQuizAnswer: (questionId, answer) => ref
                        .read(locationContentRepositoryProvider)
                        .submitQuizAnswer(
                          questionId: questionId,
                          answer: answer,
                        ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

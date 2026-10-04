import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/core/utils/optimized_image_url.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/shadows/app_shadows.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/shared/widgets/youtube_player.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';

class LocationContentView extends StatelessWidget {
  const LocationContentView({
    required this.location,
    required this.onSubmitQuizAnswer,
    this.currentStage = 1,
    this.onStageSelected,
    this.showLocationHeader = true,
    this.showJourneyStepper = true,
    this.showStageBody = true,
    this.showStageNavigation = true,
    super.key,
  });

  final PublishedLocationDetail location;
  final Future<QuizAnswerResult> Function(String questionId, JsonMap answer)
  onSubmitQuizAnswer;
  final int currentStage;
  final ValueChanged<int>? onStageSelected;
  final bool showLocationHeader;
  final bool showJourneyStepper;
  final bool showStageBody;
  final bool showStageNavigation;

  @override
  Widget build(BuildContext context) {
    final stage = currentStage.clamp(1, 9).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLocationHeader)
          _LocationHeader(location: location, currentStage: stage),
        if (showLocationHeader && showJourneyStepper)
          const SizedBox(height: AppSpacing.lg),
        if (showJourneyStepper)
          JourneyStepper(currentStage: stage, onStageSelected: onStageSelected),
        if (showJourneyStepper && showStageBody)
          const SizedBox(height: AppSpacing.xl),
        if (showStageBody) _stageBody(stage),
        if (showStageNavigation &&
            showStageBody &&
            onStageSelected != null) ...[
          const SizedBox(height: AppSpacing.xl),
          _StageNavigation(
            currentStage: stage,
            onPressed: () => onStageSelected!(stage == 9 ? 0 : stage + 1),
          ),
        ],
      ],
    );
  }

  Widget _stageBody(int stage) => switch (stage) {
    1 => _HeroStage(
      location: location,
      onStart: onStageSelected == null ? null : () => onStageSelected!(2),
    ),
    2 => _OverviewStage(location: location),
    3 => _ListStage(
      stage: 3,
      icon: Icons.history_edu_rounded,
      title: 'Lịch sử',
      subtitle:
          'Timeline các mốc nội dung, có ảnh, mô tả ngắn và thông tin mở rộng.',
      emptyMessage: 'Nội dung lịch sử đang được cập nhật.',
      items: location.history,
      builder: (item, index) => _TimelineCard(
        index: index,
        title: _fallback(item.string('title'), 'Mốc lịch sử ${index + 1}'),
        eyebrow: item.string('period_label'),
        description: _paragraphs([
          item.string('short_description'),
          item.string('long_description'),
        ]),
        media: item.jsonObject('media'),
        details: [
          ('Nhân vật liên quan', item.string('related_people')),
          ('Danh mục', item.stringList('categories').join(' · ')),
          ('Bạn có biết?', item.string('fun_fact')),
        ],
      ),
    ),
    4 => _ListStage(
      stage: 4,
      icon: Icons.pin_drop_rounded,
      title: 'Điểm đến nổi bật',
      subtitle:
          'Các postcard nhỏ cho từng điểm đáng chú ý trong địa điểm đang xem.',
      emptyMessage: 'Chưa có điểm đến nổi bật để hiển thị.',
      items: location.highlights,
      builder: (item, index) => _ContentCard(
        title: _fallback(item.string('name'), 'Điểm đến ${index + 1}'),
        eyebrow: _inline([item.string('korean_name'), item.string('tagline')]),
        description: _paragraphs([
          item.string('short_description'),
          item.string('long_description'),
        ]),
        media: item.jsonObject('media'),
        details: [
          ('Địa chỉ', item.string('address')),
          ('Hoạt động', item.stringList('activities').join(' · ')),
          ('Danh mục', item.stringList('categories').join(' · ')),
          ('Bạn có biết?', item.string('fun_fact')),
        ],
      ),
    ),
    5 => Column(
      children: [
        _ListStage(
          stage: 5,
          icon: Icons.celebration_rounded,
          title: 'Trải nghiệm văn hóa',
          subtitle:
              'Story card có nguồn gốc, dấu hiệu nhận biết và gợi ý ứng xử.',
          emptyMessage: 'Chưa có trải nghiệm văn hóa để hiển thị.',
          items: location.experiences,
          builder: (item, index) => _ContentCard(
            title: _fallback(item.string('name'), 'Trải nghiệm ${index + 1}'),
            eyebrow: item.string('korean_name'),
            description: _paragraphs([
              item.string('short_description'),
              item.string('long_description'),
            ]),
            media: item.jsonObject('media'),
            wideMedia: true,
            details: [
              ('Nguồn gốc & ý nghĩa', item.string('origin_meaning')),
              (
                'Dấu hiệu nhận biết',
                item.stringList('recognizable_features').join(' · '),
              ),
              ('Nên làm', item.stringList('dos').join(' · ')),
              ('Không nên làm', item.stringList('donts').join(' · ')),
              ('Trải nghiệm liên quan', item.string('related_experience')),
            ],
          ),
        ),
        if (location.cultureGuidelines.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _GuidelineStage(items: location.cultureGuidelines),
        ],
      ],
    ),
    6 => _ListStage(
      stage: 6,
      icon: Icons.restaurant_rounded,
      title: 'Ẩm thực',
      subtitle:
          'Grid món ăn dùng ảnh lớn, chip nguyên liệu/hương vị và nơi trải nghiệm.',
      emptyMessage: 'Chưa có nội dung ẩm thực để hiển thị.',
      items: location.foods,
      asGrid: true,
      builder: (item, index) => _FoodCard(
        title: _fallback(item.string('name'), 'Món ăn ${index + 1}'),
        eyebrow: item.string('korean_name'),
        description: _paragraphs([
          item.string('short_description'),
          item.string('long_description'),
        ]),
        media: item.jsonObject('media'),
        chips: [
          ...item.stringList('ingredients').take(3),
          ...item.stringList('flavors').take(2),
        ],
        details: [
          ('Điểm đặc biệt', item.string('special_feature')),
          ('Nơi trải nghiệm', item.stringList('experience_places').join(' · ')),
        ],
      ),
    ),
    7 => _FunFactsStage(items: location.funFacts),
    8 => _QuizStage(
      questions: location.quiz,
      onSubmitQuizAnswer: onSubmitQuizAnswer,
    ),
    9 => _TravelStage(location: location),
    _ => const SizedBox.shrink(),
  };
}

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({required this.location, required this.currentStage});
  final PublishedLocationDetail location;
  final int currentStage;

  @override
  Widget build(BuildContext context) => _Card(
    child: Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton.filledTonal(
          tooltip: 'Trở về bản đồ Hàn Quốc',
          onPressed: () => context.go('/explore'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.stitchText,
                ),
              ),
              Text(
                _inline([location.koreanName, location.englishName]),
                style: const TextStyle(color: AppColors.stitchMuted),
              ),
            ],
          ),
        ),
        _Chip(
          label: _fallback(location.region, location.city),
          icon: Icons.public_rounded,
        ),
        _Chip(
          label: 'Chặng $currentStage/9',
          icon: Icons.route_rounded,
          color: AppColors.palePink,
        ),
        _Chip(
          label: '${location.estimatedDurationMinutes ?? 30} phút',
          icon: Icons.timelapse_rounded,
        ),
        IconButton.outlined(
          tooltip: 'Lưu địa điểm',
          onPressed: () {},
          icon: const Icon(Icons.bookmark_add_outlined),
        ),
      ],
    ),
  );
}

class JourneyStepper extends StatelessWidget {
  const JourneyStepper({
    required this.currentStage,
    this.onStageSelected,
    super.key,
  });

  final int currentStage;
  final ValueChanged<int>? onStageSelected;

  static const stages = [
    (Icons.play_circle_rounded, 'Mở đầu'),
    (Icons.explore_rounded, 'Tổng quan'),
    (Icons.history_edu_rounded, 'Lịch sử'),
    (Icons.pin_drop_rounded, 'Điểm đến'),
    (Icons.celebration_rounded, 'Trải nghiệm'),
    (Icons.restaurant_rounded, 'Ẩm thực'),
    (Icons.lightbulb_rounded, 'Fun Facts'),
    (Icons.quiz_rounded, 'Quiz'),
    (Icons.flight_takeoff_rounded, 'Du lịch'),
  ];

  @override
  Widget build(BuildContext context) => _Card(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < stages.length; index++) ...[
            _StageStep(
              number: index + 1,
              icon: stages[index].$1,
              label: stages[index].$2,
              isCurrent: index + 1 == currentStage,
              isCompleted: index + 1 < currentStage,
              onTap: onStageSelected == null
                  ? null
                  : () => onStageSelected!(index + 1),
            ),
            if (index != stages.length - 1)
              Container(
                width: 28,
                height: 2,
                color: index + 1 < currentStage
                    ? AppColors.completedGreen
                    : AppColors.borderSoft,
              ),
          ],
        ],
      ),
    ),
  );
}

class _StageStep extends StatelessWidget {
  const _StageStep({
    required this.number,
    required this.icon,
    required this.label,
    required this.isCurrent,
    required this.isCompleted,
    this.onTap,
  });

  final int number;
  final IconData icon;
  final String label;
  final bool isCurrent;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isCurrent
        ? AppColors.koreanRed
        : isCompleted
        ? AppColors.completedGreen
        : AppColors.stitchMuted;
    return Semantics(
      button: onTap != null,
      label: 'Chặng $number: $label',
      selected: isCurrent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: SizedBox(
          width: 84,
          child: Column(
            children: [
              CircleAvatar(
                radius: isCurrent ? 21 : 18,
                backgroundColor: isCurrent || isCompleted
                    ? color
                    : Colors.white,
                foregroundColor: isCurrent || isCompleted
                    ? Colors.white
                    : color,
                child: Icon(isCompleted ? Icons.check_rounded : icon, size: 18),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$number. $label',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageNavigation extends StatelessWidget {
  const _StageNavigation({required this.currentStage, required this.onPressed});

  final int currentStage;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = currentStage == 9
        ? 'Trở về bản đồ Hàn Quốc'
        : 'Tiếp tục đến ${JourneyStepper.stages[currentStage].$2}';
    return Align(
      alignment: Alignment.centerRight,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(
          currentStage == 9 ? Icons.map_outlined : Icons.arrow_forward_rounded,
        ),
        label: Text(label),
      ),
    );
  }
}

class _HeroStage extends StatelessWidget {
  const _HeroStage({required this.location, this.onStart});
  final PublishedLocationDetail location;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) => _Stage(
    stage: 1,
    icon: Icons.play_circle_rounded,
    title: 'Mở đầu hành trình',
    subtitle:
        'Khung media lớn tạo cảm xúc trước khi người học bước vào các chặng khám phá.',
    child: LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;
        final media = _Media(
          media: location.coverMedia,
          fallbackLabel: location.name,
          large: true,
        );
        final info = _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Chip(
                label: _fallback(location.locationType, 'Địa điểm khám phá'),
                icon: Icons.style_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                location.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.stitchText,
                ),
              ),
              if (location.koreanName.isNotEmpty)
                Text(
                  location.koreanName,
                  style: const TextStyle(
                    color: AppColors.koreanBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              Text(
                location.shortDescription,
                style: const TextStyle(
                  color: AppColors.stitchMuted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Bắt đầu khám phá'),
              ),
            ],
          ),
        );
        return wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: media),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(flex: 4, child: info),
                ],
              )
            : Column(
                children: [
                  media,
                  const SizedBox(height: AppSpacing.lg),
                  info,
                ],
              );
      },
    ),
  );
}

class _OverviewStage extends StatelessWidget {
  const _OverviewStage({required this.location});
  final PublishedLocationDetail location;

  @override
  Widget build(BuildContext context) => _Stage(
    stage: 2,
    icon: Icons.explore_rounded,
    title: 'Tổng quan',
    subtitle:
        'Bento layout cho thông tin nhận diện, mô tả, bản đồ nhỏ và fact nhanh.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 820;
            final media = Column(
              children: [
                _Media(
                  media: location.hookMedia.isEmpty
                      ? location.coverMedia
                      : location.hookMedia,
                  fallbackLabel: location.name,
                ),
                const SizedBox(height: AppSpacing.md),
                _MiniMap(location: location),
              ],
            );
            final identity = _Identity(location: location);
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: media),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(flex: 5, child: identity),
                    ],
                  )
                : Column(
                    children: [
                      media,
                      const SizedBox(height: AppSpacing.lg),
                      identity,
                    ],
                  );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        _QuickFacts(location: location),
      ],
    ),
  );
}

class _Identity extends StatelessWidget {
  const _Identity({required this.location});
  final PublishedLocationDetail location;

  @override
  Widget build(BuildContext context) => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin chung',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.stitchText),
        ),
        const SizedBox(height: AppSpacing.md),
        _InfoRow(
          icon: Icons.public_rounded,
          label: 'Khu vực',
          value: _inline([location.city, location.region, location.country]),
        ),
        _InfoRow(
          icon: Icons.signpost_rounded,
          label: 'Loại địa điểm',
          value: location.locationType,
        ),
        _InfoRow(
          icon: Icons.translate_rounded,
          label: 'Tên tiếng Anh',
          value: location.englishName,
        ),
        const Divider(height: AppSpacing.xl),
        Text(
          location.longDescription.isEmpty
              ? location.shortDescription
              : location.longDescription,
          style: const TextStyle(height: 1.65),
        ),
        if (location.tags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [for (final tag in location.tags) _Chip(label: '#$tag')],
          ),
        ],
      ],
    ),
  );
}

class _QuickFacts extends StatelessWidget {
  const _QuickFacts({required this.location});
  final PublishedLocationDetail location;

  @override
  Widget build(BuildContext context) {
    if (location.quickFacts.isEmpty) {
      return const _Empty('Chưa có thông tin nhanh để hiển thị.');
    }
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final fact in location.quickFacts)
          SizedBox(
            width: 230,
            child: _Card(
              color: AppColors.skyLight.withValues(alpha: .45),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fact.string('label'),
                    style: const TextStyle(
                      color: AppColors.stitchMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    fact.string('value'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.stitchText,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ListStage extends StatelessWidget {
  const _ListStage({
    required this.stage,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.items,
    required this.builder,
    this.asGrid = false,
  });

  final int stage;
  final IconData icon;
  final String title;
  final String subtitle;
  final String emptyMessage;
  final List<JsonMap> items;
  final Widget Function(JsonMap item, int index) builder;
  final bool asGrid;

  @override
  Widget build(BuildContext context) => _Stage(
    stage: stage,
    icon: icon,
    title: title,
    subtitle: subtitle,
    child: items.isEmpty
        ? _Empty(emptyMessage)
        : LayoutBuilder(
            builder: (context, constraints) {
              if (!asGrid || constraints.maxWidth < 760) {
                return Column(
                  children: [
                    for (var index = 0; index < items.length; index++) ...[
                      builder(items[index], index),
                      if (index != items.length - 1)
                        const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                );
              }
              final width = (constraints.maxWidth - AppSpacing.md * 2) / 3;
              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  for (var index = 0; index < items.length; index++)
                    SizedBox(width: width, child: builder(items[index], index)),
                ],
              );
            },
          ),
  );
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.index,
    required this.title,
    required this.description,
    required this.details,
    this.eyebrow = '',
    this.media = const {},
  });

  final int index;
  final String title;
  final String eyebrow;
  final String description;
  final JsonMap media;
  final List<(String, String)> details;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.palePink,
            foregroundColor: AppColors.koreanRed,
            child: Text(
              '${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Container(width: 2, height: 96, color: AppColors.borderSoft),
        ],
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: _ContentCard(
          title: title,
          eyebrow: eyebrow,
          description: description,
          media: media,
          details: details,
        ),
      ),
    ],
  );
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.title,
    required this.description,
    required this.details,
    this.eyebrow = '',
    this.media = const {},
    this.wideMedia = false,
  });

  final String title;
  final String eyebrow;
  final String description;
  final JsonMap media;
  final List<(String, String)> details;
  final bool wideMedia;

  @override
  Widget build(BuildContext context) => _Card(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final canSplit =
            wideMedia &&
            media.string('url').isNotEmpty &&
            constraints.maxWidth >= 720;
        final body = _ContentBody(
          title: title,
          eyebrow: eyebrow,
          description: description,
          details: details,
        );
        if (canSplit) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 280,
                child: _Media(
                  media: media,
                  fallbackLabel: title,
                  compact: true,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: body),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (media.string('url').isNotEmpty) ...[
              _Media(media: media, fallbackLabel: title, compact: true),
              const SizedBox(height: AppSpacing.md),
            ],
            body,
          ],
        );
      },
    ),
  );
}

class _ContentBody extends StatelessWidget {
  const _ContentBody({
    required this.title,
    required this.description,
    required this.details,
    this.eyebrow = '',
  });

  final String title;
  final String eyebrow;
  final String description;
  final List<(String, String)> details;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (eyebrow.isNotEmpty)
        Text(
          eyebrow,
          style: const TextStyle(
            color: AppColors.koreanBlue,
            fontWeight: FontWeight.w800,
          ),
        ),
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: AppColors.stitchText),
      ),
      if (description.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: const TextStyle(height: 1.6, color: AppColors.stitchMuted),
        ),
      ],
      _DetailRows(entries: details),
    ],
  );
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({
    required this.title,
    required this.description,
    required this.details,
    required this.chips,
    this.eyebrow = '',
    this.media = const {},
  });

  final String title;
  final String eyebrow;
  final String description;
  final JsonMap media;
  final List<String> chips;
  final List<(String, String)> details;

  @override
  Widget build(BuildContext context) => _Card(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Media(
          media: media,
          fallbackLabel: title,
          compact: true,
          roundedBottom: false,
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow.isNotEmpty)
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: AppColors.koreanBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.stitchText),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.stitchMuted,
                  height: 1.5,
                ),
              ),
              if (chips.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [for (final chip in chips) _Chip(label: chip)],
                ),
              ],
              _DetailRows(entries: details),
            ],
          ),
        ),
      ],
    ),
  );
}

class _GuidelineStage extends StatelessWidget {
  const _GuidelineStage({required this.items});
  final List<JsonMap> items;

  @override
  Widget build(BuildContext context) => _Stage(
    stage: null,
    icon: Icons.volunteer_activism_rounded,
    title: 'Ứng xử văn hóa',
    subtitle:
        'Các ghi chú nên làm và không nên làm được tách thành thẻ dễ quét.',
    child: Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final item in items)
          SizedBox(
            width: 360,
            child: _Card(
              color: item.string('kind') == 'dont'
                  ? AppColors.palePink.withValues(alpha: .5)
                  : AppColors.mint.withValues(alpha: .45),
              child: _InfoRow(
                icon: item.string('kind') == 'dont'
                    ? Icons.do_not_disturb_on_rounded
                    : Icons.check_circle_rounded,
                label: item.string('kind') == 'dont'
                    ? 'Không nên làm'
                    : 'Nên làm',
                value: item.string('content'),
              ),
            ),
          ),
      ],
    ),
  );
}

class _FunFactsStage extends StatelessWidget {
  const _FunFactsStage({required this.items});
  final List<JsonMap> items;

  @override
  Widget build(BuildContext context) => _Stage(
    stage: 7,
    icon: Icons.lightbulb_rounded,
    title: 'Fun Facts',
    subtitle: 'Các fact được trình bày như sticker/postcard sưu tầm.',
    child: items.isEmpty
        ? const _Empty('Chưa có fun fact để hiển thị.')
        : Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (var index = 0; index < items.length; index++)
                SizedBox(
                  width: 260,
                  child: _Card(
                    color: index < 2
                        ? Colors.white
                        : AppColors.skyLight.withValues(alpha: .45),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          index < 2
                              ? Icons.auto_awesome_rounded
                              : Icons.lock_outline_rounded,
                          color: index < 2
                              ? AppColors.koreanRed
                              : AppColors.lockedGray,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _fallback(
                            items[index].string('title'),
                            'Fun Fact ${index + 1}',
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.stitchText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          items[index].string('fact'),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.stitchMuted,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
  );
}

class _QuizStage extends StatelessWidget {
  const _QuizStage({required this.questions, required this.onSubmitQuizAnswer});
  final List<JsonMap> questions;
  final Future<QuizAnswerResult> Function(String questionId, JsonMap answer)
  onSubmitQuizAnswer;

  @override
  Widget build(BuildContext context) => _Stage(
    stage: 8,
    icon: Icons.quiz_rounded,
    title: 'Thử thách khám phá',
    subtitle:
        'Quiz hỗ trợ lựa chọn, đúng/sai, matching và sắp xếp. Trả lời sai vẫn hoàn thành nhiệm vụ.',
    child: questions.isEmpty
        ? const _Empty('Chưa có câu hỏi quiz để hiển thị.')
        : Column(
            children: [
              _Card(
                color: AppColors.skyLight.withValues(alpha: .45),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: AppColors.koreanRed),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${questions.length} nhiệm vụ · +20 XP khi chính xác · +5 XP khi hoàn thành',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final question in questions) ...[
                _QuizCard(
                  key: ValueKey(question.string('id')),
                  question: question,
                  onSubmit: (answer) =>
                      onSubmitQuizAnswer(question.string('id'), answer),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
  );
}

class _TravelStage extends StatelessWidget {
  const _TravelStage({required this.location});
  final PublishedLocationDetail location;

  @override
  Widget build(BuildContext context) {
    final travel = location.travel;
    final transports = travel.mapList('transport_options');
    final notes = travel.mapList('visitor_notes');
    return _Stage(
      stage: 9,
      icon: Icons.flight_takeoff_rounded,
      title: 'Thông tin du lịch',
      subtitle:
          'Các thông tin thay đổi theo thời gian luôn đi kèm nguồn và ngày cập nhật.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _TravelFact(
                icon: Icons.schedule_rounded,
                label: 'Giờ mở cửa',
                value: travel.string('opening_hours'),
              ),
              _TravelFact(
                icon: Icons.confirmation_number_rounded,
                label: 'Giá vé',
                value: travel.string('ticket_price'),
              ),
              _TravelFact(
                icon: Icons.timer_rounded,
                label: 'Thời lượng',
                value: travel.string('recommended_duration'),
              ),
              _TravelFact(
                icon: Icons.wb_sunny_rounded,
                label: 'Thời điểm đẹp',
                value: travel.string('best_time_to_visit'),
              ),
            ],
          ),
          if (transports.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            for (final item in transports) ...[
              _ContentCard(
                title: _fallback(item.string('title'), 'Cách di chuyển'),
                eyebrow: item.string('mode'),
                description: item.string('instructions'),
                details: [('Mẹo', item.string('tip'))],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _Card(
              color: AppColors.butter.withValues(alpha: .24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lưu ý cho du khách',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.stitchText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final note in notes)
                    _InfoRow(
                      icon: Icons.check_rounded,
                      label: 'Lưu ý',
                      value: note.string('content'),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _Card(
            color: AppColors.palePink.withValues(alpha: .42),
            child: const Text(
              'Thông tin có thể thay đổi. Hãy kiểm tra nguồn chính thức trước khi đi.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _TravelFact extends StatelessWidget {
  const _TravelFact({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 260,
    child: _Card(
      child: _InfoRow(
        icon: icon,
        label: label,
        value: value.isEmpty ? 'Đang cập nhật' : value,
      ),
    ),
  );
}

class _Stage extends StatelessWidget {
  const _Stage({
    required this.stage,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final int? stage;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.palePink,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Icon(icon, color: AppColors.koreanRed),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stage != null)
                    Text(
                      'CHẶNG ${stage!.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: AppColors.koreanRed,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        fontSize: 12,
                      ),
                    ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.stitchText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.stitchMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        child,
      ],
    ),
  );
}

class _Media extends StatelessWidget {
  const _Media({
    required this.media,
    required this.fallbackLabel,
    this.large = false,
    this.compact = false,
    this.roundedBottom = true,
  });
  final JsonMap media;
  final String fallbackLabel;
  final bool large;
  final bool compact;
  final bool roundedBottom;

  @override
  Widget build(BuildContext context) {
    final url = media.string('url');
    final radius = BorderRadius.vertical(
      top: const Radius.circular(24),
      bottom: Radius.circular(roundedBottom ? 24 : 0),
    );
    final aspect = large
        ? 16 / 8
        : compact
        ? 16 / 10
        : 16 / 9;
    if (media.string('kind') == 'youtube' && url.isNotEmpty) {
      return Semantics(
        label: media.string('alt').isEmpty ? 'Video ' : media.string('alt'),
        child: YoutubePlayer(url: url, label: fallbackLabel),
      );
    }
    return ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: aspect,
        child: url.isEmpty
            ? _MediaPlaceholder(label: fallbackLabel, large: large)
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    optimizedImageUrl(url, maxWidth: large ? 1280 : 720),
                    fit: BoxFit.cover,
                    semanticLabel: media.string('alt').isEmpty
                        ? fallbackLabel
                        : media.string('alt'),
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : const ColoredBox(
                            color: AppColors.skyLight,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                    errorBuilder: (context, error, stackTrace) =>
                        _MediaPlaceholder(label: fallbackLabel, large: large),
                  ),
                  if (large)
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xAA111B32)],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _MediaPlaceholder extends StatelessWidget {
  const _MediaPlaceholder({required this.label, required this.large});

  final String label;
  final bool large;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.skyLight,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: large ? 56 : 36,
              color: AppColors.koreanBlue,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ảnh đang được cập nhật',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.stitchText,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.stitchMuted),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MiniMap extends StatelessWidget {
  const _MiniMap({required this.location});
  final PublishedLocationDetail location;

  @override
  Widget build(BuildContext context) => _Card(
    color: AppColors.skyLight.withValues(alpha: .45),
    child: Row(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: const Icon(
            Icons.map_rounded,
            color: AppColors.koreanBlue,
            size: 38,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bản đồ khu vực',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.stitchText,
                ),
              ),
              Text(
                _inline([location.city, location.region, location.country]),
                style: const TextStyle(color: AppColors.stitchMuted),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.skyLight,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(icon, size: 18, color: AppColors.koreanBlue),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.stitchMuted,
                    letterSpacing: .6,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.stitchText,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRows extends StatelessWidget {
  const _DetailRows({required this.entries});
  final List<(String, String)> entries;

  @override
  Widget build(BuildContext context) {
    final visible = entries
        .where((entry) => entry.$2.isNotEmpty)
        .toList(growable: false);
    if (visible.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(
                    context,
                  ).style.copyWith(height: 1.5, color: AppColors.stitchMuted),
                  children: [
                    TextSpan(
                      text: '${entry.$1}: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.stitchText,
                      ),
                    ),
                    TextSpan(text: entry.$2),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon, this.color});
  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: color ?? AppColors.skyLight,
      borderRadius: BorderRadius.circular(AppRadius.round),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: AppColors.koreanBlue),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.stitchText,
          ),
        ),
      ],
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color ?? Colors.white.withValues(alpha: .88),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.borderSoft),
      boxShadow: AppShadows.small,
    ),
    child: Padding(padding: padding, child: child),
  );
}

class _Empty extends StatelessWidget {
  const _Empty(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => _Card(
    color: AppColors.skyLight.withValues(alpha: .36),
    child: Row(
      children: [
        const Icon(Icons.hourglass_empty_rounded, color: AppColors.koreanBlue),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: AppColors.stitchMuted),
          ),
        ),
      ],
    ),
  );
}

class _QuizCard extends StatefulWidget {
  const _QuizCard({required this.question, required this.onSubmit, super.key});
  final JsonMap question;
  final Future<QuizAnswerResult> Function(JsonMap answer) onSubmit;

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard> {
  String? _optionId;
  final Map<String, String> _matches = {};
  late List<JsonMap> _orderedItems;
  QuizAnswerResult? _result;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _orderedItems = widget.question.mapList('ordering_items');
  }

  @override
  Widget build(BuildContext context) {
    final kind = widget.question.string('kind');
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Chip(
            label: _fallback(widget.question.string('category'), kind),
            icon: Icons.psychology_alt_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.question.string('prompt'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.stitchText),
          ),
          const SizedBox(height: AppSpacing.md),
          if (kind == 'single_choice' || kind == 'true_false') _options(),
          if (kind == 'matching') _matching(),
          if (kind == 'ordering') _ordering(),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: const Text('Kiểm tra đáp án'),
          ),
          if (_result != null) ...[
            const SizedBox(height: AppSpacing.md),
            _Card(
              color: _result!.isCorrect
                  ? AppColors.mint.withValues(alpha: .45)
                  : AppColors.palePink.withValues(alpha: .5),
              child: _InfoRow(
                icon: _result!.isCorrect
                    ? Icons.check_circle_rounded
                    : Icons.info_rounded,
                label: _result!.isCorrect
                    ? 'Chính xác!'
                    : 'Chưa chính xác, nhưng nhiệm vụ vẫn được hoàn thành.',
                value: _result!.explanation,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _options() => Column(
    children: [
      for (final option in widget.question.mapList('options'))
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: InkWell(
            onTap: () => setState(() => _optionId = option.string('id')),
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: _optionId == option.string('id')
                    ? AppColors.skyLight
                    : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(
                  color: _optionId == option.string('id')
                      ? AppColors.koreanBlue
                      : AppColors.borderSoft,
                  width: 2,
                ),
              ),
              child: Text(
                option.string('text'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
    ],
  );

  Widget _matching() {
    final rightItems = widget.question.mapList('matching_right');
    return Column(
      children: [
        for (final left in widget.question.mapList('matching_left'))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: DropdownButtonFormField<String>(
              initialValue: _matches[left.string('id')],
              decoration: InputDecoration(labelText: left.string('text')),
              items: [
                for (final right in rightItems)
                  DropdownMenuItem(
                    value: right.string('text'),
                    child: Text(right.string('text')),
                  ),
              ],
              onChanged: (value) => setState(
                () => value == null
                    ? _matches.remove(left.string('id'))
                    : _matches[left.string('id')] = value,
              ),
            ),
          ),
      ],
    );
  }

  Widget _ordering() => Column(
    children: [
      for (var index = 0; index < _orderedItems.length; index++)
        ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(_orderedItems[index].string('text')),
          trailing: Wrap(
            children: [
              IconButton(
                tooltip: 'Đưa lên',
                onPressed: index == 0
                    ? null
                    : () => _moveItem(index, index - 1),
                icon: const Icon(Icons.keyboard_arrow_up_rounded),
              ),
              IconButton(
                tooltip: 'Đưa xuống',
                onPressed: index == _orderedItems.length - 1
                    ? null
                    : () => _moveItem(index, index + 1),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
            ],
          ),
        ),
    ],
  );

  void _moveItem(int from, int to) => setState(() {
    final item = _orderedItems.removeAt(from);
    _orderedItems.insert(to, item);
  });

  Future<void> _submit() async {
    final kind = widget.question.string('kind');
    final JsonMap answer = switch (kind) {
      'single_choice' || 'true_false' => {'option_id': _optionId},
      'matching' => {
        'pairs': _matches.entries
            .map((entry) => {'left_id': entry.key, 'right_text': entry.value})
            .toList(),
      },
      'ordering' => {
        'item_ids': _orderedItems.map((item) => item.string('id')).toList(),
      },
      _ => <String, dynamic>{},
    };
    setState(() => _submitting = true);
    try {
      final result = await widget.onSubmit(answer);
      if (mounted) setState(() => _result = result);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể chấm quiz: $error')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

String _fallback(String value, String fallback) =>
    value.trim().isEmpty ? fallback : value;
String _inline(Iterable<String> values) =>
    values.where((value) => value.trim().isNotEmpty).join(' · ');
String _paragraphs(Iterable<String> values) =>
    values.where((value) => value.trim().isNotEmpty).join('\n\n');

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/core/responsive/responsive_breakpoints.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/app_structure.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/shadows/app_shadows.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  final _howItWorksKey = GlobalKey();

  void _showHowItWorks() {
    final target = _howItWorksKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(locationsProvider);
    return AppScaffold(
      body: locationsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (_, _) => ErrorState(
          message: 'Không thể tải dữ liệu địa điểm cho trang giới thiệu.',
          onRetry: () => ref.invalidate(locationsProvider),
        ),
        data: (locations) {
          if (locations.isEmpty) {
            return const ErrorState(
              message: 'Chưa có địa điểm để bắt đầu hành trình.',
            );
          }
          return _LandingContent(
            locations: locations,
            howItWorksKey: _howItWorksKey,
            onShowHowItWorks: _showHowItWorks,
          );
        },
      ),
    );
  }
}

class _LandingContent extends ConsumerWidget {
  const _LandingContent({
    required this.locations,
    required this.howItWorksKey,
    required this.onShowHowItWorks,
  });

  final List<Location> locations;
  final GlobalKey howItWorksKey;
  final VoidCallback onShowHowItWorks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = locations.firstWhere(
      (location) => location.status == LocationStatus.inProgress,
      orElse: () => locations.first,
    );
    final journey = ref.watch(journeyProvider(active.id)).value;
    final missions = ref.watch(missionsProvider(active.id)).value ?? const [];

    return SingleChildScrollView(
      child: CustomPaint(
        painter: const _DotPatternPainter(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroSection(
              active: active,
              locations: locations,
              progress: journey?.percentage ?? 0,
              onShowHowItWorks: onShowHowItWorks,
            ),
            const _FeatureStrip(),
            _HowItWorksSection(key: howItWorksKey, missions: missions),
            _FeaturedLocations(locations: locations, active: active),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.active,
    required this.locations,
    required this.progress,
    required this.onShowHowItWorks,
  });

  final Location active;
  final List<Location> locations;
  final double progress;
  final VoidCallback onShowHowItWorks;

  @override
  Widget build(BuildContext context) => ResponsiveContent(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.section),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < ResponsiveBreakpoints.desktop;
          final mobile = constraints.maxWidth < ResponsiveBreakpoints.mobile;
          final copy = _HeroCopy(
            compact: compact,
            onShowHowItWorks: onShowHowItWorks,
          );
          final map = _QuestMap(
            active: active,
            locations: locations,
            progress: progress,
            compact: compact,
            mobile: mobile,
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                copy,
                const SizedBox(height: AppSpacing.xxl),
                map,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 102, child: copy),
              const SizedBox(width: AppSpacing.xxl),
              Expanded(flex: 98, child: map),
            ],
          );
        },
      ),
    ),
  );
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.compact, required this.onShowHowItWorks});

  final bool compact;
  final VoidCallback onShowHowItWorks;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _Eyebrow(label: 'Khám phá Hàn Quốc theo cách của bạn'),
      const SizedBox(height: AppSpacing.md),
      Text.rich(
        const TextSpan(
          children: [
            TextSpan(text: 'Mỗi điểm đến,\n'),
            TextSpan(
              text: 'một chương phiêu lưu.',
              style: TextStyle(color: AppColors.coral),
            ),
          ],
        ),
        style: compact
            ? Theme.of(context).textTheme.displaySmall
            : Theme.of(context).textTheme.displayLarge,
      ),
      const SizedBox(height: AppSpacing.lg),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 630),
        child: Text(
          'Đọc chuyện xưa, giải thử thách nhỏ và sưu tầm dấu mộc độc đáo qua từng địa danh nổi tiếng của Hàn Quốc.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          PrimaryButton(
            label: 'Bắt đầu hành trình',
            onPressed: () => context.go('/register'),
          ),
          SecondaryButton(
            label: 'Xem cách hoạt động',
            icon: Icons.play_circle_outline_rounded,
            onPressed: onShowHowItWorks,
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.xl),
      const _TrustRow(),
    ],
  );
}

class _TrustRow extends StatelessWidget {
  const _TrustRow();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(
        width: 80,
        height: 34,
        child: Stack(
          children: [
            _MiniAvatar(initial: 'D', color: AppColors.teal),
            Positioned(
              left: 23,
              child: _MiniAvatar(initial: 'M', color: AppColors.gold),
            ),
            Positioned(
              left: 46,
              child: _MiniAvatar(initial: 'N', color: AppColors.coral),
            ),
          ],
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Flexible(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Học qua trải nghiệm\n',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const TextSpan(text: 'Không áp lực, luôn có phần thưởng'),
            ],
          ),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ),
    ],
  );
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.initial, required this.color});

  final String initial;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      border: Border.all(color: AppColors.cream, width: 2),
    ),
    child: Text(
      initial,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _QuestMap extends StatelessWidget {
  const _QuestMap({
    required this.active,
    required this.locations,
    required this.progress,
    required this.compact,
    required this.mobile,
  });

  final Location active;
  final List<Location> locations;
  final double progress;
  final bool compact;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final mapLocations = locations.take(4).toList();
    return Container(
      width: double.infinity,
      height: mobile ? 390 : (compact ? 450 : 480),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.warmMap, AppColors.paper],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.large * 2),
          topRight: Radius.circular(AppRadius.large * 2),
          bottomRight: Radius.circular(AppRadius.large * 2),
          bottomLeft: Radius.circular(AppRadius.large * 4.5),
        ),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.large,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final positions = mobile
              ? const [(.12, .39), (.68, .24), (.72, .57), (.24, .68)]
              : const [(.18, .36), (.70, .23), (.74, .58), (.27, .72)];
          return Stack(
            children: [
              const Positioned.fill(child: CustomPaint(painter: _MapPainter())),
              Positioned(
                left: AppSpacing.xl,
                top: AppSpacing.lg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bản đồ phiêu lưu',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      mapLocations.map((item) => item.city).toSet().join(' → '),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              for (var index = 0; index < mapLocations.length; index++)
                Positioned(
                  left: constraints.maxWidth * positions[index].$1,
                  top: constraints.maxHeight * positions[index].$2,
                  child: _MapNode(
                    location: mapLocations[index],
                    active: mapLocations[index].id == active.id,
                  ),
                ),
              Positioned(
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: SizedBox(
                  width: math.min(190, constraints.maxWidth * .48),
                  child: _QuestTicket(active: active, progress: progress),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MapNode extends StatelessWidget {
  const _MapNode({required this.location, required this.active});

  final Location location;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final locked = location.status == LocationStatus.locked;
    final color = locked
        ? AppColors.disabled
        : active
        ? AppColors.coral
        : location.status == LocationStatus.completed
        ? AppColors.teal
        : AppColors.gold;
    final icon = locked
        ? Icons.lock_rounded
        : location.status == LocationStatus.completed
        ? Icons.check_rounded
        : Icons.location_on_rounded;
    return Semantics(
      label: '${location.name}, ${location.status.name}',
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 5),
              boxShadow: AppShadows.small,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 120),
            margin: const EdgeInsets.only(top: AppSpacing.xxs),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Text(
              location.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestTicket extends StatelessWidget {
  const _QuestTicket({required this.active, required this.progress});

  final Location active;
  final double progress;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.navy,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      boxShadow: AppShadows.small,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hành trình hiện tại',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .66),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          active.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.round),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: Colors.white.withValues(alpha: .18),
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          '${(progress * 100).round()}% hoàn thành',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .66),
            fontSize: 9,
          ),
        ),
      ],
    ),
  );
}

class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final water = Paint()..color = AppColors.water;
    canvas.save();
    canvas.rotate(-.08);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .88, size.height * .42),
        width: size.width * .64,
        height: size.height * 1.08,
      ),
      water,
    );
    canvas.restore();

    final land = Paint()..color = AppColors.land;
    final landPath = Path()
      ..moveTo(size.width * .47, size.height * .14)
      ..cubicTo(
        size.width * .67,
        size.height * .18,
        size.width * .67,
        size.height * .48,
        size.width * .60,
        size.height * .66,
      )
      ..cubicTo(
        size.width * .54,
        size.height * .84,
        size.width * .38,
        size.height * .76,
        size.width * .40,
        size.height * .53,
      )
      ..cubicTo(
        size.width * .42,
        size.height * .34,
        size.width * .37,
        size.height * .18,
        size.width * .47,
        size.height * .14,
      )
      ..close();
    canvas.drawPath(landPath, land);

    final route = Path()
      ..moveTo(size.width * .22, size.height * .45)
      ..cubicTo(
        size.width * .36,
        size.height * .10,
        size.width * .76,
        size.height * .15,
        size.width * .77,
        size.height * .62,
      )
      ..cubicTo(
        size.width * .67,
        size.height * .78,
        size.width * .43,
        size.height * .83,
        size.width * .30,
        size.height * .76,
      );
    final routePaint = Paint()
      ..color = AppColors.coral
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (final metric in route.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, math.min(distance + 7, metric.length)),
          routePaint,
        );
        distance += 14;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FeatureStrip extends StatelessWidget {
  const _FeatureStrip();

  static const _features = [
    (
      Icons.explore_outlined,
      'Khám phá theo hành trình',
      'Không học rời rạc, luôn có mục tiêu tiếp theo',
    ),
    (
      Icons.auto_awesome_rounded,
      'Tích XP & lên cấp',
      'Mỗi câu trả lời đều giúp bạn tiến lên',
    ),
    (
      Icons.approval_outlined,
      'Sưu tầm dấu mộc',
      'Lưu giữ ký ức tại từng điểm đến',
    ),
  ];

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.navy,
    child: ResponsiveContent(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < ResponsiveBreakpoints.desktop;
          final children = [
            for (var index = 0; index < _features.length; index++)
              _FeatureItem(
                icon: _features[index].$1,
                title: _features[index].$2,
                description: _features[index].$3,
                showDivider: index != _features.length - 1,
                verticalDivider: !compact,
              ),
          ];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: compact
                ? Column(children: children)
                : Row(
                    children: [
                      for (final child in children) Expanded(child: child),
                    ],
                  ),
          );
        },
      ),
    ),
  );
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.showDivider,
    required this.verticalDivider,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool showDivider;
  final bool verticalDivider;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      border: showDivider
          ? Border(
              right: verticalDivider
                  ? BorderSide(color: Colors.white.withValues(alpha: .14))
                  : BorderSide.none,
              bottom: verticalDivider
                  ? BorderSide.none
                  : BorderSide(color: Colors.white.withValues(alpha: .14)),
            )
          : null,
    ),
    child: Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .68),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection({required this.missions, super.key});

  final List<Mission> missions;

  @override
  Widget build(BuildContext context) => ResponsiveContent(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.section),
      child: Column(
        children: [
          const _SectionHeading(
            eyebrow: 'Ba chặng khám phá',
            title: 'Văn hóa không chỉ để đọc.\nNó là một cuộc chơi.',
            description:
                'Mỗi địa điểm là một câu chuyện gồm ba chặng ngắn, trực quan và có phần thưởng rõ ràng.',
          ),
          const SizedBox(height: AppSpacing.xl),
          if (missions.isEmpty)
            const LoadingIndicator()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final mobile =
                    constraints.maxWidth < ResponsiveBreakpoints.mobile;
                final tablet =
                    constraints.maxWidth < ResponsiveBreakpoints.desktop;
                final columns = mobile ? 1 : (tablet ? 2 : 3);
                final width =
                    (constraints.maxWidth - AppSpacing.lg * (columns - 1)) /
                    columns;
                return Wrap(
                  spacing: AppSpacing.lg,
                  runSpacing: AppSpacing.lg,
                  children: [
                    for (var index = 0; index < missions.length; index++)
                      SizedBox(
                        width: width,
                        child: _StageCard(
                          mission: missions[index],
                          index: index,
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    ),
  );
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.mission, required this.index});

  final Mission mission;
  final int index;

  @override
  Widget build(BuildContext context) {
    final details = switch (mission.stage) {
      JourneyStage.checkIn => (
        Icons.location_searching_rounded,
        AppColors.coral,
        'Xem hình ảnh, video và những lát cắt lịch sử quan trọng trước khi trả lời câu hỏi mở màn.',
      ),
      JourneyStage.culture => (
        Icons.temple_buddhist_outlined,
        AppColors.teal,
        'Hiểu nghi lễ, kiến trúc và câu chuyện đời sống qua nhiệm vụ tương tác ngắn.',
      ),
      JourneyStage.vocabulary => (
        Icons.translate_rounded,
        AppColors.gold,
        'Ghi nhớ từ mới theo đúng bối cảnh và hoàn tất thử thách cuối để nhận dấu mộc.',
      ),
      JourneyStage.summary => (
        Icons.emoji_events_outlined,
        AppColors.green,
        'Tổng kết hành trình và ghi nhận những phần thưởng bạn đã chinh phục.',
      ),
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.small,
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: -AppSpacing.md,
            child: Text(
              '0${index + 1}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppColors.navy.withValues(alpha: .05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: details.$2.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(AppRadius.large),
                ),
                child: Icon(details.$1, color: details.$2),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                mission.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                details.$3,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                child: Text(
                  '+${mission.rewardXp} XP',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturedLocations extends StatelessWidget {
  const _FeaturedLocations({required this.locations, required this.active});

  final List<Location> locations;
  final Location active;

  @override
  Widget build(BuildContext context) {
    final ordered = [
      active,
      ...locations.where((location) => location.id != active.id),
    ].take(3).toList();
    return ColoredBox(
      color: AppColors.creamDark,
      child: ResponsiveContent(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.section),
          child: Column(
            children: [
              const _SectionHeading(
                eyebrow: 'Điểm đến nổi bật',
                title: 'Chọn nơi câu chuyện bắt đầu',
                description:
                    'Tiếp tục hành trình hiện tại hoặc mở một câu chuyện văn hóa mới.',
              ),
              const SizedBox(height: AppSpacing.xl),
              LayoutBuilder(
                builder: (context, constraints) {
                  final mobile =
                      constraints.maxWidth < ResponsiveBreakpoints.mobile;
                  final tablet =
                      constraints.maxWidth < ResponsiveBreakpoints.desktop;
                  if (mobile) {
                    return Column(
                      children: [
                        for (
                          var index = 0;
                          index < ordered.length;
                          index++
                        ) ...[
                          _LocationCard(
                            location: ordered[index],
                            featured: index == 0,
                            palette: index,
                          ),
                          if (index != ordered.length - 1)
                            const SizedBox(height: AppSpacing.lg),
                        ],
                      ],
                    );
                  }
                  if (tablet) {
                    return Column(
                      children: [
                        _LocationCard(
                          location: ordered.first,
                          featured: true,
                          palette: 0,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            for (
                              var index = 1;
                              index < ordered.length;
                              index++
                            ) ...[
                              Expanded(
                                child: _LocationCard(
                                  location: ordered[index],
                                  featured: false,
                                  palette: index,
                                ),
                              ),
                              if (index != ordered.length - 1)
                                const SizedBox(width: AppSpacing.lg),
                            ],
                          ],
                        ),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var index = 0; index < ordered.length; index++) ...[
                        Expanded(
                          flex: index == 0 ? 11 : 9,
                          child: _LocationCard(
                            location: ordered[index],
                            featured: index == 0,
                            palette: index,
                          ),
                        ),
                        if (index != ordered.length - 1)
                          const SizedBox(width: AppSpacing.lg),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.featured,
    required this.palette,
  });

  final Location location;
  final bool featured;
  final int palette;

  @override
  Widget build(BuildContext context) {
    final colors = switch (palette) {
      0 => const [AppColors.navy, AppColors.locationBlue],
      1 => const [AppColors.locationClay, AppColors.locationPeach],
      _ => const [AppColors.locationTeal, AppColors.locationMint],
    };
    final locked = location.status == LocationStatus.locked;
    final status = switch (location.status) {
      LocationStatus.completed => 'Đã hoàn thành',
      LocationStatus.inProgress => 'Đang thực hiện',
      LocationStatus.available => 'Có thể khám phá',
      LocationStatus.locked => 'Chưa mở khóa',
    };
    return Container(
      height: featured ? 410 : 330,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(AppRadius.large + AppSpacing.xxs),
        boxShadow: AppShadows.small,
      ),
      child: Stack(
        children: [
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: 90,
            child: const _PalaceSilhouette(),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.footer.withValues(alpha: .92),
                  ],
                  stops: const [.34, 1],
                ),
              ),
            ),
          ),
          Positioned(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .9),
                    borderRadius: BorderRadius.circular(AppRadius.round),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: .72),
                    borderRadius: BorderRadius.circular(AppRadius.round),
                  ),
                  child: Text(
                    '${location.rewardXp} XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: featured ? 27 : 23,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${location.city} · ${location.description}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .74),
                    fontSize: 12,
                  ),
                ),
                if (featured) ...[
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Tiếp tục hành trình',
                    onPressed: locked
                        ? null
                        : () => context.go('/journey/${location.id}'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PalaceSilhouette extends StatelessWidget {
  const _PalaceSilhouette();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 80,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .12),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.round),
          ),
        ),
      ),
      Container(
        width: 150,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .16),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.round),
          ),
        ),
      ),
      Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .20),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.round),
          ),
        ),
      ),
    ],
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 720),
    child: Column(
      children: [
        _Eyebrow(label: eyebrow, centered: true),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
        ),
      ],
    ),
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.label, this.centered = false});

  final String label;
  final bool centered;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: centered
        ? MainAxisAlignment.center
        : MainAxisAlignment.start,
    children: [
      Container(width: 28, height: 2, color: AppColors.coral),
      const SizedBox(width: AppSpacing.xs),
      Flexible(
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.coral,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
      ),
    ],
  );
}

class _DotPatternPainter extends CustomPainter {
  const _DotPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.line.withValues(alpha: .32);
    const gap = 23.0;
    for (var x = 0.0; x < size.width; x += gap) {
      for (var y = 0.0; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), .8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

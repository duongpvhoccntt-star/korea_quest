import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/progress_components.dart';
import 'package:korea_quest/design_system/components/app_scroll_view.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/shadows/app_shadows.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final progressAsync = ref.watch(userProgressProvider);
    final locationsAsync = ref.watch(locationsProvider);

    if (userAsync.isLoading ||
        progressAsync.isLoading ||
        locationsAsync.isLoading) {
      return const LoadingIndicator();
    }
    if (userAsync.hasError ||
        progressAsync.hasError ||
        locationsAsync.hasError) {
      return ErrorState(
        message: 'Không thể đọc dữ liệu hành trình.',
        onRetry: () => ref.invalidate(koreaQuestRepositoryProvider),
      );
    }

    final user = userAsync.requireValue;
    final progress = progressAsync.requireValue;
    final locations = locationsAsync.requireValue;
    final active = _activeLocation(locations);

    return ColoredBox(
      color: AppColors.pageBg,
      child: AppScrollView(
        child: ResponsiveContent(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1040;
                final left = _JourneySidePanel(
                  user: user,
                  progress: progress,
                  locations: locations,
                  active: active,
                );
                final map = _StitchMapCanvas(
                  locations: locations,
                  active: active,
                );
                if (!wide) {
                  return Column(
                    children: [
                      left,
                      const SizedBox(height: AppSpacing.lg),
                      map,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 360, child: left),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(child: map),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Location _activeLocation(List<Location> locations) {
    for (final location in locations) {
      if (location.status == LocationStatus.inProgress) return location;
    }
    return locations.isEmpty
        ? const Location(
            id: 'gyeongbokgung',
            name: 'Bản đồ Hàn Quốc',
            koreanName: '한국 지도',
            city: 'KoreaQuest',
            description: 'Chọn địa điểm đầu tiên để bắt đầu hành trình.',
            status: LocationStatus.available,
            rewardXp: 240,
          )
        : locations.first;
  }
}

class _JourneySidePanel extends StatelessWidget {
  const _JourneySidePanel({
    required this.user,
    required this.progress,
    required this.locations,
    required this.active,
  });

  final AppUser user;
  final UserProgress progress;
  final List<Location> locations;
  final Location active;

  @override
  Widget build(BuildContext context) {
    final completed = locations
        .where((item) => item.status == LocationStatus.completed)
        .length;
    final total = locations.isEmpty ? 12 : locations.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Surface(
          padding: const EdgeInsets.all(32),
          child: Stack(
            children: [
              Positioned(
                right: -52,
                top: -52,
                child: _Glow(
                  color: AppColors.palePink.withValues(alpha: .58),
                  size: 150,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bạn muốn bắt đầu từ đâu?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.stitchText,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Khám phá văn hóa Hàn Quốc qua từng địa danh. ${user.displayName}, hành trình của bạn đang chờ đón!',
                    style: const TextStyle(
                      color: AppColors.stitchMuted,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ProgressPostcard(
                    completed: completed,
                    total: total,
                    progress: progress,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _RoundActionButton(
                    label: 'Tiếp tục hành trình',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => context.go('/journey/${active.id}'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader(title: 'Gợi ý cho bạn', action: 'Xem tất cả'),
        const SizedBox(height: AppSpacing.sm),
        for (final location in locations.take(2)) ...[
          _SuggestionCard(location: location),
          const SizedBox(height: AppSpacing.md),
        ],
        _BadgeCollection(progress: progress),
      ],
    );
  }
}

class _ProgressPostcard extends StatelessWidget {
  const _ProgressPostcard({
    required this.completed,
    required this.total,
    required this.progress,
  });

  final int completed;
  final int total;
  final UserProgress progress;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.skyLight.withValues(alpha: .34),
      borderRadius: BorderRadius.circular(AppRadius.large),
      border: Border.all(color: AppColors.borderSoft),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tiến độ khám phá',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  '$completed/$total Huy hiệu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: AppColors.koreanRed,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.round),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : completed / total,
              minHeight: 10,
              color: AppColors.koreanRed,
              backgroundColor: AppColors.borderSoft,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: LevelBadge(level: progress.level),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${progress.currentXp} XP',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.stitchMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.location});

  final Location location;

  @override
  Widget build(BuildContext context) => _Surface(
    padding: const EdgeInsets.all(AppSpacing.md),
    child: InkWell(
      onTap: () => context.go('/journey/${location.id}'),
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _statusColor(location.status).withValues(alpha: .16),
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: Icon(
              _statusIcon(location.status),
              color: _statusColor(location.status),
              size: 34,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniTag(
                  label: location.city,
                  color: AppColors.skyLight,
                  foreground: AppColors.koreanBlue,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  location.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  location.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.stitchMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.go('/journey/${location.id}'),
            icon: const Icon(Icons.bookmark_add_rounded),
            color: AppColors.koreanRed,
          ),
        ],
      ),
    ),
  );
}

class _BadgeCollection extends StatelessWidget {
  const _BadgeCollection({required this.progress});

  final UserProgress progress;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.skyLight.withValues(alpha: .3),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.borderSoft),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bộ sưu tập huy hiệu',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final item in [
                Icons.local_dining_rounded,
                Icons.stadium_rounded,
                Icons.train_rounded,
              ])
                _BadgeBubble(icon: item, unlocked: true),
              for (var i = 0; i < 2; i++)
                const _BadgeBubble(icon: Icons.lock_rounded, unlocked: false),
            ],
          ),
        ],
      ),
    ),
  );
}

class _StitchMapCanvas extends StatelessWidget {
  const _StitchMapCanvas({required this.locations, required this.active});

  final List<Location> locations;
  final Location active;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 640),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: AppColors.borderSoft),
      boxShadow: AppShadows.small,
    ),
    clipBehavior: Clip.antiAlias,
    child: Stack(
      children: [
        const Positioned.fill(child: _KoreaMapBackdrop()),
        Positioned(
          top: AppSpacing.lg,
          left: AppSpacing.lg,
          child: _FilterPills(),
        ),
        const Positioned(
          right: AppSpacing.lg,
          bottom: 128,
          child: _MapControls(),
        ),
        _MapMarker(
          alignment: const Alignment(-.42, -.55),
          label: 'Thủ đô Seoul',
          subtitle: 'Đã hoàn thành',
          status: LocationStatus.completed,
          icon: Icons.location_city_rounded,
          onTap: () => context.go(
            '/journey/${locations.isEmpty ? active.id : locations.first.id}',
          ),
        ),
        _MapMarker(
          alignment: const Alignment(-.52, .72),
          label: active.name,
          subtitle: 'Đang khám phá',
          status: LocationStatus.inProgress,
          icon: Icons.spa_rounded,
          emphasized: true,
          onTap: () => context.go('/journey/${active.id}'),
        ),
        const _MapMarker(
          alignment: Alignment(.58, .32),
          label: 'Thành phố Busan',
          subtitle: 'Chưa mở khóa',
          status: LocationStatus.locked,
          icon: Icons.lock_rounded,
        ),
        Positioned(
          bottom: AppSpacing.lg,
          left: 0,
          right: 0,
          child: Center(child: _CurrentStageCard(location: active)),
        ),
      ],
    ),
  );
}

class _KoreaMapBackdrop extends StatelessWidget {
  const _KoreaMapBackdrop();

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      painter: _KoreaMapPainter(),
      isComplex: true,
      willChange: false,
      child: const SizedBox.expand(),
    ),
  );
}

class _KoreaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF8F1), Color(0xFFF1ECE4)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final land = Paint()..color = AppColors.mint.withValues(alpha: .34);
    final border = Paint()
      ..color = AppColors.koreanBlue.withValues(alpha: .45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final path = Path()
      ..moveTo(size.width * .48, size.height * .08)
      ..cubicTo(
        size.width * .34,
        size.height * .16,
        size.width * .33,
        size.height * .34,
        size.width * .41,
        size.height * .46,
      )
      ..cubicTo(
        size.width * .30,
        size.height * .58,
        size.width * .38,
        size.height * .75,
        size.width * .54,
        size.height * .83,
      )
      ..cubicTo(
        size.width * .68,
        size.height * .74,
        size.width * .72,
        size.height * .53,
        size.width * .62,
        size.height * .40,
      )
      ..cubicTo(
        size.width * .73,
        size.height * .27,
        size.width * .64,
        size.height * .11,
        size.width * .48,
        size.height * .08,
      )
      ..close();
    canvas.drawPath(path, land);
    canvas.drawPath(path, border);

    final route = Paint()
      ..color = AppColors.koreanBlue.withValues(alpha: .5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final routePath = Path()
      ..moveTo(size.width * .30, size.height * .25)
      ..quadraticBezierTo(
        size.width * .38,
        size.height * .48,
        size.width * .52,
        size.height * .70,
      )
      ..quadraticBezierTo(
        size.width * .60,
        size.height * .80,
        size.width * .70,
        size.height * .84,
      );
    canvas.drawPath(routePath, route);

    final sticker = Paint()..color = AppColors.palePink.withValues(alpha: .46);
    canvas.drawCircle(Offset(size.width * .82, size.height * .15), 38, sticker);
    canvas.drawCircle(
      Offset(size.width * .17, size.height * .88),
      52,
      Paint()..color = AppColors.skyLight.withValues(alpha: .7),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FilterPills extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _FloatingSurface(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _MapFilter(label: 'Tất cả', selected: true),
        _MapFilter(label: 'Đã xong'),
        _MapFilter(label: 'Chưa mở'),
      ],
    ),
  );
}

class _MapFilter extends StatelessWidget {
  const _MapFilter({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(4),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? AppColors.skyLight : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.round),
        border: selected
            ? Border.all(color: AppColors.koreanBlue, width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.koreanBlue : AppColors.stitchMuted,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    ),
  );
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.alignment,
    required this.label,
    required this.subtitle,
    required this.status,
    required this.icon,
    this.emphasized = false,
    this.onTap,
  });

  final Alignment alignment;
  final String label;
  final String subtitle;
  final LocationStatus status;
  final IconData icon;
  final bool emphasized;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Align(
      alignment: alignment,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FloatingSurface(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Column(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Stack(
              alignment: Alignment.center,
              children: [
                if (emphasized)
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: .14),
                    ),
                  ),
                Container(
                  width: emphasized ? 64 : 56,
                  height: emphasized ? 64 : 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: emphasized ? 4 : 3),
                    boxShadow: AppShadows.small,
                  ),
                  child: Icon(icon, color: color, size: emphasized ? 30 : 26),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentStageCard extends StatelessWidget {
  const _CurrentStageCard({required this.location});

  final Location location;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 430),
    child: _FloatingSurface(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.skyLight,
                borderRadius: BorderRadius.circular(AppRadius.large),
                border: Border.all(
                  color: AppColors.koreanBlue.withValues(alpha: .22),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chặng',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '04',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    location.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.stitchMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filled(
              onPressed: () => context.go('/journey/${location.id}'),
              icon: const Icon(Icons.play_arrow_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.koreanRed,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MapControls extends StatelessWidget {
  const _MapControls();

  @override
  Widget build(BuildContext context) => Column(
    children: const [
      _CircleControl(icon: Icons.add_rounded),
      SizedBox(height: AppSpacing.xs),
      _CircleControl(icon: Icons.remove_rounded),
      SizedBox(height: AppSpacing.sm),
      _CircleControl(
        icon: Icons.my_location_rounded,
        color: AppColors.koreanRed,
      ),
    ],
  );
}

class _CircleControl extends StatelessWidget {
  const _CircleControl({required this.icon, this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: AppShadows.small,
    ),
    child: SizedBox(
      width: 48,
      height: 48,
      child: Icon(icon, color: color ?? AppColors.stitchText),
    ),
  );
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    icon: Icon(icon),
    label: Text(label),
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.koreanRed,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.stitchText,
          fontWeight: FontWeight.w900,
        ),
      ),
      const Spacer(),
      Text(
        action,
        style: const TextStyle(
          color: AppColors.koreanRed,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    ],
  );
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({
    required this.label,
    required this.color,
    required this.foreground,
  });

  final String label;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(AppRadius.round),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 4,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    ),
  );
}

class _BadgeBubble extends StatelessWidget {
  const _BadgeBubble({required this.icon, required this.unlocked});

  final IconData icon;
  final bool unlocked;

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(
        color: unlocked ? AppColors.completedGreen : AppColors.lockedGray,
      ),
      boxShadow: AppShadows.small,
    ),
    child: Icon(
      icon,
      color: unlocked ? AppColors.completedGreen : AppColors.lockedGray,
    ),
  );
}

class _FloatingSurface extends StatelessWidget {
  const _FloatingSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(AppRadius.round),
      border: Border.all(color: AppColors.borderSoft),
      boxShadow: AppShadows.small,
    ),
    child: child,
  );
}

class _Surface extends StatelessWidget {
  const _Surface({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.borderSoft),
      boxShadow: AppShadows.small,
    ),
    child: Padding(padding: padding, child: child),
  );
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

Color _statusColor(LocationStatus status) => switch (status) {
  LocationStatus.completed => AppColors.completedGreen,
  LocationStatus.inProgress => AppColors.koreanBlue,
  LocationStatus.available => AppColors.koreanRed,
  LocationStatus.locked => AppColors.lockedGray,
};

IconData _statusIcon(LocationStatus status) => switch (status) {
  LocationStatus.completed => Icons.check_circle_rounded,
  LocationStatus.inProgress => Icons.explore_rounded,
  LocationStatus.available => Icons.temple_buddhist_rounded,
  LocationStatus.locked => Icons.lock_rounded,
};

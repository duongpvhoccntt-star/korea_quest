import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/core/utils/optimized_image_url.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/app_scroll_view.dart';
import 'package:korea_quest/design_system/components/progress_components.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/shadows/app_shadows.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';
import 'package:korea_quest/features/explore/presentation/providers/location_content_providers.dart';
import 'package:korea_quest/l10n/app_strings.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';

const _allFilter = '__all__';
const _comingSoonFilter = '__coming_soon__';

class PublishedExplorePage extends ConsumerStatefulWidget {
  const PublishedExplorePage({super.key});

  @override
  ConsumerState<PublishedExplorePage> createState() =>
      _PublishedExplorePageState();
}

class _PublishedExplorePageState extends ConsumerState<PublishedExplorePage> {
  String _query = '';
  String _filter = _allFilter;
  String? _selectedSlug;

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(publishedLocationsProvider);
    final achievements = ref.watch(earnedAchievementsProvider);
    final user = ref.watch(currentUserProvider).value;
    final progress = ref.watch(userProgressProvider).value;
    final personalLocations = ref.watch(locationsProvider).value;
    if (achievements.isLoading) {
      return const Center(child: LoadingIndicator());
    }
    if (achievements.hasError) {
      return const Center(
        child: ErrorState(message: 'Không thể tải huy hiệu đã nhận.'),
      );
    }
    return locations.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ErrorState(
            message: appStrings(context).loadMapError(error.toString()),
            onRetry: () => ref.invalidate(publishedLocationsProvider),
          ),
        ),
      ),
      data: (items) => _buildDashboard(
        items,
        achievements.requireValue,
        user: user,
        progress: progress,
        personalLocations: personalLocations,
      ),
    );
  }

  Widget _buildDashboard(
    List<PublishedLocationSummary> items,
    List<Achievement> achievements, {
    required AppUser? user,
    required UserProgress? progress,
    required List<Location>? personalLocations,
  }) {
    final filters = _filtersFor(items);
    final visible = _filtered(items);
    final selected = _selectedLocation(visible, items);
    final personal = _personalOverview(
      items,
      selected: selected,
      user: user,
      progress: progress,
      personalLocations: personalLocations,
    );
    final isWide = MediaQuery.sizeOf(context).width >= 1050;

    return ColoredBox(
      color: AppColors.pageBg,
      child: AppScrollView(
        child: ResponsiveContent(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 360,
                        child: _SideRail(
                          total: items.length,
                          visible: visible,
                          selected: selected,
                          achievements: achievements,
                          personal: personal,
                          onExplore: _openLocation,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(
                        child: _MapExperience(
                          locations: visible,
                          selected: selected,
                          query: _query,
                          filters: filters,
                          selectedFilter: _filter,
                          onQueryChanged: (value) =>
                              setState(() => _query = value),
                          onFilterChanged: (value) =>
                              setState(() => _filter = value),
                          onSelect: (location) =>
                              setState(() => _selectedSlug = location.slug),
                          onExplore: _openLocation,
                        ),
                      ),
                    ],
                  )
                else ...[
                  _IntroPanel(
                    total: personal.total,
                    personal: personal,
                    onExplore: _openLocation,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _MapExperience(
                    locations: visible,
                    selected: selected,
                    query: _query,
                    filters: filters,
                    selectedFilter: _filter,
                    onQueryChanged: (value) => setState(() => _query = value),
                    onFilterChanged: (value) => setState(() => _filter = value),
                    onSelect: (location) =>
                        setState(() => _selectedSlug = location.slug),
                    onExplore: _openLocation,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _RecommendationStrip(
                    locations: items,
                    onExplore: _openLocation,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _BadgeCollection(
                    total: items.length,
                    achievements: achievements,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _filtersFor(List<PublishedLocationSummary> items) {
    final values = <String>{
      _allFilter,
      _comingSoonFilter,
      ...items
          .expand((item) => [item.city, ...item.categories])
          .where((item) => item.isNotEmpty),
    };
    return values.take(12).toList(growable: false);
  }

  List<PublishedLocationSummary> _filtered(
    List<PublishedLocationSummary> items,
  ) {
    final query = _query.trim().toLowerCase();
    return items
        .where((item) {
          final matchesQuery =
              query.isEmpty ||
              [
                item.name,
                item.koreanName,
                item.city,
                item.shortDescription,
                ...item.categories,
              ].join(' ').toLowerCase().contains(query);
          final matchesFilter = switch (_filter) {
            _allFilter => true,
            _comingSoonFilter => !item.isReleased,
            _ => item.city == _filter || item.categories.contains(_filter),
          };
          return matchesQuery && matchesFilter;
        })
        .toList(growable: false);
  }

  PublishedLocationSummary? _selectedLocation(
    List<PublishedLocationSummary> visible,
    List<PublishedLocationSummary> all,
  ) {
    if (visible.isEmpty) return null;
    final selected = visible
        .where((item) => item.slug == _selectedSlug)
        .firstOrNull;
    return selected ??
        visible.firstWhere(
          (item) => item.isReleased,
          orElse: () => visible.first,
        );
  }

  _PersonalOverview _personalOverview(
    List<PublishedLocationSummary> items, {
    required PublishedLocationSummary? selected,
    required AppUser? user,
    required UserProgress? progress,
    required List<Location>? personalLocations,
  }) {
    final released = items.where((item) => item.isReleased).toList();
    final personalById = {
      for (final location in personalLocations ?? const <Location>[])
        location.id: location,
    };
    final completed = personalLocations == null
        ? null
        : released
              .where(
                (item) =>
                    personalById[item.slug]?.status == LocationStatus.completed,
              )
              .length;

    PublishedLocationSummary? active;
    if (personalLocations != null) {
      for (final location in personalLocations) {
        if (location.status != LocationStatus.inProgress) continue;
        for (final item in released) {
          if (item.slug == location.id) {
            active = item;
            break;
          }
        }
        if (active != null) break;
      }
    }

    final selectedReleased = selected?.isReleased == true ? selected : null;
    return _PersonalOverview(
      user: user,
      progress: progress,
      completed: completed,
      total: released.length,
      target: active ?? selectedReleased ?? released.firstOrNull,
      hasActiveJourney: active != null,
    );
  }

  void _openLocation(PublishedLocationSummary location) {
    if (!location.isReleased) return;
    context.go('/locations/${location.slug}');
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({
    required this.total,
    required this.visible,
    required this.selected,
    required this.achievements,
    required this.personal,
    required this.onExplore,
  });

  final int total;
  final List<PublishedLocationSummary> visible;
  final PublishedLocationSummary? selected;
  final List<Achievement> achievements;
  final _PersonalOverview personal;
  final ValueChanged<PublishedLocationSummary> onExplore;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _IntroPanel(
        total: personal.total,
        personal: personal,
        onExplore: onExplore,
      ),
      const SizedBox(height: AppSpacing.lg),
      _RecommendationStrip(locations: visible, onExplore: onExplore),
      const SizedBox(height: AppSpacing.lg),
      _BadgeCollection(total: total, achievements: achievements),
      if (selected != null) ...[
        const SizedBox(height: AppSpacing.lg),
        _MiniJourneyCard(location: selected!, onExplore: onExplore),
      ],
    ],
  );
}

class _IntroPanel extends StatelessWidget {
  const _IntroPanel({
    required this.total,
    required this.personal,
    required this.onExplore,
  });

  final int total;
  final _PersonalOverview personal;
  final ValueChanged<PublishedLocationSummary> onExplore;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow(appStrings(context).exploreKorea),
        const SizedBox(height: AppSpacing.sm),
        Text(
          appStrings(context).whereStart,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.stitchText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          personal.user == null
              ? appStrings(context).exploreIntro
              : appStrings(
                  context,
                ).exploreHeroDescription(personal.user!.displayName),
          style: const TextStyle(color: AppColors.stitchMuted, height: 1.6),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ProgressBlock(
          total: total,
          completed: personal.completed,
          progress: personal.progress,
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: personal.target == null
                ? null
                : () => onExplore(personal.target!),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              personal.hasActiveJourney
                  ? appStrings(context).continueJourney
                  : appStrings(context).startExploring,
            ),
          ),
        ),
      ],
    ),
  );
}

class _MapExperience extends StatelessWidget {
  const _MapExperience({
    required this.locations,
    required this.selected,
    required this.query,
    required this.filters,
    required this.selectedFilter,
    required this.onQueryChanged,
    required this.onFilterChanged,
    required this.onSelect,
    required this.onExplore,
  });

  final List<PublishedLocationSummary> locations;
  final PublishedLocationSummary? selected;
  final String query;
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<PublishedLocationSummary> onSelect;
  final ValueChanged<PublishedLocationSummary> onExplore;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: onQueryChanged,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        hintText: appStrings(context).searchLocationsHint,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filledTonal(
                    tooltip: appStrings(context).locationList,
                    onPressed: () {},
                    icon: const Icon(Icons.format_list_bulleted_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final filter in filters) ...[
                      ChoiceChip(
                        label: Text(
                          filter == _allFilter
                              ? appStrings(context).all
                              : filter == _comingSoonFilter
                              ? appStrings(context).comingSoon
                              : filter,
                        ),
                        selected: filter == selectedFilter,
                        onSelected: (_) => onFilterChanged(filter),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (locations.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: EmptyState(
              title: appStrings(context).noMatchingLocations,
              message: appStrings(context).changeSearchOrFilter,
            ),
          )
        else
          SizedBox(
            height: MediaQuery.sizeOf(context).width >= 700 ? 620 : 560,
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _KoreaMapPainter(),
                        isComplex: true,
                        willChange: false,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: AppSpacing.lg,
                    left: AppSpacing.lg,
                    child: _MapControls(),
                  ),
                  for (
                    var index = 0;
                    index < math.min(locations.length, 10);
                    index++
                  )
                    _MapMarker(
                      location: locations[index],
                      position:
                          _markerPositions[index % _markerPositions.length],
                      canvasSize: constraints.biggest,
                      status: _statusFor(locations[index], selected),
                      onTap: () => onSelect(locations[index]),
                    ),
                  if (selected != null)
                    Positioned(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: AppSpacing.lg,
                      child: _DestinationPreviewCard(
                        location: selected!,
                        onExplore: () => onExplore(selected!),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    ),
  );

  static _MarkerStatus _statusFor(
    PublishedLocationSummary item,
    PublishedLocationSummary? selected,
  ) {
    if (!item.isReleased) return _MarkerStatus.comingSoon;
    if (selected?.slug == item.slug) return _MarkerStatus.selected;
    return _MarkerStatus.available;
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.location,
    required this.position,
    required this.canvasSize,
    required this.status,
    required this.onTap,
  });

  final PublishedLocationSummary location;
  final Offset position;
  final Size canvasSize;
  final _MarkerStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      _MarkerStatus.selected => AppColors.koreanBlue,
      _MarkerStatus.comingSoon => AppColors.disabled,
      _ => AppColors.blossom,
    };
    final size = status == _MarkerStatus.selected ? 72.0 : 56.0;
    final safeMaxLeft = math.max(8.0, canvasSize.width - size - 8.0);
    final safeMaxTop = math.max(72.0, canvasSize.height - size - 160.0);
    final left = (position.dx * canvasSize.width - size / 2).clamp(
      8.0,
      safeMaxLeft,
    );
    final top = (position.dy * canvasSize.height - size / 2).clamp(
      72.0,
      safeMaxTop,
    );

    return Positioned(
      left: left,
      top: top,
      child: Tooltip(
        message: '${location.name} · ${location.city}',
        child: Semantics(
          button: true,
          label: appStrings(context).chooseLocation(location.name),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.round),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: size,
              height: size,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: status == _MarkerStatus.comingSoon ? 2 : 4,
                ),
                boxShadow: AppShadows.small,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipOval(child: _LocationImage(location: location)),
                  if (status == _MarkerStatus.comingSoon)
                    const ColoredBox(
                      color: Color(0x88FFFFFF),
                      child: Icon(
                        Icons.schedule_rounded,
                        color: AppColors.disabled,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DestinationPreviewCard extends StatelessWidget {
  const _DestinationPreviewCard({
    required this.location,
    required this.onExplore,
  });

  final PublishedLocationSummary location;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 560;
      final image = ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: SizedBox(
          width: compact ? double.infinity : 92,
          height: compact ? 150 : 92,
          child: _LocationImage(location: location),
        ),
      );
      final details = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (location.koreanName.isNotEmpty)
            Text(
              location.koreanName,
              style: const TextStyle(
                color: AppColors.koreanBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          Text(
            location.name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.stitchText),
          ),
          Text(
            '${location.city} · ${location.shortDescription}',
            maxLines: compact ? 3 : 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.stitchMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _InfoPill(
                icon: Icons.timelapse_rounded,
                label: location.estimatedDurationMinutes == null
                    ? appStrings(context).durationUpdating
                    : appStrings(
                        context,
                      ).minutes(location.estimatedDurationMinutes!),
              ),
              for (final category in location.categories.take(2))
                _InfoPill(label: category),
            ],
          ),
        ],
      );
      final action = FilledButton.icon(
        onPressed: location.isReleased ? onExplore : null,
        icon: const Icon(Icons.explore_rounded),
        label: Text(appStrings(context).explore),
      );

      return _SurfaceCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  image,
                  const SizedBox(height: AppSpacing.md),
                  details,
                  const SizedBox(height: AppSpacing.md),
                  action,
                ],
              )
            : Row(
                children: [
                  image,
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: details),
                  const SizedBox(width: AppSpacing.sm),
                  action,
                ],
              ),
      );
    },
  );
}

class _RecommendationStrip extends StatelessWidget {
  const _RecommendationStrip({
    required this.locations,
    required this.onExplore,
  });

  final List<PublishedLocationSummary> locations;
  final ValueChanged<PublishedLocationSummary> onExplore;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    padding: const EdgeInsets.all(AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                appStrings(context).recommendedForYou,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            TextButton(
              onPressed: () {},
              child: Text(appStrings(context).viewAll),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final item in locations.take(3)) ...[
          _SuggestionTile(location: item, onTap: () => onExplore(item)),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    ),
  );
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.location, required this.onTap});

  final PublishedLocationSummary location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: location.isReleased ? onTap : null,
    borderRadius: BorderRadius.circular(AppRadius.large),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.small),
          child: SizedBox.square(
            dimension: 64,
            child: _LocationImage(location: location),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                location.city,
                style: const TextStyle(
                  color: AppColors.stitchMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: appStrings(context).saveToJourney,
          onPressed: () {},
          icon: const Icon(Icons.bookmark_add_outlined),
        ),
      ],
    ),
  );
}

class _BadgeCollection extends StatelessWidget {
  const _BadgeCollection({required this.total, required this.achievements});

  final int total;
  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    color: AppColors.skyLight.withValues(alpha: .45),
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appStrings(context).journeyBadge,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.md),
        if (achievements.isEmpty)
          const Text(
            'Chưa nhận huy hiệu nào.',
            style: TextStyle(color: AppColors.stitchMuted),
          )
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final achievement in achievements)
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.completedGreen),
                  ),
                  child: Text(
                    achievement.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
            ],
          ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          appStrings(context).publishedLocationsWaiting(total),
          style: const TextStyle(color: AppColors.stitchMuted, fontSize: 12),
        ),
      ],
    ),
  );
}

class _MiniJourneyCard extends StatelessWidget {
  const _MiniJourneyCard({required this.location, required this.onExplore});

  final PublishedLocationSummary location;
  final ValueChanged<PublishedLocationSummary> onExplore;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    color: Colors.white.withValues(alpha: .94),
    padding: const EdgeInsets.all(AppSpacing.md),
    child: Row(
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.skyLight,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: AppColors.koreanBlue.withValues(alpha: .25),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appStrings(context).content,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  '09',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.koreanBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                appStrings(context).readyToExplore,
                style: const TextStyle(
                  color: AppColors.stitchMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton.filled(
          tooltip: appStrings(context).continueJourney,
          onPressed: location.isReleased ? () => onExplore(location) : null,
          icon: const Icon(Icons.play_arrow_rounded),
        ),
      ],
    ),
  );
}

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({
    required this.total,
    required this.completed,
    required this.progress,
  });

  final int total;
  final int? completed;
  final UserProgress? progress;

  @override
  Widget build(BuildContext context) {
    final hasPersonalProgress = completed != null && progress != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.skyLight.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasPersonalProgress
                  ? appStrings(context).explorationProgress
                  : appStrings(context).publishedLocations,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              hasPersonalProgress
                  ? appStrings(
                      context,
                    ).completedLocationsProgress(completed!, total)
                  : appStrings(context).locationCount(total),
              style: const TextStyle(
                color: AppColors.koreanRed,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (hasPersonalProgress) ...[
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.round),
                child: LinearProgressIndicator(
                  minHeight: 9,
                  value: total == 0 ? 0 : completed! / total,
                  backgroundColor: Colors.white,
                  color: AppColors.koreanRed,
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
                        child: LevelBadge(level: progress!.level),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${progress!.currentXp} XP',
                    style: const TextStyle(
                      color: AppColors.stitchMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PersonalOverview {
  const _PersonalOverview({
    required this.user,
    required this.progress,
    required this.completed,
    required this.total,
    required this.target,
    required this.hasActiveJourney,
  });

  final AppUser? user;
  final UserProgress? progress;
  final int? completed;
  final int total;
  final PublishedLocationSummary? target;
  final bool hasActiveJourney;
}

class _LocationImage extends StatelessWidget {
  const _LocationImage({required this.location});

  final PublishedLocationSummary location;

  @override
  Widget build(BuildContext context) {
    if (location.thumbnailUrl.isEmpty) {
      return const ColoredBox(
        color: AppColors.skyLight,
        child: Center(
          child: Icon(
            Icons.travel_explore_rounded,
            color: AppColors.koreanBlue,
          ),
        ),
      );
    }
    return Image.network(
      optimizedImageUrl(location.thumbnailUrl, maxWidth: 720),
      fit: BoxFit.cover,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      semanticLabel: location.thumbnailAlt.isEmpty
          ? location.name
          : location.thumbnailAlt,
      loadingBuilder: (context, child, loading) => loading == null
          ? child
          : const ColoredBox(
              color: AppColors.skyLight,
              child: Center(child: CircularProgressIndicator()),
            ),
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: AppColors.skyLight,
        child: Center(
          child: Icon(Icons.broken_image_outlined, color: AppColors.koreanBlue),
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, required this.padding, this.color});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.borderSoft),
      boxShadow: AppShadows.small,
    ),
    child: Padding(padding: padding, child: child),
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.koreanRed,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.2,
      fontSize: 12,
    ),
  );
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xxs,
    ),
    decoration: BoxDecoration(
      color: AppColors.palePink.withValues(alpha: .65),
      borderRadius: BorderRadius.circular(AppRadius.round),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: AppColors.koreanRed),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _MapControls extends StatelessWidget {
  const _MapControls();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .92),
      borderRadius: BorderRadius.circular(AppRadius.round),
      border: Border.all(color: AppColors.borderSoft),
      boxShadow: AppShadows.small,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: appStrings(context).zoomIn,
          onPressed: () {},
          icon: const Icon(Icons.add_rounded),
        ),
        IconButton(
          tooltip: appStrings(context).zoomOut,
          onPressed: () {},
          icon: const Icon(Icons.remove_rounded),
        ),
        IconButton(
          tooltip: appStrings(context).resetMap,
          onPressed: () {},
          icon: const Icon(Icons.my_location_rounded),
        ),
      ],
    ),
  );
}

class _KoreaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.pageBg, Color(0xFFF1E8DC)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
      bg,
    );

    final land = Paint()..color = AppColors.mint.withValues(alpha: .58);
    final coast = Paint()
      ..color = Colors.white.withValues(alpha: .75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final path = Path()
      ..moveTo(size.width * .46, size.height * .10)
      ..cubicTo(
        size.width * .60,
        size.height * .14,
        size.width * .66,
        size.height * .30,
        size.width * .60,
        size.height * .44,
      )
      ..cubicTo(
        size.width * .73,
        size.height * .56,
        size.width * .68,
        size.height * .74,
        size.width * .53,
        size.height * .80,
      )
      ..cubicTo(
        size.width * .40,
        size.height * .86,
        size.width * .31,
        size.height * .70,
        size.width * .38,
        size.height * .57,
      )
      ..cubicTo(
        size.width * .26,
        size.height * .45,
        size.width * .30,
        size.height * .24,
        size.width * .46,
        size.height * .10,
      )
      ..close();
    canvas.drawPath(path, coast);
    canvas.drawPath(path, land);

    final jeju = Rect.fromCenter(
      center: Offset(size.width * .34, size.height * .86),
      width: size.width * .18,
      height: size.height * .07,
    );
    canvas.drawOval(
      jeju.inflate(4),
      Paint()..color = Colors.white.withValues(alpha: .70),
    );
    canvas.drawOval(jeju, land);

    final route = Paint()
      ..color = AppColors.koreanBlue.withValues(alpha: .30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final routePath = Path()
      ..moveTo(size.width * .36, size.height * .25)
      ..quadraticBezierTo(
        size.width * .58,
        size.height * .36,
        size.width * .60,
        size.height * .62,
      )
      ..quadraticBezierTo(
        size.width * .50,
        size.height * .78,
        size.width * .34,
        size.height * .86,
      );
    canvas.drawPath(routePath, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _MarkerStatus { available, selected, comingSoon }

const _markerPositions = [
  Offset(.36, .22),
  Offset(.46, .28),
  Offset(.30, .76),
  Offset(.70, .62),
  Offset(.76, .70),
  Offset(.58, .48),
  Offset(.44, .58),
  Offset(.56, .20),
  Offset(.80, .46),
  Offset(.34, .48),
];

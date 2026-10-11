import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/core/utils/optimized_image_url.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/app_scroll_view.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/shadows/app_shadows.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';
import 'package:korea_quest/features/explore/presentation/providers/location_content_providers.dart';
import 'package:korea_quest/l10n/app_strings.dart';

const _allLocationsFilter = '__all__';
const _comingSoonLocationsFilter = '__coming_soon__';

class AllLocationsPage extends ConsumerStatefulWidget {
  const AllLocationsPage({super.key});

  @override
  ConsumerState<AllLocationsPage> createState() => _AllLocationsPageState();
}

class _AllLocationsPageState extends ConsumerState<AllLocationsPage> {
  String _query = '';
  String _filter = _allLocationsFilter;

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(publishedLocationsProvider);
    return locations.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ErrorState(
            message: appStrings(context).loadMapError(error.toString()),
            onRetry: () => ref.invalidate(publishedLocationsProvider),
          ),
        ),
      ),
      data: _buildPage,
    );
  }

  Widget _buildPage(List<PublishedLocationSummary> locations) {
    final filters = _filtersFor(locations);
    final visible = _filtered(locations);
    return ColoredBox(
      color: AppColors.pageBg,
      child: AppScrollView(
        child: ResponsiveContent(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: appStrings(context).explore,
                      onPressed: () => context.go('/explore'),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appStrings(context).locationList,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            appStrings(context).locationCount(locations.length),
                            style: const TextStyle(color: AppColors.stitchMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _LocationFilters(
                  filters: filters,
                  selectedFilter: _filter,
                  onFilterChanged: (value) => setState(() => _filter = value),
                  onQueryChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (visible.isEmpty)
                  EmptyState(
                    title: appStrings(context).noMatchingLocations,
                    message: appStrings(context).changeSearchOrFilter,
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) => GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: constraints.maxWidth < 560
                            ? constraints.maxWidth
                            : 330,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: .68,
                      ),
                      itemCount: visible.length,
                      itemBuilder: (context, index) => _AllLocationCard(
                        location: visible[index],
                        onExplore: () => context.go(
                          '/locations/${visible[index].slug}',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _filtersFor(List<PublishedLocationSummary> items) => <String>{
    _allLocationsFilter,
    _comingSoonLocationsFilter,
    ...items
        .expand((item) => [item.city, ...item.categories])
        .where((value) => value.isNotEmpty),
  }.take(12).toList(growable: false);

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
            _allLocationsFilter => true,
            _comingSoonLocationsFilter => !item.isReleased,
            _ => item.city == _filter || item.categories.contains(_filter),
          };
          return matchesQuery && matchesFilter;
        })
        .toList(growable: false);
  }
}

class _LocationFilters extends StatelessWidget {
  const _LocationFilters({
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onQueryChanged,
  });

  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        onChanged: onQueryChanged,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded),
          hintText: appStrings(context).searchLocationsHint,
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final filter in filters) ...[
              ChoiceChip(
                label: Text(
                  filter == _allLocationsFilter
                      ? appStrings(context).all
                      : filter == _comingSoonLocationsFilter
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
  );
}

class _AllLocationCard extends StatelessWidget {
  const _AllLocationCard({required this.location, required this.onExplore});

  final PublishedLocationSummary location;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) => Semantics(
    button: location.isReleased,
    label: location.name,
    child: Material(
      color: AppColors.paper,
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: InkWell(
        onTap: location.isReleased ? onExplore : null,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: AppColors.borderSoft),
            boxShadow: AppShadows.small,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.large),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _AllLocationsImage(location: location),
                      Positioned(
                        top: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: _ReleaseStatusBadge(isReleased: location.isReleased),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (location.koreanName.isNotEmpty)
                        Text(
                          location.koreanName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.koreanBlue),
                        ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        location.city,
                        style: const TextStyle(color: AppColors.stitchMuted),
                      ),
                      const Spacer(),
                      Wrap(
                        spacing: AppSpacing.xxs,
                        children: [
                          for (final category in location.categories.take(2))
                            Chip(label: Text(category)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: ValueKey('all-location-action-${location.slug}'),
                          onPressed: location.isReleased ? onExplore : null,
                          icon: Icon(
                            location.isReleased
                                ? Icons.explore_rounded
                                : Icons.schedule_rounded,
                          ),
                          label: Text(
                            location.isReleased
                                ? appStrings(context).explore
                                : appStrings(context).comingSoon,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ReleaseStatusBadge extends StatelessWidget {
  const _ReleaseStatusBadge({required this.isReleased});

  final bool isReleased;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: (isReleased ? AppColors.completedGreen : AppColors.gold).withValues(
        alpha: .94,
      ),
      borderRadius: BorderRadius.circular(AppRadius.round),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      child: Text(
        isReleased ? appStrings(context).explore : appStrings(context).comingSoon,
        style: const TextStyle(
          color: AppColors.paper,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _AllLocationsImage extends StatelessWidget {
  const _AllLocationsImage({required this.location});

  final PublishedLocationSummary location;

  @override
  Widget build(BuildContext context) {
    final originalUrl = location.thumbnailUrl.trim();
    if (originalUrl.isEmpty) return const _AllLocationsImageFallback();

    final optimizedUrl = optimizedImageUrl(originalUrl, maxWidth: 720);
    return _networkImage(
      optimizedUrl,
      retryOriginalUrl: optimizedUrl != originalUrl,
    );
  }

  Widget _networkImage(
    String url, {
    required bool retryOriginalUrl,
  }) => Image.network(
    url,
    fit: BoxFit.cover,
    webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
    semanticLabel: location.thumbnailAlt.isEmpty
        ? location.name
        : location.thumbnailAlt,
    errorBuilder: (_, _, _) => retryOriginalUrl
        ? _networkImage(location.thumbnailUrl.trim(), retryOriginalUrl: false)
        : const _AllLocationsImageFallback(),
  );
}

class _AllLocationsImageFallback extends StatelessWidget {
  const _AllLocationsImageFallback();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppColors.skyLight,
    child: Center(
      child: Icon(
        Icons.travel_explore_rounded,
        color: AppColors.koreanBlue,
        size: AppSpacing.xl,
      ),
    ),
  );
}

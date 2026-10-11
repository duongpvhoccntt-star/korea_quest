import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:korea_quest/app/app_config.dart';
import 'package:korea_quest/core/utils/optimized_image_url.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/shadows/app_shadows.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:latlong2/latlong.dart';

final koreaMapCenter = LatLng(36.35, 127.8);
final koreaMapBounds = LatLngBounds(LatLng(32.8, 124), LatLng(39.3, 132));

bool isInsideKoreaMapBounds(double latitude, double longitude) =>
    latitude >= 32.8 &&
    latitude <= 39.3 &&
    longitude >= 124 &&
    longitude <= 132;

bool isOutsideKoreaMainlandBounds(double latitude, double longitude) =>
    latitude < 34.4 ||
    latitude > 38.9 ||
    longitude < 125.1 ||
    longitude > 130.3;

class KoreaMapPlace {
  const KoreaMapPlace({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.thumbnailUrl,
    required this.thumbnailAlt,
    required this.latitude,
    required this.longitude,
    required this.isReleased,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String thumbnailUrl;
  final String thumbnailAlt;
  final double latitude;
  final double longitude;
  final bool isReleased;
  final bool isCompleted;

  bool get isOutsideMainland =>
      isOutsideKoreaMainlandBounds(latitude, longitude);
}

String? _tileUrl() {
  final key = AppConfig.mapTilerApiKey.trim();
  if (key.isEmpty) return null;
  return 'https://api.maptiler.com/maps/streets-v4/256/{z}/{x}/{y}.png?key=$key';
}

Widget _attribution() => RichAttributionWidget(
  attributions: [
    TextSourceAttribution('MapTiler'),
    TextSourceAttribution('OpenStreetMap contributors'),
  ],
);

class KoreaLocationsMap extends StatefulWidget {
  const KoreaLocationsMap({
    required this.places,
    required this.selectedPlaceId,
    required this.onPlaceSelected,
    required this.resetLabel,
    required this.remotePlacesLabel,
    required this.unavailableBuilder,
    super.key,
  });

  final List<KoreaMapPlace> places;
  final String? selectedPlaceId;
  final ValueChanged<String> onPlaceSelected;
  final String resetLabel;
  final String remotePlacesLabel;
  final WidgetBuilder unavailableBuilder;

  @override
  State<KoreaLocationsMap> createState() => _KoreaLocationsMapState();
}

class _KoreaLocationsMapState extends State<KoreaLocationsMap> {
  final _controller = MapController();

  List<Marker> get _markers => widget.places
      .map((place) {
        final selected = place.id == widget.selectedPlaceId;
        return Marker(
          point: LatLng(place.latitude, place.longitude),
          width: selected ? 80 : 64,
          height: selected ? 80 : 64,
          child: KoreaMapPlaceMarker(
            place: place,
            selected: selected,
            onTap: () => widget.onPlaceSelected(place.id),
          ),
        );
      })
      .toList(growable: false);

  List<KoreaMapPlace> get _remotePlaces => widget.places
      .where((place) => place.isOutsideMainland)
      .toList(growable: false);

  void _reset() => _controller.fitCamera(
    CameraFit.bounds(
      bounds: koreaMapBounds,
      padding: const EdgeInsets.all(AppSpacing.xl),
    ),
  );

  @override
  void didUpdateWidget(KoreaLocationsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPlaceId != null &&
        widget.selectedPlaceId != oldWidget.selectedPlaceId) {
      final selected = widget.places
          .where((place) => place.id == widget.selectedPlaceId)
          .firstOrNull;
      if (selected != null) {
        _controller.move(LatLng(selected.latitude, selected.longitude), 14);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tileUrl() == null) return widget.unavailableBuilder(context);
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.center_focus_strong_rounded),
              label: Text(widget.resetLabel),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.large),
            child: SizedBox(
              height: constraints.maxWidth < 600 ? 390 : 520,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _controller,
                    options: MapOptions(
                      initialCenter: koreaMapCenter,
                      initialZoom: constraints.maxWidth < 600 ? 5.6 : 6.2,
                      minZoom: 5,
                      maxZoom: 19,
                      cameraConstraint: CameraConstraint.contain(
                        bounds: koreaMapBounds,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: _tileUrl()!,
                        userAgentPackageName: 'com.koreaquest.app',
                      ),
                      MarkerClusterLayerWidget(
                        options: MarkerClusterLayerOptions(
                          markers: _markers,
                          maxClusterRadius: 45,
                          size: const Size(42, 42),
                          builder: (context, markers) => Container(
                            decoration: const BoxDecoration(
                              color: AppColors.koreanBlue,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${markers.length}',
                              style: const TextStyle(color: AppColors.paper),
                            ),
                          ),
                        ),
                      ),
                      _attribution(),
                    ],
                  ),
                  if (_remotePlaces.isNotEmpty)
                    Positioned(
                      left: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                      child: KoreaMapRemotePlacesInset(
                        label: widget.remotePlacesLabel,
                        places: _remotePlaces,
                        selectedPlaceId: widget.selectedPlaceId,
                        onSelected: widget.onPlaceSelected,
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
}

class KoreaMapRemotePlacesInset extends StatelessWidget {
  const KoreaMapRemotePlacesInset({
    required this.label,
    required this.places,
    required this.selectedPlaceId,
    required this.onSelected,
    super.key,
  });

  final String label;
  final List<KoreaMapPlace> places;
  final String? selectedPlaceId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.paper.withValues(alpha: .94),
    borderRadius: BorderRadius.circular(AppRadius.medium),
    elevation: 3,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.travel_explore_rounded,
                  size: 16,
                  color: AppColors.koreanBlue,
                ),
                const SizedBox(width: AppSpacing.xxs),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final place in places)
                  Tooltip(
                    message: place.title,
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: KoreaMapPlaceMarker(
                        place: place,
                        selected: place.id == selectedPlaceId,
                        compact: true,
                        onTap: () => onSelected(place.id),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class KoreaMapPlaceMarker extends StatelessWidget {
  const KoreaMapPlaceMarker({
    required this.place,
    required this.selected,
    required this.onTap,
    this.compact = false,
    super.key,
  });

  final KoreaMapPlace place;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact
        ? 40.0
        : selected
        ? 68.0
        : 54.0;
    final borderColor = selected
        ? AppColors.koreanBlue
        : place.isReleased
        ? AppColors.koreanRed
        : AppColors.gold;

    return Semantics(
      button: true,
      label: place.title,
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.skyLight,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: selected ? 4 : 3),
              boxShadow: AppShadows.small,
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _MarkerImage(place: place),
                  if (!place.isReleased)
                    ColoredBox(
                      color: AppColors.paper.withValues(alpha: .62),
                      child: Icon(
                        Icons.schedule_rounded,
                        color: AppColors.gold,
                        size: compact ? 18 : 24,
                      ),
                    ),
                  if (place.isCompleted)
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        radius: 11,
                        backgroundColor: AppColors.koreanBlue,
                        child: Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppColors.paper,
                        ),
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

class _MarkerImage extends StatelessWidget {
  const _MarkerImage({required this.place});

  final KoreaMapPlace place;

  @override
  Widget build(BuildContext context) {
    final originalUrl = place.thumbnailUrl.trim();
    if (originalUrl.isEmpty) return const _MarkerImageFallback();

    final optimizedUrl = optimizedImageUrl(originalUrl, maxWidth: 160);
    return _networkImage(
      optimizedUrl,
      retryOriginalUrl: optimizedUrl != originalUrl,
    );
  }

  Widget _networkImage(String url, {required bool retryOriginalUrl}) =>
      Image.network(
        url,
        fit: BoxFit.cover,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        semanticLabel: place.thumbnailAlt.isEmpty
            ? place.title
            : place.thumbnailAlt,
        errorBuilder: (_, _, _) => retryOriginalUrl
            ? _networkImage(place.thumbnailUrl.trim(), retryOriginalUrl: false)
            : const _MarkerImageFallback(),
      );
}

class _MarkerImageFallback extends StatelessWidget {
  const _MarkerImageFallback();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppColors.skyLight,
    child: Center(
      child: Icon(Icons.location_on_rounded, color: AppColors.koreanBlue),
    ),
  );
}

class LocationCoordinateMap extends StatefulWidget {
  const LocationCoordinateMap({
    required this.latitude,
    required this.longitude,
    required this.onChanged,
    required this.resetLabel,
    required this.unavailableBuilder,
    this.previewLatitude,
    this.previewLongitude,
    super.key,
  });

  final double? latitude;
  final double? longitude;
  final void Function(double latitude, double longitude) onChanged;
  final String resetLabel;
  final WidgetBuilder unavailableBuilder;
  final double? previewLatitude;
  final double? previewLongitude;

  @override
  State<LocationCoordinateMap> createState() => _LocationCoordinateMapState();
}

class _LocationCoordinateMapState extends State<LocationCoordinateMap> {
  final _controller = MapController();
  var _isMapReady = false;

  bool get _hasCoordinates =>
      widget.latitude != null && widget.longitude != null;

  bool get _hasPreview =>
      widget.previewLatitude != null && widget.previewLongitude != null;

  LatLng get _point => _hasCoordinates
      ? LatLng(widget.latitude!, widget.longitude!)
      : koreaMapCenter;

  LatLng? get _previewPoint => _hasPreview
      ? LatLng(widget.previewLatitude!, widget.previewLongitude!)
      : null;

  void _reset() => _controller.fitCamera(
    CameraFit.bounds(
      bounds: koreaMapBounds,
      padding: const EdgeInsets.all(AppSpacing.xl),
    ),
  );

  void _syncCamera() {
    if (!_isMapReady) return;
    final target = _previewPoint ?? (_hasCoordinates ? _point : null);
    if (target == null) {
      _reset();
      return;
    }
    _controller.move(target, 15);
  }

  @override
  void didUpdateWidget(covariant LocationCoordinateMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latitude != oldWidget.latitude ||
        widget.longitude != oldWidget.longitude ||
        widget.previewLatitude != oldWidget.previewLatitude ||
        widget.previewLongitude != oldWidget.previewLongitude) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncCamera());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tileUrl() == null) return widget.unavailableBuilder(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.center_focus_strong_rounded),
            label: Text(widget.resetLabel),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.large),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).width < 600 ? 320 : 420,
            child: FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: _previewPoint ?? _point,
                initialZoom: _hasPreview || _hasCoordinates ? 15 : 5.8,
                minZoom: 5,
                maxZoom: 19,
                cameraConstraint: CameraConstraint.contain(
                  bounds: koreaMapBounds,
                ),
                onMapReady: () {
                  _isMapReady = true;
                  _syncCamera();
                },
                onTap: (_, position) =>
                    widget.onChanged(position.latitude, position.longitude),
              ),
              children: [
                TileLayer(
                  urlTemplate: _tileUrl()!,
                  userAgentPackageName: 'com.koreaquest.app',
                ),
                if (_hasCoordinates)
                  DragMarkers(
                    markers: [
                      DragMarker(
                        point: _point,
                        size: const Size(48, 48),
                        builder: (context, _, dragging) => Icon(
                          Icons.location_on,
                          size: dragging ? 50 : 42,
                          color: AppColors.koreanBlue,
                        ),
                        onDragEnd: (_, position) => widget.onChanged(
                          position.latitude,
                          position.longitude,
                        ),
                      ),
                    ],
                  ),
                if (_previewPoint != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _previewPoint!,
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.location_searching_rounded,
                          color: AppColors.gold,
                          size: 42,
                        ),
                      ),
                    ],
                  ),
                _attribution(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

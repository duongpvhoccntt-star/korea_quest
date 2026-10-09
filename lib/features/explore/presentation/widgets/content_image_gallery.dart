import 'package:flutter/material.dart';
import 'package:korea_quest/core/utils/optimized_image_url.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/l10n/app_strings.dart';

class ContentGalleryImage {
  const ContentGalleryImage({
    required this.url,
    required this.credit,
    required this.sourceUrl,
    required this.alt,
  });

  factory ContentGalleryImage.fromJson(Map<String, dynamic> json) =>
      ContentGalleryImage(
        url: json['url']?.toString() ?? '',
        credit: json['credit']?.toString() ?? '',
        sourceUrl: json['source_url']?.toString() ?? '',
        alt: json['alt']?.toString() ?? '',
      );

  final String url;
  final String credit;
  final String sourceUrl;
  final String alt;
}

List<ContentGalleryImage> contentGalleryImages(Map<String, dynamic> media) {
  final rawImages = media['images'];
  if (rawImages is List && rawImages.isNotEmpty) {
    return rawImages
        .whereType<Map>()
        .map(
          (image) => ContentGalleryImage.fromJson(
            image.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList(growable: false);
  }

  final url = media['url']?.toString() ?? '';
  if (url.isEmpty || media['kind']?.toString() == 'youtube') {
    return const <ContentGalleryImage>[];
  }
  return [
    ContentGalleryImage(
      url: url,
      credit: media['credit']?.toString() ?? '',
      sourceUrl: media['source_url']?.toString() ?? '',
      alt: media['alt']?.toString() ?? '',
    ),
  ];
}

class ContentImageGallery extends StatefulWidget {
  const ContentImageGallery({
    required this.images,
    required this.fallbackLabel,
    required this.aspectRatio,
    required this.borderRadius,
    this.maxImageWidth = 720,
    this.showGradient = false,
    super.key,
  });

  final List<ContentGalleryImage> images;
  final String fallbackLabel;
  final double aspectRatio;
  final BorderRadius borderRadius;
  final int maxImageWidth;
  final bool showGradient;

  @override
  State<ContentImageGallery> createState() => _ContentImageGalleryState();
}

class _ContentImageGalleryState extends State<ContentImageGallery> {
  late final PageController _controller;
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void didUpdateWidget(ContentImageGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentIndex < widget.images.length || _currentIndex == 0) return;
    _currentIndex = widget.images.isEmpty ? 0 : widget.images.length - 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _controller.hasClients) {
        _controller.jumpToPage(_currentIndex);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showPage(int index) {
    if (index < 0 || index >= widget.images.length) return;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller.jumpToPage(index);
    } else {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleImages = widget.images.length > 1;
    final positionLabel = hasMultipleImages
        ? appStrings(
            context,
          ).imagePosition(_currentIndex + 1, widget.images.length)
        : null;

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: widget.images.isEmpty
            ? ContentImagePlaceholder(
                label: widget.fallbackLabel,
                large: widget.showGradient,
              )
            : Semantics(
                label: positionLabel,
                liveRegion: hasMultipleImages,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasMultipleImages)
                      PageView.builder(
                        controller: _controller,
                        itemCount: widget.images.length,
                        onPageChanged: (index) =>
                            setState(() => _currentIndex = index),
                        itemBuilder: (context, index) => _GalleryImage(
                          image: widget.images[index],
                          fallbackLabel: widget.fallbackLabel,
                          maxImageWidth: widget.maxImageWidth,
                          large: widget.showGradient,
                        ),
                      )
                    else
                      _GalleryImage(
                        image: widget.images.single,
                        fallbackLabel: widget.fallbackLabel,
                        maxImageWidth: widget.maxImageWidth,
                        large: widget.showGradient,
                      ),
                    if (widget.showGradient)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.stitchText.withValues(alpha: .72),
                            ],
                          ),
                        ),
                      ),
                    if (hasMultipleImages) ...[
                      _GalleryArrows(
                        currentIndex: _currentIndex,
                        imageCount: widget.images.length,
                        onPrevious: () => _showPage(_currentIndex - 1),
                        onNext: () => _showPage(_currentIndex + 1),
                      ),
                      Positioned(
                        top: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: ExcludeSemantics(
                          child: _PositionCounter(
                            current: _currentIndex + 1,
                            total: widget.images.length,
                          ),
                        ),
                      ),
                      Positioned(
                        left: AppSpacing.md,
                        right: AppSpacing.md,
                        bottom: AppSpacing.sm,
                        child: ExcludeSemantics(
                          child: _PositionDots(
                            currentIndex: _currentIndex,
                            count: widget.images.length,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _GalleryImage extends StatelessWidget {
  const _GalleryImage({
    required this.image,
    required this.fallbackLabel,
    required this.maxImageWidth,
    required this.large,
  });

  final ContentGalleryImage image;
  final String fallbackLabel;
  final int maxImageWidth;
  final bool large;

  @override
  Widget build(BuildContext context) => image.url.isEmpty
      ? ContentImagePlaceholder(label: fallbackLabel, large: large)
      : Image.network(
          optimizedImageUrl(image.url, maxWidth: maxImageWidth),
          key: ValueKey(image.url),
          fit: BoxFit.cover,
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          semanticLabel: image.alt.isEmpty ? fallbackLabel : image.alt,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const ColoredBox(
                  color: AppColors.skyLight,
                  child: Center(child: CircularProgressIndicator()),
                ),
          errorBuilder: (context, error, stackTrace) =>
              ContentImagePlaceholder(label: fallbackLabel, large: large),
        );
}

class _GalleryArrows extends StatelessWidget {
  const _GalleryArrows({
    required this.currentIndex,
    required this.imageCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentIndex;
  final int imageCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GalleryArrowButton(
            controlKey: const ValueKey('gallery-previous'),
            tooltip: appStrings(context).previousImage,
            icon: Icons.chevron_left_rounded,
            onPressed: currentIndex > 0 ? onPrevious : null,
          ),
          _GalleryArrowButton(
            controlKey: const ValueKey('gallery-next'),
            tooltip: appStrings(context).nextImage,
            icon: Icons.chevron_right_rounded,
            onPressed: currentIndex < imageCount - 1 ? onNext : null,
          ),
        ],
      ),
    ),
  );
}

class _GalleryArrowButton extends StatelessWidget {
  const _GalleryArrowButton({
    required this.controlKey,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final Key controlKey;
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filled(
    key: controlKey,
    tooltip: tooltip,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      minimumSize: const Size.square(kMinInteractiveDimension),
      backgroundColor: AppColors.stitchText.withValues(alpha: .76),
      foregroundColor: AppColors.paper,
      disabledBackgroundColor: AppColors.stitchText.withValues(alpha: .32),
      disabledForegroundColor: AppColors.paper.withValues(alpha: .72),
    ),
    icon: Icon(icon),
  );
}

class _PositionCounter extends StatelessWidget {
  const _PositionCounter({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.stitchText.withValues(alpha: .76),
      borderRadius: BorderRadius.circular(AppRadius.round),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        '$current/$total',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.paper,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _PositionDots extends StatelessWidget {
  const _PositionDots({required this.currentIndex, required this.count});

  final int currentIndex;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var index = 0; index < count; index++)
        Container(
          key: ValueKey('gallery-dot-$index'),
          width: index == currentIndex ? 18 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: index == currentIndex
                ? AppColors.paper
                : AppColors.paper.withValues(alpha: .58),
            borderRadius: BorderRadius.circular(AppRadius.round),
          ),
        ),
    ],
  );
}

class ContentImagePlaceholder extends StatelessWidget {
  const ContentImagePlaceholder({
    required this.label,
    this.large = false,
    super.key,
  });

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
              appStrings(context).imageUpdating,
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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/explore/presentation/widgets/content_image_gallery.dart';

void main() {
  Widget buildGallery({
    required List<ContentGalleryImage> images,
    bool disableAnimations = false,
  }) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: 600,
            child: ContentImageGallery(
              images: images,
              fallbackLabel: 'Gallery test',
              aspectRatio: 16 / 9,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    ),
  );

  const images = [
    ContentGalleryImage(url: '', credit: '', sourceUrl: '', alt: 'Ảnh 1'),
    ContentGalleryImage(url: '', credit: '', sourceUrl: '', alt: 'Ảnh 2'),
    ContentGalleryImage(url: '', credit: '', sourceUrl: '', alt: 'Ảnh 3'),
  ];

  testWidgets('shows arrows, counter and dots for multiple images', (
    tester,
  ) async {
    await tester.pumpWidget(buildGallery(images: images));

    expect(find.text('1/3'), findsOneWidget);
    expect(find.byKey(const ValueKey('gallery-previous')), findsOneWidget);
    expect(find.byKey(const ValueKey('gallery-next')), findsOneWidget);
    expect(find.byKey(const ValueKey('gallery-dot-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('gallery-dot-2')), findsOneWidget);
    expect(find.byTooltip('Ảnh trước'), findsOneWidget);
    expect(find.byTooltip('Ảnh tiếp theo'), findsOneWidget);
    expect(find.bySemanticsLabel('Ảnh 1 trên 3'), findsOneWidget);

    final previous = tester.widget<IconButton>(
      find.byKey(const ValueKey('gallery-previous')),
    );
    expect(previous.onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey('gallery-next')));
    await tester.pumpAndSettle();
    expect(find.text('2/3'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.text('3/3'), findsOneWidget);

    final next = tester.widget<IconButton>(
      find.byKey(const ValueKey('gallery-next')),
    );
    expect(next.onPressed, isNull);
  });

  testWidgets('hides navigation for a single image', (tester) async {
    await tester.pumpWidget(buildGallery(images: images.take(1).toList()));

    expect(find.byKey(const ValueKey('gallery-previous')), findsNothing);
    expect(find.byKey(const ValueKey('gallery-next')), findsNothing);
    expect(find.text('1/1'), findsNothing);
    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('changes page immediately when reduced motion is enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildGallery(images: images.take(2).toList(), disableAnimations: true),
    );

    await tester.tap(find.byKey(const ValueKey('gallery-next')));
    await tester.pump();
    expect(find.text('2/2'), findsOneWidget);
  });

  test('parses gallery payload and falls back to legacy media', () {
    final gallery = contentGalleryImages({
      'kind': 'image',
      'url': 'legacy.jpg',
      'images': [
        {'url': 'one.jpg', 'credit': 'A', 'source_url': 'source', 'alt': 'One'},
        {'url': 'two.jpg', 'credit': 'B', 'source_url': 'source', 'alt': 'Two'},
      ],
    });
    expect(gallery.map((image) => image.url), ['one.jpg', 'two.jpg']);

    final legacy = contentGalleryImages({
      'kind': 'image',
      'url': 'legacy.jpg',
      'credit': 'Legacy',
    });
    expect(legacy.single.url, 'legacy.jpg');
    expect(legacy.single.credit, 'Legacy');
  });
}

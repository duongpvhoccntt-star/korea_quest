import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/presentation/widgets/admin_image_gallery_editor.dart';
import 'package:korea_quest/features/admin/presentation/widgets/location_editor_content.dart';

void main() {
  testWidgets('adds, reorders and removes gallery images', (tester) async {
    final item = <String, dynamic>{
      'image_gallery': <Map<String, dynamic>>[
        {...emptyAdminGalleryImage(), 'url': 'first.jpg'},
        {...emptyAdminGalleryImage(), 'url': 'second.jpg'},
      ],
    };

    await tester.pumpWidget(_GalleryHarness(item: item));

    await tester.tap(find.byIcon(Icons.arrow_upward_rounded).last);
    await tester.pump();
    expect(
      adminImageGallery(item, legacyPrefix: 'media').first['url'],
      'second.jpg',
    );

    await tester.tap(find.byIcon(Icons.delete_outline_rounded).last);
    await tester.pump();
    expect(adminImageGallery(item, legacyPrefix: 'media'), hasLength(1));

    await tester.tap(find.text('Thêm ảnh'));
    await tester.pump();
    expect(adminImageGallery(item, legacyPrefix: 'media'), hasLength(2));
  });

  testWidgets('disables adding after ten images', (tester) async {
    final item = <String, dynamic>{
      'image_gallery': List.generate(
        adminImageGalleryLimit,
        (index) => {...emptyAdminGalleryImage(), 'url': '$index.jpg'},
      ),
    };

    await tester.pumpWidget(_GalleryHarness(item: item));

    final addButton = find.ancestor(
      of: find.text('Thêm ảnh'),
      matching: find.byType(OutlinedButton),
    );
    expect(tester.widget<OutlinedButton>(addButton).onPressed, isNull);
  });

  testWidgets('shows only the active media editor and retains the gallery', (
    tester,
  ) async {
    final draft = AdminLocationDraft(
      history: [
        {
          'media_kind': 'image',
          'media_url': '',
          'media_credit': '',
          'media_source_url': '',
          'media_alt': '',
          'image_gallery': [
            {
              ...emptyAdminGalleryImage(),
              'url': 'https://example.com/retained.jpg',
            },
          ],
          'is_visible': true,
        },
      ],
    );

    await tester.pumpWidget(_HistoryHarness(draft: draft));
    expect(find.text('Thư viện ảnh'), findsOneWidget);

    var selector = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(selector);
    await tester.tap(selector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('YouTube').last);
    await tester.pumpAndSettle();

    expect(find.text('Thư viện ảnh'), findsNothing);
    expect(find.text('URL media'), findsOneWidget);
    expect(draft.history.single['image_gallery'], hasLength(1));

    selector = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(selector);
    await tester.tap(selector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ảnh').last);
    await tester.pumpAndSettle();

    expect(find.text('Thư viện ảnh'), findsOneWidget);
    expect(draft.history.single['image_gallery'], hasLength(1));
  });

  test('normalizes legacy media and fills uploaded-image defaults', () {
    final item = <String, dynamic>{
      'media_url': 'legacy.jpg',
      'media_credit': 'Legacy credit',
      'media_source_url': 'https://example.com/source',
      'media_alt': 'Legacy alt',
    };

    final gallery = adminImageGallery(item, legacyPrefix: 'media');
    expect(gallery.single['url'], 'legacy.jpg');
    expect(gallery.single['alt'], 'Legacy alt');

    final uploaded = emptyAdminGalleryImage();
    applyUploadedGalleryImage(uploaded, 'https://example.com/upload.jpg');
    expect(uploaded['credit'], 'KoreaQuest');
    expect(uploaded['source_url'], 'https://example.com/upload.jpg');
    expect(uploaded['alt'], isNotEmpty);
  });
}

class _GalleryHarness extends StatefulWidget {
  const _GalleryHarness({required this.item});

  final Map<String, dynamic> item;

  @override
  State<_GalleryHarness> createState() => _GalleryHarnessState();
}

class _GalleryHarnessState extends State<_GalleryHarness> {
  final draft = AdminLocationDraft();

  @override
  Widget build(BuildContext context) => ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: AdminImageGalleryEditor(
            draft: draft,
            item: widget.item,
            legacyPrefix: 'media',
            onChanged: () => setState(() {}),
          ),
        ),
      ),
    ),
  );
}

class _HistoryHarness extends StatefulWidget {
  const _HistoryHarness({required this.draft});

  final AdminLocationDraft draft;

  @override
  State<_HistoryHarness> createState() => _HistoryHarnessState();
}

class _HistoryHarnessState extends State<_HistoryHarness> {
  @override
  Widget build(BuildContext context) => ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: LocationHistoryEditor(
            draft: widget.draft,
            onChanged: () => setState(() {}),
          ),
        ),
      ),
    ),
  );
}

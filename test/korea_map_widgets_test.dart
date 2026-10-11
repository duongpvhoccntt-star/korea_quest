import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/shared/widgets/korea_map.dart';

void main() {
  const released = KoreaMapPlace(
    id: 'seoul',
    title: 'Seoul palace',
    subtitle: 'Seoul',
    thumbnailUrl: '',
    thumbnailAlt: '',
    latitude: 37.5796,
    longitude: 126.977,
    isReleased: true,
  );
  const withThumbnail = KoreaMapPlace(
    id: 'busan',
    title: 'Busan harbour',
    subtitle: 'Busan',
    thumbnailUrl: 'https://example.test/busan.jpg',
    thumbnailAlt: 'Busan harbour thumbnail',
    latitude: 35.1796,
    longitude: 129.0756,
    isReleased: true,
  );

  const comingSoon = KoreaMapPlace(
    id: 'jeju',
    title: 'Jeju island',
    subtitle: 'Jeju',
    thumbnailUrl: '',
    thumbnailAlt: '',
    latitude: 33.4996,
    longitude: 126.5312,
    isReleased: false,
  );

  test('recognises Jeju as outside the mainland map view', () {
    expect(isOutsideKoreaMainlandBounds(comingSoon.latitude, comingSoon.longitude), isTrue);
    expect(isOutsideKoreaMainlandBounds(released.latitude, released.longitude), isFalse);
  });

  testWidgets('marker has an image fallback and selected coming-soon state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        KoreaMapPlaceMarker(
          place: released,
          selected: false,
          onTap: () {},
        ),
      ),
    );
    expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);

    await tester.pumpWidget(
      _app(
        KoreaMapPlaceMarker(
          place: withThumbnail,
          selected: false,
          onTap: () {},
        ),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
    await tester.pumpWidget(
      _app(
        KoreaMapPlaceMarker(
          place: comingSoon,
          selected: true,
          onTap: () {},
        ),
      ),
    );
    expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    expect(
      tester.getSize(find.byType(AnimatedContainer)).width,
      68,
    );
  });

  testWidgets('remote inset selects the Jeju place', (tester) async {
    String? selectedId;
    await tester.pumpWidget(
      _app(
        KoreaMapRemotePlacesInset(
          label: 'Places beyond the main map',
          places: const [comingSoon],
          selectedPlaceId: null,
          onSelected: (id) => selectedId = id,
        ),
      ),
    );

    expect(find.text('Places beyond the main map'), findsOneWidget);
    await tester.tap(find.byType(KoreaMapPlaceMarker));
    expect(selectedId, 'jeju');
  });
}

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

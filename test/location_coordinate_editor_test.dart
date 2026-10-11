import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/app/app_theme.dart';
import 'package:korea_quest/features/admin/data/demo_admin_repository.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/domain/admin_repository.dart';
import 'package:korea_quest/features/admin/presentation/providers/admin_providers.dart';
import 'package:korea_quest/features/admin/presentation/widgets/location_coordinate_editor.dart';

void main() {
  testWidgets('preview does not change draft and apply saves coordinates', (
    tester,
  ) async {
    final repository = _SuggestionRepository();
    addTearDown(repository.dispose);
    final draft = AdminLocationDraft(
      overview: {...AdminLocationDraft.emptyOverview(), 'name': 'Gyeongbokgung'},
    );
    var changes = 0;

    await tester.pumpWidget(
      _app(
        repository: repository,
        child: LocationCoordinateEditor(
          draft: draft,
          onChanged: () => changes++,
        ),
      ),
    );

    await tester.tap(find.text('AI gợi ý vị trí'));
    await tester.pump();
    expect(find.text('Gyeongbokgung Palace'), findsOneWidget);

    await tester.tap(find.text('Xem trước'));
    await tester.pump();
    expect(find.textContaining('Ghim vàng chưa được lưu.'), findsOneWidget);
    expect(draft.overview['latitude'], isEmpty);
    expect(draft.overview['longitude'], isEmpty);
    expect(changes, 0);

    await tester.tap(find.text('Áp dụng'));
    await tester.pump();
    expect(draft.overview['latitude'], '37.579600');
    expect(draft.overview['longitude'], '126.977000');
    expect(changes, 1);
  });

  testWidgets('shows a clear empty result message', (tester) async {
    final repository = _SuggestionRepository(results: const []);
    addTearDown(repository.dispose);
    final draft = AdminLocationDraft(
      overview: {...AdminLocationDraft.emptyOverview(), 'name': 'No result'},
    );

    await tester.pumpWidget(
      _app(
        repository: repository,
        child: LocationCoordinateEditor(draft: draft, onChanged: () {}),
      ),
    );

    await tester.tap(find.text('AI gợi ý vị trí'));
    await tester.pump();
    expect(find.textContaining('Không tìm thấy vị trí phù hợp.'), findsOneWidget);
  });

  testWidgets('shows a recoverable message when coordinate lookup fails', (
    tester,
  ) async {
    final repository = _SuggestionRepository(shouldThrow: true);
    addTearDown(repository.dispose);
    final draft = AdminLocationDraft(
      overview: {...AdminLocationDraft.emptyOverview(), 'name': 'Lookup error'},
    );

    await tester.pumpWidget(
      _app(
        repository: repository,
        child: LocationCoordinateEditor(draft: draft, onChanged: () {}),
      ),
    );

    await tester.tap(find.text('AI gợi ý vị trí'));
    await tester.pump();
    expect(find.textContaining('Không thể lấy gợi ý vị trí'), findsOneWidget);
  });
}

Widget _app({
  required AdminRepository repository,
  required Widget child,
}) => ProviderScope(
  overrides: [adminRepositoryProvider.overrideWithValue(repository)],
  child: MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  ),
);

class _SuggestionRepository extends DemoAdminRepository {
  _SuggestionRepository({this.results = _defaultResults, this.shouldThrow = false});

  final List<LocationCoordinateSuggestion> results;
  final bool shouldThrow;

  static const _defaultResults = [
    LocationCoordinateSuggestion(
      latitude: 37.5796,
      longitude: 126.977,
      label: 'Gyeongbokgung Palace',
      address: '161 Sajik-ro, Jongno-gu, Seoul',
      source: 'maptiler',
      confidence: 0.98,
      reason: 'Kết quả khớp cao',
    ),
  ];

  @override
  Future<List<LocationCoordinateSuggestion>> suggestLocationCoordinates(
    AdminLocationDraft draft,
  ) async {
    if (shouldThrow) throw StateError('network');
    return results;
  }
}
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/admin/domain/admin_repository.dart';

void main() {
  test('parses numeric strings and rejects invalid coordinates', () {
    final suggestion = LocationCoordinateSuggestion.fromJson({
      'latitude': '37.579600',
      'longitude': 126.977,
      'label': 'Gyeongbokgung',
      'confidence': '0.98',
    });
    expect(suggestion.latitude, 37.5796);
    expect(suggestion.longitude, 126.977);
    expect(suggestion.confidence, 0.98);
    expect(
      LocationCoordinateSuggestion.fromJson({
        'latitude': 37.5,
        'longitude': 126.9,
        'confidence': 2,
      }).confidence,
      1,
    );
    expect(() => LocationCoordinateSuggestion.fromJson({
      'latitude': 91,
      'longitude': 126,
    }), throwsFormatException);
  });
}

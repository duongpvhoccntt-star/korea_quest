import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/admin/data/demo_admin_repository.dart';
import 'package:korea_quest/features/admin/domain/admin_repository.dart';

void main() {
  test('demo admin repository explains that image upload needs Supabase', () {
    final repository = DemoAdminRepository();
    addTearDown(repository.dispose);

    expect(
      () => repository.uploadContentImage(
        locationId: 'location',
        revisionId: 'revision',
        filename: 'image.png',
        bytes: Uint8List(1),
        contentType: 'image/png',
      ),
      throwsA(isA<AdminConfigurationException>()),
    );
  });
}

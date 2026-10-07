import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/shared/models/domain_models.dart';

void main() {
  test('AppUser supports bio, avatarPreset, avatarBytes and copyWith', () {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final user = AppUser(
      id: 'u1',
      fullName: 'Phạm Văn Dương',
      displayName: 'Dương',
      handle: 'duong.kq',
      joinedDate: DateTime(2026, 8, 2),
      bio: 'Người khám phá Seoul',
      avatarPreset: 'hanbok',
      avatarBytes: bytes,
    );

    expect(user.bio, 'Người khám phá Seoul');
    expect(user.avatarPreset, 'hanbok');
    expect(user.avatarBytes, bytes);

    final updated = user.copyWith(
      displayName: 'Dương Phạm',
      bio: 'Yêu văn hóa Hàn',
      avatarPreset: 'seoul',
    );
    expect(updated.displayName, 'Dương Phạm');
    expect(updated.bio, 'Yêu văn hóa Hàn');
    expect(updated.avatarPreset, 'seoul');
    expect(updated.fullName, 'Phạm Văn Dương');
  });
}

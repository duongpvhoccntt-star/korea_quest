import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/passport/presentation/widgets/passport_stamp_assets.dart';

void main() {
  test('maps the released locations to their passport stamp assets', () {
    expect(
      PassportStampAssets.forLocation('gyeongbokgung'),
      'assets/images/passport_stamps/gyeongbokgung_stamp.png',
    );
    expect(
      PassportStampAssets.forLocation('bukchon-hanok'),
      'assets/images/passport_stamps/bukchon_hanok_stamp.png',
    );
    expect(PassportStampAssets.forLocation('namsan'), isNotNull);
    expect(PassportStampAssets.forLocation('jeju'), isNotNull);
    expect(PassportStampAssets.forLocation('unknown'), isNull);
  });
}

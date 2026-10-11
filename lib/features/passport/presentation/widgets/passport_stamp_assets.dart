abstract final class PassportStampAssets {
  const PassportStampAssets._();

  static const _basePath = 'assets/images/passport_stamps';

  static String? forLocation(String locationId) => switch (locationId) {
    'gyeongbokgung' => '$_basePath/gyeongbokgung_stamp.png',
    'bukchon-hanok' => '$_basePath/bukchon_hanok_stamp.png',
    'namsan' => '$_basePath/namsan_seoul_stamp.png',
    'jeju' => '$_basePath/jeju_stamp.png',
    _ => null,
  };
}

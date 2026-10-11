/// No-op implementation for platforms without the Web Audio API.
abstract final class CelebrationSound {
  static Future<void> prime() async {}

  static Future<void> play() async {}
}

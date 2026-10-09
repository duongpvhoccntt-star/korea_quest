/// No-op implementation for platforms without the Web Audio API.
abstract final class QuizFeedbackSound {
  static Future<void> prime() async {}

  static Future<void> play({required bool isCorrect}) async {}
}

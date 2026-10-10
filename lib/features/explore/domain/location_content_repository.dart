import 'package:korea_quest/features/explore/domain/published_location.dart';

abstract interface class LocationContentRepository {
  Future<List<PublishedLocationSummary>> listPublishedLocations({
    String locale = 'vi',
  });
  Future<PublishedLocationDetail?> getPublishedLocation(
    String slug, {
    String locale = 'vi',
  });
  Future<QuizAnswerResult> submitQuizAnswer({
    required String questionId,
    required JsonMap answer,
    String locale = 'vi',
  });
  Future<GameplayReward> completeStage({
    required String slug,
    required int stageNumber,
    String locale = 'vi',
  });
}

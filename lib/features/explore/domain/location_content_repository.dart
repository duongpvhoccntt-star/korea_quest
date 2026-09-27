import 'package:korea_quest/features/explore/domain/published_location.dart';

abstract interface class LocationContentRepository {
  Future<List<PublishedLocationSummary>> listPublishedLocations();
  Future<PublishedLocationDetail?> getPublishedLocation(String slug);
  Future<QuizAnswerResult> submitQuizAnswer({
    required String questionId,
    required JsonMap answer,
  });
}

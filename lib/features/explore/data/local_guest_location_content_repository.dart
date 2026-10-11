import 'package:korea_quest/core/services/local_guest_gameplay.dart';
import 'package:korea_quest/core/services/local_guest_store.dart';
import 'package:korea_quest/features/explore/domain/location_content_repository.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';

class LocalGuestLocationContentRepository implements LocationContentRepository {
  LocalGuestLocationContentRepository({
    required this._publicRepository,
    LocalGuestStore? store,
  }) : _gameplay = LocalGuestGameplay(store ?? LocalGuestStore());

  final LocationContentRepository _publicRepository;
  final LocalGuestGameplay _gameplay;

  @override
  Future<List<PublishedLocationSummary>> listPublishedLocations({
    String locale = 'vi',
  }) => _publicRepository.listPublishedLocations(locale: locale);

  @override
  Future<PublishedLocationDetail?> getPublishedLocation(
    String slug, {
    String locale = 'vi',
  }) => _publicRepository.getPublishedLocation(slug, locale: locale);

  @override
  Future<QuizAnswerResult> submitQuizAnswer({
    required String questionId,
    required JsonMap answer,
    String locale = 'vi',
  }) async {
    final result = await _publicRepository.submitQuizAnswer(
      questionId: questionId,
      answer: answer,
      locale: locale,
    );
    final reward = await _gameplay.recordQuiz(
      questionId: questionId,
      isCorrect: result.isCorrect,
      locale: locale,
    );
    return QuizAnswerResult(
      isCorrect: result.isCorrect,
      explanation: result.explanation,
      reward: reward,
    );
  }

  @override
  Future<GameplayReward> completeStage({
    required String slug,
    required int stageNumber,
    String locale = 'vi',
  }) => _gameplay.completeStage(
    slug: slug,
    stageNumber: stageNumber,
    locale: locale,
  );
}

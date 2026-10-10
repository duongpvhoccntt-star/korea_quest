import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:korea_quest/features/explore/domain/location_content_repository.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';

class SupabaseLocationContentRepository implements LocationContentRepository {
  const SupabaseLocationContentRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<PublishedLocationSummary>> listPublishedLocations({
    String locale = 'vi',
  }) async {
    final response = await _client.rpc(
      'list_published_locations',
      params: {'requested_locale': locale},
    );
    return jsonMapList(
      response,
    ).map(PublishedLocationSummary.fromJson).toList(growable: false);
  }

  @override
  Future<PublishedLocationDetail?> getPublishedLocation(
    String slug, {
    String locale = 'vi',
  }) async {
    final response = await _client.rpc(
      'get_published_location',
      params: {'target_slug': slug, 'requested_locale': locale},
    );
    if (response == null) return null;
    final json = jsonMap(response);
    return json.isEmpty ? null : PublishedLocationDetail.fromJson(json);
  }

  @override
  Future<QuizAnswerResult> submitQuizAnswer({
    required String questionId,
    required JsonMap answer,
    String locale = 'vi',
  }) async {
    final response = await _client.rpc(
      'submit_quiz_answer',
      params: {
        'question_id': questionId,
        'answer': answer,
        'requested_locale': locale,
      },
    );
    return QuizAnswerResult.fromJson(jsonMap(response));
  }

  @override
  Future<GameplayReward> completeStage({
    required String slug,
    required int stageNumber,
    String locale = 'vi',
  }) async {
    final response = await _client.rpc(
      'complete_location_stage',
      params: {
        'target_slug': slug,
        'stage_number': stageNumber,
        'requested_locale': locale,
      },
    );
    return GameplayReward.fromJson(jsonMap(response));
  }
}

class UnconfiguredLocationContentRepository
    implements LocationContentRepository {
  const UnconfiguredLocationContentRepository();

  Never _unavailable() => throw StateError(
    'Supabase chưa được cấu hình. Hãy chạy ứng dụng với SUPABASE_URL và SUPABASE_PUBLISHABLE_KEY.',
  );

  @override
  Future<PublishedLocationDetail?> getPublishedLocation(
    String slug, {
    String locale = 'vi',
  }) async => _unavailable();

  @override
  Future<List<PublishedLocationSummary>> listPublishedLocations({
    String locale = 'vi',
  }) async => _unavailable();

  @override
  Future<QuizAnswerResult> submitQuizAnswer({
    required String questionId,
    required JsonMap answer,
    String locale = 'vi',
  }) async => _unavailable();

  @override
  Future<GameplayReward> completeStage({
    required String slug,
    required int stageNumber,
    String locale = 'vi',
  }) async => _unavailable();
}

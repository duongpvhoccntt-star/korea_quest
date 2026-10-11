import 'content_speech_service.dart';

ContentSpeechService createPlatformContentSpeechService() =>
    _UnavailableContentSpeechService();

class _UnavailableContentSpeechService implements ContentSpeechService {
  @override
  bool get isSupported => false;

  @override
  SpeechPlayback get playback => const SpeechPlayback.idle();

  @override
  Stream<SpeechPlayback> get changes => const Stream.empty();

  @override
  Stream<void> get voiceChanges => const Stream.empty();

  @override
  SpeechLocaleAvailability availabilityFor(String locale) =>
      SpeechLocaleAvailability.unavailable;

  @override
  void pause() {}

  @override
  void resume() {}

  @override
  Future<SpeechStartResult> speak({
    required String sessionId,
    required String text,
    required String locale,
    required LocationSpeechSource source,
  }) async => const SpeechStartResult.unavailable();

  @override
  void stop() {}
}

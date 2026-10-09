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
  void pause() {}

  @override
  void resume() {}

  @override
  void speak({
    required String sessionId,
    required String text,
    required String locale,
  }) {}

  @override
  void stop() {}
}

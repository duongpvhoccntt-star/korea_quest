import 'dart:async';

import 'content_speech_stub.dart'
    if (dart.library.js_interop) 'content_speech_web.dart';

enum SpeechPlaybackState { idle, speaking, paused }

class SpeechPlayback {
  const SpeechPlayback({required this.state, this.sessionId});

  const SpeechPlayback.idle() : this(state: SpeechPlaybackState.idle);

  final SpeechPlaybackState state;
  final String? sessionId;
}

abstract interface class ContentSpeechService {
  bool get isSupported;
  SpeechPlayback get playback;
  Stream<SpeechPlayback> get changes;

  void speak({
    required String sessionId,
    required String text,
    required String locale,
  });
  void pause();
  void resume();
  void stop();
}

final ContentSpeechService contentSpeechService =
    createPlatformContentSpeechService();

import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'content_speech_service.dart';

ContentSpeechService createPlatformContentSpeechService() =>
    _WebContentSpeechService();

class _WebContentSpeechService implements ContentSpeechService {
  final _changes = StreamController<SpeechPlayback>.broadcast();
  SpeechPlayback _playback = const SpeechPlayback.idle();
  int _generation = 0;

  @override
  bool get isSupported => true;

  @override
  SpeechPlayback get playback => _playback;

  @override
  Stream<SpeechPlayback> get changes => _changes.stream;

  @override
  void speak({
    required String sessionId,
    required String text,
    required String locale,
  }) {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return;

    final generation = ++_generation;
    try {
      final speech = web.window.speechSynthesis;
      speech.cancel();
      final utterance = web.SpeechSynthesisUtterance(normalizedText)
        ..lang = _speechLocale(locale)
        ..rate = .92
        ..pitch = 1
        ..volume = 1
        ..onstart = ((web.Event _) {
          if (_isCurrent(generation)) {
            _setPlayback(
              SpeechPlayback(
                state: SpeechPlaybackState.speaking,
                sessionId: sessionId,
              ),
            );
          }
        }).toJS
        ..onpause = ((web.Event _) {
          if (_isCurrent(generation)) {
            _setPlayback(
              SpeechPlayback(
                state: SpeechPlaybackState.paused,
                sessionId: sessionId,
              ),
            );
          }
        }).toJS
        ..onresume = ((web.Event _) {
          if (_isCurrent(generation)) {
            _setPlayback(
              SpeechPlayback(
                state: SpeechPlaybackState.speaking,
                sessionId: sessionId,
              ),
            );
          }
        }).toJS
        ..onend = ((web.Event _) {
          if (_isCurrent(generation)) _setPlayback(const SpeechPlayback.idle());
        }).toJS
        ..onerror = ((web.Event _) {
          if (_isCurrent(generation)) _setPlayback(const SpeechPlayback.idle());
        }).toJS;
      _setPlayback(
        SpeechPlayback(
          state: SpeechPlaybackState.speaking,
          sessionId: sessionId,
        ),
      );
      speech.speak(utterance);
    } on Object {
      _setPlayback(const SpeechPlayback.idle());
    }
  }

  @override
  void pause() {
    web.window.speechSynthesis.pause();
    if (_playback.state == SpeechPlaybackState.speaking) {
      _setPlayback(
        SpeechPlayback(
          state: SpeechPlaybackState.paused,
          sessionId: _playback.sessionId,
        ),
      );
    }
  }

  @override
  void resume() {
    web.window.speechSynthesis.resume();
    if (_playback.state == SpeechPlaybackState.paused) {
      _setPlayback(
        SpeechPlayback(
          state: SpeechPlaybackState.speaking,
          sessionId: _playback.sessionId,
        ),
      );
    }
  }

  @override
  void stop() {
    _generation++;
    web.window.speechSynthesis.cancel();
    _setPlayback(const SpeechPlayback.idle());
  }

  bool _isCurrent(int generation) => generation == _generation;

  void _setPlayback(SpeechPlayback playback) {
    _playback = playback;
    _changes.add(playback);
  }

  String _speechLocale(String locale) => switch (locale) {
    'ko' => 'ko-KR',
    'en' => 'en-US',
    _ => 'vi-VN',
  };
}

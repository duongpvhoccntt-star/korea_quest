import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'content_speech_service.dart';

ContentSpeechService createPlatformContentSpeechService() =>
    _BrowserContentSpeechService();

/// Uses the browser's speech synthesis so reading content works without a
/// third-party API key, billing account, or audio download.
class _BrowserContentSpeechService implements ContentSpeechService {
  _BrowserContentSpeechService() : _synthesis = web.window.speechSynthesis {
    _synthesis.onvoiceschanged = ((web.Event _) {
      _availabilityChanges.add(null);
    }).toJS;
  }

  final web.SpeechSynthesis _synthesis;
  final _changes = StreamController<SpeechPlayback>.broadcast();
  final _availabilityChanges = StreamController<void>.broadcast();
  SpeechPlayback _playback = const SpeechPlayback.idle();
  web.SpeechSynthesisUtterance? _utterance;
  int _generation = 0;

  @override
  bool get isSupported => true;

  @override
  SpeechPlayback get playback => _playback;

  @override
  Stream<SpeechPlayback> get changes => _changes.stream;

  @override
  Stream<void> get voiceChanges => _availabilityChanges.stream;

  @override
  SpeechLocaleAvailability availabilityFor(String locale) =>
      SpeechLocaleAvailability.available;

  @override
  Future<SpeechStartResult> speak({
    required String sessionId,
    required String text,
    required String locale,
    required LocationSpeechSource source,
  }) async {
    if (text.trim().isEmpty) return const SpeechStartResult.emptyText();

    final generation = ++_generation;
    _synthesis.cancel();
    final utterance = web.SpeechSynthesisUtterance(text)
      ..lang = speechLocaleFor(locale)
      ..voice = _preferredVoice(locale)
      ..onend = ((web.Event _) {
        if (_isCurrent(generation)) {
          _utterance = null;
          _setPlayback(const SpeechPlayback.idle());
        }
      }).toJS
      ..onerror = ((web.Event _) {
        if (_isCurrent(generation)) {
          _utterance = null;
          _setPlayback(const SpeechPlayback.idle());
        }
      }).toJS;

    try {
      _utterance = utterance;
      _synthesis.speak(utterance);
      _setPlayback(
        SpeechPlayback(
          state: SpeechPlaybackState.speaking,
          sessionId: sessionId,
        ),
      );
      return const SpeechStartResult.started();
    } on Object {
      if (_isCurrent(generation)) _setPlayback(const SpeechPlayback.idle());
      return const SpeechStartResult.failed();
    }
  }

  @override
  void pause() {
    if (_utterance == null) return;
    _synthesis.pause();
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
    if (_utterance == null) return;
    _synthesis.resume();
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
    _synthesis.cancel();
    _utterance = null;
    _setPlayback(const SpeechPlayback.idle());
  }

  web.SpeechSynthesisVoice? _preferredVoice(String locale) {
    final expectedLanguage = speechLocaleFor(locale).toLowerCase();
    final expectedCode = expectedLanguage.split('-').first;
    final voices = _synthesis.getVoices().toDart;
    for (final voice in voices) {
      if (voice.lang.toLowerCase() == expectedLanguage) return voice;
    }
    for (final voice in voices) {
      if (voice.lang.toLowerCase().startsWith('$expectedCode-')) return voice;
    }
    return null;
  }

  bool _isCurrent(int generation) => generation == _generation;

  void _setPlayback(SpeechPlayback playback) {
    _playback = playback;
    _changes.add(playback);
  }
}

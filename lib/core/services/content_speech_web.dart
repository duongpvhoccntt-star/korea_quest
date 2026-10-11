import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'content_speech_service.dart';

ContentSpeechService createPlatformContentSpeechService() =>
    _BrowserContentSpeechService();

/// Reads content through the browser's built-in speech engine. This keeps
/// read-aloud available to Guests without a cloud API key or audio download.
class _BrowserContentSpeechService implements ContentSpeechService {
  _BrowserContentSpeechService() {
    try {
      _synthesis = web.window.speechSynthesis;
      _synthesis.onvoiceschanged = ((web.Event _) {
        _availabilityChanges.add(null);
      }).toJS;
    } on Object {
      _supported = false;
    }
  }

  late final web.SpeechSynthesis _synthesis;
  final _changes = StreamController<SpeechPlayback>.broadcast();
  final _availabilityChanges = StreamController<void>.broadcast();
  SpeechPlayback _playback = const SpeechPlayback.idle();
  web.SpeechSynthesisUtterance? _utterance;
  var _supported = true;
  int _generation = 0;

  @override
  bool get isSupported => _supported;

  @override
  SpeechPlayback get playback => _playback;

  @override
  Stream<SpeechPlayback> get changes => _changes.stream;

  @override
  Stream<void> get voiceChanges => _availabilityChanges.stream;

  @override
  SpeechLocaleAvailability availabilityFor(LocationSpeechSource source) =>
      _supported
      ? SpeechLocaleAvailability.available
      : SpeechLocaleAvailability.unavailable;

  @override
  Future<SpeechStartResult> speak({
    required String sessionId,
    required String text,
    required String locale,
    required LocationSpeechSource source,
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return const SpeechStartResult.emptyText();
    if (!_supported) return const SpeechStartResult.unavailable();

    final generation = ++_generation;
    try {
      _synthesis.cancel();
      final utterance = web.SpeechSynthesisUtterance(normalizedText)
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
      if (_isCurrent(generation)) {
        _utterance = null;
        _setPlayback(const SpeechPlayback.idle());
      }
      return const SpeechStartResult.failed();
    }
  }

  @override
  void pause() {
    if (!_supported || _utterance == null) return;
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
    if (!_supported || _utterance == null) return;
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
    if (_supported) _synthesis.cancel();
    _utterance = null;
    _setPlayback(const SpeechPlayback.idle());
  }

  web.SpeechSynthesisVoice? _preferredVoice(String locale) {
    try {
      final expectedLanguage = speechLocaleFor(locale).toLowerCase();
      final expectedCode = expectedLanguage.split('-').first;
      final voices = _synthesis.getVoices().toDart;
      for (final voice in voices) {
        if (voice.lang.toLowerCase() == expectedLanguage) return voice;
      }
      for (final voice in voices) {
        if (voice.lang.toLowerCase().startsWith('$expectedCode-')) return voice;
      }
    } on Object {
      // Let the browser select its normal fallback voice.
    }
    return null;
  }

  bool _isCurrent(int generation) => generation == _generation;

  void _setPlayback(SpeechPlayback playback) {
    _playback = playback;
    _changes.add(playback);
  }
}

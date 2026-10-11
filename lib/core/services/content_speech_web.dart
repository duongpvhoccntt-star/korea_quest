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
        _refreshVoices();
      }).toJS;
      _refreshVoices();
    } on Object {
      _supported = false;
    }
  }

  late final web.SpeechSynthesis _synthesis;
  final _changes = StreamController<SpeechPlayback>.broadcast();
  final _availabilityChanges = StreamController<void>.broadcast();
  SpeechPlayback _playback = const SpeechPlayback.idle();
  web.SpeechSynthesisUtterance? _utterance;
  List<web.SpeechSynthesisVoice> _voices = const [];
  var _supported = true;
  var _voicesAreReady = false;
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
      browserSpeechAvailability(
        isSupported: _supported,
        voicesAreReady: _voicesAreReady,
        voiceLanguages: _voices.map((voice) => voice.lang),
        locale: source.locale,
      );

  @override
  Future<SpeechStartResult> speak({
    required String sessionId,
    required String text,
    required String locale,
    required LocationSpeechSource source,
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return const SpeechStartResult.emptyText();
    if (availabilityFor(source) != SpeechLocaleAvailability.available) {
      return const SpeechStartResult.unavailable();
    }

    final voice = _preferredVoice(locale);
    if (voice == null) return const SpeechStartResult.unavailable();

    final generation = ++_generation;
    try {
      _synthesis.cancel();
      final utterance = web.SpeechSynthesisUtterance(normalizedText)
        ..lang = speechLocaleFor(locale)
        ..voice = voice
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

  void _refreshVoices() {
    try {
      _voices = _synthesis.getVoices().toDart;
      _voicesAreReady = _voices.isNotEmpty;
    } on Object {
      _voices = const [];
      _voicesAreReady = false;
    }
    _availabilityChanges.add(null);
  }

  web.SpeechSynthesisVoice? _preferredVoice(String locale) {
    final expectedLanguage = speechLocaleFor(locale).toLowerCase();
    final expectedCode = expectedLanguage.split('-').first;
    for (final voice in _voices) {
      if (voice.lang.toLowerCase() == expectedLanguage) return voice;
    }
    for (final voice in _voices) {
      final language = voice.lang.toLowerCase();
      if (language == expectedCode || language.startsWith('$expectedCode-')) {
        return voice;
      }
    }
    return null;
  }

  bool _isCurrent(int generation) => generation == _generation;

  void _setPlayback(SpeechPlayback playback) {
    _playback = playback;
    _changes.add(playback);
  }
}

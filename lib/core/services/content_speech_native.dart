import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:korea_quest/core/services/content_speech_service.dart';

/// Uses the operating system's installed speech engine. It deliberately does
/// not require a cloud voice: if the requested locale is absent, the platform
/// is allowed to choose its normal system fallback voice.
ContentSpeechService createPlatformContentSpeechService() =>
    _NativeContentSpeechService();

class _NativeContentSpeechService implements ContentSpeechService {
  _NativeContentSpeechService() {
    _tts
      ..setStartHandler(() => _setPlayback(_activePlayback()))
      ..setCompletionHandler(() => _setPlayback(const SpeechPlayback.idle()))
      ..setCancelHandler(() => _setPlayback(const SpeechPlayback.idle()))
      ..setPauseHandler(
        () => _setPlayback(
          SpeechPlayback(
            state: SpeechPlaybackState.paused,
            sessionId: _activeSessionId,
          ),
        ),
      )
      ..setContinueHandler(() => _setPlayback(_activePlayback()))
      ..setErrorHandler(
        (message) => _setPlayback(
          SpeechPlayback(
            state: SpeechPlaybackState.error,
            sessionId: _activeSessionId,
            message: message.toString(),
          ),
        ),
      );
    unawaited(_refreshVoices());
  }

  final FlutterTts _tts = FlutterTts();
  final _changes = StreamController<SpeechPlayback>.broadcast();
  final _voiceChanges = StreamController<void>.broadcast();
  SpeechPlayback _playback = const SpeechPlayback.idle();
  String? _activeSessionId;
  String? _activeText;
  String? _activeLocale;
  // Native engines commonly do not answer getVoices until their first speak
  // request. Start as usable and let the platform report a real failure;
  // otherwise every read-aloud button stays on an indeterminate loader.
  var _voicesLoaded = true;
  var _hasAnyVoice = true;

  @override
  bool get isSupported => true;

  @override
  SpeechPlayback get playback => _playback;

  @override
  Stream<SpeechPlayback> get changes => _changes.stream;

  @override
  Stream<void> get voiceChanges => _voiceChanges.stream;

  @override
  SpeechLocaleAvailability availabilityFor(String locale) {
    if (!_voicesLoaded) return SpeechLocaleAvailability.loading;
    // A system fallback voice is preferable to refusing to read content.
    return _hasAnyVoice
        ? SpeechLocaleAvailability.available
        : SpeechLocaleAvailability.unavailable;
  }

  @override
  Future<SpeechStartResult> speak({
    required String sessionId,
    required String text,
    required String locale,
    required LocationSpeechSource source,
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return const SpeechStartResult.emptyText();
    if (!_voicesLoaded) await _refreshVoices();
    if (!_hasAnyVoice) return const SpeechStartResult.unavailable();

    _activeSessionId = sessionId;
    _activeText = normalizedText;
    _activeLocale = locale;
    try {
      await _tts.stop();
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSpeechRate(.46);
      final requestedLocale = speechLocaleFor(locale);
      final available = await _tts.isLanguageAvailable(requestedLocale);
      if (available == true) await _tts.setLanguage(requestedLocale);
      _setPlayback(_activePlayback());
      await _tts.speak(normalizedText);
      return const SpeechStartResult.started();
    } on Object catch (error) {
      _setPlayback(
        SpeechPlayback(
          state: SpeechPlaybackState.error,
          sessionId: _activeSessionId,
          message: error.toString(),
        ),
      );
      return const SpeechStartResult.failed();
    }
  }

  Future<void> _refreshVoices() async {
    try {
      final voices = await _tts.getVoices;
      _hasAnyVoice = voices is List && voices.isNotEmpty;
    } catch (_) {
      // Several engines do not expose their voice list but can still speak.
      _hasAnyVoice = true;
    } finally {
      _voicesLoaded = true;
      _voiceChanges.add(null);
    }
  }

  @override
  void pause() {
    unawaited(_tts.pause());
  }

  @override
  void resume() {
    final text = _activeText;
    if (text != null) {
      // flutter_tts has no dependable cross-platform resume. Restarting the
      // active passage is clearer than leaving the player silently paused.
      unawaited(
        speak(
          sessionId: _activeSessionId ?? '',
          text: text,
          locale: _activeLocale ?? 'vi',
          source: LocationSpeechSource(
            slug: '',
            locale: _activeLocale ?? 'vi',
            segment: LocationSpeechSegment.overview,
          ),
        ),
      );
    }
  }

  @override
  void stop() {
    unawaited(_tts.stop());
    _activeSessionId = null;
    _activeText = null;
    _activeLocale = null;
    _setPlayback(const SpeechPlayback.idle());
  }

  SpeechPlayback _activePlayback() => SpeechPlayback(
    state: SpeechPlaybackState.speaking,
    sessionId: _activeSessionId,
  );

  void _setPlayback(SpeechPlayback playback) {
    _playback = playback;
    _changes.add(playback);
  }
}

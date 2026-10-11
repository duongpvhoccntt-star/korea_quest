import 'dart:async';
import 'dart:js_interop';

import 'package:korea_quest/app/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;

import 'content_speech_service.dart';

ContentSpeechService createPlatformContentSpeechService() =>
    _CloudContentSpeechService();

/// Plays cached Cloud TTS MP3. Native Web Speech is deliberately never used:
/// published content therefore sounds the same on every supported device.
class _CloudContentSpeechService implements ContentSpeechService {
  final _changes = StreamController<SpeechPlayback>.broadcast();
  final _availabilityChanges = StreamController<void>.broadcast();
  SpeechPlayback _playback = const SpeechPlayback.idle();
  web.HTMLAudioElement? _audio;
  int _generation = 0;

  @override
  bool get isSupported => AppConfig.hasSupabaseConfiguration;

  @override
  SpeechPlayback get playback => _playback;

  @override
  Stream<SpeechPlayback> get changes => _changes.stream;

  @override
  Stream<void> get voiceChanges => _availabilityChanges.stream;

  @override
  SpeechLocaleAvailability availabilityFor(String locale) => isSupported
      ? SpeechLocaleAvailability.available
      : SpeechLocaleAvailability.unavailable;

  @override
  Future<SpeechStartResult> speak({
    required String sessionId,
    required String text,
    required String locale,
    required LocationSpeechSource source,
  }) async {
    if (text.trim().isEmpty) return const SpeechStartResult.emptyText();
    if (!isSupported) return const SpeechStartResult.unavailable();

    final generation = ++_generation;
    _stopAudio();
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'synthesize-location-speech',
        body: source.toRequest(),
      );
      final data = response.data;
      final audioUrl = data is Map ? data['audio_url'] : null;
      if (audioUrl is! String || audioUrl.isEmpty || !_isCurrent(generation)) {
        return const SpeechStartResult.failed();
      }

      final audio = web.HTMLAudioElement()
        ..src = audioUrl
        ..preload = 'auto'
        ..onended = ((web.Event _) {
          if (_isCurrent(generation)) _setPlayback(const SpeechPlayback.idle());
        }).toJS
        ..onerror = ((web.Event _) {
          if (_isCurrent(generation)) _setPlayback(const SpeechPlayback.idle());
        }).toJS;
      _audio = audio;
      await audio.play().toDart;
      if (!_isCurrent(generation)) return const SpeechStartResult.failed();
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
    _audio?.pause();
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
    final audio = _audio;
    if (audio == null) return;
    unawaited(audio.play().toDart);
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
    _stopAudio();
    _setPlayback(const SpeechPlayback.idle());
  }

  bool _isCurrent(int generation) => generation == _generation;

  void _stopAudio() {
    final audio = _audio;
    if (audio == null) return;
    audio.pause();
    audio.currentTime = 0;
    _audio = null;
  }

  void _setPlayback(SpeechPlayback playback) {
    _playback = playback;
    _changes.add(playback);
  }
}

import 'dart:async';
import 'dart:js_interop';

import 'package:korea_quest/app/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;

import 'content_speech_service.dart';

ContentSpeechService createPlatformContentSpeechService() =>
    _CloudContentSpeechService();

/// Cloud MP3 is the default production path. The native branch is deliberately
/// available only when LOCAL_NAMSAN_NATIVE_SPEECH is set for a local demo.
class _CloudContentSpeechService implements ContentSpeechService {
  final _changes = StreamController<SpeechPlayback>.broadcast();
  final _availabilityChanges = StreamController<void>.broadcast();
  SpeechPlayback _playback = const SpeechPlayback.idle();
  web.HTMLAudioElement? _audio;
  List<web.SpeechSynthesisVoice> _voices = const [];
  bool _voicesReady = false;
  bool _nativeSupported = true;
  bool _usingNative = false;
  int _generation = 0;

  _CloudContentSpeechService() {
    if (!AppConfig.localNamsanNativeSpeech) return;
    try {
      _refreshVoices();
      web.window.speechSynthesis.onvoiceschanged = ((web.Event _) {
        _voicesReady = true;
        _refreshVoices(notify: true);
      }).toJS;
      Timer(const Duration(seconds: 1), () {
        if (_voicesReady) return;
        _voicesReady = true;
        _refreshVoices(notify: true);
      });
    } on Object {
      _nativeSupported = false;
      _voicesReady = true;
    }
  }

  @override
  bool get isSupported =>
      AppConfig.hasSupabaseConfiguration || AppConfig.localNamsanNativeSpeech;

  @override
  SpeechPlayback get playback => _playback;

  @override
  Stream<SpeechPlayback> get changes => _changes.stream;

  @override
  Stream<void> get voiceChanges => _availabilityChanges.stream;

  @override
  SpeechLocaleAvailability availabilityFor(LocationSpeechSource source) {
    if (AppConfig.localNamsanNativeSpeech) {
      if (!_usesLocalNativeSpeech(source)) {
        return SpeechLocaleAvailability.unavailable;
      }
      if (!_nativeSupported) return SpeechLocaleAvailability.unavailable;
      if (_voiceFor(source.locale) != null) {
        return SpeechLocaleAvailability.available;
      }
      return _voicesReady
          ? SpeechLocaleAvailability.unavailable
          : SpeechLocaleAvailability.loading;
    }
    return AppConfig.hasSupabaseConfiguration
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
    if (text.trim().isEmpty) return const SpeechStartResult.emptyText();
    if (_usesLocalNativeSpeech(source)) {
      return _speakLocally(
        sessionId: sessionId,
        text: text,
        locale: source.locale,
      );
    }
    if (!AppConfig.hasSupabaseConfiguration) {
      return const SpeechStartResult.unavailable();
    }
    return _speakCloud(sessionId: sessionId, source: source);
  }

  Future<SpeechStartResult> _speakCloud({
    required String sessionId,
    required LocationSpeechSource source,
  }) async {
    final generation = ++_generation;
    _usingNative = false;
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

  Future<SpeechStartResult> _speakLocally({
    required String sessionId,
    required String text,
    required String locale,
  }) async {
    final voice = _voiceFor(locale);
    if (voice == null) return const SpeechStartResult.unavailable();
    final generation = ++_generation;
    _usingNative = true;
    _stopAudio();
    try {
      final speech = web.window.speechSynthesis;
      speech.cancel();
      final utterance = web.SpeechSynthesisUtterance(text.trim())
        ..lang = speechLocaleFor(locale)
        ..voice = voice
        ..rate = .92
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
      speech.speak(utterance);
      return const SpeechStartResult.started();
    } on Object {
      _setPlayback(const SpeechPlayback.idle());
      return const SpeechStartResult.unavailable();
    }
  }

  @override
  void pause() {
    if (_usingNative) {
      web.window.speechSynthesis.pause();
    } else {
      _audio?.pause();
    }
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
    if (_usingNative) {
      web.window.speechSynthesis.resume();
    } else {
      final audio = _audio;
      if (audio != null) unawaited(audio.play().toDart);
    }
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
    if (_usingNative) web.window.speechSynthesis.cancel();
    _stopAudio();
    _setPlayback(const SpeechPlayback.idle());
  }

  bool _usesLocalNativeSpeech(LocationSpeechSource source) =>
      AppConfig.localNamsanNativeSpeech && source.slug == 'namsan';

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

  void _refreshVoices({bool notify = false}) {
    try {
      _voices = web.window.speechSynthesis.getVoices().toDart;
      if (_voices.isNotEmpty) _voicesReady = true;
    } on Object {
      _voices = const [];
    }
    if (notify) _availabilityChanges.add(null);
  }

  web.SpeechSynthesisVoice? _voiceFor(String locale) {
    _refreshVoices();
    final target = speechLocaleFor(locale).toLowerCase();
    final language = target.split('-').first;
    final matches =
        _voices
            .where(
              (voice) => voice.lang.toLowerCase().split('-').first == language,
            )
            .toList()
          ..sort((left, right) {
            final leftExact = left.lang.toLowerCase() == target ? 0 : 1;
            final rightExact = right.lang.toLowerCase() == target ? 0 : 1;
            final exact = leftExact.compareTo(rightExact);
            if (exact != 0) return exact;
            final defaults = (right.default_ ? 1 : 0).compareTo(
              left.default_ ? 1 : 0,
            );
            if (defaults != 0) return defaults;
            final local = (right.localService ? 1 : 0).compareTo(
              left.localService ? 1 : 0,
            );
            if (local != 0) return local;
            return left.name.toLowerCase().compareTo(right.name.toLowerCase());
          });
    return matches.isEmpty ? null : matches.first;
  }
}

import 'dart:async';

import 'content_speech_stub.dart'
    if (dart.library.js_interop) 'content_speech_web.dart';

enum SpeechPlaybackState { idle, speaking, paused }

enum SpeechLocaleAvailability { loading, available, unavailable }

enum SpeechStartStatus { started, emptyText, unavailable, failed }

/// A public, server-validated segment of a published location.
///
/// The browser never sends the text to synthesize. The Edge Function rebuilds
/// it from the published read model only.
enum LocationSpeechSegment {
  overview,
  history,
  highlight,
  experience,
  food,
  funFact,
  transport;

  String get wireName => switch (this) {
    LocationSpeechSegment.overview => 'overview',
    LocationSpeechSegment.history => 'history',
    LocationSpeechSegment.highlight => 'highlight',
    LocationSpeechSegment.experience => 'experience',
    LocationSpeechSegment.food => 'food',
    LocationSpeechSegment.funFact => 'fun_fact',
    LocationSpeechSegment.transport => 'transport',
  };

  bool get needsIndex => this != LocationSpeechSegment.overview;
}

class LocationSpeechSource {
  const LocationSpeechSource({
    required this.slug,
    required this.locale,
    required this.segment,
    this.index,
  }) : assert(segment == LocationSpeechSegment.overview || index != null);

  final String slug;
  final String locale;
  final LocationSpeechSegment segment;
  final int? index;

  Map<String, dynamic> toRequest() => {
    'slug': slug,
    'locale': _languageCode(locale),
    'segment': segment.wireName,
    if (index != null) 'index': index,
  };
}

class SpeechPlayback {
  const SpeechPlayback({required this.state, this.sessionId});

  const SpeechPlayback.idle() : this(state: SpeechPlaybackState.idle);

  final SpeechPlaybackState state;
  final String? sessionId;
}

class SpeechStartResult {
  const SpeechStartResult._(this.status);

  const SpeechStartResult.started() : this._(SpeechStartStatus.started);

  const SpeechStartResult.emptyText() : this._(SpeechStartStatus.emptyText);

  const SpeechStartResult.unavailable() : this._(SpeechStartStatus.unavailable);

  const SpeechStartResult.failed() : this._(SpeechStartStatus.failed);

  final SpeechStartStatus status;

  bool get didStart => status == SpeechStartStatus.started;
}

String speechLocaleFor(String locale) => switch (_languageCode(locale)) {
  'ko' => 'ko-KR',
  'en' => 'en-US',
  _ => 'vi-VN',
};

/// Fixed voices are intentionally versioned in the cache input server-side.
String cloudSpeechVoiceFor(String locale) => switch (_languageCode(locale)) {
  'ko' => 'ko-KR-Neural2-A',
  'en' => 'en-US-Neural2-F',
  _ => 'vi-VN-Neural2-A',
};

String _languageCode(String locale) => locale.toLowerCase().split('-').first;

abstract interface class ContentSpeechService {
  bool get isSupported;
  SpeechPlayback get playback;
  Stream<SpeechPlayback> get changes;
  Stream<void> get voiceChanges;

  SpeechLocaleAvailability availabilityFor(String locale);

  Future<SpeechStartResult> speak({
    required String sessionId,
    required String text,
    required String locale,
    required LocationSpeechSource source,
  });
  void pause();
  void resume();
  void stop();
}

final ContentSpeechService contentSpeechService =
    createPlatformContentSpeechService();

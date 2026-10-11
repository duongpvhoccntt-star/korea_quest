import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/core/services/content_speech_service.dart';
import 'package:korea_quest/features/explore/presentation/widgets/content_read_aloud_controls.dart';

void main() {
  test('maps each public locale to a browser speech locale', () {
    expect(speechLocaleFor('vi'), 'vi-VN');
    expect(speechLocaleFor('ko-KR'), 'ko-KR');
    expect(speechLocaleFor('en-US'), 'en-US');
  });

  test('serializes only a public segment selector', () {
    const source = LocationSpeechSource(
      slug: 'gyeongbokgung',
      locale: 'vi-VN',
      segment: LocationSpeechSegment.history,
      index: 2,
    );
    expect(source.toRequest(), {
      'slug': 'gyeongbokgung',
      'locale': 'vi',
      'segment': 'history',
      'index': 2,
    });
  });

  testWidgets('uses the resolved content locale and public selector', (
    tester,
  ) async {
    final speech = _FakeSpeechService();
    const source = LocationSpeechSource(
      slug: 'gyeongbokgung',
      locale: 'vi',
      segment: LocationSpeechSegment.overview,
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        home: Scaffold(
          body: ContentReadAloudControls(
            sessionId: 'overview',
            text: 'Nội dung tiếng Việt',
            source: source,
            speechService: speech,
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.volume_up_rounded));
    await tester.pump();
    expect(speech.sources.single.toRequest(), source.toRequest());
  });

  testWidgets('does not start playback when speech is unavailable', (
    tester,
  ) async {
    final speech = _FakeSpeechService(
      availability: SpeechLocaleAvailability.unavailable,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ContentReadAloudControls(
            sessionId: 'overview',
            text: 'Nội dung',
            source: const LocationSpeechSource(
              slug: 'gyeongbokgung',
              locale: 'vi',
              segment: LocationSpeechSegment.overview,
            ),
            speechService: speech,
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
    expect(speech.sources, isEmpty);
  });
}

class _FakeSpeechService implements ContentSpeechService {
  _FakeSpeechService({this.availability = SpeechLocaleAvailability.available});
  final SpeechLocaleAvailability availability;
  final _changes = StreamController<SpeechPlayback>.broadcast();
  final _voiceChanges = StreamController<void>.broadcast();
  final List<LocationSpeechSource> sources = [];
  SpeechPlayback _playback = const SpeechPlayback.idle();
  @override
  bool get isSupported => true;
  @override
  SpeechPlayback get playback => _playback;
  @override
  Stream<SpeechPlayback> get changes => _changes.stream;
  @override
  Stream<void> get voiceChanges => _voiceChanges.stream;
  @override
  SpeechLocaleAvailability availabilityFor(LocationSpeechSource source) =>
      availability;
  @override
  void pause() {}
  @override
  void resume() {}
  @override
  Future<SpeechStartResult> speak({
    required String sessionId,
    required String text,
    required String locale,
    required LocationSpeechSource source,
  }) async {
    sources.add(source);
    _playback = SpeechPlayback(
      state: SpeechPlaybackState.speaking,
      sessionId: sessionId,
    );
    _changes.add(_playback);
    return const SpeechStartResult.started();
  }

  @override
  void stop() {
    _playback = const SpeechPlayback.idle();
    _changes.add(_playback);
  }
}

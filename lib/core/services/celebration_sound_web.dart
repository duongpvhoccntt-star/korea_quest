import 'dart:js_interop';

import 'package:web/web.dart';

/// A four-second, game-style Korean-inspired victory fanfare.
///
/// The browser synthesizes the tones at runtime, so no audio file or extra
/// package is needed for Flutter Web.
abstract final class CelebrationSound {
  static AudioContext? _context;

  /// Creates the audio context while a user gesture is still active. Browsers
  /// commonly reject an audio context first created after an async request.
  static Future<void> prime() async {
    try {
      final context = _context ??= AudioContext();
      await context.resume().toDart;
    } on Object {
      // Sound is optional feedback and must not affect journey completion.
    }
  }

  static Future<void> play() async {
    await prime();
    final context = _context;
    if (context == null) return;

    for (final note in _notes) {
      _scheduleTone(context, note);
    }
  }

  static void _scheduleTone(AudioContext context, _CelebrationTone note) {
    final startAt = context.currentTime + note.delay;
    final endAt = startAt + note.duration;
    final oscillator = context.createOscillator();
    final gain = context.createGain();

    oscillator.type = note.waveform;
    oscillator.frequency.setValueAtTime(note.frequency, startAt);
    gain.gain
      ..setValueAtTime(.0001, startAt)
      ..exponentialRampToValueAtTime(note.volume, startAt + .02)
      ..exponentialRampToValueAtTime(.0001, endAt);
    oscillator
      ..connect(gain)
      ..start(startAt)
      ..stop(endAt);
    gain.connect(context.destination);
  }

  // G–A–C–D–E–G: a bright pentatonic shape, layered with a soft drone and
  // bell-like high notes to suggest a festive plucked-instrument texture.
  static const _notes = <_CelebrationTone>[
    _CelebrationTone(frequency: 392, delay: 0, duration: .42, volume: .065),
    _CelebrationTone(frequency: 440, delay: .26, duration: .42, volume: .07),
    _CelebrationTone(
      frequency: 523.25,
      delay: .52,
      duration: .44,
      volume: .075,
    ),
    _CelebrationTone(frequency: 587.33, delay: .8, duration: .46, volume: .08),
    _CelebrationTone(
      frequency: 659.25,
      delay: 1.08,
      duration: .58,
      volume: .085,
    ),
    _CelebrationTone(
      frequency: 196,
      delay: .72,
      duration: 2.7,
      volume: .026,
      waveform: 'triangle',
    ),
    _CelebrationTone(
      frequency: 293.66,
      delay: .72,
      duration: 2.7,
      volume: .03,
      waveform: 'triangle',
    ),
    _CelebrationTone(
      frequency: 783.99,
      delay: 1.44,
      duration: .46,
      volume: .06,
    ),
    _CelebrationTone(
      frequency: 659.25,
      delay: 1.75,
      duration: .38,
      volume: .055,
    ),
    _CelebrationTone(
      frequency: 783.99,
      delay: 2.02,
      duration: .42,
      volume: .065,
    ),
    _CelebrationTone(
      frequency: 1046.5,
      delay: 2.3,
      duration: .58,
      volume: .075,
    ),
    _CelebrationTone(
      frequency: 783.99,
      delay: 2.78,
      duration: .38,
      volume: .055,
    ),
    _CelebrationTone(
      frequency: 1046.5,
      delay: 3.04,
      duration: .48,
      volume: .07,
    ),
    _CelebrationTone(
      frequency: 1318.51,
      delay: 3.3,
      duration: .82,
      volume: .08,
    ),
    _CelebrationTone(
      frequency: 659.25,
      delay: 3.3,
      duration: .82,
      volume: .04,
      waveform: 'triangle',
    ),
    _CelebrationTone(
      frequency: 783.99,
      delay: 3.3,
      duration: .82,
      volume: .04,
      waveform: 'triangle',
    ),
  ];
}

class _CelebrationTone {
  const _CelebrationTone({
    required this.frequency,
    required this.delay,
    required this.duration,
    required this.volume,
    this.waveform = 'sine',
  });

  final num frequency;
  final num delay;
  final num duration;
  final num volume;
  final String waveform;
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:korea_quest/core/services/content_speech_service.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/l10n/app_strings.dart';

class ContentReadAloudControls extends StatefulWidget {
  const ContentReadAloudControls({
    required this.sessionId,
    required this.text,
    super.key,
  });

  final String sessionId;
  final String text;

  @override
  State<ContentReadAloudControls> createState() =>
      _ContentReadAloudControlsState();
}

class _ContentReadAloudControlsState extends State<ContentReadAloudControls> {
  late SpeechPlayback _playback;
  StreamSubscription<SpeechPlayback>? _subscription;

  @override
  void initState() {
    super.initState();
    _playback = contentSpeechService.playback;
    _subscription = contentSpeechService.changes.listen((playback) {
      if (mounted) setState(() => _playback = playback);
    });
  }

  @override
  void dispose() {
    if (_isActive) contentSpeechService.stop();
    _subscription?.cancel();
    super.dispose();
  }

  bool get _isActive => _playback.sessionId == widget.sessionId;

  @override
  Widget build(BuildContext context) {
    if (!contentSpeechService.isSupported || widget.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final strings = appStrings(context);
    if (!_isActive) {
      return OutlinedButton.icon(
        onPressed: () {
          contentSpeechService.speak(
            sessionId: widget.sessionId,
            text: widget.text,
            locale: Localizations.localeOf(context).languageCode,
          );
          setState(() => _playback = contentSpeechService.playback);
        },
        icon: const Icon(Icons.volume_up_rounded),
        label: Text('\u{1F50A} ${strings.listenRead}'),
      );
    }

    final isPaused = _playback.state == SpeechPlaybackState.paused;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            if (isPaused) {
              contentSpeechService.resume();
            } else {
              contentSpeechService.pause();
            }
          },
          icon: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
          label: Text(isPaused ? strings.resumeReading : strings.pauseReading),
        ),
        OutlinedButton.icon(
          onPressed: contentSpeechService.stop,
          icon: const Icon(Icons.stop_rounded),
          label: Text(strings.stopReading),
        ),
      ],
    );
  }
}

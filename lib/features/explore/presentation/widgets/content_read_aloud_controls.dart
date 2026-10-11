import 'dart:async';

import 'package:flutter/material.dart';
import 'package:korea_quest/core/services/content_speech_service.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/l10n/app_strings.dart';

class ContentReadAloudControls extends StatefulWidget {
  const ContentReadAloudControls({
    required this.sessionId,
    required this.text,
    required this.source,
    this.speechService,
    super.key,
  });

  final String sessionId;
  final String text;
  final LocationSpeechSource source;
  final ContentSpeechService? speechService;

  @override
  State<ContentReadAloudControls> createState() =>
      _ContentReadAloudControlsState();
}

class _ContentReadAloudControlsState extends State<ContentReadAloudControls> {
  late SpeechPlayback _playback;
  late ContentSpeechService _speechService;
  late SpeechLocaleAvailability _availability;
  StreamSubscription<SpeechPlayback>? _subscription;
  StreamSubscription<void>? _voiceSubscription;

  @override
  void initState() {
    super.initState();
    _speechService = widget.speechService ?? contentSpeechService;
    _playback = _speechService.playback;
    _availability = _speechService.availabilityFor(widget.source.locale);
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant ContentReadAloudControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextService = widget.speechService ?? contentSpeechService;
    if (nextService != _speechService) {
      _subscription?.cancel();
      _voiceSubscription?.cancel();
      _speechService = nextService;
      _playback = _speechService.playback;
      _subscribe();
    }
    if (oldWidget.source.locale != widget.source.locale) {
      _refreshAvailability();
    }
  }

  void _subscribe() {
    _subscription = _speechService.changes.listen((playback) {
      if (mounted) setState(() => _playback = playback);
    });
    _voiceSubscription = _speechService.voiceChanges.listen((_) {
      if (mounted) _refreshAvailability();
    });
  }

  void _refreshAvailability() {
    setState(() {
      _availability = _speechService.availabilityFor(widget.source.locale);
    });
  }

  @override
  void dispose() {
    if (_isActive) _speechService.stop();
    _subscription?.cancel();
    _voiceSubscription?.cancel();
    super.dispose();
  }

  bool get _isActive => _playback.sessionId == widget.sessionId;

  @override
  Widget build(BuildContext context) {
    if (!_speechService.isSupported || widget.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final strings = appStrings(context);
    if (_availability == SpeechLocaleAvailability.loading) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: Text(strings.speechVoiceLoading),
      );
    }
    if (_availability == SpeechLocaleAvailability.unavailable) {
      return Tooltip(
        message: strings.speechVoiceUnavailable,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.volume_off_rounded),
          label: Text(strings.speechVoiceUnavailable),
        ),
      );
    }
    if (!_isActive) {
      return OutlinedButton.icon(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final result = await _speechService.speak(
            sessionId: widget.sessionId,
            text: widget.text,
            locale: widget.source.locale,
            source: widget.source,
          );
          if (!mounted) return;
          _refreshAvailability();
          if (!result.didStart) {
            messenger.showSnackBar(
              SnackBar(content: Text(strings.speechAudioUnavailable)),
            );
          }
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
              _speechService.resume();
            } else {
              _speechService.pause();
            }
          },
          icon: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
          label: Text(isPaused ? strings.resumeReading : strings.pauseReading),
        ),
        OutlinedButton.icon(
          onPressed: _speechService.stop,
          icon: const Icon(Icons.stop_rounded),
          label: Text(strings.stopReading),
        ),
      ],
    );
  }
}

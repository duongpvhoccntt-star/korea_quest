import 'package:flutter/material.dart';
import 'package:korea_quest/l10n/app_strings.dart';
import 'package:url_launcher/link.dart';
import 'package:korea_quest/core/utils/youtube_video.dart';

class YoutubePlayer extends StatelessWidget {
  const YoutubePlayer({required this.url, required this.label, super.key});

  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    final video = YoutubeVideo.tryParse(url);
    if (video == null) {
      return const _InvalidYoutubeVideo();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Link(
          uri: video.watchUri,
          target: LinkTarget.blank,
          builder: (context, followLink) => TextButton.icon(
            onPressed: followLink,
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(appStrings(context).openVideoOnYoutube(label)),
          ),
        ),
      ),
    );
  }
}

class _InvalidYoutubeVideo extends StatelessWidget {
  const _InvalidYoutubeVideo();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(appStrings(context).invalidYoutube),
    ),
  );
}

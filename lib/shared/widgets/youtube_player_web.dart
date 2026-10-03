import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
import 'package:korea_quest/core/utils/youtube_video.dart';
import 'package:web/web.dart' as web;

class YoutubePlayer extends StatefulWidget {
  const YoutubePlayer({required this.url, required this.label, super.key});

  final String url;
  final String label;

  @override
  State<YoutubePlayer> createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubePlayer> {
  static var _nextViewId = 0;

  YoutubeVideo? _video;
  String? _viewType;

  @override
  void initState() {
    super.initState();
    _registerView();
  }

  @override
  void didUpdateWidget(covariant YoutubePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _registerView();
  }

  void _registerView() {
    _video = YoutubeVideo.tryParse(widget.url);
    if (_video == null) {
      _viewType = null;
      return;
    }

    _viewType = 'koreaquest-youtube-${_nextViewId++}';
    final video = _video!;
    ui_web.platformViewRegistry.registerViewFactory(_viewType!, (viewId) {
      final frame = web.HTMLIFrameElement()
        ..src = video.embedUri.toString()
        ..title = widget.label
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%';
      frame.setAttribute(
        'allow',
        'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share',
      );
      frame.setAttribute('allowfullscreen', 'true');
      return frame;
    });
  }

  @override
  Widget build(BuildContext context) {
    final video = _video;
    if (video == null || _viewType == null) {
      return const _InvalidYoutubeVideo();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: HtmlElementView(viewType: _viewType!),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Link(
            uri: video.watchUri,
            target: LinkTarget.blank,
            builder: (context, followLink) => TextButton.icon(
              onPressed: followLink,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Mở trên YouTube'),
            ),
          ),
        ),
      ],
    );
  }
}

class _InvalidYoutubeVideo extends StatelessWidget {
  const _InvalidYoutubeVideo();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Text('Liên kết YouTube không hợp lệ hoặc không thể nhúng.'),
    ),
  );
}

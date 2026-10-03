class YoutubeVideo {
  const YoutubeVideo._(this.id);

  final String id;

  Uri get embedUri => Uri.https(
    'www.youtube-nocookie.com',
    '/embed/$id',
    const {'rel': '0', 'modestbranding': '1', 'playsinline': '1'},
  );

  Uri get watchUri => Uri.https('www.youtube.com', '/watch', {'v': id});

  static YoutubeVideo? tryParse(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return null;
    }

    final host = uri.host.toLowerCase().replaceFirst(RegExp(r'^(www|m)\.'), '');
    String? id;
    if (host == 'youtu.be') {
      id = uri.pathSegments.firstOrNull;
    } else if (host == 'youtube.com' || host.endsWith('.youtube.com')) {
      if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'watch') {
        id = uri.queryParameters['v'];
      } else if (uri.pathSegments.length >= 2 &&
          const {'embed', 'shorts', 'live'}.contains(uri.pathSegments.first)) {
        id = uri.pathSegments[1];
      }
    }

    if (id == null || !RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id)) {
      return null;
    }
    return YoutubeVideo._(id);
  }
}

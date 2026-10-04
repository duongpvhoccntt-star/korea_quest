/// Returns a smaller rendition for known Wikimedia image URLs.
///
/// URLs from other providers, including Supabase Storage uploads, are kept
/// unchanged so the original public URL remains the source of truth. Existing
/// Wikimedia thumbnails are also preserved because not every arbitrary width has
/// a valid rendition on the upstream server.
String optimizedImageUrl(String url, {required int maxWidth}) {
  if (maxWidth <= 0) return url;

  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return url;

  const filePathPrefixes = [
    '/wiki/Special:FilePath/',
    '/wiki/Special:Redirect/file/',
  ];
  final prefix = filePathPrefixes.where(uri.path.startsWith).firstOrNull;
  if (uri.host == 'commons.wikimedia.org' && prefix != null) {
    final fileName = Uri.decodeComponent(uri.path.substring(prefix.length));
    if (fileName.isEmpty) return url;

    return Uri.https(uri.host, '/w/index.php', {
      'title': 'Special:Redirect/file/$fileName',
      'width': '$maxWidth',
    }).toString();
  }

  return url;
}

extension on Iterable<String> {
  String? get firstOrNull => isEmpty ? null : first;
}

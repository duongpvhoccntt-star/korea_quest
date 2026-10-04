import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/core/utils/optimized_image_url.dart';

void main() {
  group('optimizedImageUrl', () {
    test('requests a resized Wikimedia Special:FilePath image', () {
      final result = optimizedImageUrl(
        'https://commons.wikimedia.org/wiki/Special:FilePath/Bukchon%20Hanok.jpg',
        maxWidth: 720,
      );
      final uri = Uri.parse(result);

      expect(uri.host, 'commons.wikimedia.org');
      expect(uri.path, '/w/index.php');
      expect(
        uri.queryParameters['title'],
        'Special:Redirect/file/Bukchon Hanok.jpg',
      );
      expect(uri.queryParameters['width'], '720');
    });

    test('resizes an existing Wikimedia thumbnail URL', () {
      expect(
        optimizedImageUrl(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/photo.jpg/1920px-photo.jpg',
          maxWidth: 720,
        ),
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/photo.jpg/720px-photo.jpg',
      );
    });

    test('keeps Supabase Storage URLs unchanged', () {
      const url =
          'https://project.supabase.co/storage/v1/object/public/content-media/a.jpg';

      expect(optimizedImageUrl(url, maxWidth: 720), url);
    });
  });
}

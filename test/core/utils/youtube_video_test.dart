import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/core/utils/youtube_video.dart';

void main() {
  group('YoutubeVideo.tryParse', () {
    test('accepts watch, short, embed and shorts URLs', () {
      const id = 'dQw4w9WgXcQ';
      final urls = [
        'https://www.youtube.com/watch?v=$id',
        'https://youtu.be/$id?t=12',
        'https://youtube.com/embed/$id',
        'https://m.youtube.com/shorts/$id',
      ];

      for (final url in urls) {
        expect(YoutubeVideo.tryParse(url)?.id, id);
      }
    });

    test('rejects non-YouTube URLs and malformed IDs', () {
      expect(
        YoutubeVideo.tryParse('https://example.com/watch?v=dQw4w9WgXcQ'),
        isNull,
      );
      expect(
        YoutubeVideo.tryParse('https://youtube.com/watch?v=short'),
        isNull,
      );
      expect(YoutubeVideo.tryParse('not a url'), isNull);
    });
  });
}

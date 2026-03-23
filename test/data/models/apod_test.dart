import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/data/models/apod.dart';

void main() {
  group('apod_tests', () {
    test('fromJson maps all fields when data is complete', () {
      // this test verifies full json mapping for apod.
      final json = {
        'title': 'Milky Way',
        'date': '2026-03-21',
        'explanation': 'bright core',
        'url': 'https://example.com/apod.jpg',
        'hdurl': 'https://example.com/apod-hd.jpg',
        'media_type': 'image',
        'copyright': 'NASA',
      };

      final apod = Apod.fromJson(json);

      expect(apod.title, 'Milky Way');
      expect(apod.date, '2026-03-21');
      expect(apod.explanation, 'bright core');
      expect(apod.url, 'https://example.com/apod.jpg');
      expect(apod.hdUrl, 'https://example.com/apod-hd.jpg');
      expect(apod.mediaType, 'image');
      expect(apod.copyright, 'NASA');
    });

    test('fromJson uses defaults when values are missing', () {
      // this test verifies default values for partial apod json.
      final json = <String, dynamic>{};

      final apod = Apod.fromJson(json);

      expect(apod.title, 'Untitled');
      expect(apod.date, '');
      expect(apod.explanation, '');
      expect(apod.url, '');
      expect(apod.hdUrl, isNull);
      expect(apod.mediaType, 'image');
      expect(apod.copyright, isNull);
    });

    test('toJson serializes fields with expected keys', () {
      // this test verifies apod serialization back to json.
      final apod = Apod(
        title: 'Nebula',
        date: '2026-03-20',
        explanation: 'dust and gas',
        url: 'https://example.com/nebula.jpg',
        hdUrl: null,
        mediaType: 'image',
        copyright: null,
      );

      final json = apod.toJson();

      expect(json['title'], 'Nebula');
      expect(json['date'], '2026-03-20');
      expect(json['explanation'], 'dust and gas');
      expect(json['url'], 'https://example.com/nebula.jpg');
      expect(json['hdurl'], isNull);
      expect(json['media_type'], 'image');
      expect(json['copyright'], isNull);
    });
  });
}

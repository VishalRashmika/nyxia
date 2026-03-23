import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/data/repositories/apod_service/apod_service.dart';
import 'package:nyxia/domain/usercases/apod/fetch_background_image_usecase.dart';

class FakeApodService extends ApodService {
  String? randomResponse;
  String? todayResponse;
  List<String?> randomQueue = <String?>[];
  bool randomCalled = false;
  bool todayCalled = false;

  @override
  Future<String?> fetchRandomApodImage() async {
    randomCalled = true;
    if (randomQueue.isNotEmpty) {
      return randomQueue.removeAt(0);
    }
    return randomResponse;
  }

  @override
  Future<String?> fetchApodImage() async {
    todayCalled = true;
    return todayResponse;
  }
}

void main() {
  group('fetch_background_image_usecase_tests', () {
    test('execute returns random image url when valid', () async {
      // this test verifies execute returns a valid random image url.
      final service = FakeApodService()
        ..randomResponse = 'https://example.com/a.jpg';
      final useCase = FetchBackgroundImageUseCase(service);

      final result = await useCase.execute(useRandom: true);

      expect(result, 'https://example.com/a.jpg');
      expect(service.randomCalled, isTrue);
      expect(service.todayCalled, isFalse);
    });

    test('execute throws when service returns empty url', () async {
      // this test verifies execute throws for empty image urls.
      final service = FakeApodService()..randomResponse = '';
      final useCase = FetchBackgroundImageUseCase(service);

      expect(
        () => useCase.execute(useRandom: true),
        throwsA(isA<ApodException>()),
      );
    });

    test('execute throws when service returns invalid url', () async {
      // this test verifies execute rejects non-http urls.
      final service = FakeApodService()..randomResponse = 'not-a-url';
      final useCase = FetchBackgroundImageUseCase(service);

      expect(
        () => useCase.execute(useRandom: true),
        throwsA(isA<ApodException>()),
      );
    });

    test('fetchTodayImage calls non-random source', () async {
      // this test verifies today image path uses fetchApodImage.
      final service = FakeApodService()
        ..todayResponse = 'https://example.com/today.jpg';
      final useCase = FetchBackgroundImageUseCase(service);

      final result = await useCase.fetchTodayImage();

      expect(result, 'https://example.com/today.jpg');
      expect(service.todayCalled, isTrue);
      expect(service.randomCalled, isFalse);
    });

    test('fetchMultipleImages returns collected valid images', () async {
      // this test verifies multiple image fetch collects successful urls.
      final service = FakeApodService()
        ..randomQueue = <String?>[
          'https://example.com/1.jpg',
          'https://example.com/2.jpg',
          null,
          'https://example.com/3.jpg',
        ];
      final useCase = FetchBackgroundImageUseCase(service);

      final images = await useCase.fetchMultipleImages(count: 4);

      expect(images.length, 3);
      expect(images.first, 'https://example.com/1.jpg');
      expect(images.last, 'https://example.com/3.jpg');
    });

    test('fetchMultipleImages throws when all requests fail', () async {
      // this test verifies multiple fetch throws when no image succeeds.
      final service = FakeApodService()
        ..randomQueue = <String?>[null, null, null];
      final useCase = FetchBackgroundImageUseCase(service);

      expect(
        () => useCase.fetchMultipleImages(count: 3),
        throwsA(isA<ApodException>()),
      );
    });

    test('getFallbackImageUrl returns a valid https url', () {
      // this test verifies fallback image url is always usable.
      final service = FakeApodService();
      final useCase = FetchBackgroundImageUseCase(service);

      final url = useCase.getFallbackImageUrl();

      expect(url.startsWith('https://'), isTrue);
      expect(url.contains('apod.nasa.gov'), isTrue);
    });
  });
}

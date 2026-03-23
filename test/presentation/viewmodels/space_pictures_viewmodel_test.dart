import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/data/models/apod.dart';
import 'package:nyxia/data/repositories/apod_service/apod_service.dart';
import 'package:nyxia/presentation/viewmodels/space_pictures_viewmodel.dart';

class FakeApodService extends ApodService {
  Apod? apod;
  Object? error;

  @override
  Future<Apod?> fetchApod({DateTime? date}) async {
    if (error != null) {
      throw error!;
    }
    return apod;
  }
}

void main() {
  group('space_pictures_viewmodel_tests', () {
    test('loadApod sets current apod when service returns data', () async {
      // this test verifies successful apod load state updates.
      final service = FakeApodService()
        ..apod = Apod(
          title: 'test',
          date: '2026-01-01',
          explanation: 'sample',
          url: 'https://example.com/a.jpg',
          mediaType: 'image',
        );
      final vm = SpacePicturesViewModel(service);

      await vm.loadApod();

      expect(vm.currentApod, isNotNull);
      expect(vm.error, isNull);
      expect(vm.isLoading, isFalse);
    });

    test('loadApod sets error when service throws', () async {
      // this test verifies apod error handling path.
      final service = FakeApodService()..error = Exception('network');
      final vm = SpacePicturesViewModel(service);

      await vm.loadApod();

      expect(vm.currentApod, isNull);
      expect(vm.error, contains('Failed to load picture'));
      expect(vm.isLoading, isFalse);
    });

    test('gotoPrevious and gotoNext move date within valid range', () async {
      // this test verifies date navigation methods update state.
      final service = FakeApodService()
        ..apod = Apod(
          title: 'test',
          date: '2026-01-01',
          explanation: 'sample',
          url: 'https://example.com/a.jpg',
          mediaType: 'image',
        );
      final vm = SpacePicturesViewModel(service);

      final before = vm.currentDate;
      await vm.gotoPrevious();
      final afterPrevious = vm.currentDate;
      await vm.gotoNext();

      expect(afterPrevious.isBefore(before), isTrue);
      expect(vm.currentDate.year, before.year);
    });
  });
}

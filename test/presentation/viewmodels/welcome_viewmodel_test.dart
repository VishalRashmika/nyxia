import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/data/repositories/apod_service/apod_service.dart';
import 'package:nyxia/presentation/viewmodels/welcome_viewmodel.dart';

class FakeApodService extends ApodService {
  String? randomImage;
  Object? error;

  @override
  Future<String?> fetchRandomApodImage() async {
    if (error != null) {
      throw error!;
    }
    return randomImage;
  }
}

void main() {
  group('welcome_viewmodel_tests', () {
    test('loadBackgroundImage sets imageLoaded with image url', () async {
      // this test verifies successful image loading updates state.
      final apod = FakeApodService()
        ..randomImage = 'https://example.com/bg.jpg';
      final viewModel = WelcomeViewModel(apod);

      await viewModel.loadBackgroundImage();

      expect(viewModel.state, WelcomeState.imageLoaded);
      expect(viewModel.backgroundImageUrl, 'https://example.com/bg.jpg');
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('loadBackgroundImage sets error when service throws', () async {
      // this test verifies error state when image loading fails.
      final apod = FakeApodService()..error = Exception('network');
      final viewModel = WelcomeViewModel(apod);

      await viewModel.loadBackgroundImage();

      expect(viewModel.state, WelcomeState.error);
      expect(viewModel.errorMessage, 'Failed to load background image');
      expect(viewModel.isLoading, isFalse);
    });
  });
}

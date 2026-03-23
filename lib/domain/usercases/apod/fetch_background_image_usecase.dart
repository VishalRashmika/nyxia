import '../../../data/repositories/apod_service/apod_service.dart';

/// use case for background images
class FetchBackgroundImageUseCase {
  final ApodService _apodService;

  FetchBackgroundImageUseCase(this._apodService);

  /// fetch image url
  Future<String?> execute({bool useRandom = true}) async {
    try {
      String? imageUrl;

      if (useRandom) {
        imageUrl = await _apodService.fetchRandomApodImage();
      } else {
        imageUrl = await _apodService.fetchApodImage();
      }

      if (imageUrl == null || imageUrl.isEmpty) {
        throw ApodException('Failed to retrieve image URL');
      }

      if (!_isValidUrl(imageUrl)) {
        throw ApodException('Invalid image URL received');
      }

      return imageUrl;
    } catch (e) {
      if (e is ApodException) {
        rethrow;
      }
      throw ApodException('Failed to load background image: ${e.toString()}');
    }
  }

  /// fetch today image
  Future<String?> fetchTodayImage() async {
    return execute(useRandom: false);
  }

  /// fetch random image
  Future<String?> fetchRandomImage() async {
    return execute(useRandom: true);
  }

  /// fetch multiple images
  Future<List<String>> fetchMultipleImages({int count = 5}) async {
    final images = <String>[];

    try {
      for (int i = 0; i < count; i++) {
        try {
          final imageUrl = await fetchRandomImage();
          if (imageUrl != null && imageUrl.isNotEmpty) {
            images.add(imageUrl);
          }
        } catch (e) {
          continue;
        }
      }

      if (images.isEmpty) {
        throw ApodException('Failed to fetch any images');
      }

      return images;
    } catch (e) {
      throw ApodException('Failed to fetch multiple images: ${e.toString()}');
    }
  }

  /// validate image url
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// fallback image url
  String getFallbackImageUrl() {
    return 'https://apod.nasa.gov/apod/image/2401/NGC1499California_Peirce_960.jpg';
  }
}

/// apod exception
class ApodException implements Exception {
  final String message;

  ApodException(this.message);

  @override
  String toString() => message;
}

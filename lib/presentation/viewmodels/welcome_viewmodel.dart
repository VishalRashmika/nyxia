import 'package:flutter/material.dart';
import '../../data/repositories/apod_service/apod_service.dart';

enum WelcomeState { initial, loadingImage, imageLoaded, error }

class WelcomeViewModel extends ChangeNotifier {
  final ApodService _apodService;

  WelcomeViewModel(this._apodService);

  // State
  WelcomeState _state = WelcomeState.initial;
  String? _backgroundImageUrl;
  String? _errorMessage;

  // Getters
  WelcomeState get state => _state;
  String? get backgroundImageUrl => _backgroundImageUrl;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == WelcomeState.loadingImage;

  /// Load background image from APOD API
  Future<void> loadBackgroundImage() async {
    _state = WelcomeState.loadingImage;
    notifyListeners();

    try {
      final imageUrl = await _apodService.fetchRandomApodImage();

      _backgroundImageUrl = imageUrl;
      _state = WelcomeState.imageLoaded;
      _errorMessage = null;
    } catch (e) {
      _state = WelcomeState.error;
      _errorMessage = 'Failed to load background image';
    }

    notifyListeners();
  }

  /// navigate to login screen
  void navigateToLogin(BuildContext context) {}

  /// navigate to signup screen
  void navigateToSignup(BuildContext context) {}
}

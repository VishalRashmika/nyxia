import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/apod_service/apod_service.dart';
import '../../data/repositories/auth_service/auth_service.dart';

enum LoginState {
  initial,
  loadingImage,
  imageLoaded,
  submitting,
  success,
  error,
}

class LoginViewModel extends ChangeNotifier {
  final ApodService _apodService;
  final AuthService _authService;

  LoginViewModel(this._apodService, this._authService);

  // State
  LoginState _state = LoginState.initial;
  String? _backgroundImageUrl;
  String? _errorMessage;
  bool _obscurePassword = true;

  // Getters
  LoginState get state => _state;
  String? get backgroundImageUrl => _backgroundImageUrl;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get isSubmitting => _state == LoginState.submitting;
  bool get isLoadingImage => _state == LoginState.loadingImage;

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Load background image
  Future<void> loadBackgroundImage() async {
    _state = LoginState.loadingImage;
    notifyListeners();

    try {
      final imageUrl = await _apodService.fetchRandomApodImage();
      _backgroundImageUrl = imageUrl;
      _state = LoginState.imageLoaded;
    } catch (e) {
      _state = LoginState.error;
      _errorMessage = 'Failed to load background';
    }

    notifyListeners();
  }

  /// Login with email and password
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _state = LoginState.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (result != null) {
        _state = LoginState.success;
        notifyListeners();
        return true;
      } else {
        _state = LoginState.error;
        _errorMessage = 'Login failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = LoginState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Login with Google
  Future<bool> loginWithGoogle() async {
    _state = LoginState.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
      _state = LoginState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = LoginState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

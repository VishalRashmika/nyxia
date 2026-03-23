import 'package:flutter/material.dart';
import '../../data/repositories/apod_service/apod_service.dart';
import '../../data/repositories/auth_service/auth_service.dart';

enum SignUpState {
  initial,
  loadingImage,
  imageLoaded,
  submitting,
  success,
  error,
}

class SignUpViewModel extends ChangeNotifier {
  final ApodService _apodService;
  final AuthService _authService;

  SignUpViewModel(this._apodService, this._authService);

  // State
  SignUpState _state = SignUpState.initial;
  String? _backgroundImageUrl;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Getters
  SignUpState get state => _state;
  String? get backgroundImageUrl => _backgroundImageUrl;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isSubmitting => _state == SignUpState.submitting;

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  /// Load background image
  Future<void> loadBackgroundImage() async {
    _state = SignUpState.loadingImage;
    notifyListeners();

    try {
      final imageUrl = await _apodService.fetchRandomApodImage();
      _backgroundImageUrl = imageUrl;
      _state = SignUpState.imageLoaded;
    } catch (e) {
      _state = SignUpState.error;
      _errorMessage = 'Failed to load background';
    }

    notifyListeners();
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _state = SignUpState.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      _state = SignUpState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = SignUpState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Sign up with Google
  Future<bool> signUpWithGoogle() async {
    _state = SignUpState.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
      _state = SignUpState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = SignUpState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Validation methods
  String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your first name';
    }
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your last name';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}

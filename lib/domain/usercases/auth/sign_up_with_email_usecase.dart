import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/auth_service/auth_service.dart';

/// use case for email sign up
class SignUpWithEmailUseCase {
  final AuthService _authService;

  SignUpWithEmailUseCase(this._authService);

  /// execute sign up
  Future<UserCredential?> execute({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    // validate inputs
    _validateInputs(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    try {
      // call auth service
      final result = await _authService.signUpWithEmail(
        email: email.trim(),
        password: password,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
      );

      return result;
    } on FirebaseAuthException catch (e) {
      // map firebase error
      throw AuthException(_handleFirebaseAuthException(e));
    } catch (e) {
      // handle unknown errors
      throw AuthException('Failed to create account: ${e.toString()}');
    }
  }

  /// validate required inputs
  void _validateInputs({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    if (firstName.trim().isEmpty) {
      throw AuthException('First name is required');
    }

    if (lastName.trim().isEmpty) {
      throw AuthException('Last name is required');
    }

    if (email.trim().isEmpty) {
      throw AuthException('Email is required');
    }

    if (!_isValidEmail(email)) {
      throw AuthException('Please enter a valid email address');
    }

    if (password.isEmpty) {
      throw AuthException('Password is required');
    }

    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }

    if (!_isStrongPassword(password)) {
      throw AuthException(
        'Password must contain at least one letter and one number',
      );
    }
  }

  /// validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// check password strength
  bool _isStrongPassword(String password) {
    // require letter and number
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    return hasLetter && hasNumber;
  }

  /// map firebase auth errors
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password';
      default:
        return 'Sign up failed: ${e.message ?? e.code}';
    }
  }
}

/// auth exception
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/auth_service/auth_service.dart';

/// use case for email sign in
class SignInWithEmailUseCase {
  final AuthService _authService;

  SignInWithEmailUseCase(this._authService);

  /// execute sign in
  Future<UserCredential?> execute({
    required String email,
    required String password,
  }) async {
    // validate inputs
    if (email.isEmpty) {
      throw AuthException('Email cannot be empty');
    }

    if (password.isEmpty) {
      throw AuthException('Password cannot be empty');
    }

    if (!_isValidEmail(email)) {
      throw AuthException('Please enter a valid email address');
    }

    try {
      // call auth service
      final result = await _authService.signInWithEmail(
        email: email.trim(),
        password: password,
      );

      return result;
    } on FirebaseAuthException catch (e) {
      // map firebase error
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      // handle unknown errors
      throw AuthException('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegex.hasMatch(email);
  }

  /// map firebase auth errors
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      default:
        return 'Sign in failed: ${e.message ?? e.code}';
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

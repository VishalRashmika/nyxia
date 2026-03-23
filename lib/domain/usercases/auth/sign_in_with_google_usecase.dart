import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/auth_service/auth_service.dart';

/// use case for google sign in
class SignInWithGoogleUseCase {
  final AuthService _authService;

  SignInWithGoogleUseCase(this._authService);

  /// execute google sign in
  Future<UserCredential?> execute() async {
    try {
      // call auth service
      final result = await _authService.signInWithGoogle();

      // handle canceled sign-in
      if (result == null) {
        throw AuthException('Google sign-in was cancelled');
      }

      return result;
    } on FirebaseAuthException catch (e) {
      // map firebase error
      throw AuthException(_handleFirebaseAuthException(e));
    } catch (e) {
      // handle google sign-in errors
      final errorMessage = e.toString();

      if (errorMessage.contains('DEVELOPER_ERROR') ||
          errorMessage.contains('10:')) {
        throw AuthException(
          'Google Sign-In is not configured properly. '
          'Please contact support.',
        );
      }

      if (errorMessage.contains('canceled') ||
          errorMessage.contains('cancelled')) {
        throw AuthException('Google sign-in was cancelled');
      }

      if (errorMessage.contains('network')) {
        throw AuthException(
          'Network error. Please check your internet connection.',
        );
      }

      throw AuthException('Google sign-in failed. Please try again.');
    }
  }

  /// map firebase auth errors
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email '
            'but different sign-in credentials';
      case 'invalid-credential':
        return 'The credential is malformed or has expired';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this credential';
      case 'wrong-password':
        return 'Invalid password';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification ID';
      default:
        return 'Google sign-in failed: ${e.message ?? e.code}';
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

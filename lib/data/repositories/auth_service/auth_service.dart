import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // current user
  User? get currentUser => _auth.currentUser;

  // auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // sign up with email and password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // set display name
      await userCredential.user?.updateDisplayName('$firstName $lastName');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // sign in with email and password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // sign in with google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // start google auth flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // user canceled sign-in
        throw 'Google sign-in was canceled';
      }

      // read auth tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // build firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // sign in to firebase
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // clear google session on auth failure
      await _googleSignIn.signOut();
      throw _handleAuthException(e);
    } catch (e) {
      // clear google session on failure
      await _googleSignIn.signOut();

      if (e.toString().contains('DEVELOPER_ERROR') ||
          e.toString().contains('10:')) {
        throw 'Google Sign-In is not configured properly. Please check Firebase Console SHA-1 fingerprint.';
      }

      if (e.toString().contains('canceled')) {
        throw e.toString();
      }

      throw 'Failed to sign in with Google: ${e.toString()}';
    }
  }

  // sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  // send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: 'example@gmail.com');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send reset email. Please try again.';
    }
  }

  // map firebase auth errors
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

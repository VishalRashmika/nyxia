import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/data/repositories/apod_service/apod_service.dart';
import 'package:nyxia/data/repositories/auth_service/auth_service.dart';
import 'package:nyxia/presentation/viewmodels/login_viewmodel.dart';

class FakeUserCredential implements UserCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

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

class FakeAuthService extends AuthService {
  UserCredential? emailResult;
  Object? emailError;
  Object? googleError;

  @override
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (emailError != null) {
      throw emailError!;
    }
    return emailResult;
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    if (googleError != null) {
      throw googleError!;
    }
    return FakeUserCredential();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // initialize firebase for auth service test doubles
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  group('login_viewmodel_tests', () {
    test('togglePasswordVisibility flips visibility state', () {
      // this test verifies password visibility toggle behavior.
      final vm = LoginViewModel(FakeApodService(), FakeAuthService());

      vm.togglePasswordVisibility();

      expect(vm.obscurePassword, isFalse);
    });

    test('loadBackgroundImage sets imageLoaded when success', () async {
      // this test verifies successful background image loading.
      final apod = FakeApodService()..randomImage = 'https://example.com/a.jpg';
      final vm = LoginViewModel(apod, FakeAuthService());

      await vm.loadBackgroundImage();

      expect(vm.state, LoginState.imageLoaded);
      expect(vm.backgroundImageUrl, 'https://example.com/a.jpg');
      expect(vm.errorMessage, isNull);
    });

    test('loadBackgroundImage sets error when failure occurs', () async {
      // this test verifies background image failure handling.
      final apod = FakeApodService()..error = Exception('fail');
      final vm = LoginViewModel(apod, FakeAuthService());

      await vm.loadBackgroundImage();

      expect(vm.state, LoginState.error);
      expect(vm.errorMessage, 'Failed to load background');
    });

    test('loginWithEmail returns true on non-null credential', () async {
      // this test verifies email login success flow.
      final auth = FakeAuthService()..emailResult = FakeUserCredential();
      final vm = LoginViewModel(FakeApodService(), auth);

      final result = await vm.loginWithEmail(
        email: 'a@b.com',
        password: 'secret123',
      );

      expect(result, isTrue);
      expect(vm.state, LoginState.success);
      expect(vm.errorMessage, isNull);
    });

    test('loginWithEmail returns false when credential is null', () async {
      // this test verifies email login null result handling.
      final auth = FakeAuthService()..emailResult = null;
      final vm = LoginViewModel(FakeApodService(), auth);

      final result = await vm.loginWithEmail(
        email: 'a@b.com',
        password: 'secret123',
      );

      expect(result, isFalse);
      expect(vm.state, LoginState.error);
      expect(vm.errorMessage, 'Login failed');
    });

    test('loginWithEmail returns false when service throws', () async {
      // this test verifies email login exception handling.
      final auth = FakeAuthService()..emailError = Exception('bad auth');
      final vm = LoginViewModel(FakeApodService(), auth);

      final result = await vm.loginWithEmail(
        email: 'a@b.com',
        password: 'secret123',
      );

      expect(result, isFalse);
      expect(vm.state, LoginState.error);
      expect(vm.errorMessage, contains('Exception: bad auth'));
    });

    test('loginWithGoogle returns true when sign-in succeeds', () async {
      // this test verifies google login success flow.
      final vm = LoginViewModel(FakeApodService(), FakeAuthService());

      final result = await vm.loginWithGoogle();

      expect(result, isTrue);
      expect(vm.state, LoginState.success);
      expect(vm.errorMessage, isNull);
    });

    test('loginWithGoogle returns false when sign-in fails', () async {
      // this test verifies google login exception handling.
      final auth = FakeAuthService()..googleError = Exception('google fail');
      final vm = LoginViewModel(FakeApodService(), auth);

      final result = await vm.loginWithGoogle();

      expect(result, isFalse);
      expect(vm.state, LoginState.error);
      expect(vm.errorMessage, contains('Exception: google fail'));
    });

    test('validateEmail and validatePassword enforce basic rules', () {
      // this test verifies form validators for login.
      final vm = LoginViewModel(FakeApodService(), FakeAuthService());

      expect(vm.validateEmail(''), 'Please enter your email');
      expect(vm.validateEmail('invalid'), 'Please enter a valid email');
      expect(vm.validateEmail('user@example.com'), isNull);

      expect(vm.validatePassword(''), 'Please enter your password');
      expect(
        vm.validatePassword('12345'),
        'Password must be at least 6 characters',
      );
      expect(vm.validatePassword('123456'), isNull);
    });
  });
}

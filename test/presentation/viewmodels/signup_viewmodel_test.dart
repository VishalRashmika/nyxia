import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/data/repositories/apod_service/apod_service.dart';
import 'package:nyxia/data/repositories/auth_service/auth_service.dart';
import 'package:nyxia/presentation/viewmodels/signup_viewmodel.dart';

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
  Object? signUpError;
  Object? googleError;

  @override
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    if (signUpError != null) {
      throw signUpError!;
    }
    return FakeUserCredential();
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

  group('signup_viewmodel_tests', () {
    test('password visibility toggles for both fields', () {
      // this test verifies password and confirm visibility toggles.
      final vm = SignUpViewModel(FakeApodService(), FakeAuthService());

      vm.togglePasswordVisibility();
      vm.toggleConfirmPasswordVisibility();

      expect(vm.obscurePassword, isFalse);
      expect(vm.obscureConfirmPassword, isFalse);
    });

    test('loadBackgroundImage sets imageLoaded on success', () async {
      // this test verifies signup background loading success.
      final apod = FakeApodService()
        ..randomImage = 'https://example.com/bg.jpg';
      final vm = SignUpViewModel(apod, FakeAuthService());

      await vm.loadBackgroundImage();

      expect(vm.state, SignUpState.imageLoaded);
      expect(vm.backgroundImageUrl, 'https://example.com/bg.jpg');
      expect(vm.errorMessage, isNull);
    });

    test('loadBackgroundImage sets error on failure', () async {
      // this test verifies signup background loading failure.
      final apod = FakeApodService()..error = Exception('network');
      final vm = SignUpViewModel(apod, FakeAuthService());

      await vm.loadBackgroundImage();

      expect(vm.state, SignUpState.error);
      expect(vm.errorMessage, 'Failed to load background');
    });

    test('signUpWithEmail returns true when service succeeds', () async {
      // this test verifies signup success flow.
      final vm = SignUpViewModel(FakeApodService(), FakeAuthService());

      final result = await vm.signUpWithEmail(
        email: 'user@example.com',
        password: 'secret123',
        firstName: 'Jane',
        lastName: 'Doe',
      );

      expect(result, isTrue);
      expect(vm.state, SignUpState.success);
      expect(vm.errorMessage, isNull);
    });

    test('signUpWithEmail returns false when service throws', () async {
      // this test verifies signup failure flow.
      final auth = FakeAuthService()..signUpError = Exception('signup fail');
      final vm = SignUpViewModel(FakeApodService(), auth);

      final result = await vm.signUpWithEmail(
        email: 'user@example.com',
        password: 'secret123',
        firstName: 'Jane',
        lastName: 'Doe',
      );

      expect(result, isFalse);
      expect(vm.state, SignUpState.error);
      expect(vm.errorMessage, contains('Exception: signup fail'));
    });

    test('signUpWithGoogle returns false when service throws', () async {
      // this test verifies google signup failure flow.
      final auth = FakeAuthService()..googleError = Exception('google fail');
      final vm = SignUpViewModel(FakeApodService(), auth);

      final result = await vm.signUpWithGoogle();

      expect(result, isFalse);
      expect(vm.state, SignUpState.error);
      expect(vm.errorMessage, contains('Exception: google fail'));
    });

    test('validation methods return expected messages', () {
      // this test verifies signup validators.
      final vm = SignUpViewModel(FakeApodService(), FakeAuthService());

      expect(vm.validateFirstName(''), 'Please enter your first name');
      expect(vm.validateLastName(''), 'Please enter your last name');
      expect(vm.validateEmail('invalid'), 'Please enter a valid email');
      expect(
        vm.validatePassword('12345'),
        'Password must be at least 6 characters',
      );
      expect(
        vm.validateConfirmPassword('abc123', 'abc124'),
        'Passwords do not match',
      );

      expect(vm.validateFirstName('Jane'), isNull);
      expect(vm.validateLastName('Doe'), isNull);
      expect(vm.validateEmail('jane@doe.com'), isNull);
      expect(vm.validatePassword('123456'), isNull);
      expect(vm.validateConfirmPassword('abc123', 'abc123'), isNull);
    });
  });
}

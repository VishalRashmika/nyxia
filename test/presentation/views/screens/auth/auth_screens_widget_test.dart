import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nyxia/data/repositories/apod_service/apod_service.dart';
import 'package:nyxia/data/repositories/auth_service/auth_service.dart';
import 'package:nyxia/presentation/viewmodels/login_viewmodel.dart';
import 'package:nyxia/presentation/viewmodels/signup_viewmodel.dart';
import 'package:nyxia/presentation/views/screens/auth/login_screen.dart';
import 'package:nyxia/presentation/views/screens/auth/signup_screen.dart';

class _FakeApodService extends ApodService {}

class _FakeAuthService extends AuthService {
  @override
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return null;
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    return null;
  }

  @override
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    return null;
  }
}

class _FakeLoginViewModel extends LoginViewModel {
  _FakeLoginViewModel() : super(_FakeApodService(), _FakeAuthService());

  bool loginResult = false;
  bool googleResult = false;
  String? loginError = 'login failed';
  bool _isObscure = true;

  @override
  bool get obscurePassword => _isObscure;

  @override
  bool get isSubmitting => false;

  @override
  String? get errorMessage => loginError;

  @override
  Future<void> loadBackgroundImage() async {}

  @override
  void togglePasswordVisibility() {
    _isObscure = !_isObscure;
    notifyListeners();
  }

  @override
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return loginResult;
  }

  @override
  Future<bool> loginWithGoogle() async {
    return googleResult;
  }
}

class _FakeSignUpViewModel extends SignUpViewModel {
  _FakeSignUpViewModel() : super(_FakeApodService(), _FakeAuthService());

  bool signUpResult = false;
  bool googleResult = false;
  String? signUpError = 'signup failed';
  bool _isObscure = true;
  bool _isConfirmObscure = true;

  @override
  bool get obscurePassword => _isObscure;

  @override
  bool get obscureConfirmPassword => _isConfirmObscure;

  @override
  bool get isSubmitting => false;

  @override
  String? get errorMessage => signUpError;

  @override
  Future<void> loadBackgroundImage() async {}

  @override
  void togglePasswordVisibility() {
    _isObscure = !_isObscure;
    notifyListeners();
  }

  @override
  void toggleConfirmPasswordVisibility() {
    _isConfirmObscure = !_isConfirmObscure;
    notifyListeners();
  }

  @override
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    return signUpResult;
  }

  @override
  Future<bool> signUpWithGoogle() async {
    return googleResult;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // this setup initializes firebase for auth service test doubles.
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  group('auth_screens_widget_tests', () {
    testWidgets('login screen renders core controls', (tester) async {
      // this test verifies login screen baseline ui elements.
      await tester.binding.setSurfaceSize(const Size(1080, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final vm = _FakeLoginViewModel();

      await tester.pumpWidget(
        ChangeNotifierProvider<LoginViewModel>.value(
          value: vm,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('LOGIN'), findsWidgets);
      expect(find.text('Continue With Google'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('login form validation shows errors when empty', (
      tester,
    ) async {
      // this test verifies empty login form validation messages.
      await tester.binding.setSurfaceSize(const Size(1080, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final vm = _FakeLoginViewModel();

      await tester.pumpWidget(
        ChangeNotifierProvider<LoginViewModel>.value(
          value: vm,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('login password visibility toggle updates icon', (
      tester,
    ) async {
      // this test verifies login password visibility toggle behavior.
      await tester.binding.setSurfaceSize(const Size(1080, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final vm = _FakeLoginViewModel();

      await tester.pumpWidget(
        ChangeNotifierProvider<LoginViewModel>.value(
          value: vm,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('login google failure shows snackbar', (tester) async {
      // this test verifies login google failure feedback.
      await tester.binding.setSurfaceSize(const Size(1080, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final vm = _FakeLoginViewModel()
        ..googleResult = false
        ..loginError = 'google failed';

      await tester.pumpWidget(
        ChangeNotifierProvider<LoginViewModel>.value(
          value: vm,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Continue With Google'));
      await tester.pumpAndSettle();

      expect(find.text('google failed'), findsOneWidget);
    });

    testWidgets('signup screen renders core controls', (tester) async {
      // this test verifies signup screen baseline ui elements.
      await tester.binding.setSurfaceSize(const Size(1080, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final vm = _FakeSignUpViewModel();

      await tester.pumpWidget(
        ChangeNotifierProvider<SignUpViewModel>.value(
          value: vm,
          child: const MaterialApp(home: SignUpScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('SIGN UP'), findsWidgets);
      expect(find.text('Continue With Google'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(5));
    });

    testWidgets('signup form shows password mismatch error', (tester) async {
      // this test verifies signup confirm password mismatch validation.
      await tester.binding.setSurfaceSize(const Size(1080, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final vm = _FakeSignUpViewModel();

      await tester.pumpWidget(
        ChangeNotifierProvider<SignUpViewModel>.value(
          value: vm,
          child: const MaterialApp(home: SignUpScreen()),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(0), 'Jane');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'jane@doe.com');
      await tester.enterText(find.byType(TextFormField).at(3), 'abc123');
      await tester.enterText(find.byType(TextFormField).at(4), 'abc124');

      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'SIGN UP'),
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'SIGN UP'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('signup visibility toggles update both password icons', (
      tester,
    ) async {
      // this test verifies signup password visibility toggles.
      await tester.binding.setSurfaceSize(const Size(1080, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final vm = _FakeSignUpViewModel();

      await tester.pumpWidget(
        ChangeNotifierProvider<SignUpViewModel>.value(
          value: vm,
          child: const MaterialApp(home: SignUpScreen()),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsNWidgets(2));
    });
  });
}

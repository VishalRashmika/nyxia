import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/domain/usercases/auth/validate_auth_form_usecase.dart';

void main() {
  group('validate_auth_form_usecase_tests', () {
    final useCase = ValidateAuthFormUseCase();

    test('validateEmail returns required error for empty value', () {
      // this test verifies empty emails are rejected.
      final result = useCase.validateEmail('   ');

      expect(result, 'Email is required');
    });

    test('validateEmail rejects malformed email text', () {
      // this test verifies malformed email format returns an error.
      final result = useCase.validateEmail('invalid-email');

      expect(result, 'Please enter a valid email address');
    });

    test('validateEmail rejects consecutive periods', () {
      // this test verifies emails with double periods fail validation.
      final result = useCase.validateEmail('astro..user@example.com');

      expect(result, 'Email cannot contain consecutive periods');
    });

    test('validateEmail accepts valid trimmed address', () {
      // this test verifies a valid email passes validation.
      final result = useCase.validateEmail('  astro.user@example.com  ');

      expect(result, isNull);
    });

    test('validatePassword rejects short password', () {
      // this test verifies short passwords are rejected.
      final result = useCase.validatePassword('12345');

      expect(result, 'Password must be at least 6 characters');
    });

    test('validatePassword signUp requires at least eight chars', () {
      // this test verifies signup password length hardening.
      final result = useCase.validatePassword('a1bcde7', isSignUp: true);

      expect(
        result,
        'Password should be at least 8 characters for better security',
      );
    });

    test('validatePassword signUp requires a number', () {
      // this test verifies signup password requires a number.
      final result = useCase.validatePassword('abcdefgh', isSignUp: true);

      expect(result, 'Password must contain at least one number');
    });

    test('validatePassword signUp accepts strong password', () {
      // this test verifies strong signup password passes validation.
      final result = useCase.validatePassword('Astro1234', isSignUp: true);

      expect(result, isNull);
    });

    test('validatePasswordConfirmation rejects mismatch', () {
      // this test verifies confirm password mismatch returns error.
      final result = useCase.validatePasswordConfirmation(
        'Astro1234',
        'Astro123',
      );

      expect(result, 'Passwords do not match');
    });

    test('validateLoginForm returns both field errors when invalid', () {
      // this test verifies login form aggregates field validation errors.
      final errors = useCase.validateLoginForm(email: 'bad', password: '1');

      expect(errors.containsKey('email'), isTrue);
      expect(errors.containsKey('password'), isTrue);
    });

    test('validateSignUpForm returns empty errors for valid input', () {
      // this test verifies signup form passes with valid values.
      final errors = useCase.validateSignUpForm(
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane.doe@example.com',
        password: 'Astro1234',
        confirmPassword: 'Astro1234',
      );

      expect(errors, isEmpty);
    });

    test('isFormValid reflects if error map is empty', () {
      // this test verifies form validity uses error map emptiness.
      final valid = useCase.isFormValid({});
      final invalid = useCase.isFormValid({'email': 'error'});

      expect(valid, isTrue);
      expect(invalid, isFalse);
    });
  });
}

class ValidateAuthFormUseCase {
  /// validate email
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();

    // basic email check
    if (!email.contains('@')) {
      return 'Please enter a valid email address';
    }

    // regex email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    // common format checks
    if (email.endsWith('.')) {
      return 'Email cannot end with a period';
    }

    if (email.startsWith('.')) {
      return 'Email cannot start with a period';
    }

    if (email.contains('..')) {
      return 'Email cannot contain consecutive periods';
    }

    return null;
  }

  /// validate password
  String? validatePassword(String? value, {bool isSignUp = false}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // sign-up rules
    if (isSignUp) {
      if (value.length < 8) {
        return 'Password should be at least 8 characters for better security';
      }

      // require one letter
      if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
        return 'Password must contain at least one letter';
      }

      // require one number
      if (!RegExp(r'[0-9]').hasMatch(value)) {
        return 'Password must contain at least one number';
      }
    }

    return null;
  }

  /// validate confirm password
  String? validatePasswordConfirmation(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// validate first name
  String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }

    final name = value.trim();

    if (name.length < 2) {
      return 'First name must be at least 2 characters';
    }

    if (name.length > 50) {
      return 'First name is too long';
    }

    // allow letters and separators
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(name)) {
      return 'First name can only contain letters';
    }

    return null;
  }

  /// validate last name
  String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }

    final name = value.trim();

    if (name.length < 2) {
      return 'Last name must be at least 2 characters';
    }

    if (name.length > 50) {
      return 'Last name is too long';
    }

    // allow letters and separators
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(name)) {
      return 'Last name can only contain letters';
    }

    return null;
  }

  /// validate login form
  Map<String, String> validateLoginForm({
    required String email,
    required String password,
  }) {
    final errors = <String, String>{};

    final emailError = validateEmail(email);
    if (emailError != null) {
      errors['email'] = emailError;
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      errors['password'] = passwordError;
    }

    return errors;
  }

  /// validate sign-up form
  Map<String, String> validateSignUpForm({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    final errors = <String, String>{};

    final firstNameError = validateFirstName(firstName);
    if (firstNameError != null) {
      errors['firstName'] = firstNameError;
    }

    final lastNameError = validateLastName(lastName);
    if (lastNameError != null) {
      errors['lastName'] = lastNameError;
    }

    final emailError = validateEmail(email);
    if (emailError != null) {
      errors['email'] = emailError;
    }

    final passwordError = validatePassword(password, isSignUp: true);
    if (passwordError != null) {
      errors['password'] = passwordError;
    }

    final confirmPasswordError = validatePasswordConfirmation(
      password,
      confirmPassword,
    );
    if (confirmPasswordError != null) {
      errors['confirmPassword'] = confirmPasswordError;
    }

    return errors;
  }

  /// check form validity
  bool isFormValid(Map<String, String> errors) {
    return errors.isEmpty;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/signup_viewmodel.dart';
import '../../widgets/bg_image_container.dart';
import 'login_screen.dart';
import '../home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Form key and controllers remain in the View (UI-specific)
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load background image using ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SignUpViewModel>().loadBackgroundImage();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handle sign-up button press
  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<SignUpViewModel>();

      final success = await viewModel.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (success && mounted) {
        _showSuccessMessage('Account created successfully!');
        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (mounted && viewModel.errorMessage != null) {
        _showErrorMessage(viewModel.errorMessage!);
      }
    }
  }

  /// Handle Google Sign-In button press
  Future<void> _handleGoogleSignIn() async {
    final viewModel = context.read<SignUpViewModel>();

    final success = await viewModel.signUpWithGoogle();

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (mounted && viewModel.errorMessage != null) {
      _showErrorMessage(viewModel.errorMessage!);
    }
  }

  /// Show error message via SnackBar
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success message via SnackBar
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final viewportHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<SignUpViewModel>(
        builder: (context, viewModel, child) {
          return MediaQuery.removeViewInsets(
            context: context,
            removeBottom: true,
            child: BackgroundImageContainer(
              imageUrl: viewModel.backgroundImageUrl,
              isLoading: viewModel.state == SignUpState.loadingImage,
              child: SafeArea(
                child: Stack(
                  children: [
                    _buildLogo(theme),
                    _buildFormSection(
                      theme,
                      isDarkMode,
                      viewModel,
                      keyboardInset,
                      viewportHeight,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build logo section at top
  Widget _buildLogo(ThemeData theme) {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          'assets/logos/round-logo.png',
          width: 80,
          height: 80,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  /// Build form section with all input fields
  Widget _buildFormSection(
    ThemeData theme,
    bool isDarkMode,
    SignUpViewModel viewModel,
    double keyboardInset,
    double viewportHeight,
  ) {
    final sheetHeight = keyboardInset > 0
        ? viewportHeight * 0.85
        : viewportHeight * 0.68;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: isDarkMode ? theme.scaffoldBackgroundColor : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    32.0,
                    20.0,
                    32.0,
                    16.0 + keyboardInset,
                  ),
                  child: Column(
                    children: [
                      // Sign up heading
                      Text(
                        'SIGN UP',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // First Name field
                      _buildFirstNameField(theme, isDarkMode, viewModel),

                      const SizedBox(height: 10),

                      // Last Name field
                      _buildLastNameField(theme, isDarkMode, viewModel),

                      const SizedBox(height: 10),

                      // Email field
                      _buildEmailField(theme, isDarkMode, viewModel),

                      const SizedBox(height: 10),

                      // Password field
                      _buildPasswordField(theme, isDarkMode, viewModel),

                      const SizedBox(height: 10),

                      // Confirm Password field
                      _buildConfirmPasswordField(theme, isDarkMode, viewModel),

                      const SizedBox(height: 20),

                      // Sign up button
                      _buildSignUpButton(theme, viewModel),

                      const SizedBox(height: 12),

                      // Google Sign-In button
                      _buildGoogleSignInButton(theme, viewModel),

                      const SizedBox(height: 12),

                      // Login link
                      _buildLoginLink(theme, viewModel),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build first name input field
  Widget _buildFirstNameField(
    ThemeData theme,
    bool isDarkMode,
    SignUpViewModel viewModel,
  ) {
    return TextFormField(
      controller: _firstNameController,
      enabled: !viewModel.isSubmitting,
      decoration: InputDecoration(
        hintText: 'First Name',
        filled: true,
        fillColor: isDarkMode ? theme.colorScheme.surface : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
      ),
      validator: viewModel.validateFirstName,
    );
  }

  /// Build last name input field
  Widget _buildLastNameField(
    ThemeData theme,
    bool isDarkMode,
    SignUpViewModel viewModel,
  ) {
    return TextFormField(
      controller: _lastNameController,
      enabled: !viewModel.isSubmitting,
      decoration: InputDecoration(
        hintText: 'Last Name',
        filled: true,
        fillColor: isDarkMode ? theme.colorScheme.surface : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
      ),
      validator: viewModel.validateLastName,
    );
  }

  /// Build email input field
  Widget _buildEmailField(
    ThemeData theme,
    bool isDarkMode,
    SignUpViewModel viewModel,
  ) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      enabled: !viewModel.isSubmitting,
      decoration: InputDecoration(
        hintText: 'Email',
        filled: true,
        fillColor: isDarkMode ? theme.colorScheme.surface : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
      ),
      validator: viewModel.validateEmail,
    );
  }

  /// Build password input field
  Widget _buildPasswordField(
    ThemeData theme,
    bool isDarkMode,
    SignUpViewModel viewModel,
  ) {
    return Consumer<SignUpViewModel>(
      builder: (context, vm, child) {
        return TextFormField(
          controller: _passwordController,
          obscureText: vm.obscurePassword,
          enabled: !vm.isSubmitting,
          decoration: InputDecoration(
            hintText: 'Password',
            filled: true,
            fillColor: isDarkMode
                ? theme.colorScheme.surface
                : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                vm.obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: vm.togglePasswordVisibility,
            ),
          ),
          validator: viewModel.validatePassword,
        );
      },
    );
  }

  /// Build confirm password input field
  Widget _buildConfirmPasswordField(
    ThemeData theme,
    bool isDarkMode,
    SignUpViewModel viewModel,
  ) {
    return Consumer<SignUpViewModel>(
      builder: (context, vm, child) {
        return TextFormField(
          controller: _confirmPasswordController,
          obscureText: vm.obscureConfirmPassword,
          enabled: !vm.isSubmitting,
          decoration: InputDecoration(
            hintText: 'Confirm Password',
            filled: true,
            fillColor: isDarkMode
                ? theme.colorScheme.surface
                : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                vm.obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: vm.toggleConfirmPasswordVisibility,
            ),
          ),
          validator: (value) => viewModel.validateConfirmPassword(
            _passwordController.text,
            value,
          ),
        );
      },
    );
  }

  /// Build sign-up button
  Widget _buildSignUpButton(ThemeData theme, SignUpViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: viewModel.isSubmitting ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.6),
        ),
        child: viewModel.isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'SIGN UP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }

  /// Build Google Sign-In button
  Widget _buildGoogleSignInButton(ThemeData theme, SignUpViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: viewModel.isSubmitting ? null : _handleGoogleSignIn,
        icon: Icon(
          Icons.g_mobiledata,
          size: 24,
          color: viewModel.isSubmitting
              ? Colors.grey
              : theme.colorScheme.primary,
        ),
        label: Text(
          'Continue With Google',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: viewModel.isSubmitting
                ? Colors.grey
                : theme.colorScheme.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(
            color: viewModel.isSubmitting
                ? Colors.grey
                : theme.colorScheme.primary,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }

  /// Build login link
  Widget _buildLoginLink(ThemeData theme, SignUpViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.isSubmitting
          ? null
          : () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
      child: RichText(
        text: TextSpan(
          text: "Already have an account? ",
          style: theme.textTheme.bodyMedium,
          children: [
            TextSpan(
              text: 'Log In',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/ui_constants.dart';
import '../../../viewmodels/login_viewmodel.dart';
import '../../widgets/bg_image_container.dart';
import 'signup_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form key and controllers remain in the View (UI-specific)
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load background image using ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginViewModel>().loadBackgroundImage();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login button press
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<LoginViewModel>();

      final success = await viewModel.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
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
    final viewModel = context.read<LoginViewModel>();

    final success = await viewModel.loginWithGoogle();

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return BackgroundImageContainer(
            imageUrl: viewModel.backgroundImageUrl,
            isLoading: viewModel.isLoadingImage,
            child: SafeArea(
              child: Column(
                children: [
                  _buildLogo(theme),
                  const Spacer(),
                  _buildFormSection(theme, isDarkMode, viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build logo section
  Widget _buildLogo(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Center(
        child: Image.asset(
          'assets/logos/round-logo.png',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  /// Build form section with input fields and buttons
  Widget _buildFormSection(
    ThemeData theme,
    bool isDarkMode,
    LoginViewModel viewModel,
  ) {
    return Container(
      width: double.infinity,
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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Login heading
                Text(
                  'LOGIN',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 40),

                // Email field
                _buildEmailField(theme, isDarkMode, viewModel),

                const SizedBox(height: 16),

                // Password field
                _buildPasswordField(theme, isDarkMode, viewModel),

                const SizedBox(height: 32),

                // Login button
                _buildLoginButton(theme, viewModel),

                const SizedBox(height: 24),

                // Google Sign-In button
                _buildGoogleSignInButton(theme, viewModel),

                const SizedBox(height: 24),

                // Sign up link
                _buildSignUpLink(theme, viewModel),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build email input field
  Widget _buildEmailField(
    ThemeData theme,
    bool isDarkMode,
    LoginViewModel viewModel,
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
          vertical: 18,
        ),
      ),
      validator: viewModel.validateEmail,
    );
  }

  /// Build password input field
  Widget _buildPasswordField(
    ThemeData theme,
    bool isDarkMode,
    LoginViewModel viewModel,
  ) {
    return Consumer<LoginViewModel>(
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
              vertical: 18,
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

  /// Build login button
  Widget _buildLoginButton(ThemeData theme, LoginViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: viewModel.isSubmitting ? null : _handleLogin,
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
                'LOGIN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }

  /// Build Google Sign-In button
  Widget _buildGoogleSignInButton(ThemeData theme, LoginViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: viewModel.isSubmitting ? null : _handleGoogleSignIn,
        icon: Icon(
          Icons.g_mobiledata,
          size: 28,
          color: viewModel.isSubmitting
              ? Colors.grey
              : theme.colorScheme.primary,
        ),
        label: Text(
          'Continue With Google',
          style: TextStyle(
            fontSize: 16,
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

  /// Build sign-up link
  Widget _buildSignUpLink(ThemeData theme, LoginViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.isSubmitting
          ? null
          : () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              );
            },
      child: RichText(
        text: TextSpan(
          text: "Don't have any account? ",
          style: theme.textTheme.bodyMedium,
          children: [
            TextSpan(
              text: 'Sign Up',
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

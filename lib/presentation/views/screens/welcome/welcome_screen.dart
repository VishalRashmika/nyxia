import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/ui_constants.dart';
import '../../../viewmodels/welcome_viewmodel.dart';
import '../../widgets/bg_image_container.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load background image using ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WelcomeViewModel>().loadBackgroundImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<WelcomeViewModel>(
        builder: (context, viewModel, child) {
          return BackgroundImageContainer(
            imageUrl: viewModel.backgroundImageUrl,
            isLoading: viewModel.isLoading,
            child: SafeArea(
              child: Column(
                children: [
                  _buildLogo(theme),
                  const Spacer(),
                  _buildBottomSection(theme, isDarkMode),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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

  Widget _buildBottomSection(ThemeData theme, bool isDarkMode) {
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'WELCOME',
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Discover and capture the wonders of the night sky.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 40),
            _buildLoginButton(theme),
            const SizedBox(height: 16),
            _buildSignUpButton(theme, isDarkMode),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Text(
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

  Widget _buildSignUpButton(ThemeData theme, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignUpScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode
              ? theme.colorScheme.surface
              : theme.colorScheme.primary.withOpacity(0.1),
          foregroundColor: theme.colorScheme.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
        ),
        child: Text(
          'SIGN UP',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

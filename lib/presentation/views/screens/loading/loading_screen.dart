import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/ui_constants.dart';
import '../../../viewmodels/loading_viewmodel.dart';
import '../../../viewmodels/tabs/home_tab_viewmodel.dart';
import '../../../viewmodels/tabs/plan_tab_viewmodel.dart';
import '../../../viewmodels/tabs/track_tab_viewmodel.dart';
import '../home/home_screen.dart';
import '../welcome/welcome_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // Delay initialization until after the first frame to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: UiConstants.fadeInDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Start animation immediately
    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    final viewModel = Provider.of<LoadingViewModel>(context, listen: false);

    // Initialize app and preload data while reporting truthful progress.
    final target = await viewModel.initializeAndPrepareApp(
      preloadHomeData: _preloadHomeData,
    );

    // Reverse animation before navigation
    if (!mounted || _hasNavigated) return;
    await _animationController.reverse();

    // Navigate to appropriate screen
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;
    _navigateToScreen(target);
  }

  Future<void> _preloadHomeData() async {
    final homeVm = context.read<HomeTabViewModel>();
    final planVm = context.read<PlanTabViewModel>();
    final trackVm = context.read<TrackTabViewModel>();

    try {
      await Future.wait([
        homeVm.refreshData(),
        planVm.fetchEvents(),
        trackVm.refreshAllData(),
      ]);
    } catch (error) {
      // Preload should never block app entry if one source fails.
      debugPrint('Preload warning: $error');
    }
  }

  void _navigateToScreen(NavigationTarget target) {
    final Widget targetScreen = target == NavigationTarget.home
        ? const HomeScreen()
        : const WelcomeScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<LoadingViewModel>(
        builder: (context, viewModel, child) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo with scale animation
                        _buildLogo(theme),

                        const SizedBox(height: 28),

                        // Progress bar directly below logo
                        _buildProgressBar(theme, viewModel.progress),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: Image.asset(
        'assets/logos/splash-logo-transparent-bg.png',
        width: UiConstants.logoSize,
        height: UiConstants.logoSize,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme, double progress) {
    return SizedBox(
      width: UiConstants.progressBarWidth,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              UiConstants.progressBarHeight / 2,
            ),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: UiConstants.progressBarHeight,
              backgroundColor: theme.progressIndicatorTheme.linearTrackColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.progressIndicatorTheme.color ?? theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${(progress * 100).toInt()}%',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

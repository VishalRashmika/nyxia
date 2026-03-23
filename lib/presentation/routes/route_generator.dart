import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../views/screens/loading/loading_screen.dart';
import '../views/screens/welcome/welcome_screen.dart';
import '../views/screens/auth/login_screen.dart';
import '../views/screens/auth/signup_screen.dart';
import '../views/screens/home/home_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.loading:
        return MaterialPageRoute(builder: (_) => const LoadingScreen());
      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

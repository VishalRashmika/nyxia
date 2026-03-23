import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './core/constants/firebase_options.dart';
import './presentation/views/themes/theme_provider.dart';
import 'data/repositories/auth_service/auth_service.dart';
import 'data/repositories/apod_service/apod_service.dart';
import 'presentation/viewmodels/loading_viewmodel.dart';
import 'presentation/viewmodels/welcome_viewmodel.dart';
import 'presentation/viewmodels/login_viewmodel.dart';
import 'presentation/viewmodels/signup_viewmodel.dart';
import 'presentation/viewmodels/home_viewmodel.dart';
import 'presentation/viewmodels/tabs/home_tab_viewmodel.dart';
import 'presentation/viewmodels/tabs/plan_tab_viewmodel.dart';
import 'presentation/viewmodels/tabs/track_tab_viewmodel.dart';
import 'presentation/viewmodels/tabs/you_tab_viewmodel.dart';
import 'presentation/viewmodels/equipment_viewmodel.dart';
import 'presentation/viewmodels/space_pictures_viewmodel.dart';
import 'presentation/views/screens/loading/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load environment variables
  await dotenv.load(fileName: '.env');

  // initialize firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // set auth persistence where supported
  try {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  } catch (e) {
    debugPrint('Auth persistence setting not available on this platform');
  }

  // load saved theme
  final themeProvider = ThemeProvider();
  await themeProvider.loadThemePreference();

  runApp(
    MultiProvider(
      providers: [
        // services
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ApodService>(create: (_) => ApodService()),

        // theme
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),

        // auth view models
        ChangeNotifierProvider<LoadingViewModel>(
          create: (context) => LoadingViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<WelcomeViewModel>(
          create: (context) => WelcomeViewModel(context.read<ApodService>()),
        ),
        ChangeNotifierProvider<LoginViewModel>(
          create: (context) => LoginViewModel(
            context.read<ApodService>(),
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider<SignUpViewModel>(
          create: (context) => SignUpViewModel(
            context.read<ApodService>(),
            context.read<AuthService>(),
          ),
        ),

        // home view models
        ChangeNotifierProvider<HomeViewModel>(create: (_) => HomeViewModel()),
        ChangeNotifierProvider<HomeTabViewModel>(
          create: (_) => HomeTabViewModel(),
        ),
        ChangeNotifierProvider<PlanTabViewModel>(
          create: (_) => PlanTabViewModel(),
        ),
        ChangeNotifierProvider<TrackTabViewModel>(
          create: (_) => TrackTabViewModel(),
        ),
        ChangeNotifierProvider<YouTabViewModel>(
          create: (context) => YouTabViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<EquipmentViewModel>(
          create: (_) => EquipmentViewModel(),
        ),
        ChangeNotifierProvider<SpacePicturesViewModel>(
          create: (context) =>
              SpacePicturesViewModel(context.read<ApodService>()),
        ),
      ],
      child: const NyxiaApp(),
    ),
  );
}

class NyxiaApp extends StatelessWidget {
  const NyxiaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Nyxia',
          theme: themeProvider.currentTheme,
          home: const LoadingScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

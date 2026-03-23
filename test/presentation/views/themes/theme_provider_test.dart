import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/presentation/views/themes/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('theme_provider_tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('provider starts in light mode by default', () {
      // this test verifies the provider default theme mode is light.
      final provider = ThemeProvider();

      expect(provider.themeMode, AppThemeMode.light);
    });

    test('toggleTheme cycles light to dark to night to light', () {
      // this test verifies theme toggling cycles through all modes.
      final provider = ThemeProvider();

      provider.toggleTheme();
      final modeAfterFirstToggle = provider.themeMode;
      provider.toggleTheme();
      final modeAfterSecondToggle = provider.themeMode;
      provider.toggleTheme();
      final modeAfterThirdToggle = provider.themeMode;

      expect(modeAfterFirstToggle, AppThemeMode.dark);
      expect(modeAfterSecondToggle, AppThemeMode.night);
      expect(modeAfterThirdToggle, AppThemeMode.light);
    });

    test('setTheme updates current mode and persists preference', () async {
      // this test verifies setTheme changes mode and writes preference.
      final provider = ThemeProvider();

      await provider.setTheme(AppThemeMode.dark);

      final storedPrefs = await SharedPreferences.getInstance();
      expect(provider.themeMode, AppThemeMode.dark);
      expect(storedPrefs.getString('theme_mode'), 'dark');
    });

    test('loadThemePreference restores saved mode', () async {
      // this test verifies saved theme mode is restored on load.
      SharedPreferences.setMockInitialValues({'theme_mode': 'night'});
      final provider = ThemeProvider();

      await provider.loadThemePreference();

      expect(provider.themeMode, AppThemeMode.night);
    });
  });
}

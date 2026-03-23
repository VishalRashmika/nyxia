import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'themes.dart';

enum AppThemeMode { light, dark, night }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.light;
  static const String _themePreferenceKey = 'theme_mode';

  AppThemeMode get themeMode => _themeMode;

  ThemeData get currentTheme {
    switch (_themeMode) {
      case AppThemeMode.light:
        return AppThemes.lightTheme;
      case AppThemeMode.dark:
        return AppThemes.darkTheme;
      case AppThemeMode.night:
        return AppThemes.nightTheme;
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await saveThemePreference();
  }

  void toggleTheme() {
    switch (_themeMode) {
      case AppThemeMode.light:
        _themeMode = AppThemeMode.dark;
        break;
      case AppThemeMode.dark:
        _themeMode = AppThemeMode.night;
        break;
      case AppThemeMode.night:
        _themeMode = AppThemeMode.light;
        break;
    }
    saveThemePreference();
    notifyListeners();
  }

  // load saved theme preference
  Future<void> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePreferenceKey);

      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            _themeMode = AppThemeMode.light;
            break;
          case 'dark':
            _themeMode = AppThemeMode.dark;
            break;
          case 'night':
            _themeMode = AppThemeMode.night;
            break;
        }
        notifyListeners();
      }
    } catch (e) {
      // keep default theme if load fails
      debugPrint('Error loading theme preference: $e');
    }
  }

  // save theme preference
  Future<void> saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeString;

      switch (_themeMode) {
        case AppThemeMode.light:
          themeString = 'light';
          break;
        case AppThemeMode.dark:
          themeString = 'dark';
          break;
        case AppThemeMode.night:
          themeString = 'night';
          break;
      }

      await prefs.setString(_themePreferenceKey, themeString);
    } catch (e) {
      // continue if save fails
      debugPrint('Error saving theme preference: $e');
    }
  }
}

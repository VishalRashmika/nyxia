import 'package:flutter/material.dart';

class AppThemes {
  static const BorderRadius _cardRadius = BorderRadius.all(Radius.circular(16));

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF28436C),
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    dividerColor: const Color(0xFFD8E2EF),
    disabledColor: const Color(0xFF8099BC),

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF28436C),
      onPrimary: Color(0xFFE8EDF5),
      secondary: Color(0xFF3A5E96),
      onSecondary: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF141B27),
      error: Color(0xFFFAE0DC),
      onError: Color(0xFF141B27),
      outline: Color(0xFFB0C2D8),
      surfaceContainerHighest: Color(0xFFE4EAF4),
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(borderRadius: _cardRadius),
      surfaceTintColor: const Color(0xFFD4DFF0),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F7FA),
      foregroundColor: Color(0xFF141B27),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF141B27),
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF141B27),
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF141B27)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF3D5275)),
      bodySmall: TextStyle(fontSize: 12, color: Color(0xFF8099BC)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFEDF1F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB0C2D8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB0C2D8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF28436C), width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFF8099BC)),
      labelStyle: const TextStyle(color: Color(0xFF3D5275)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF28436C),
        foregroundColor: const Color(0xFFE8EDF5),
      ),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFF28436C),
      linearTrackColor: Color(0xFFD4DFF0),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF28436C),
    scaffoldBackgroundColor: const Color(0xFF0D1117),
    dividerColor: const Color(0xFF1E2D44),
    disabledColor: const Color(0xFF5C7099),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF28436C),
      onPrimary: Color(0xFFE8EDF5),
      secondary: Color(0xFF3358A0),
      onSecondary: Color(0xFFE8EDF5),
      surface: Color(0xFF141B27),
      onSurface: Color(0xFFE8EDF5),
      error: Color(0xFF7A3A1E),
      onError: Color(0xFFE8EDF5),
      outline: Color(0xFF28436C),
      surfaceContainerHighest: Color(0xFF1E2D44),
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xFF141B27),
      shape: const RoundedRectangleBorder(borderRadius: _cardRadius),
      surfaceTintColor: const Color(0xFF1A2438),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D1117),
      foregroundColor: Color(0xFFE8EDF5),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE8EDF5),
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE8EDF5),
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFE8EDF5)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF9BADC7)),
      bodySmall: TextStyle(fontSize: 12, color: Color(0xFF5C7099)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E2D44),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF28436C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF28436C)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A5680), width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFF5C7099)),
      labelStyle: const TextStyle(color: Color(0xFF9BADC7)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF28436C),
        foregroundColor: const Color(0xFFE8EDF5),
      ),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFF4A74C7),
      linearTrackColor: Color(0xFF1E2D44),
    ),
  );

  // Night Mode (Red-shifted for preserving night vision)
  static ThemeData nightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF8B1A1A),
    scaffoldBackgroundColor: const Color(0xFF0A0000),
    dividerColor: const Color(0xFF2A0808),
    disabledColor: const Color(0xFF7A1C1C),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF8B1A1A),
      onPrimary: Color(0xFFFF6B6B),
      secondary: Color(0xFFB02222),
      onSecondary: Color(0xFFFF6B6B),
      surface: Color(0xFF120404),
      onSurface: Color(0xFFFF6B6B),
      error: Color(0xFF2A0000),
      onError: Color(0xFFFF6B6B),
      outline: Color(0xFF4A1010),
      surfaceContainerHighest: Color(0xFF220808),
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xFF120404),
      shape: const RoundedRectangleBorder(borderRadius: _cardRadius),
      surfaceTintColor: const Color(0xFF1A0606),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A0000),
      foregroundColor: Color(0xFFFF6B6B),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFF6B6B),
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFF6B6B),
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFFF6B6B)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFCC3333)),
      bodySmall: TextStyle(fontSize: 12, color: Color(0xFF7A1C1C)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF220808),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4A1010)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4A1010)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8B1A1A), width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFF7A1C1C)),
      labelStyle: const TextStyle(color: Color(0xFFCC3333)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8B1A1A),
        foregroundColor: const Color(0xFFFF6B6B),
      ),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFFB02222),
      linearTrackColor: Color(0xFF2A0808),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/presentation/views/themes/themes.dart';

void main() {
  group('themes_tests', () {
    test('light theme uses brand accent as primary color', () {
      // this test verifies light theme primary accent matches brand color.
      final theme = AppThemes.lightTheme;

      expect(theme.colorScheme.primary, const Color(0xFF28436C));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF5F7FA));
      expect(theme.progressIndicatorTheme.color, const Color(0xFF28436C));
    });

    test('dark theme keeps brand accent and deep background', () {
      // this test verifies dark theme keeps brand accent consistency.
      final theme = AppThemes.darkTheme;

      expect(theme.colorScheme.primary, const Color(0xFF28436C));
      expect(theme.scaffoldBackgroundColor, const Color(0xFF0D1117));
      expect(theme.colorScheme.surface, const Color(0xFF141B27));
    });

    test('night theme uses red shift palette values', () {
      // this test verifies night theme uses red-shifted token values.
      final theme = AppThemes.nightTheme;

      expect(theme.colorScheme.primary, const Color(0xFF8B1A1A));
      expect(theme.scaffoldBackgroundColor, const Color(0xFF0A0000));
      expect(theme.colorScheme.surface, const Color(0xFF120404));
    });

    test('themes expose readable text hierarchy colors', () {
      // this test verifies text hierarchy is mapped in every theme.
      final light = AppThemes.lightTheme;
      final dark = AppThemes.darkTheme;
      final night = AppThemes.nightTheme;

      expect(light.textTheme.bodyLarge?.color, const Color(0xFF141B27));
      expect(dark.textTheme.bodyMedium?.color, const Color(0xFF9BADC7));
      expect(night.textTheme.bodySmall?.color, const Color(0xFF7A1C1C));
    });
  });
}

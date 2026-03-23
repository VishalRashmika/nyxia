import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/presentation/views/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('theme_provider_widget_tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('material app uses provider theme colors in light mode', (
      WidgetTester tester,
    ) async {
      // this test verifies widget tree reads light theme from provider.
      final provider = ThemeProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: provider,
          child: Consumer<ThemeProvider>(
            builder: (context, theme, child) {
              return MaterialApp(
                theme: theme.currentTheme,
                home: const Scaffold(body: SizedBox(key: Key('home'))),
              );
            },
          ),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.colorScheme.primary, const Color(0xFF28436C));
      expect(
        materialApp.theme?.scaffoldBackgroundColor,
        const Color(0xFFF5F7FA),
      );
    });

    testWidgets('material app updates when provider theme changes', (
      WidgetTester tester,
    ) async {
      // this test verifies widget theme updates after provider mode change.
      final provider = ThemeProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: provider,
          child: Consumer<ThemeProvider>(
            builder: (context, theme, child) {
              return MaterialApp(
                theme: theme.currentTheme,
                home: const Scaffold(body: SizedBox(key: Key('home'))),
              );
            },
          ),
        ),
      );

      await provider.setTheme(AppThemeMode.dark);
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, Brightness.dark);
      expect(
        materialApp.theme?.scaffoldBackgroundColor,
        const Color(0xFF0D1117),
      );
    });
  });
}

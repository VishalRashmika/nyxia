import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/presentation/views/screens/tools/npf_calculator_screen.dart';

void main() {
  group('npf_calculator_screen_widget_tests', () {
    testWidgets('renders calculator title and calculate button', (
      WidgetTester tester,
    ) async {
      // this test verifies core npf calculator ui elements render.
      await tester.pumpWidget(const MaterialApp(home: NPFCalculatorScreen()));

      expect(find.text('NPF CALCULATOR'), findsOneWidget);
      expect(find.text('CALCULATE'), findsOneWidget);
    });

    testWidgets('calculates and displays max exposure result', (
      WidgetTester tester,
    ) async {
      // this test verifies calculate action shows result content.
      await tester.pumpWidget(const MaterialApp(home: NPFCalculatorScreen()));

      await tester.ensureVisible(find.text('CALCULATE'));
      await tester.tap(find.text('CALCULATE'));
      await tester.pumpAndSettle();

      expect(find.text('RESULT:'), findsOneWidget);
      expect(find.textContaining('Max Exposure:'), findsOneWidget);
    });

    testWidgets('shows validation message for invalid declination', (
      WidgetTester tester,
    ) async {
      // this test verifies declination validation blocks calculate.
      await tester.pumpWidget(const MaterialApp(home: NPFCalculatorScreen()));

      await tester.enterText(find.byType(TextFormField).at(3), '100');
      await tester.ensureVisible(find.text('CALCULATE'));
      await tester.tap(find.text('CALCULATE'));
      await tester.pumpAndSettle();

      expect(find.text('-90° to 90°'), findsOneWidget);
      expect(find.text('RESULT:'), findsNothing);
    });

    testWidgets('shows very short exposure recommendation branch', (
      WidgetTester tester,
    ) async {
      // this test verifies recommendation text for short exposure.
      await tester.pumpWidget(const MaterialApp(home: NPFCalculatorScreen()));

      await tester.enterText(find.byType(TextFormField).at(0), '500');
      await tester.enterText(find.byType(TextFormField).at(1), '1.4');
      await tester.enterText(find.byType(TextFormField).at(2), '2');
      await tester.enterText(find.byType(TextFormField).at(3), '0');

      await tester.ensureVisible(find.text('CALCULATE'));
      await tester.tap(find.text('CALCULATE'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Very short exposure.'), findsOneWidget);
    });

    testWidgets('shows long exposure recommendation branch', (
      WidgetTester tester,
    ) async {
      // this test verifies recommendation text for long exposure.
      await tester.pumpWidget(const MaterialApp(home: NPFCalculatorScreen()));

      await tester.enterText(find.byType(TextFormField).at(0), '8');
      await tester.enterText(find.byType(TextFormField).at(1), '2.8');
      await tester.enterText(find.byType(TextFormField).at(2), '6');
      await tester.enterText(find.byType(TextFormField).at(3), '0');

      await tester.ensureVisible(find.text('CALCULATE'));
      await tester.tap(find.text('CALCULATE'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Long exposure possible.'), findsOneWidget);
    });
  });
}

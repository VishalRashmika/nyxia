import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/presentation/views/screens/tools/depth_of_field_calculator_screen.dart';

void main() {
  group('depth_of_field_calculator_screen_widget_tests', () {
    testWidgets('renders dof calculator title and calculate button', (
      WidgetTester tester,
    ) async {
      // this test verifies core dof calculator ui renders.
      await tester.pumpWidget(
        const MaterialApp(home: DepthOfFieldCalculatorScreen()),
      );

      expect(find.text('DEPTH OF FIELD'), findsOneWidget);
      expect(find.text('CALCULATE'), findsOneWidget);
    });

    testWidgets('calculates and displays dof results section', (
      WidgetTester tester,
    ) async {
      // this test verifies dof calculate action shows result section.
      await tester.pumpWidget(
        const MaterialApp(home: DepthOfFieldCalculatorScreen()),
      );

      await tester.ensureVisible(find.text('CALCULATE'));
      await tester.tap(find.text('CALCULATE'));
      await tester.pumpAndSettle();

      expect(find.text('RESULT:'), findsOneWidget);
      expect(find.textContaining('Hyperfocal Distance:'), findsOneWidget);
    });

    testWidgets('shows required validation when subject distance is empty', (
      WidgetTester tester,
    ) async {
      // this test verifies required validation for subject distance.
      await tester.pumpWidget(
        const MaterialApp(home: DepthOfFieldCalculatorScreen()),
      );

      await tester.enterText(find.byType(TextFormField).at(2), '');
      await tester.ensureVisible(find.text('CALCULATE'));
      await tester.tap(find.text('CALCULATE'));
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsOneWidget);
      expect(find.text('RESULT:'), findsNothing);
    });

    testWidgets('shows infinity branch for far focus limit', (
      WidgetTester tester,
    ) async {
      // this test verifies infinity branch rendering in results.
      await tester.pumpWidget(
        const MaterialApp(home: DepthOfFieldCalculatorScreen()),
      );

      await tester.enterText(find.byType(TextFormField).at(2), '1000');
      await tester.ensureVisible(find.text('CALCULATE'));
      await tester.tap(find.text('CALCULATE'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Infinity'), findsWidgets);
    });

    testWidgets('allows changing sensor size before calculate', (
      WidgetTester tester,
    ) async {
      // this test verifies dropdown interaction and finite calculation path.
      await tester.pumpWidget(
        const MaterialApp(home: DepthOfFieldCalculatorScreen()),
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Micro Four Thirds').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(2), '5');
      await tester.ensureVisible(find.text('CALCULATE'));
      await tester.tap(find.text('CALCULATE'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Total Depth of Field:'), findsOneWidget);
    });
  });
}

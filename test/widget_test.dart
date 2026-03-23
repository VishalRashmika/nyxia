import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/presentation/views/themes/themes.dart';

void main() {
  testWidgets('theme smoke test renders scaffold with light theme', (
    WidgetTester tester,
  ) async {
    // this test verifies a basic themed scaffold can render.
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.lightTheme,
        home: const Scaffold(body: Text('nyxia')),
      ),
    );

    expect(find.text('nyxia'), findsOneWidget);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, isNull);
  });
}

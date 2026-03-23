import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/presentation/views/widgets/bg_image_container.dart';

void main() {
  group('bg_image_container_widget_tests', () {
    testWidgets('shows loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      // this test verifies loading state renders a progress indicator.
      await tester.pumpWidget(
        const MaterialApp(
          home: BackgroundImageContainer(
            imageUrl: null,
            isLoading: true,
            child: Text('child'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('child'), findsNothing);
    });

    testWidgets('shows child when isLoading is false', (
      WidgetTester tester,
    ) async {
      // this test verifies content is displayed when not loading.
      await tester.pumpWidget(
        const MaterialApp(
          home: BackgroundImageContainer(
            imageUrl: null,
            isLoading: false,
            child: Text('child'),
          ),
        ),
      );

      expect(find.text('child'), findsOneWidget);
    });
  });
}

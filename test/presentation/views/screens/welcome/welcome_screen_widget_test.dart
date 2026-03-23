import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nyxia/data/repositories/apod_service/apod_service.dart';
import 'package:nyxia/presentation/viewmodels/welcome_viewmodel.dart';
import 'package:nyxia/presentation/views/screens/welcome/welcome_screen.dart';

class _FakeApodService extends ApodService {}

class _FakeWelcomeViewModel extends WelcomeViewModel {
  _FakeWelcomeViewModel() : super(_FakeApodService());

  @override
  Future<void> loadBackgroundImage() async {}
}

void main() {
  group('welcome_screen_widget_tests', () {
    testWidgets('renders welcome title and action buttons', (tester) async {
      // this test verifies welcome screen baseline ui content.
      final vm = _FakeWelcomeViewModel();

      await tester.pumpWidget(
        ChangeNotifierProvider<WelcomeViewModel>.value(
          value: vm,
          child: const MaterialApp(home: WelcomeScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('WELCOME'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'LOGIN'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'SIGN UP'), findsOneWidget);
      expect(
        find.text('Discover and capture the wonders of the night sky.'),
        findsOneWidget,
      );
    });
  });
}

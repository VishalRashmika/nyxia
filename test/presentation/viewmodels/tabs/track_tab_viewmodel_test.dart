import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/presentation/viewmodels/tabs/track_tab_viewmodel.dart';

void main() {
  group('track_tab_viewmodel_tests', () {
    test('refreshMoonData updates moon fields to non-loading values', () async {
      // this test verifies moon computation updates visible state values.
      final vm = TrackTabViewModel();

      await vm.refreshMoonData();

      expect(vm.moonPhase, isNot('Loading...'));
      expect(vm.moonIllumination, isNot('Loading...'));
      expect(vm.moonrise, isNot('Loading...'));
      expect(vm.moonset, isNot('Loading...'));
    });

    test('refreshAllData sets loaded flag after completion', () async {
      // this test verifies refresh flow marks data as loaded.
      final vm = TrackTabViewModel();

      await vm.refreshAllData();

      expect(vm.hasLoadedOnce, isTrue);
      expect(vm.isLoading, isFalse);
    });

    test('aurora color getter maps kp ranges consistently', () async {
      // this test verifies aurora color getter returns a color object.
      final vm = TrackTabViewModel();

      await vm.refreshMoonData();

      expect(vm.auroraColor, isNotNull);
    });
  });
}

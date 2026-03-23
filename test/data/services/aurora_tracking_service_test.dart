import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/data/services/aurora_tracking_service.dart';

void main() {
  group('aurora_tracking_service_model_tests', () {
    test('kpIndexInt rounds and clamps into 0 to 9', () {
      // this test verifies kp index integer normalization.
      final low = AuroraData(kpIndex: -2.2, timestamp: DateTime(2026, 1, 1));
      final mid = AuroraData(kpIndex: 4.6, timestamp: DateTime(2026, 1, 1));
      final high = AuroraData(kpIndex: 12.4, timestamp: DateTime(2026, 1, 1));

      expect(low.kpIndexInt, 0);
      expect(mid.kpIndexInt, 5);
      expect(high.kpIndexInt, 9);
    });

    test('activityLevel maps kp ranges', () {
      // this test verifies activity level threshold mapping.
      expect(
        AuroraData(kpIndex: 2.9, timestamp: DateTime(2026, 1, 1)).activityLevel,
        'Low',
      );
      expect(
        AuroraData(kpIndex: 3.0, timestamp: DateTime(2026, 1, 1)).activityLevel,
        'Moderate',
      );
      expect(
        AuroraData(kpIndex: 5.0, timestamp: DateTime(2026, 1, 1)).activityLevel,
        'High',
      );
      expect(
        AuroraData(kpIndex: 7.2, timestamp: DateTime(2026, 1, 1)).activityLevel,
        'Very High',
      );
    });

    test('probability maps kp buckets', () {
      // this test verifies probability percentage mapping.
      expect(
        AuroraData(kpIndex: 0.8, timestamp: DateTime(2026, 1, 1)).probability,
        '5%',
      );
      expect(
        AuroraData(kpIndex: 1.2, timestamp: DateTime(2026, 1, 1)).probability,
        '10%',
      );
      expect(
        AuroraData(kpIndex: 2.2, timestamp: DateTime(2026, 1, 1)).probability,
        '20%',
      );
      expect(
        AuroraData(kpIndex: 3.2, timestamp: DateTime(2026, 1, 1)).probability,
        '40%',
      );
      expect(
        AuroraData(kpIndex: 4.2, timestamp: DateTime(2026, 1, 1)).probability,
        '60%',
      );
      expect(
        AuroraData(kpIndex: 5.2, timestamp: DateTime(2026, 1, 1)).probability,
        '75%',
      );
      expect(
        AuroraData(kpIndex: 6.2, timestamp: DateTime(2026, 1, 1)).probability,
        '85%',
      );
      expect(
        AuroraData(kpIndex: 7.2, timestamp: DateTime(2026, 1, 1)).probability,
        '95%',
      );
      expect(
        AuroraData(kpIndex: 8.2, timestamp: DateTime(2026, 1, 1)).probability,
        '99%',
      );
    });

    test('colorHex and visibilityLatitude map activity bands', () {
      // this test verifies color and latitude outputs at thresholds.
      final low = AuroraData(kpIndex: 2.0, timestamp: DateTime(2026, 1, 1));
      final mod = AuroraData(kpIndex: 4.0, timestamp: DateTime(2026, 1, 1));
      final high = AuroraData(kpIndex: 6.0, timestamp: DateTime(2026, 1, 1));
      final veryHigh = AuroraData(
        kpIndex: 9.0,
        timestamp: DateTime(2026, 1, 1),
      );

      expect(low.colorHex, '#4CAF50');
      expect(mod.colorHex, '#FFC107');
      expect(high.colorHex, '#FF9800');
      expect(veryHigh.colorHex, '#F44336');

      expect(low.visibilityLatitude, 'Typically only visible above 70°N');
      expect(mod.visibilityLatitude, 'Visible around 65°N');
      expect(high.visibilityLatitude, 'Visible as low as 55°N');
      expect(veryHigh.visibilityLatitude, 'Visible as low as 40°N');
    });

    test('description text varies by kp level', () {
      // this test verifies narrative description branch coverage.
      expect(
        AuroraData(kpIndex: 1.0, timestamp: DateTime(2026, 1, 1)).description,
        contains('very low'),
      );
      expect(
        AuroraData(kpIndex: 3.0, timestamp: DateTime(2026, 1, 1)).description,
        contains('Moderate aurora activity'),
      );
      expect(
        AuroraData(kpIndex: 5.0, timestamp: DateTime(2026, 1, 1)).description,
        contains('Active aurora conditions'),
      );
      expect(
        AuroraData(kpIndex: 7.0, timestamp: DateTime(2026, 1, 1)).description,
        contains('Strong aurora storm'),
      );
      expect(
        AuroraData(kpIndex: 8.5, timestamp: DateTime(2026, 1, 1)).description,
        contains('Severe aurora storm'),
      );
    });

    test('bestViewingTime and forecast formattedTime are stable', () {
      // this test verifies static viewing text and utc hour formatting.
      final aurora = AuroraData(kpIndex: 4.0, timestamp: DateTime(2026, 1, 1));
      final forecast = KPForecast(
        timestamp: DateTime.utc(2026, 1, 1, 3, 30),
        kpIndex: 4.4,
      );

      expect(aurora.bestViewingTime, '10:00 PM - 2:00 AM');
      expect(forecast.formattedTime, '03:00 UTC');
      expect(forecast.kpIndexInt, 4);
    });
  });
}

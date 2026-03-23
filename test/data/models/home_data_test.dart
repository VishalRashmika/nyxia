import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/data/models/home_data.dart';

void main() {
  group('home_data_tests', () {
    test('homeData initial creates safe default values', () {
      // this test verifies initial home data creates non-null defaults.
      final homeData = HomeData.initial();

      expect(homeData.location.latitude, 0.0);
      expect(homeData.location.longitude, 0.0);
      expect(homeData.weather.description, 'Unknown');
      expect(homeData.elevation, isNull);
      expect(homeData.lightPollution.bortleScale, 5);
    });

    test('location coordinates formats latitude and longitude', () {
      // this test verifies coordinate formatting to four decimals.
      final location = LocationData(latitude: 7.4807661, longitude: 79.8012788);

      final coordinates = location.coordinates;

      expect(coordinates, '7.4808°, 79.8013°');
    });

    test('weather string getters format readable values', () {
      // this test verifies weather string getters include units.
      final weather = WeatherData(
        temperature: 24.56,
        humidity: 61,
        cloudCover: 28,
        description: 'clear sky',
        icon: '01d',
      );

      expect(weather.temperatureString, '24.6°C');
      expect(weather.humidityString, '61%');
      expect(weather.cloudCoverString, '28%');
    });

    test('lightPollution unknown returns expected baseline', () {
      // this test verifies unknown light pollution baseline values.
      final pollution = LightPollution.unknown();

      expect(pollution.sqm, isNull);
      expect(pollution.bortleScale, 5);
      expect(pollution.description, 'Unknown');
      expect(pollution.sqmString, 'N/A');
      expect(pollution.bortleString, 'Bortle 5');
    });

    test('lightPollution fromSQM maps very dark sky to bortle 1', () {
      // this test verifies highest sqm maps to bortle one.
      final pollution = LightPollution.fromSQM(22.0);

      expect(pollution.bortleScale, 1);
      expect(pollution.description, 'Excellent dark sky');
      expect(pollution.sqmString, '22.00 mag/arcsec²');
    });

    test('lightPollution fromSQM maps suburban threshold to bortle 5', () {
      // this test verifies suburban sqm threshold mapping.
      final pollution = LightPollution.fromSQM(19.50);

      expect(pollution.bortleScale, 5);
      expect(pollution.description, 'Suburban sky');
    });

    test('lightPollution fromSQM maps low sqm to bortle 9', () {
      // this test verifies low sqm maps to inner city skies.
      final pollution = LightPollution.fromSQM(17.0);

      expect(pollution.bortleScale, 9);
      expect(pollution.description, 'Inner city sky');
    });
  });
}

import 'dart:convert';
import 'package:http/http.dart' as http;

/// service for aurora and kp index data
class AuroraTrackingService {
  // noaa space weather apis
  final String _kpIndexUrl =
      'https://services.swpc.noaa.gov/products/noaa-planetary-k-index.json';
  final String _threeDayForecastUrl =
      'https://services.swpc.noaa.gov/products/noaa-planetary-k-index-forecast.json';

  /// get current aurora data
  Future<AuroraData?> getCurrentAuroraData() async {
    try {
      print('Fetching KP index from NOAA');

      final response = await http
          .get(Uri.parse(_kpIndexUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // read the latest row
        if (data.length > 1) {
          final latest = data.last;

          double kpValue;
          try {
            kpValue = double.parse(latest[1].toString());
          } catch (e) {
            kpValue = 0.0;
          }

          final auroraData = AuroraData(
            kpIndex: kpValue,
            timestamp: DateTime.parse(latest[0]),
          );

          print('Current KP index: ${auroraData.kpIndex}');
          return auroraData;
        }
      } else {
        print('NOAA API error: ${response.statusCode}');
      }

      return null;
    } catch (e) {
      print('Error fetching aurora data: $e');
      return null;
    }
  }

  /// get kp forecast
  Future<List<KPForecast>> getKPForecast() async {
    try {
      print('Fetching KP forecast from NOAA');

      final response = await http
          .get(Uri.parse(_threeDayForecastUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // skip header row
        if (data.length > 1) {
          final forecasts = data
              .skip(1)
              .map((item) {
                try {
                  return KPForecast(
                    timestamp: DateTime.parse(item[0]),
                    kpIndex: double.parse(item[1].toString()),
                  );
                } catch (e) {
                  return null;
                }
              })
              .where((f) => f != null)
              .cast<KPForecast>()
              .toList();

          print('Fetched ${forecasts.length} KP forecasts');
          return forecasts;
        }
      }

      return [];
    } catch (e) {
      print('Error fetching KP forecast: $e');
      return [];
    }
  }
}

/// data model for aurora
class AuroraData {
  final double kpIndex;
  final DateTime timestamp;

  AuroraData({required this.kpIndex, required this.timestamp});

  /// kp index as integer
  int get kpIndexInt => kpIndex.round().clamp(0, 9);

  /// activity level
  String get activityLevel {
    if (kpIndex < 3) return 'Low';
    if (kpIndex < 5) return 'Moderate';
    if (kpIndex < 7) return 'High';
    return 'Very High';
  }

  /// aurora probability
  String get probability {
    if (kpIndex < 1) return '5%';
    if (kpIndex < 2) return '10%';
    if (kpIndex < 3) return '20%';
    if (kpIndex < 4) return '40%';
    if (kpIndex < 5) return '60%';
    if (kpIndex < 6) return '75%';
    if (kpIndex < 7) return '85%';
    if (kpIndex < 8) return '95%';
    return '99%';
  }

  /// color by activity level
  String get colorHex {
    if (kpIndex < 3) return '#4CAF50';
    if (kpIndex < 5) return '#FFC107';
    if (kpIndex < 7) return '#FF9800';
    return '#F44336';
  }

  /// best viewing time
  String get bestViewingTime {
    return '10:00 PM - 2:00 AM';
  }

  /// visibility latitude range
  String get visibilityLatitude {
    if (kpIndex >= 9) return 'Visible as low as 40°N';
    if (kpIndex >= 8) return 'Visible as low as 45°N';
    if (kpIndex >= 7) return 'Visible as low as 50°N';
    if (kpIndex >= 6) return 'Visible as low as 55°N';
    if (kpIndex >= 5) return 'Visible as low as 60°N';
    if (kpIndex >= 4) return 'Visible around 65°N';
    return 'Typically only visible above 70°N';
  }

  /// description
  String get description {
    if (kpIndex < 2) {
      return 'Aurora activity is very low. Visible only in far northern regions.';
    } else if (kpIndex < 4) {
      return 'Moderate aurora activity. Visible in northern regions with dark skies.';
    } else if (kpIndex < 6) {
      return 'Active aurora conditions! Good visibility in mid-latitude regions.';
    } else if (kpIndex < 8) {
      return 'Strong aurora storm! Visible at lower latitudes. Great viewing opportunity!';
    } else {
      return 'Severe aurora storm! Exceptional visibility even at mid-latitudes. Don\'t miss this!';
    }
  }
}

/// data model for kp forecast
class KPForecast {
  final DateTime timestamp;
  final double kpIndex;

  KPForecast({required this.timestamp, required this.kpIndex});

  int get kpIndexInt => kpIndex.round().clamp(0, 9);

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    return '$hour:00 UTC';
  }
}

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/home_data.dart';

class HomeDataService {
  static const String _openWeatherMapBaseUrl =
      'https://api.openweathermap.org/data/2.5';
  static const String _openElevationBaseUrl =
      'https://api.open-elevation.com/api/v1';
  static const String _openMeteoElevationBaseUrl =
      'https://api.open-meteo.com/v1';

  String get _openWeatherMapApiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  /// get current location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // check location service
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } on TimeoutException catch (_) {
      // use cached position after timeout
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return lastKnownPosition;
      }

      // retry once with lower accuracy
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
    } catch (_) {
      // recover with cached position
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return lastKnownPosition;
      }
      rethrow;
    }
  }

  /// fetch weather data
  Future<WeatherData> fetchWeatherData(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '$_openWeatherMapBaseUrl/weather?lat=$lat&lon=$lon&appid=$_openWeatherMapApiKey&units=metric',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return WeatherData(
          temperature: (data['main']['temp'] as num).toDouble(),
          humidity: data['main']['humidity'] as int,
          cloudCover: data['clouds']['all'] as int,
          description: data['weather'][0]['description'] as String,
          icon: data['weather'][0]['icon'] as String?,
        );
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }

  /// fetch elevation data
  Future<double> fetchElevation(double lat, double lon) async {
    // primary provider
    try {
      final url = Uri.parse(
        '$_openElevationBaseUrl/lookup?locations=$lat,$lon',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'][0]['elevation'] as num).toDouble();
      } else {
        throw Exception(
          'Failed to load elevation data: ${response.statusCode}',
        );
      }
    } catch (_) {
      // fallback provider
      try {
        final fallbackUrl = Uri.parse(
          '$_openMeteoElevationBaseUrl/elevation?latitude=$lat&longitude=$lon',
        );

        final fallbackResponse = await http.get(fallbackUrl);

        if (fallbackResponse.statusCode == 200) {
          final data = json.decode(fallbackResponse.body);
          final elevations = data['elevation'];

          if (elevations is List && elevations.isNotEmpty) {
            return (elevations.first as num).toDouble();
          }

          throw Exception('Invalid fallback elevation response format');
        }

        throw Exception(
          'Failed to load fallback elevation data: ${fallbackResponse.statusCode}',
        );
      } catch (fallbackError) {
        throw Exception('Error fetching elevation data: $fallbackError');
      }
    }
  }

  /// fetch location details
  Future<LocationData> fetchLocationData(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'http://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lon&limit=1&appid=$_openWeatherMapApiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          return LocationData(
            latitude: lat,
            longitude: lon,
            city: data[0]['name'] as String?,
            country: data[0]['country'] as String?,
          );
        }
      }

      // fallback if reverse geocoding fails
      return LocationData(
        latitude: lat,
        longitude: lon,
        city: null,
        country: null,
      );
    } catch (e) {
      // return basic location data
      return LocationData(
        latitude: lat,
        longitude: lon,
        city: null,
        country: null,
      );
    }
  }

  /// estimate light pollution
  Future<LightPollution> estimateLightPollution(double lat, double lon) async {
    return LightPollution.fromSQM(19.5);
  }

  /// fetch all home data
  Future<HomeData> fetchAllHomeData() async {
    try {
      final position = await getCurrentLocation();
      final lat = position.latitude;
      final lon = position.longitude;

      // fetch data in parallel
      final results = await Future.wait([
        fetchLocationData(lat, lon),
        fetchWeatherData(lat, lon),
        fetchElevation(lat, lon),
        estimateLightPollution(lat, lon),
      ]);

      return HomeData(
        location: results[0] as LocationData,
        weather: results[1] as WeatherData,
        elevation: results[2] as double,
        lightPollution: results[3] as LightPollution,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error fetching home data: $e');
    }
  }

  /// fetch home data with coordinates
  Future<HomeData> fetchHomeDataWithCoordinates(double lat, double lon) async {
    try {
      // fetch data in parallel
      final results = await Future.wait([
        fetchLocationData(lat, lon),
        fetchWeatherData(lat, lon),
        fetchElevation(lat, lon),
        estimateLightPollution(lat, lon),
      ]);

      return HomeData(
        location: results[0] as LocationData,
        weather: results[1] as WeatherData,
        elevation: results[2] as double,
        lightPollution: results[3] as LightPollution,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error fetching home data: $e');
    }
  }
}

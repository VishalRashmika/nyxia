import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/services/home_data_service.dart';
import '../../../data/models/home_data.dart';

class HomeTabViewModel extends ChangeNotifier {
  final HomeDataService _homeDataService = HomeDataService();
  bool _isDisposed = false;

  // state
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String? _errorMessage;

  // location data
  String _location = 'Loading...';
  String _coordinates = 'Loading...';
  String _elevation = 'Loading...';

  // weather data
  double _cloudCoverValue = 0;
  double _temperatureValue = 0;
  int _humidityValue = 0;
  String _weatherDescription = '';

  // light pollution data
  String _lightPollution = 'Calculating...';

  // visibility state
  String _visibility = 'LOADING';

  // getters
  bool get isLoading => _isLoading;
  bool get hasLoadedOnce => _hasLoadedOnce;
  String? get errorMessage => _errorMessage;
  String get greetingMessage => _getGreeting();
  String get locationName => _location;
  String get location => _location;
  String get coordinates => _coordinates;
  String get elevation => _elevation;
  String get localTime => DateFormat('h:mm a').format(DateTime.now());
  String get cloudCover => '${_cloudCoverValue.round()}';
  String get temperature => '${_temperatureValue.round()}';
  String get humidity => '$_humidityValue';
  String get lightPollution => _lightPollution;
  String get visibilityStatus => _visibility;
  Color get visibilityColor => _getVisibilityColor();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Color _getVisibilityColor() {
    switch (_visibility) {
      case 'EXCELLENT':
        return Colors.green;
      case 'GOOD':
        return Colors.lightGreen;
      case 'FAIR':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  void _notifySafely() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  String _buildUserFriendlyError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('location permissions are denied')) {
      return 'Location permission is required to load your home data.';
    }

    if (message.contains('location services are disabled')) {
      return 'Location services are turned off. Please enable GPS and try again.';
    }

    if (message.contains('timed out')) {
      return 'Request timed out. Please check your connection and try again.';
    }

    return 'Unable to load home data right now. Please try again.';
  }

  /// fetch home data from device location
  Future<void> refreshData() async {
    if (_isDisposed) return;

    _isLoading = true;
    _errorMessage = null;
    _notifySafely();

    try {
      // get current location
      final position = await _homeDataService.getCurrentLocation();

      // fetch location name
      final locationData = await _homeDataService.fetchLocationData(
        position.latitude,
        position.longitude,
      );

      // fetch weather data
      final weatherData = await _homeDataService.fetchWeatherData(
        position.latitude,
        position.longitude,
      );

      // fetch elevation
      final elevationValue = await _homeDataService.fetchElevation(
        position.latitude,
        position.longitude,
      );

      // estimate light pollution
      final lightPollutionData = await _homeDataService.estimateLightPollution(
        position.latitude,
        position.longitude,
      );

      // update state
      _location = locationData.city ?? locationData.country ?? 'Unknown';
      _coordinates = locationData.coordinates;
      _elevation = '${elevationValue.round()}m';

      _cloudCoverValue = weatherData.cloudCover.toDouble();
      _temperatureValue = weatherData.temperature;
      _humidityValue = weatherData.humidity;
      _weatherDescription = weatherData.description;

      _lightPollution = lightPollutionData.description;

      // calculate visibility
      _visibility = _calculateVisibility(_cloudCoverValue);
    } catch (e, st) {
      _errorMessage = _buildUserFriendlyError(e);
      debugPrint('Error fetching home data: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      _isLoading = false;
      _hasLoadedOnce = true;
      _notifySafely();
    }
  }

  void handleUnexpectedError(Object error, StackTrace stackTrace) {
    _errorMessage = _buildUserFriendlyError(error);
    _isLoading = false;
    debugPrint('Unhandled home future error: $error');
    debugPrintStack(stackTrace: stackTrace);
    _notifySafely();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  String _calculateVisibility(double cloudCover) {
    if (cloudCover <= 20) return 'EXCELLENT';
    if (cloudCover <= 40) return 'GOOD';
    if (cloudCover <= 60) return 'FAIR';
    return 'POOR';
  }
}

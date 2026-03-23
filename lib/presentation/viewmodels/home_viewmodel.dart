import 'package:flutter/material.dart';
import '../../data/models/home_data.dart';
import '../../data/services/home_data_service.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeDataService _homeDataService = HomeDataService();

  int _selectedIndex = 0;
  HomeData _homeData = HomeData.initial();
  bool _isLoading = false;
  String? _errorMessage;

  int get selectedIndex => _selectedIndex;
  HomeData get homeData => _homeData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void onTabChanged(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  /// Refresh all home data using device GPS
  Future<void> refreshHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _homeData = await _homeDataService.fetchAllHomeData();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error refreshing home data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh home data with manual coordinates
  Future<void> refreshHomeDataWithCoordinates(double lat, double lon) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _homeData = await _homeDataService.fetchHomeDataWithCoordinates(lat, lon);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error refreshing home data with coordinates: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get individual data components for easy access
  LocationData get location => _homeData.location;
  WeatherData get weather => _homeData.weather;
  double? get elevation => _homeData.elevation;
  LightPollution get lightPollution => _homeData.lightPollution;
  DateTime get lastUpdated => _homeData.lastUpdated;

  /// Formatted strings for display
  String get elevationString =>
      elevation != null ? '${elevation!.toStringAsFixed(1)} m' : 'N/A';
  String get lastUpdatedString {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/services/aurora_tracking_service.dart';
import '../../../data/services/home_data_service.dart';

class TrackTabViewModel extends ChangeNotifier {
  final AuroraTrackingService _auroraService = AuroraTrackingService();
  final HomeDataService _homeDataService = HomeDataService();

  // loading state
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String? _errorMessage;

  // moon data
  String _moonPhase = 'Loading...';
  String _moonIllumination = 'Loading...';
  String _moonrise = 'Loading...';
  String _moonset = 'Loading...';
  IconData _moonPhaseIcon = Icons.brightness_3;

  // aurora data
  int _kpIndex = 0;
  String _auroraLevel = 'Loading...';
  String _auroraProbability = 'Loading...';
  String _bestViewingTime = 'Loading...';
  String _auroraDescription = '';

  // current position
  Position? _currentPosition;

  // getters
  bool get isLoading => _isLoading;
  bool get hasLoadedOnce => _hasLoadedOnce;
  String? get errorMessage => _errorMessage;
  IconData get moonPhaseIcon => _moonPhaseIcon;
  String get moonPhaseName => _moonPhase;
  String get moonPhase => _moonPhase;
  String get moonIllumination => _moonIllumination;
  String get moonrise => _moonrise;
  String get moonset => _moonset;
  int get kpIndex => _kpIndex;
  String get auroraActivity => _auroraLevel;
  String get auroraProbability => _auroraProbability;
  String get auroraViewingTime => _bestViewingTime;
  String get auroraDescription => _auroraDescription;
  String get auroraInfo => 'KP Index: $kpIndex - $_auroraLevel activity';
  Color get auroraColor => _getAuroraColor(_kpIndex);

  Color _getAuroraColor(int kp) {
    if (kp <= 2) return Colors.green;
    if (kp <= 5) return Colors.yellow;
    if (kp <= 7) return Colors.orange;
    return Colors.red;
  }

  /// initialize tracking data
  Future<void> initialize() async {
    await refreshAllData();
  }

  /// refresh tracking data
  Future<void> refreshAllData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // get current location
      _currentPosition = await _homeDataService.getCurrentLocation();

      // fetch data in parallel
      await Future.wait([refreshMoonData(), refreshAuroraData()]);
    } catch (e) {
      _errorMessage = 'Error loading tracking data: $e';
      debugPrint('Error in refreshAllData: $e');
    } finally {
      _isLoading = false;
      _hasLoadedOnce = true;
      notifyListeners();
    }
  }

  /// calculate moon data
  Future<void> refreshMoonData() async {
    try {
      final now = DateTime.now();

      // calculate current moon phase
      final knownNewMoon = DateTime(2000, 1, 6, 18, 14);
      final synodicMonth = 29.53058867;

      final daysSinceKnown = now.difference(knownNewMoon).inDays;
      final phase = (daysSinceKnown % synodicMonth) / synodicMonth;

      // set phase name and icon
      if (phase < 0.03 || phase > 0.97) {
        _moonPhase = 'New Moon';
        _moonPhaseIcon = Icons.brightness_1;
        _moonIllumination = '0%';
      } else if (phase < 0.22) {
        _moonPhase = 'Waxing Crescent';
        _moonPhaseIcon = Icons.brightness_2;
        _moonIllumination = '${(phase * 400).round()}%';
      } else if (phase < 0.28) {
        _moonPhase = 'First Quarter';
        _moonPhaseIcon = Icons.brightness_3;
        _moonIllumination = '50%';
      } else if (phase < 0.47) {
        _moonPhase = 'Waxing Gibbous';
        _moonPhaseIcon = Icons.brightness_4;
        _moonIllumination = '${(phase * 200).round()}%';
      } else if (phase < 0.53) {
        _moonPhase = 'Full Moon';
        _moonPhaseIcon = Icons.brightness_5;
        _moonIllumination = '100%';
      } else if (phase < 0.72) {
        _moonPhase = 'Waning Gibbous';
        _moonPhaseIcon = Icons.brightness_4;
        _moonIllumination = '${((1 - phase) * 200).round()}%';
      } else if (phase < 0.78) {
        _moonPhase = 'Last Quarter';
        _moonPhaseIcon = Icons.brightness_3;
        _moonIllumination = '50%';
      } else {
        _moonPhase = 'Waning Crescent';
        _moonPhaseIcon = Icons.brightness_2;
        _moonIllumination = '${((1 - phase) * 400).round()}%';
      }

      // estimate moonrise and moonset from phase
      final moonriseHour = 6 + (phase * 24).round();
      final moonsetHour = (18 + (phase * 24).round()) % 24;

      _moonrise = DateFormat(
        'h:mm a',
      ).format(DateTime(now.year, now.month, now.day, moonriseHour % 24, 0));
      _moonset = DateFormat(
        'h:mm a',
      ).format(DateTime(now.year, now.month, now.day, moonsetHour, 0));

      notifyListeners();
    } catch (e) {
      debugPrint('Error calculating moon data: $e');
      _moonPhase = 'Error';
      _moonIllumination = 'N/A';
      notifyListeners();
    }
  }

  /// fetch aurora data
  Future<void> refreshAuroraData() async {
    try {
      final auroraData = await _auroraService.getCurrentAuroraData();

      if (auroraData != null) {
        _kpIndex = auroraData.kpIndexInt;
        _auroraLevel = auroraData.activityLevel;
        _auroraProbability = auroraData.probability;
        _bestViewingTime = auroraData.bestViewingTime;
        _auroraDescription = auroraData.description;
      } else {
        _kpIndex = 0;
        _auroraLevel = 'Unavailable';
        _auroraProbability = 'N/A';
        _auroraDescription = 'Unable to fetch aurora data';
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching aurora data: $e');
      _kpIndex = 0;
      _auroraLevel = 'Error';
      _auroraProbability = 'N/A';
      notifyListeners();
    }
  }
}

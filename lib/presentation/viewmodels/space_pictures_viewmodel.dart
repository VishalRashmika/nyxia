import 'package:flutter/material.dart';
import '../../../data/models/apod.dart';
import '../../../data/repositories/apod_service/apod_service.dart';

/// view model for apod screen
class SpacePicturesViewModel extends ChangeNotifier {
  final ApodService _apodService;

  Apod? _currentApod;
  DateTime _currentDate;
  bool _isLoading = false;
  String? _error;

  SpacePicturesViewModel(this._apodService)
    : _currentDate = _latestAvailableDate() {
    // load latest available apod on init
    loadApod();
  }

  static DateTime _latestAvailableDate() {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // getters
  Apod? get currentApod => _currentApod;
  DateTime get currentDate => _currentDate;
  DateTime get latestAvailableDate => _latestAvailableDate();
  bool get isAtLatestAvailableDate =>
      _isSameDay(_currentDate, latestAvailableDate);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasApod => _currentApod != null;

  // next day is limited by latest available date
  bool get canGoNext {
    final nextDay = DateTime(
      _currentDate.year,
      _currentDate.month,
      _currentDate.day + 1,
    );
    final latest = latestAvailableDate;
    return nextDay.isBefore(latest) || _isSameDay(nextDay, latest);
  }

  // apod starts on june 16, 1995
  bool get canGoPrevious {
    final firstApodDate = DateTime(1995, 6, 16);
    final prevDay = DateTime(
      _currentDate.year,
      _currentDate.month,
      _currentDate.day - 1,
    );
    return prevDay.isAfter(firstApodDate) ||
        prevDay.isAtSameMomentAs(firstApodDate);
  }

  /// load apod for current date
  Future<void> loadApod() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final apod = await _apodService.fetchApod(date: _currentDate);

      if (apod != null) {
        _currentApod = apod;
        _error = null;
      } else {
        _error = 'Failed to load picture';
      }
    } catch (e) {
      debugPrint('Error loading APOD: $e');
      _error = 'Failed to load picture: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// go to previous day
  Future<void> gotoPrevious() async {
    if (!canGoPrevious) return;

    _currentDate = DateTime(
      _currentDate.year,
      _currentDate.month,
      _currentDate.day - 1,
    );
    await loadApod();
  }

  /// go to next day
  Future<void> gotoNext() async {
    if (!canGoNext) return;

    _currentDate = DateTime(
      _currentDate.year,
      _currentDate.month,
      _currentDate.day + 1,
    );
    await loadApod();
  }

  /// reload current apod
  Future<void> refresh() async {
    await loadApod();
  }

  /// go to latest available apod
  Future<void> gotoToday() async {
    _currentDate = latestAvailableDate;
    await loadApod();
  }
}

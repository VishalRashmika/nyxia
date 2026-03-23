import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/services/astronomy_events_service.dart';
import '../../../data/services/home_data_service.dart';
import '../../../data/services/user_events_service.dart';
import '../../../data/models/user_event.dart';
import 'dart:async';

class PlanTabViewModel extends ChangeNotifier {
  final AstronomyEventsService _astronomyService = AstronomyEventsService();
  final HomeDataService _homeDataService = HomeDataService();
  final UserEventsService _userEventsService = UserEventsService();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  int _selectedTabIndex = 0;

  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String? _errorMessage;

  List<EventModel> _allEvents = [];
  List<UserEvent> _myEvents = [];
  StreamSubscription<List<UserEvent>>? _eventsSubscription;

  Position? _currentPosition;

  // getters
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  int get selectedTabIndex => _selectedTabIndex;
  List<EventModel> get allEvents => _filteredAllEvents;
  List<UserEvent> get myEvents => _myEvents;

  bool get isLoading => _isLoading;
  bool get hasLoadedOnce => _hasLoadedOnce;
  String? get errorMessage => _errorMessage;

  // filter events by selected day
  List<EventModel> get _filteredAllEvents {
    if (_selectedDay == null) return _allEvents;
    return _allEvents.where((event) {
      return event.dateTime.year == _selectedDay!.year &&
          event.dateTime.month == _selectedDay!.month &&
          event.dateTime.day == _selectedDay!.day;
    }).toList();
  }

  List<UserEvent> get _filteredMyEvents {
    if (_selectedDay == null) return _myEvents;
    return _myEvents.where((event) {
      return event.dateTime.year == _selectedDay!.year &&
          event.dateTime.month == _selectedDay!.month &&
          event.dateTime.day == _selectedDay!.day;
    }).toList();
  }

  // events for calendar markers
  List<EventModel> getEventsForDay(DateTime day) {
    return _allEvents.where((event) {
      return event.dateTime.year == day.year &&
          event.dateTime.month == day.month &&
          event.dateTime.day == day.day;
    }).toList();
  }

  // methods
  Future<void> fetchEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // resolve location with fallback
      try {
        _currentPosition = await _homeDataService.getCurrentLocation();
      } catch (locationError) {
        _currentPosition = await Geolocator.getLastKnownPosition();
        debugPrint(
          'Location unavailable for events, using fallback: $locationError',
        );
      }

      final fallbackLat = _currentPosition?.latitude ?? 0.0;
      final fallbackLon = _currentPosition?.longitude ?? 0.0;

      // fetch events for current month
      final events = await _astronomyService.fetchAllEvents(
        _focusedDay,
        fallbackLat,
        fallbackLon,
      );

      // map service events to ui model
      _allEvents = events.map((event) {
        return EventModel(
          name: event.name,
          date: event.formattedDate,
          dateTime: event.date,
          probability: event.probability,
          icon: _getIconForEventType(event.type),
          description: event.description,
        );
      }).toList();

      // load user events
      await loadUserEvents();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching astronomy events: $e');
    } finally {
      _isLoading = false;
      _hasLoadedOnce = true;
      notifyListeners();
    }
  }

  /// load user events
  Future<void> loadUserEvents() async {
    try {
      _myEvents = await _userEventsService.getUserEvents();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user events: $e');
    }
  }

  /// listen to real-time user events
  void startListeningToUserEvents() {
    _eventsSubscription?.cancel();
    _eventsSubscription = _userEventsService.getUserEventsStream().listen(
      (events) {
        _myEvents = events;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error listening to user events: $error');
      },
    );
  }

  /// add user event
  Future<void> addUserEvent(UserEvent event) async {
    try {
      await _userEventsService.addEvent(event);
    } catch (e) {
      debugPrint('Error adding user event: $e');
      _errorMessage = 'Failed to add event: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// delete user event
  Future<void> deleteUserEvent(UserEvent event) async {
    if (event.id == null) return;

    try {
      await _userEventsService.deleteEvent(event.id!);
    } catch (e) {
      debugPrint('Error deleting user event: $e');
      _errorMessage = 'Failed to delete event: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// restore deleted event
  Future<void> restoreUserEvent(UserEvent event) async {
    try {
      await addUserEvent(event);
    } catch (e) {
      debugPrint('Error restoring user event: $e');
      rethrow;
    }
  }

  IconData _getIconForEventType(AstronomicalEventType type) {
    switch (type) {
      case AstronomicalEventType.meteorShower:
        return Icons.star_rate;
      case AstronomicalEventType.moonPhase:
        return Icons.nights_stay;
      case AstronomicalEventType.planetary:
        return Icons.public;
      case AstronomicalEventType.satellite:
        return Icons.satellite_alt;
      case AstronomicalEventType.asteroid:
        return Icons.circle_outlined;
      case AstronomicalEventType.eclipse:
        return Icons.brightness_2;
      default:
        return Icons.stars;
    }
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    notifyListeners();
  }

  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    // fetch events for new month
    fetchEvents();
    notifyListeners();
  }

  void selectDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  void setFocusedDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  /// initialize view model
  void initialize() {
    startListeningToUserEvents();
  }

  void addEvent() {}

  void addEventToMyEvents(EventModel event) {}

  void removeFromMyEvents(EventModel event) {}

  Future<void> refreshEvents() async {
    await fetchEvents();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }
}

class EventModel {
  final String name;
  final String date;
  final DateTime dateTime;
  final String probability;
  final IconData icon;
  final String description;

  EventModel({
    required this.name,
    required this.date,
    required this.dateTime,
    required this.probability,
    required this.icon,
    this.description = '',
  });

  // backward compatibility getter
  String get visibility => probability;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          dateTime == other.dateTime;

  @override
  int get hashCode => name.hashCode ^ dateTime.hashCode;
}

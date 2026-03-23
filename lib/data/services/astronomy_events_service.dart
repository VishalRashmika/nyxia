import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AstronomyEventsService {
  static const String _nasaApiBase = 'https://api.nasa.gov';

  String get _nasaApiKey => dotenv.env['NASA_API_KEY'] ?? 'DEMO_KEY';

  /// fetch near earth objects
  Future<List<AstronomicalEvent>> fetchNearEarthObjects(DateTime date) async {
    try {
      final startDate = _formatDate(date);
      final endDate = _formatDate(date.add(const Duration(days: 7)));

      final url = Uri.parse(
        '$_nasaApiBase/neo/rest/v1/feed?start_date=$startDate&end_date=$endDate&api_key=$_nasaApiKey',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final nearEarthObjects = data['near_earth_objects'] as Map;

        List<AstronomicalEvent> events = [];

        nearEarthObjects.forEach((dateKey, objects) {
          final objectsList = objects as List;
          for (var obj in objectsList.take(2)) {
            // keep top two per day
            final name = obj['name'] as String;
            final isPotentiallyHazardous =
                obj['is_potentially_hazardous_asteroid'] as bool;

            String probability = 'Safe';
            if (isPotentiallyHazardous) {
              probability = 'Monitor';
            }

            events.add(
              AstronomicalEvent(
                name: 'Asteroid: $name',
                date: DateTime.parse(dateKey),
                probability: probability,
                type: AstronomicalEventType.asteroid,
                description: isPotentiallyHazardous
                    ? 'Potentially hazardous asteroid'
                    : 'Near Earth asteroid pass',
              ),
            );
          }
        });

        return events;
      }
      return [];
    } on TimeoutException {
      print('NEO request timed out');
      return [];
    } catch (e) {
      print('Error fetching NEO data: $e');
      return [];
    }
  }

  /// calculate moon phases
  Future<List<AstronomicalEvent>> calculateMoonPhases(DateTime month) async {
    List<AstronomicalEvent> events = [];

    // approximate lunar cycle
    final knownNewMoon = DateTime(2000, 1, 6, 18, 14);
    final synodicMonth = 29.53058867;

    DateTime currentDate = month;
    final endDate = DateTime(month.year, month.month + 1, 0);

    while (currentDate.isBefore(endDate)) {
      final daysSince = currentDate.difference(knownNewMoon).inDays;
      final phase = (daysSince % synodicMonth) / synodicMonth;

      if ((phase < 0.03 || phase > 0.97)) {
        events.add(
          AstronomicalEvent(
            name: 'New Moon',
            date: currentDate,
            probability: '100%',
            type: AstronomicalEventType.moonPhase,
            description: 'Best time for deep sky observation',
          ),
        );
      } else if (phase > 0.22 && phase < 0.28) {
        events.add(
          AstronomicalEvent(
            name: 'First Quarter',
            date: currentDate,
            probability: '100%',
            type: AstronomicalEventType.moonPhase,
            description: 'Moon 50% illuminated',
          ),
        );
      } else if (phase > 0.47 && phase < 0.53) {
        events.add(
          AstronomicalEvent(
            name: 'Full Moon',
            date: currentDate,
            probability: '100%',
            type: AstronomicalEventType.moonPhase,
            description: 'Avoid for deep sky, great for lunar imaging',
          ),
        );
      } else if (phase > 0.72 && phase < 0.78) {
        events.add(
          AstronomicalEvent(
            name: 'Last Quarter',
            date: currentDate,
            probability: '100%',
            type: AstronomicalEventType.moonPhase,
            description: 'Moon 50% illuminated',
          ),
        );
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return events;
  }

  /// get meteor showers
  Future<List<AstronomicalEvent>> getMeteorShowers(DateTime date) async {
    // known shower peaks
    final meteorShowers = [
      {
        'name': 'Quadrantids',
        'month': 1,
        'day': 3,
        'rate': '120/hr',
        'probability': '92%',
      },
      {
        'name': 'Lyrids',
        'month': 4,
        'day': 22,
        'rate': '18/hr',
        'probability': '85%',
      },
      {
        'name': 'Eta Aquarids',
        'month': 5,
        'day': 6,
        'rate': '60/hr',
        'probability': '88%',
      },
      {
        'name': 'Perseids',
        'month': 8,
        'day': 12,
        'rate': '100/hr',
        'probability': '95%',
      },
      {
        'name': 'Orionids',
        'month': 10,
        'day': 21,
        'rate': '20/hr',
        'probability': '87%',
      },
      {
        'name': 'Leonids',
        'month': 11,
        'day': 17,
        'rate': '15/hr',
        'probability': '83%',
      },
      {
        'name': 'Geminids',
        'month': 12,
        'day': 14,
        'rate': '120/hr',
        'probability': '96%',
      },
    ];

    List<AstronomicalEvent> events = [];

    for (var shower in meteorShowers) {
      final showerDate = DateTime(
        date.year,
        shower['month'] as int,
        shower['day'] as int,
      );

      // include events in current month
      if (showerDate.month == date.month) {
        events.add(
          AstronomicalEvent(
            name: '${shower['name']} Meteor Shower',
            date: showerDate,
            probability: shower['probability'] as String,
            type: AstronomicalEventType.meteorShower,
            description: 'Peak: ${shower['rate']}',
          ),
        );
      }
    }

    return events;
  }

  /// get planetary events
  Future<List<AstronomicalEvent>> getPlanetaryEvents(DateTime date) async {
    // simplified event list
    List<AstronomicalEvent> events = [];

    // hardcoded examples
    final planetaryEvents = [
      {
        'name': 'Jupiter at Opposition',
        'month': 1,
        'day': 30,
        'probability': '100%',
      },
      {
        'name': 'Venus-Jupiter Conjunction',
        'month': 3,
        'day': 15,
        'probability': '98%',
      },
      {
        'name': 'Saturn at Opposition',
        'month': 7,
        'day': 4,
        'probability': '100%',
      },
      {
        'name': 'Mars-Venus Conjunction',
        'month': 9,
        'day': 22,
        'probability': '95%',
      },
    ];

    for (var event in planetaryEvents) {
      final eventDate = DateTime(
        date.year,
        event['month'] as int,
        event['day'] as int,
      );

      if (eventDate.month == date.month) {
        events.add(
          AstronomicalEvent(
            name: event['name'] as String,
            date: eventDate,
            probability: event['probability'] as String,
            type: AstronomicalEventType.planetary,
            description: 'Excellent viewing opportunity',
          ),
        );
      }
    }

    return events;
  }

  /// fetch all events
  Future<List<AstronomicalEvent>> fetchAllEvents(
    DateTime month,
    double lat,
    double lon,
  ) async {
    try {
      // fetch event groups in parallel
      final results = await Future.wait([
        getMeteorShowers(month),
        calculateMoonPhases(month),
        getPlanetaryEvents(month),
        fetchNearEarthObjects(month),
      ]);

      List<AstronomicalEvent> allEvents = [];
      for (var eventList in results) {
        allEvents.addAll(eventList);
      }

      // sort by date
      allEvents.sort((a, b) => a.date.compareTo(b.date));

      return allEvents;
    } catch (e) {
      print('Error fetching astronomical events: $e');
      return [];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

enum AstronomicalEventType {
  meteorShower,
  moonPhase,
  planetary,
  satellite,
  asteroid,
  eclipse,
  other,
}

class AstronomicalEvent {
  final String name;
  final DateTime date;
  final String probability;
  final AstronomicalEventType type;
  final String description;

  AstronomicalEvent({
    required this.name,
    required this.date,
    required this.probability,
    required this.type,
    required this.description,
  });

  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

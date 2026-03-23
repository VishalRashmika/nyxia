import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/data/services/astronomy_events_service.dart';

class FakeAstronomyEventsService extends AstronomyEventsService {
  @override
  Future<List<AstronomicalEvent>> fetchNearEarthObjects(DateTime date) async {
    return [
      AstronomicalEvent(
        name: 'Asteroid: test',
        date: DateTime(date.year, date.month, 5),
        probability: 'Safe',
        type: AstronomicalEventType.asteroid,
        description: 'test object',
      ),
    ];
  }
}

void main() {
  group('astronomy_events_service_tests', () {
    test('calculateMoonPhases returns moon phase events in month', () async {
      // this test verifies moon phase generation in a target month.
      final service = AstronomyEventsService();

      final events = await service.calculateMoonPhases(DateTime(2026, 1, 1));

      expect(events, isNotEmpty);
      expect(
        events.any((e) => e.type == AstronomicalEventType.moonPhase),
        isTrue,
      );
    });

    test('getMeteorShowers returns only events in selected month', () async {
      // this test verifies meteor shower filtering by month.
      final service = AstronomyEventsService();

      final events = await service.getMeteorShowers(DateTime(2026, 8, 1));

      expect(events, isNotEmpty);
      expect(events.every((e) => e.date.month == 8), isTrue);
      expect(
        events.any((e) => e.type == AstronomicalEventType.meteorShower),
        isTrue,
      );
    });

    test('getPlanetaryEvents returns month-matching events only', () async {
      // this test verifies planetary event month filtering.
      final service = AstronomyEventsService();

      final events = await service.getPlanetaryEvents(DateTime(2026, 3, 1));

      expect(events, isNotEmpty);
      expect(events.every((e) => e.date.month == 3), isTrue);
      expect(
        events.any((e) => e.type == AstronomicalEventType.planetary),
        isTrue,
      );
    });

    test('fetchAllEvents merges and sorts event lists', () async {
      // this test verifies aggregate fetching and chronological sorting.
      final service = FakeAstronomyEventsService();

      final events = await service.fetchAllEvents(
        DateTime(2026, 1, 1),
        0.0,
        0.0,
      );

      expect(events, isNotEmpty);
      for (int i = 1; i < events.length; i++) {
        expect(
          events[i - 1].date.isBefore(events[i].date) ||
              events[i - 1].date.isAtSameMomentAs(events[i].date),
          isTrue,
        );
      }
    });

    test('formattedDate returns expected short month format', () {
      // this test verifies event date label formatting.
      final event = AstronomicalEvent(
        name: 'sample',
        date: DateTime(2026, 12, 14),
        probability: '95%',
        type: AstronomicalEventType.meteorShower,
        description: 'test',
      );

      expect(event.formattedDate, 'Dec 14, 2026');
    });
  });
}

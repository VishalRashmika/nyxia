import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/data/models/user_event.dart';

void main() {
  group('user_event_tests', () {
    test('toMap serializes event data for firestore storage', () {
      // this test verifies event serialization to firestore map.
      final dateTime = DateTime(2026, 5, 1, 21, 0);
      final createdAt = DateTime(2026, 4, 1, 10, 0);
      final event = UserEvent(
        id: 'ev-1',
        userId: 'user-1',
        name: 'meteor shower',
        dateTime: dateTime,
        description: 'peak window',
        location: 'sigiriya',
        icon: Icons.event,
        createdAt: createdAt,
      );

      final map = event.toMap();

      expect(map['userId'], 'user-1');
      expect(map['name'], 'meteor shower');
      expect((map['dateTime'] as Timestamp).toDate(), dateTime);
      expect(map['description'], 'peak window');
      expect(map['location'], 'sigiriya');
      expect(map['iconCodePoint'], Icons.event.codePoint);
      expect((map['createdAt'] as Timestamp).toDate(), createdAt);
    });

    test('fromMap builds event object from valid firestore map', () {
      // this test verifies event parsing from firestore values.
      final map = <String, dynamic>{
        'userId': 'user-2',
        'name': 'moonrise',
        'dateTime': Timestamp.fromDate(DateTime(2026, 6, 2, 19, 15)),
        'description': 'near horizon',
        'location': 'kandy',
        'iconCodePoint': Icons.nightlight.codePoint,
        'createdAt': Timestamp.fromDate(DateTime(2026, 3, 1)),
      };

      final event = UserEvent.fromMap(map, 'ev-2');

      expect(event.id, 'ev-2');
      expect(event.userId, 'user-2');
      expect(event.name, 'moonrise');
      expect(event.description, 'near horizon');
      expect(event.location, 'kandy');
      expect(event.icon.codePoint, Icons.nightlight.codePoint);
      expect(event.createdAt, DateTime(2026, 3, 1));
    });

    test('copyWith updates selected fields and preserves others', () {
      // this test verifies copyWith behavior for user events.
      final original = UserEvent(
        id: 'ev-3',
        userId: 'user-3',
        name: 'session',
        dateTime: DateTime(2026, 7, 10, 22, 0),
        description: 'initial',
        location: 'jaffna',
        icon: Icons.star,
        createdAt: DateTime(2026, 1, 1),
      );

      final updated = original.copyWith(
        name: 'deep sky session',
        location: 'galle',
      );

      expect(updated.id, 'ev-3');
      expect(updated.userId, 'user-3');
      expect(updated.name, 'deep sky session');
      expect(updated.location, 'galle');
      expect(updated.description, 'initial');
      expect(updated.icon.codePoint, Icons.star.codePoint);
    });

    test('event equality matches by id value', () {
      // this test verifies custom equality compares id only.
      final a = UserEvent(
        id: 'same-id',
        userId: 'u1',
        name: 'a',
        dateTime: DateTime(2026, 1, 1),
        icon: Icons.event,
      );
      final b = UserEvent(
        id: 'same-id',
        userId: 'u2',
        name: 'b',
        dateTime: DateTime(2027, 1, 1),
        icon: Icons.alarm,
      );

      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
    });
  });
}

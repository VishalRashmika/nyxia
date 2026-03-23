import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/data/models/equipment.dart';

void main() {
  group('equipment_tests', () {
    test('toMap serializes equipment fields for firestore', () {
      // this test verifies equipment serialization to firestore map.
      final createdAt = DateTime(2026, 3, 21, 4, 30);
      final equipment = Equipment(
        id: 'eq-1',
        userId: 'user-1',
        name: 'Primary Scope',
        type: 'Telescope',
        icon: Icons.camera_alt,
        notes: 'good seeing',
        createdAt: createdAt,
      );

      final map = equipment.toMap();

      expect(map['userId'], 'user-1');
      expect(map['name'], 'Primary Scope');
      expect(map['type'], 'Telescope');
      expect(map['iconCodePoint'], Icons.camera_alt.codePoint);
      expect(map['iconFontFamily'], Icons.camera_alt.fontFamily);
      expect(map['notes'], 'good seeing');
      expect((map['createdAt'] as Timestamp).toDate(), createdAt);
    });

    test('fromMap parses icon and timestamp when values are valid', () {
      // this test verifies equipment parsing from a valid map.
      final createdAt = DateTime(2026, 1, 5);
      final map = <String, dynamic>{
        'userId': 'user-2',
        'name': 'Field Lens',
        'type': 'Lens',
        'iconCodePoint': Icons.lens.codePoint,
        'iconFontFamily': Icons.lens.fontFamily,
        'notes': 'fast lens',
        'createdAt': Timestamp.fromDate(createdAt),
      };

      final equipment = Equipment.fromMap('eq-2', map);

      expect(equipment.id, 'eq-2');
      expect(equipment.userId, 'user-2');
      expect(equipment.name, 'Field Lens');
      expect(equipment.type, 'Lens');
      expect(equipment.icon.codePoint, Icons.lens.codePoint);
      expect(equipment.notes, 'fast lens');
      expect(equipment.createdAt, createdAt);
    });

    test('fromMap falls back when icon and timestamp are missing', () {
      // this test verifies safe fallbacks for missing map fields.
      final map = <String, dynamic>{'userId': 'user-3'};

      final equipment = Equipment.fromMap('eq-3', map);

      expect(equipment.name, 'Unnamed Equipment');
      expect(equipment.type, 'Unknown Type');
      expect(equipment.icon.codePoint, Icons.camera.codePoint);
      expect(equipment.createdAt, isA<DateTime>());
    });

    test('copyWith updates only provided values', () {
      // this test verifies copyWith keeps unchanged values intact.
      final original = Equipment(
        id: 'eq-4',
        userId: 'user-4',
        name: 'Mount',
        type: 'Tracker',
        icon: Icons.settings,
        notes: 'portable',
        createdAt: DateTime(2025, 10, 1),
      );

      final updated = original.copyWith(name: 'Star Tracker', notes: 'stable');

      expect(updated.id, 'eq-4');
      expect(updated.userId, 'user-4');
      expect(updated.type, 'Tracker');
      expect(updated.name, 'Star Tracker');
      expect(updated.notes, 'stable');
      expect(updated.icon.codePoint, Icons.settings.codePoint);
    });
  });
}

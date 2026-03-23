import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// data model for equipment
class Equipment {
  final String id;
  final String userId;
  final String name;
  final String type;
  final IconData icon;
  final String? notes;
  final DateTime createdAt;

  Equipment({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.icon,
    this.notes,
    required this.createdAt,
  });

  /// map for firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// create from firestore map
  factory Equipment.fromMap(String id, Map<String, dynamic> map) {
    IconData equipmentIcon = Icons.camera;
    try {
      final codePoint = map['iconCodePoint'] as int?;
      final fontFamily = map['iconFontFamily'] as String?;
      if (codePoint != null) {
        equipmentIcon = IconData(codePoint, fontFamily: fontFamily);
      }
    } catch (_) {}

    DateTime createdAtDate = DateTime.now();
    try {
      final timestamp = map['createdAt'];
      if (timestamp is Timestamp) {
        createdAtDate = timestamp.toDate();
      }
    } catch (_) {}

    return Equipment(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? 'Unnamed Equipment',
      type: map['type'] ?? 'Unknown Type',
      icon: equipmentIcon,
      notes: map['notes'],
      createdAt: createdAtDate,
    );
  }

  Equipment copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    IconData? icon,
    String? notes,
    DateTime? createdAt,
  }) {
    return Equipment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

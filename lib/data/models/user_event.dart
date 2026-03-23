import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// data model for user event
class UserEvent {
  final String? id;
  final String userId;
  final String name;
  final DateTime dateTime;
  final String? description;
  final String? location;
  final IconData icon;
  final DateTime createdAt;

  UserEvent({
    this.id,
    required this.userId,
    required this.name,
    required this.dateTime,
    this.description,
    this.location,
    required this.icon,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// map for firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'dateTime': Timestamp.fromDate(dateTime),
      'description': description,
      'location': location,
      'iconCodePoint': icon.codePoint,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// create from firestore map
  factory UserEvent.fromMap(Map<String, dynamic> map, String documentId) {
    try {
      return UserEvent(
        id: documentId,
        userId: map['userId'] ?? '',
        name: map['name'] ?? '',
        dateTime: (map['dateTime'] as Timestamp).toDate(),
        description: map['description'],
        location: map['location'],
        icon: IconData(
          map['iconCodePoint'] ?? Icons.event.codePoint,
          fontFamily: 'MaterialIcons',
        ),
        createdAt: map['createdAt'] != null
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
    } catch (_) {
      rethrow;
    }
  }

  /// copy with updates
  UserEvent copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? dateTime,
    String? description,
    String? location,
    IconData? icon,
    DateTime? createdAt,
  }) {
    return UserEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dateTime: dateTime ?? this.dateTime,
      description: description ?? this.description,
      location: location ?? this.location,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEvent && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_event.dart';

/// service for user events
class UserEventsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// user events collection
  CollectionReference get _userEventsCollection =>
      _firestore.collection('user_events');

  /// current user id
  String? get _currentUserId => _auth.currentUser?.uid;

  /// stream user events
  Stream<List<UserEvent>> getUserEventsStream() {
    final userId = _currentUserId;

    if (userId == null) {
      print('No user logged in for events stream');
      return Stream.value([]);
    }

    return _userEventsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs.map((doc) {
            return UserEvent.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          // sort in memory instead of firestore query
          events.sort((a, b) => a.dateTime.compareTo(b.dateTime));

          print('Returning ${events.length} events from stream');

          return events;
        });
  }

  /// get user events
  Future<List<UserEvent>> getUserEvents() async {
    final userId = _currentUserId;

    if (userId == null) {
      print('No user logged in for events fetch');
      return [];
    }

    try {
      final snapshot = await _userEventsCollection
          .where('userId', isEqualTo: userId)
          .get();

      final events = snapshot.docs.map((doc) {
        return UserEvent.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // sort in memory
      events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      print('Returning ${events.length} events');

      return events;
    } catch (e) {
      print('Error fetching user events: $e');
      return [];
    }
  }

  /// add event
  Future<String?> addEvent(UserEvent event) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User must be logged in to add events');
    }

    try {
      final eventWithUserId = event.copyWith(userId: userId);
      final docRef = await _userEventsCollection.add(eventWithUserId.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding event: $e');
      rethrow;
    }
  }

  /// update event
  Future<void> updateEvent(UserEvent event) async {
    if (event.id == null) {
      throw Exception('Event ID is required for update');
    }

    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User must be logged in to update events');
    }

    try {
      await _userEventsCollection.doc(event.id).update(event.toMap());
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  /// delete event
  Future<void> deleteEvent(String eventId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User must be logged in to delete events');
    }

    try {
      await _userEventsCollection.doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  /// get events in range
  Future<List<UserEvent>> getEventsInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final userId = _currentUserId;
    if (userId == null) {
      return [];
    }

    try {
      final snapshot = await _userEventsCollection
          .where('userId', isEqualTo: userId)
          .where(
            'dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final events = snapshot.docs.map((doc) {
        return UserEvent.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // sort in memory to avoid composite index
      events.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      return events;
    } catch (e) {
      print('Error fetching events in range: $e');
      return [];
    }
  }
}

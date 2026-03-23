import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/equipment.dart';

/// service for user equipment
class EquipmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// equipment collection
  CollectionReference get _equipmentCollection =>
      _firestore.collection('equipment');

  /// current user id
  String? get _userId => _auth.currentUser?.uid;

  /// stream user equipment
  Stream<List<Equipment>> getUserEquipmentStream() {
    if (_userId == null) {
      print('No user logged in for equipment stream');
      return Stream.value([]);
    }

    return _equipmentCollection
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
          final equipment = snapshot.docs.map((doc) {
            return Equipment.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();

          // sort in memory to avoid composite index
          equipment.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          print('Loaded ${equipment.length} equipment items');
          return equipment;
        });
  }

  /// fix empty user ids
  Future<void> fixEquipmentUserId() async {
    if (_userId == null) {
      throw Exception('User must be logged in');
    }

    try {
      final snapshot = await _equipmentCollection
          .where('userId', isEqualTo: '')
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'userId': _userId});
      }

      print('Equipment user id migration complete');
    } catch (e) {
      print('Error fixing equipment: $e');
      rethrow;
    }
  }

  /// add equipment
  Future<void> addEquipment(Equipment equipment) async {
    if (_userId == null) {
      throw Exception('User must be logged in to add equipment');
    }

    try {
      final equipmentWithUserId = equipment.copyWith(userId: _userId);
      await _equipmentCollection.add(equipmentWithUserId.toMap());
    } catch (e) {
      print('Error adding equipment: $e');
      rethrow;
    }
  }

  /// update equipment
  Future<void> updateEquipment(Equipment equipment) async {
    if (_userId == null) {
      throw Exception('User must be logged in to update equipment');
    }

    try {
      await _equipmentCollection.doc(equipment.id).update(equipment.toMap());
    } catch (e) {
      print('Error updating equipment: $e');
      rethrow;
    }
  }

  /// delete equipment
  Future<void> deleteEquipment(String equipmentId) async {
    if (_userId == null) {
      throw Exception('User must be logged in to delete equipment');
    }

    try {
      await _equipmentCollection.doc(equipmentId).delete();
    } catch (e) {
      print('Error deleting equipment: $e');
      rethrow;
    }
  }

  /// get user equipment
  Future<List<Equipment>> getUserEquipment() async {
    if (_userId == null) {
      print('No user logged in for equipment fetch');
      return [];
    }

    try {
      final snapshot = await _equipmentCollection
          .where('userId', isEqualTo: _userId)
          .get();

      final equipment = snapshot.docs.map((doc) {
        return Equipment.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      // sort in memory to avoid composite index
      equipment.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('Fetched ${equipment.length} equipment items');
      return equipment;
    } catch (e) {
      print('Error fetching equipment: $e');
      return [];
    }
  }
}

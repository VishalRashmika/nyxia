import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/equipment.dart';
import '../../../data/services/equipment_service.dart';

/// view model for user equipment
class EquipmentViewModel extends ChangeNotifier {
  final EquipmentService _equipmentService = EquipmentService();

  List<Equipment> _equipment = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Equipment>>? _equipmentSubscription;

  // recently deleted equipment for undo
  Equipment? _recentlyDeletedEquipment;

  List<Equipment> get equipment => _equipment;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasEquipment => _equipment.isNotEmpty;

  /// start listening to equipment changes
  void startListeningToEquipment() {
    _equipmentSubscription?.cancel();

    _equipmentSubscription = _equipmentService.getUserEquipmentStream().listen(
      (equipmentList) {
        _equipment = equipmentList;
        _isLoading = false;
        _error = null;
        notifyListeners();

        // fix missing user ids on first load
        if (equipmentList.isEmpty) {
          _fixEmptyUserIds();
        }
      },
      onError: (error) {
        debugPrint('Error listening to equipment: $error');
        _error = 'Failed to load equipment';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// fix equipment with empty user id
  Future<void> _fixEmptyUserIds() async {
    try {
      await _equipmentService.fixEquipmentUserId();
    } catch (e) {
      debugPrint('Error fixing equipment userId: $e');
    }
  }

  /// stop listening to equipment changes
  void stopListeningToEquipment() {
    _equipmentSubscription?.cancel();
    _equipmentSubscription = null;
  }

  /// add equipment
  Future<void> addEquipment({
    required String name,
    required String type,
    required IconData icon,
    String? notes,
  }) async {
    try {
      _error = null;
      notifyListeners();

      final newEquipment = Equipment(
        id: '',
        userId: '',
        name: name,
        type: type,
        icon: icon,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await _equipmentService.addEquipment(newEquipment);
    } catch (e) {
      debugPrint('Error adding equipment: $e');
      _error = 'Failed to add equipment';
      notifyListeners();
      rethrow;
    }
  }

  /// update equipment
  Future<void> updateEquipment(Equipment equipment) async {
    try {
      _error = null;
      notifyListeners();

      await _equipmentService.updateEquipment(equipment);
    } catch (e) {
      debugPrint('Error updating equipment: $e');
      _error = 'Failed to update equipment';
      notifyListeners();
      rethrow;
    }
  }

  /// delete equipment
  Future<void> deleteEquipment(Equipment equipment) async {
    try {
      _error = null;
      _recentlyDeletedEquipment = equipment;
      notifyListeners();

      await _equipmentService.deleteEquipment(equipment.id);
    } catch (e) {
      debugPrint('Error deleting equipment: $e');
      _error = 'Failed to delete equipment';
      _recentlyDeletedEquipment = null;
      notifyListeners();
      rethrow;
    }
  }

  /// undo last deletion
  Future<void> undoDelete() async {
    if (_recentlyDeletedEquipment == null) return;

    try {
      await _equipmentService.addEquipment(_recentlyDeletedEquipment!);
      _recentlyDeletedEquipment = null;
    } catch (e) {
      debugPrint('Error restoring equipment: $e');
      _error = 'Failed to restore equipment';
      notifyListeners();
    }
  }

  /// clear recently deleted equipment
  void clearRecentlyDeleted() {
    _recentlyDeletedEquipment = null;
  }

  /// refresh equipment list
  Future<void> refreshEquipment() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final equipmentList = await _equipmentService.getUserEquipment();
      _equipment = equipmentList;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing equipment: $e');
      _error = 'Failed to refresh equipment';
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopListeningToEquipment();
    super.dispose();
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/auth_service/auth_service.dart';

class YouTabViewModel extends ChangeNotifier {
  final AuthService _authService;

  YouTabViewModel(this._authService);

  // Getters
  User? get currentUser => _authService.currentUser;
  String get userName => currentUser?.displayName ?? 'User';
  String get userEmail => currentUser?.email ?? 'No email';
  String? get userPhotoUrl => currentUser?.photoURL;
  bool get hasProfilePhoto => userPhotoUrl != null && userPhotoUrl!.isNotEmpty;

  // Methods

  String getThemeName(String themeMode) {
    switch (themeMode) {
      case 'light':
        return 'Light Mode';
      case 'dark':
        return 'Dark Mode';
      case 'night':
        return 'Night Mode';
      default:
        return 'Light Mode';
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      await _authService.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }
}

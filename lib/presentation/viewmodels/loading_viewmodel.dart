import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_service/auth_service.dart';

enum LoadingState { initializing, loading, completed, navigating }

class LoadingViewModel extends ChangeNotifier {
  final AuthService _authService;

  LoadingViewModel(this._authService);

  // state
  LoadingState _state = LoadingState.initializing;
  double _progress = 0.0;

  // getters
  LoadingState get state => _state;
  double get progress => _progress;
  bool get isLoading => _state == LoadingState.loading;
  bool get isCompleted => _state == LoadingState.completed;

  /// initialize app and complete progress with work completion
  Future<NavigationTarget> initializeAndPrepareApp({
    required Future<void> Function() preloadHomeData,
  }) async {
    _state = LoadingState.loading;
    _progress = 0.0;
    notifyListeners();

    // early boot progress
    await _animateProgressTo(0.2, const Duration(milliseconds: 350));

    final target = await _resolveNavigationTarget();

    _state = LoadingState.navigating;
    notifyListeners();

    await _animateProgressTo(0.35, const Duration(milliseconds: 220));

    if (target == NavigationTarget.home) {
      await _runPreloadWithProgress(preloadHomeData);
    } else {
      await _animateProgressTo(0.85, const Duration(milliseconds: 250));
    }

    // complete progress when required work finishes
    await _animateProgressTo(1.0, const Duration(milliseconds: 240));

    _state = LoadingState.completed;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 120));
    return target;
  }

  Future<void> _animateProgressTo(double target, Duration duration) async {
    if (_progress >= target) return;

    const tickMs = 30;
    final ticks = (duration.inMilliseconds / tickMs).clamp(1, 1000).round();
    final start = _progress;

    for (int i = 1; i <= ticks; i++) {
      final t = i / ticks;
      _progress = start + (target - start) * t;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: tickMs));
    }
  }

  Future<void> _runPreloadWithProgress(
    Future<void> Function() preloadHomeData,
  ) async {
    var finished = false;

    preloadHomeData()
        .catchError((error) {
          debugPrint('Home preload failed: $error');
        })
        .whenComplete(() {
          finished = true;
        });

    while (!finished) {
      await Future.delayed(const Duration(milliseconds: 110));
      final next = (_progress + 0.02).clamp(0.0, 0.92);
      if (next > _progress) {
        _progress = next;
        notifyListeners();
      }
    }
  }

  /// resolve initial navigation target
  Future<NavigationTarget> _resolveNavigationTarget() async {
    // wait briefly for auth initialization
    await Future.delayed(const Duration(milliseconds: 100));

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return NavigationTarget.home;
    } else {
      return NavigationTarget.welcome;
    }
  }

  // backward compatible wrapper
  Future<NavigationTarget> getNavigationTarget() async {
    return _resolveNavigationTarget();
  }

  /// get current user
  User? getCurrentUser() {
    return _authService.currentUser;
  }
}

/// navigation target enum
enum NavigationTarget { home, welcome }

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/network_checker.dart';
// import '../network/network_checker.dart';

final appLifecycleProvider = StateNotifierProvider<AppLifecycleNotifier, AppLifecycleState>((ref) {
  return AppLifecycleNotifier(ref);
});

class AppLifecycleState {
  final bool isOnline;
  final bool isBackendConnected;
  final String? lastError;

  const AppLifecycleState({
    this.isOnline = true,
    this.isBackendConnected = false,
    this.lastError,
  });

  AppLifecycleState copyWith({
    bool? isOnline,
    bool? isBackendConnected,
    String? lastError,
  }) {
    return AppLifecycleState(
      isOnline: isOnline ?? this.isOnline,
      isBackendConnected: isBackendConnected ?? this.isBackendConnected,
      lastError: lastError,
    );
  }
}

class AppLifecycleNotifier extends StateNotifier<AppLifecycleState> {
  final Ref ref;

  AppLifecycleNotifier(this.ref) : super(const AppLifecycleState()) {
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    try {
      final isBackendConnected = await NetworkChecker.checkBackendConnection();
      state = state.copyWith(
        isOnline: true,
        isBackendConnected: isBackendConnected,
      );

      if (!isBackendConnected && kDebugMode) {
        print('⚠️  Backend is not reachable. Check your server configuration.');
      }
    } catch (e) {
      state = state.copyWith(
        isOnline: false,
        isBackendConnected: false,
        lastError: e.toString(),
      );
    }
  }

  Future<void> retryConnection() async {
    await _checkConnectivity();
  }
}

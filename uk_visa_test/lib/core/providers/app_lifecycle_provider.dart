import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/network_checker.dart';

final appLifecycleProvider = StateNotifierProvider<AppLifecycleNotifier, AppLifecycleState>(AppLifecycleNotifier.new);

class AppLifecycleState {

  const AppLifecycleState({
    this.isOnline = true,
    this.isBackendConnected = false,
    this.lastError,
  });
  final bool isOnline;
  final bool isBackendConnected;
  final String? lastError;

  AppLifecycleState copyWith({
    bool? isOnline,
    bool? isBackendConnected,
    String? lastError,
  }) => AppLifecycleState(
      isOnline: isOnline ?? this.isOnline,
      isBackendConnected: isBackendConnected ?? this.isBackendConnected,
      lastError: lastError,
    );
}

class AppLifecycleNotifier extends StateNotifier<AppLifecycleState> {

  AppLifecycleNotifier(this.ref) : super(const AppLifecycleState()) {
    _checkConnectivity();
  }
  final Ref ref;

  Future<void> _checkConnectivity() async {
    try {
      final isBackendConnected = await NetworkChecker.checkBackendConnection();
      state = state.copyWith(
        isOnline: true,
        isBackendConnected: isBackendConnected,
      );
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

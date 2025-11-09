import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketly/core/enums/app_mode.dart';

class AppState {
  final AppMode mode;
  final bool canSync;
  final DateTime? lastSyncTime;
  final int pendingSyncCount;
  final bool isAuthenticated;
  final int failedSyncCount;
  final bool isSyncing;
  final String? lastSyncError;

  AppState({
    required this.mode,
    required this.canSync,
    this.lastSyncTime,
    this.pendingSyncCount = 0,
    required this.isAuthenticated,
    this.failedSyncCount = 0,
    this.isSyncing = false,
    this.lastSyncError,
  });

  AppState copyWith({
    AppMode? mode,
    bool? canSync,
    DateTime? lastSyncTime,
    int? pendingSyncCount,
    bool? isAuthenticated,
    int? failedSyncCount,
    bool? isSyncing,
    String? lastSyncError,
  }) {
    return AppState(
      mode: mode ?? this.mode,
      canSync: canSync ?? this.canSync,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      failedSyncCount: failedSyncCount ?? this.failedSyncCount,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncError: lastSyncError ?? this.lastSyncError,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier()
    : super(
        AppState(
          mode: AppMode.localMode,
          canSync: false,
          isAuthenticated: false,
        ),
      );

  void setOnlineMode() {
    state = state.copyWith(
      mode: AppMode.online,
      canSync: true,
      isAuthenticated: true,
    );
  }

  void setOfflineMode() {
    state = state.copyWith(mode: AppMode.offline, canSync: false);
  }

  void setLocalMode() {
    state = state.copyWith(
      mode: AppMode.localMode,
      canSync: false,
      isAuthenticated: false,
    );
  }

  void updateLastSyncTime(DateTime time) {
    state = state.copyWith(lastSyncTime: time);
  }

  void updatePendingSyncCount(int count) {
    state = state.copyWith(pendingSyncCount: count);
  }

  void updateFailedSyncCount(int count) {
    state = state.copyWith(failedSyncCount: count);
  }

  void setSyncing(bool isSyncing) {
    state = state.copyWith(isSyncing: isSyncing);
  }

  void setLastSyncError(String? error) {
    state = state.copyWith(lastSyncError: error);
  }

  void updateSyncState({
    DateTime? lastSyncTime,
    int? pendingSyncCount,
    int? failedSyncCount,
    bool? isSyncing,
    String? lastSyncError,
  }) {
    state = state.copyWith(
      lastSyncTime: lastSyncTime,
      pendingSyncCount: pendingSyncCount,
      failedSyncCount: failedSyncCount,
      isSyncing: isSyncing,
      lastSyncError: lastSyncError,
    );
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  return AppStateNotifier();
});

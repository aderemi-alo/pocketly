import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketly/core/enums/app_mode.dart';

class AppState {
  final AppMode mode;
  final bool canSync;
  final DateTime? lastSyncTime;
  final int pendingSyncCount;
  final bool isAuthenticated;

  AppState({
    required this.mode,
    required this.canSync,
    this.lastSyncTime,
    this.pendingSyncCount = 0,
    required this.isAuthenticated,
  });

  AppState copyWith({
    AppMode? mode,
    bool? canSync,
    DateTime? lastSyncTime,
    int? pendingSyncCount,
    bool? isAuthenticated,
  }) {
    return AppState(
      mode: mode ?? this.mode,
      canSync: canSync ?? this.canSync,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
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
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  return AppStateNotifier();
});

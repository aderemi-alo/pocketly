import 'package:pocketly/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final SharedPreferences _prefs;
  static const String _lastSyncTimeKey = 'last_sync_time';

  AppStateNotifier(this._prefs)
    : super(
        AppState(
          mode: AppMode.localMode,
          canSync: false,
          isAuthenticated: false,
          lastSyncTime: _loadLastSyncTime(_prefs),
        ),
      );

  static DateTime? _loadLastSyncTime(SharedPreferences prefs) {
    final timestamp = prefs.getInt(_lastSyncTimeKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<void> _saveLastSyncTime(DateTime? time) async {
    if (time == null) {
      await _prefs.remove(_lastSyncTimeKey);
    } else {
      await _prefs.setInt(_lastSyncTimeKey, time.millisecondsSinceEpoch);
    }
  }

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

  Future<void> updateLastSyncTime(DateTime? time) async {
    await _saveLastSyncTime(time);
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
  return AppStateNotifier(locator<SharedPreferences>());
});

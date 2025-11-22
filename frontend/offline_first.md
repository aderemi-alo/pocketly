# Offline-First Authentication Guide for Pocketly
## Simple Implementation Guide

---

## Core Principle

**Local data should ALWAYS be accessible, regardless of authentication status.**

Authentication only controls cloud sync features, never local features.

---

## Step 1: Define App Modes

Create an enum to track what mode the app is in:

```dart
// lib/core/enums/app_mode.dart

enum AppMode {
  /// User is authenticated and online - full access
  online,
  
  /// User is offline but was previously authenticated
  offline,
  
  /// User's auth expired or logged out - local access only
  localMode,
}
```

---

## Step 2: Create App State Provider

Manage authentication state across the app:

```dart
// lib/core/providers/app_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      : super(AppState(
          mode: AppMode.localMode,
          canSync: false,
          isAuthenticated: false,
        ));

  void setOnlineMode() {
    state = state.copyWith(
      mode: AppMode.online,
      canSync: true,
      isAuthenticated: true,
    );
  }

  void setOfflineMode() {
    state = state.copyWith(
      mode: AppMode.offline,
      canSync: false,
    );
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

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});
```

---

## Step 3: Modify Authentication Check

**BEFORE (Your current approach - BAD):**
```dart
void checkAuth() async {
  final isValid = await validateToken();
  
  if (!isValid) {
    // ❌ This kicks user out completely
    Navigator.pushReplacementNamed(context, '/login');
  }
}
```

**AFTER (Recommended approach - GOOD):**
```dart
// lib/core/services/auth_service.dart

class AuthService {
  final Ref ref;
  
  AuthService(this.ref);

  Future<void> checkAuthOnAppStart() async {
    // Step 1: ALWAYS load local data first
    await _loadLocalData();
    
    // Step 2: Check auth status in background
    try {
      final hasValidToken = await _validateAccessToken();
      
      if (hasValidToken) {
        // User is authenticated - enable sync
        ref.read(appStateProvider.notifier).setOnlineMode();
        await _attemptSync();
      } else {
        // Try to refresh token
        final refreshed = await _attemptTokenRefresh();
        
        if (refreshed) {
          ref.read(appStateProvider.notifier).setOnlineMode();
          await _attemptSync();
        } else {
          // Can't refresh - switch to local mode
          ref.read(appStateProvider.notifier).setLocalMode();
          _showLocalModeNotification();
        }
      }
    } catch (e) {
      // Network error or other issue
      ref.read(appStateProvider.notifier).setOfflineMode();
    }
  }

  Future<void> _loadLocalData() async {
    // Load expenses from Hive
    // This ALWAYS happens, regardless of auth
    final expenses = await HiveService.getAllExpenses();
    ref.read(expensesProvider.notifier).setExpenses(expenses);
  }

  Future<bool> _validateAccessToken() async {
    // Check if access token is valid
    final token = await _getStoredAccessToken();
    if (token == null) return false;
    
    final expiresAt = await _getTokenExpiryTime();
    if (expiresAt == null) return false;
    
    return DateTime.now().isBefore(expiresAt);
  }

  Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshToken = await _getStoredRefreshToken();
      if (refreshToken == null) return false;
      
      // Call your auth API to refresh
      final newTokens = await _refreshTokenAPI(refreshToken);
      
      if (newTokens != null) {
        await _storeTokens(newTokens);
        return true;
      }
      
      return false;
    } catch (e) {
      // Network error or refresh failed
      return false;
    }
  }

  Future<void> _attemptSync() async {
    try {
      // Sync pending local changes to cloud
      await SyncService.syncPendingChanges();
      
      ref.read(appStateProvider.notifier).updateLastSyncTime(DateTime.now());
    } catch (e) {
      // Sync failed, but app still works locally
      print('Sync failed: $e');
    }
  }

  void _showLocalModeNotification() {
    // Show non-blocking banner/snackbar
    // Don't use dialog or force navigation
  }
}
```

---

## Step 4: Update Main App Entry

```dart
// lib/main.dart

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: AppInitializer(),
    );
  }
}

class AppInitializer extends ConsumerStatefulWidget {
  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize Hive
    await HiveService.init();
    
    // Check auth (non-blocking)
    final authService = AuthService(ref);
    await authService.checkAuthOnAppStart();
    
    // Navigate to dashboard regardless of auth status
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

---

## Step 5: Add Local Mode Banner

Create a widget to show when in local mode:

```dart
// lib/widgets/local_mode_banner.dart

class LocalModeBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    
    // Only show in local mode
    if (appState.mode != AppMode.localMode) {
      return SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(Icons.offline_bolt, color: Colors.orange.shade700),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Offline Mode - Sign in to sync',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: Text('Sign In'),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 20),
            onPressed: () {
              // Dismiss banner (store preference)
            },
          ),
        ],
      ),
    );
  }
}
```

Add to your dashboard:

```dart
// lib/screens/dashboard_screen.dart

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          LocalModeBanner(), // Add this
          Expanded(
            child: YourDashboardContent(),
          ),
        ],
      ),
    );
  }
}
```

---

## Step 6: Gate Cloud Features

Only block cloud-specific features:

```dart
// lib/widgets/sync_button.dart

class SyncButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    
    return IconButton(
      icon: Icon(
        appState.canSync ? Icons.cloud_sync : Icons.cloud_off,
      ),
      onPressed: appState.canSync
          ? () async {
              // Sync is available
              await SyncService.syncNow();
            }
          : () {
              // Show login prompt
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Sign in to Sync'),
                  content: Text(
                    'Sign in to sync your expenses across devices.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Maybe Later'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text('Sign In'),
                    ),
                  ],
                ),
              );
            },
    );
  }
}
```

---

## Step 7: Update Expense Operations

Ensure all CRUD operations work regardless of auth:

```dart
// lib/services/expense_service.dart

class ExpenseService {
  final Ref ref;
  
  ExpenseService(this.ref);

  Future<void> addExpense(Expense expense) async {
    // Step 1: ALWAYS save locally (this never fails due to auth)
    await HiveService.saveExpense(expense);
    
    // Step 2: Update local state immediately
    ref.read(expensesProvider.notifier).addExpense(expense);
    
    // Step 3: Try to sync if authenticated
    final appState = ref.read(appStateProvider);
    
    if (appState.canSync) {
      try {
        await SyncService.syncExpenseToCloud(expense);
      } catch (e) {
        // Sync failed - add to queue
        await SyncQueue.addPendingSync(expense);
        ref.read(appStateProvider.notifier).updatePendingSyncCount(
          await SyncQueue.getPendingCount(),
        );
      }
    } else {
      // Not authenticated - add to queue for later
      await SyncQueue.addPendingSync(expense);
      ref.read(appStateProvider.notifier).updatePendingSyncCount(
        await SyncQueue.getPendingCount(),
      );
    }
  }

  // Same pattern for update and delete
  Future<void> updateExpense(Expense expense) async {
    await HiveService.updateExpense(expense);
    ref.read(expensesProvider.notifier).updateExpense(expense);
    
    if (ref.read(appStateProvider).canSync) {
      try {
        await SyncService.updateExpenseInCloud(expense);
      } catch (e) {
        await SyncQueue.addPendingUpdate(expense);
      }
    } else {
      await SyncQueue.addPendingUpdate(expense);
    }
  }

  Future<void> deleteExpense(String id) async {
    await HiveService.deleteExpense(id);
    ref.read(expensesProvider.notifier).deleteExpense(id);
    
    if (ref.read(appStateProvider).canSync) {
      try {
        await SyncService.deleteExpenseFromCloud(id);
      } catch (e) {
        await SyncQueue.addPendingDelete(id);
      }
    } else {
      await SyncQueue.addPendingDelete(id);
    }
  }
}
```

---

## Step 8: Sync Queue for Pending Changes

```dart
// lib/services/sync_queue.dart

class SyncQueue {
  static const String _queueBox = 'sync_queue';

  static Future<void> addPendingSync(Expense expense) async {
    final box = await Hive.openBox(_queueBox);
    await box.add({
      'type': 'create',
      'expense': expense.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> addPendingUpdate(Expense expense) async {
    final box = await Hive.openBox(_queueBox);
    await box.add({
      'type': 'update',
      'expense': expense.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> addPendingDelete(String id) async {
    final box = await Hive.openBox(_queueBox);
    await box.add({
      'type': 'delete',
      'expenseId': id,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<int> getPendingCount() async {
    final box = await Hive.openBox(_queueBox);
    return box.length;
  }

  static Future<void> processPendingQueue() async {
    final box = await Hive.openBox(_queueBox);
    
    for (var i = 0; i < box.length; i++) {
      final item = box.getAt(i);
      
      try {
        switch (item['type']) {
          case 'create':
            await SyncService.syncExpenseToCloud(
              Expense.fromJson(item['expense']),
            );
            break;
          case 'update':
            await SyncService.updateExpenseInCloud(
              Expense.fromJson(item['expense']),
            );
            break;
          case 'delete':
            await SyncService.deleteExpenseFromCloud(item['expenseId']);
            break;
        }
        
        // Success - remove from queue
        await box.deleteAt(i);
        i--; // Adjust index after deletion
      } catch (e) {
        // Failed - keep in queue for next sync attempt
        print('Sync failed for item: $e');
      }
    }
  }
}
```

---

## Step 9: Login Flow Updates

When user logs in, process pending syncs:

```dart
// lib/screens/login_screen.dart

Future<void> _handleLogin() async {
  try {
    // Perform login
    final tokens = await AuthAPI.login(email, password);
    
    // Store tokens
    await TokenStorage.storeTokens(tokens);
    
    // Update app state
    ref.read(appStateProvider.notifier).setOnlineMode();
    
    // Process pending syncs
    await SyncQueue.processPendingQueue();
    
    // Update sync count
    final pendingCount = await SyncQueue.getPendingCount();
    ref.read(appStateProvider.notifier).updatePendingSyncCount(pendingCount);
    
    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signed in and synced successfully!')),
    );
    
    // Navigate back
    Navigator.pop(context);
  } catch (e) {
    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: $e')),
    );
  }
}
```

---

## Step 10: Status Indicators

Show sync status in your UI:

```dart
// lib/widgets/sync_status_indicator.dart

class SyncStatusIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    
    String statusText;
    IconData statusIcon;
    Color statusColor;
    
    switch (appState.mode) {
      case AppMode.online:
        if (appState.lastSyncTime != null) {
          final timeAgo = _getTimeAgo(appState.lastSyncTime!);
          statusText = 'Synced $timeAgo';
        } else {
          statusText = 'Synced';
        }
        statusIcon = Icons.cloud_done;
        statusColor = Colors.green;
        break;
        
      case AppMode.offline:
        if (appState.pendingSyncCount > 0) {
          statusText = '${appState.pendingSyncCount} pending';
        } else {
          statusText = 'Offline';
        }
        statusIcon = Icons.cloud_off;
        statusColor = Colors.grey;
        break;
        
      case AppMode.localMode:
        if (appState.pendingSyncCount > 0) {
          statusText = '${appState.pendingSyncCount} pending sync';
        } else {
          statusText = 'Local only';
        }
        statusIcon = Icons.cloud_queue;
        statusColor = Colors.orange;
        break;
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(statusIcon, size: 16, color: statusColor),
        SizedBox(width: 4),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 12,
            color: statusColor,
          ),
        ),
      ],
    );
  }
  
  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
```

---

## Quick Reference: What Changes

### ❌ Remove (Bad Patterns)
```dart
// Don't do this anymore
if (!authenticated) {
  Navigator.pushReplacementNamed(context, '/login');
}

// Don't block local operations
if (!hasValidToken) {
  throw Exception('Please login');
}
```

### ✅ Add (Good Patterns)
```dart
// Always load local data first
await loadLocalData();

// Check auth in background
await checkAuthStatus();

// Gate only cloud features
if (canSync) {
  await syncToCloud();
} else {
  await addToSyncQueue();
}

// Show non-blocking indicators
if (inLocalMode) {
  showBanner('Sign in to sync');
}
```

---

## Testing Checklist

- [ ] Open app with expired tokens → Shows local data
- [ ] Add expense offline → Saves locally, adds to queue
- [ ] Login after offline period → Syncs all pending changes
- [ ] Be offline for 7 days → App still fully functional
- [ ] Token expires during use → Switch to local mode gracefully
- [ ] Poor network → Doesn't repeatedly prompt login
- [ ] View analytics offline → Shows local data correctly
- [ ] Export CSV offline → Works without auth

---

## Summary

**The Golden Rule:**
> Authentication controls sync, not access to user's own data.

**User Experience:**
- App opens instantly with local data
- All features work offline
- Sync happens automatically when authenticated
- Gentle, non-blocking prompts for login
- No data loss, ever

**Technical Implementation:**
1. Define app modes (online/offline/local)
2. Always load local data first
3. Check auth in background
4. Queue syncs when not authenticated
5. Process queue when user logs in
6. Show status indicators
7. Never block local operations

This approach makes Pocketly perfect for African markets while maintaining security and good UX!
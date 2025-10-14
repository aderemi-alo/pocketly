# Frontend API Integration Summary

## ✅ Implementation Complete

This document outlines the changes made to integrate the frontend with the new backend API.

---

## 📦 New Dependencies Added

```yaml
dependencies:
  dio: ^5.4.0                        # HTTP client with interceptors
  flutter_secure_storage: ^9.0.0    # Secure token storage
  device_info_plus: ^10.0.0          # Device ID generation
  connectivity_plus: ^5.0.2          # Network connectivity monitoring
  uuid: ^4.3.3                       # UUID generation for sync queue
```

---

## 🏗️ New Architecture Components

### 1. Core Models (`lib/core/models/`)
- **UserModel**: User data model with JSON serialization
- **AuthResponse**: Authentication response wrapper

### 2. API Models (`lib/features/expenses/data/models/`)
- **CategoryApiModel**: Category API model with domain conversion
- **ExpenseApiModel**: Expense API model with JSON serialization
- **ExpenseStatsModel**: Statistics model from backend

### 3. Core Services (`lib/core/services/`)

#### **TokenStorageService**
- Secure storage for JWT tokens (access & refresh)
- Device ID management
- User ID persistence

#### **DeviceIdService**
- Platform-specific device ID generation
- Persistent device ID storage
- Fallback strategies for unsupported platforms

#### **NetworkService**
- Real-time connectivity monitoring
- Stream-based connection status
- Internet access verification

#### **ApiClient**
- Dio-based HTTP client with interceptors
- Automatic token refresh on 401 errors
- Request/response logging (debug mode)
- Configurable base URL (dev/production)

### 4. Sync Infrastructure (`lib/core/services/sync/`)

#### **SyncQueueService**
- Offline operation queue management
- Retry logic with max attempts (3)
- Status tracking (pending, in-progress, failed, completed)
- Automatic cleanup of completed items

#### **ConflictResolution**
- Multiple resolution strategies:
  - `serverWins`: Server data takes precedence
  - `clientWins`: Local data takes precedence  
  - `newerWins`: Most recent update wins (default)
  - `manual`: Requires user intervention
- Conflict detection logic

#### **ExpenseCacheManager**
- **100-item cache limit** with LRU eviction
- Automatic oldest-item removal when full
- Sorted by date (most recent first)
- Fast lookup by expense ID

#### **SyncManager**
- Automatic sync on network restoration
- Periodic sync every 5 minutes
- Queue processing with retry logic
- Local ID to server ID mapping
- Cache updates after sync

### 5. API Repositories (`lib/features/expenses/data/repositories/`)

#### **ExpenseApiRepository**
- Full CRUD operations for expenses
- Pagination support (limit/offset)
- Filtering (category, date range)
- Statistics endpoint integration
- Optional category details inclusion

#### **CategoryApiRepository**
- CRUD operations for categories
- Support for predefined & custom categories
- Category validation

---

## 🔄 Sync Flow

### Creating an Expense (Offline-First)

1. **User creates expense** → Expense added to local Hive DB
2. **Generate temporary local ID** → Use timestamp-based ID
3. **Add to sync queue** → Operation: `create`, status: `pending`
4. **Update UI immediately** → Optimistic update
5. **Background sync** (when online):
   - Queue processes create operation
   - API call creates expense on server
   - Server returns permanent ID
   - Update local ID mapping in cache
   - Mark queue item as completed

### Updating an Expense

1. **User updates expense** → Update local Hive DB
2. **Add to sync queue** → Operation: `update`, status: `pending`
3. **Update UI immediately**
4. **Background sync**:
   - Send update to server
   - Update cache with server response
   - Mark completed

### Conflict Resolution

When local and server data differ:
- **Default**: `newerWins` strategy compares timestamps
- Can be configured to use other strategies
- Manual conflicts throw exception for UI handling

---

## 📊 Data Flow

```
┌─────────────┐
│   User UI   │
└──────┬──────┘
       │
       ↓
┌──────────────────┐      Online?      ┌─────────────┐
│ Provider/State   │ ──────Yes─────→  │   API Repo  │
└────────┬─────────┘                   └──────┬──────┘
         │                                     │
         ↓                                     ↓
    ┌─────────┐                         ┌──────────┐
    │  Hive   │←────Cache (100)────────│ Server   │
    │  Local  │                         └──────────┘
    └─────────┘
         ↑
         │
    ┌─────────────┐
    │ Sync Queue  │ ← Pending operations when offline
    └─────────────┘
```

---

## 🔐 Authentication Flow

### Login/Register
1. User submits credentials
2. API returns `AuthResponse` with tokens
3. Tokens stored securely via `TokenStorageService`
4. Access token added to all subsequent requests

### Token Refresh
1. API returns 401 (token expired)
2. `ApiClient` intercepts error
3. Automatic refresh using refresh token
4. Retry original request with new token
5. If refresh fails → Clear tokens, redirect to login

### Device Management
- Each device gets unique ID
- Stored persistently
- Sent with auth requests
- Supports per-device logout

---

## 🛠️ Service Locator Setup

All services registered in `lib/core/locator/locator_service.dart`:

```dart
await setupLocator();  // Call in main.dart
```

**Services Available:**
- `tokenStorageService`
- `networkService`
- `expenseApiRepository`
- `categoryApiRepository`
- `syncManager`
- `expenseCacheManager`

---

## 📝 Icon Mapping

Extended `IconMapper` utility to support string-based icons:
- `getIconFromString(String)` → Convert API icon name to `IconData`
- `getIconName(IconData)` → Convert `IconData` to API icon name
- Supports Lucide icons matching backend names

Backend icon names:
```dart
'utensils', 'car', 'tv', 'shoppingCart', 'fileText', 'heart', 
'menu', 'dumbbell', 'activity', 'coffee', 'home', 'briefcase', 
'book', 'gift', 'plane', 'wallet', 'creditCard', 'smartphone', 
'music', 'gamepad'
```

---

## 🗂️ Hive Type IDs

- `ExpenseHive`: Type ID 0
- `SyncQueueItem`: Type ID 10

Both adapters auto-generated via `build_runner`.

---

## 🚀 Next Steps

### Provider Integration (Todo ID: 14)

Update the following providers to use API repositories:

1. **ExpensesProvider**
   - Check network status
   - Use `ExpenseApiRepository` when online
   - Fallback to local `ExpenseHiveRepository` when offline
   - Queue operations for offline sync

2. **CategoriesProvider**
   - Fetch from `CategoryApiRepository`
   - Combine predefined + custom categories
   - Cache locally

3. **AuthProvider** (New)
   - Handle login/register
   - Token management
   - Logout functionality

### Example Provider Pattern:

```dart
class ExpensesNotifier extends StateNotifier<ExpensesState> {
  final ExpenseApiRepository _apiRepo;
  final ExpenseHiveRepository _localRepo;
  final NetworkService _networkService;
  final SyncQueueService _syncQueue;
  
  Future<void> addExpense(Expense expense) async {
    final isOnline = await _networkService.isConnected;
    
    // Optimistic update
    state = state.copyWith(expenses: [...state.expenses, expense]);
    
    if (isOnline) {
      try {
        final created = await _apiRepo.createExpense(...);
        // Update with server ID
      } catch (e) {
        // Queue for later sync
        await _syncQueue.enqueue(...);
      }
    } else {
      // Queue for later sync
      await _syncQueue.enqueue(...);
    }
    
    // Save to local
    await _localRepo.addExpense(expense);
  }
}
```

---

## 🧪 Testing Checklist

### Authentication
- [ ] Register new user
- [ ] Login with credentials
- [ ] Token refresh on expiration
- [ ] Logout (single device)
- [ ] Logout (all devices)

### Expenses (Online)
- [ ] Fetch expenses with pagination
- [ ] Create new expense
- [ ] Update existing expense
- [ ] Delete expense
- [ ] Filter by category
- [ ] Filter by date range
- [ ] Fetch statistics

### Expenses (Offline)
- [ ] Create expense offline → Syncs when online
- [ ] Update expense offline → Syncs when online
- [ ] Delete expense offline → Syncs when online
- [ ] Cache respects 100-item limit
- [ ] Oldest items evicted properly

### Categories
- [ ] Fetch all categories (predefined + custom)
- [ ] Create custom category
- [ ] Update custom category
- [ ] Delete custom category
- [ ] Cannot modify predefined categories

### Sync & Connectivity
- [ ] Operations queue when offline
- [ ] Auto-sync on network restoration
- [ ] Periodic sync works (5 min intervals)
- [ ] Retry logic on failures
- [ ] Max retries respected
- [ ] Local ID mapping after sync

---

## ⚠️ Important Notes

### Cache Management
- Only the **most recent 100 expenses** are cached offline
- Sorted by date (newest first)
- LRU eviction strategy
- Users should be online for full expense history

### Conflict Resolution
- Default strategy: `newerWins` (timestamp comparison)
- Can be changed in service locator registration
- Manual conflicts require UI handling

### Network Monitoring
- Real-time connectivity stream available via `connectivityProvider`
- UI can show offline indicator
- Sync status available via `syncManager.isSyncing`

### Token Security
- Tokens stored in `FlutterSecureStorage`
- Platform-specific encryption
- Never exposed in logs (production mode)

### API Base URL
- Development: `http://localhost:8080`
- Production: Update in `ApiClient` constructor
- Consider using environment variables

---

## 📚 API Documentation

Full backend API documentation available at:
`/Users/aderemialo/StudioProjects/pocketly/backend/pocketly_api/API_DOCUMENTATION.md`

---

## 🎯 Implementation Status

✅ Dependencies added  
✅ Core models created  
✅ API models created  
✅ Token storage service  
✅ Device ID service  
✅ Network service  
✅ API client with token refresh  
✅ Sync queue & conflict resolution  
✅ Cache manager (100-item limit)  
✅ Sync manager  
✅ API repositories  
✅ Service locator updated  
✅ Hive adapters generated  
✅ Icon mapper extended  
⏳ Provider integration (in progress)

---

**Ready for testing and provider integration!** 🚀


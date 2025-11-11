import 'package:pocketly/core/core.dart';

class SyncDetailsBottomSheet extends ConsumerStatefulWidget {
  const SyncDetailsBottomSheet({super.key});

  static void show({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SyncDetailsBottomSheet(),
    );
  }

  @override
  ConsumerState<SyncDetailsBottomSheet> createState() =>
      _SyncDetailsBottomSheetState();
}

class _SyncDetailsBottomSheetState
    extends ConsumerState<SyncDetailsBottomSheet> {
  bool _isSyncing = false;

  Future<void> _triggerSync() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);

    try {
      await syncManager.forceSyncNow();

      // Update app state
      ref.read(appStateProvider.notifier).updateLastSyncTime(DateTime.now());
      final syncQueue = syncQueueService;
      final pendingCount = syncQueue.getPendingItems().length;
      ref.read(appStateProvider.notifier).updatePendingSyncCount(pendingCount);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync completed successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text('Sync Status', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // Status info
            _buildStatusInfo(context, appState),
            const SizedBox(height: 24),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: appState.canSync && !_isSyncing
                    ? _triggerSync
                    : null,
                child: _isSyncing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(appState.canSync ? 'Sync Now' : 'Offline'),
              ),
            ),
            const SizedBox(height: 16),

            // Close button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInfo(BuildContext context, AppState appState) {
    final syncQueue = syncQueueService;
    final failedItems = syncQueue.getFailedItems();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          'Status',
          appState.isSyncing ? 'Syncing...' : _getStatusText(appState.mode),
          appState.isSyncing ? Icons.sync : _getStatusIcon(appState.mode),
        ),
        const SizedBox(height: 12),

        if (appState.lastSyncTime != null) ...[
          _buildInfoRow(
            context,
            'Last Sync',
            _getTimeAgo(appState.lastSyncTime!),
            Icons.access_time,
          ),
          const SizedBox(height: 12),
        ],

        _buildInfoRow(
          context,
          'Pending Items',
          '${appState.pendingSyncCount}',
          Icons.queue,
        ),
        if (appState.failedSyncCount > 0) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            'Failed Items',
            '${appState.failedSyncCount}',
            Icons.error_outline,
            errorColor: true,
          ),
        ],
        if (appState.lastSyncError != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appState.lastSyncError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (failedItems.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Failed Items',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...failedItems.map((item) => _buildFailedItem(context, item)),
        ],
      ],
    );
  }

  Widget _buildFailedItem(BuildContext context, SyncQueueItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.entityType} - ${item.operation}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Retry this item
                  syncManager.forceSyncNow();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          if (item.error != null && item.error!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ],
          Text(
            'Retry attempt: ${item.retryCount}/${SyncQueueService.maxRetries}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool errorColor = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: errorColor
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: errorColor
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: errorColor ? Theme.of(context).colorScheme.error : null,
          ),
        ),
      ],
    );
  }

  String _getStatusText(AppMode mode) {
    switch (mode) {
      case AppMode.online:
        return 'Online & Synced';
      case AppMode.offline:
        return 'Offline';
      case AppMode.localMode:
        return 'Local Mode';
    }
  }

  IconData _getStatusIcon(AppMode mode) {
    switch (mode) {
      case AppMode.online:
        return Icons.cloud_done;
      case AppMode.offline:
        return Icons.cloud_off;
      case AppMode.localMode:
        return Icons.cloud_queue;
    }
  }

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/core/providers/app_state_provider.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          'Status',
          _getStatusText(appState.mode),
          _getStatusIcon(appState.mode),
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
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
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

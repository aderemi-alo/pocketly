import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/core/providers/app_state_provider.dart';
import 'package:pocketly/features/shared/widgets/sync_details_bottom_sheet.dart';

class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    String statusText;
    IconData statusIcon;
    Color statusColor;

    // Check if syncing
    if (appState.isSyncing) {
      statusText = 'Syncing...';
      statusIcon = Icons.sync;
      statusColor = Theme.of(context).colorScheme.primary;
    } else if (appState.failedSyncCount > 0) {
      // Show failed count if there are failures
      statusText = '${appState.failedSyncCount} failed';
      statusIcon = Icons.error_outline;
      statusColor = Theme.of(context).colorScheme.error;
    } else {
      switch (appState.mode) {
        case AppMode.online:
          if (appState.lastSyncTime != null) {
            final timeAgo = _getTimeAgo(appState.lastSyncTime!);
            statusText = 'Synced $timeAgo';
          } else {
            statusText = 'Synced';
          }
          statusIcon = Icons.cloud_done;
          statusColor = Theme.of(context).colorScheme.primary;
          break;

        case AppMode.offline:
          if (appState.pendingSyncCount > 0) {
            statusText = '${appState.pendingSyncCount} pending';
          } else {
            statusText = 'Offline';
          }
          statusIcon = Icons.cloud_off;
          statusColor = Theme.of(context).colorScheme.onSurfaceVariant;
          break;

        case AppMode.localMode:
          if (appState.pendingSyncCount > 0) {
            statusText = '${appState.pendingSyncCount} pending sync';
          } else {
            statusText = 'Local';
          }
          statusIcon = Icons.cloud_queue;
          statusColor = Theme.of(context).colorScheme.tertiary;
          break;
      }
    }

    return GestureDetector(
      onTap: () => _showSyncDetails(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (appState.isSyncing)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              )
            else
              Icon(statusIcon, size: 16, color: statusColor),
            const SizedBox(width: 4),
            Text(
              statusText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showSyncDetails(BuildContext context, WidgetRef ref) {
    SyncDetailsBottomSheet.show(context: context);
  }
}

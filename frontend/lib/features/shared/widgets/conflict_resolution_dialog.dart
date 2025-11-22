import 'package:flutter/material.dart';

enum ConflictResolutionChoice { keepLocal, useServer, cancel }

class ConflictResolutionDialog extends StatelessWidget {
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final String entityName;

  const ConflictResolutionDialog({
    super.key,
    required this.localData,
    required this.serverData,
    required this.entityName,
  });

  static Future<ConflictResolutionChoice?> show({
    required BuildContext context,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> serverData,
    required String entityName,
  }) {
    return showDialog<ConflictResolutionChoice>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConflictResolutionDialog(
        localData: localData,
        serverData: serverData,
        entityName: entityName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sync Conflict'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The $entityName has been modified both locally and on the server. Choose which version to keep:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _buildDataComparison(context),
            const SizedBox(height: 24),
            Text(
              'What would you like to do?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(ConflictResolutionChoice.cancel),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(ConflictResolutionChoice.useServer),
          child: const Text('Use Server'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(ConflictResolutionChoice.keepLocal),
          child: const Text('Keep Local'),
        ),
      ],
    );
  }

  Widget _buildDataComparison(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataSection(
            context,
            'Local Version',
            localData,
            theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          _buildDataSection(
            context,
            'Server Version',
            serverData,
            theme.colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(
    BuildContext context,
    String title,
    Map<String, dynamic> data,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...data.entries.map((entry) {
          // Skip internal fields
          if (entry.key == 'updatedAt' ||
              entry.key == 'createdAt' ||
              entry.key == 'id') {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    '${entry.key}:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _formatValue(entry.value),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is DateTime) {
      return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    }
    return value.toString();
  }
}


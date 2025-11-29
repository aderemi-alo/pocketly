import 'package:pocketly/core/core.dart';
import 'package:pocketly/core/services/theme_service.dart' as theme_service;
import 'package:pocketly/features/features.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  Future<Map<String, String>> _getAppInfo() async {
    final version = await AppInfoService.getVersion();
    return {'version': version};
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    return SingleChildScrollView(
      child: Padding(
        padding: context.screenPadding(),
        child: Column(
          children: [
            // Profile Section
            GestureDetector(
              onTap: () => context.go('/settings/profile'),
              child: Container(
                padding: context.only(left: 16, top: 16, bottom: 16, right: 8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: context.radius(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const UserAvatarWidget(),
                    context.horizontalSpace(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile',
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        context.verticalSpace(4),
                        Text(
                          'Manage your account',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.chevronRight, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            context.verticalSpace(16),
            // Theme Section
            Container(
              padding: context.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: context.radius(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  context.verticalSpace(4),
                  Text(
                    'Choose your preferred theme',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  context.verticalSpace(16),
                  Row(
                    children: [
                      Expanded(
                        child: _ThemeOption(
                          icon: LucideIcons.sun,
                          label: 'Light',
                          isSelected:
                              themeState.themeMode ==
                              theme_service.ThemeMode.light,
                          onTap: () => ref
                              .read(themeProvider.notifier)
                              .setThemeMode(theme_service.ThemeMode.light),
                        ),
                      ),
                      context.horizontalSpace(12),
                      Expanded(
                        child: _ThemeOption(
                          icon: LucideIcons.moon,
                          label: 'Dark',
                          isSelected:
                              themeState.themeMode ==
                              theme_service.ThemeMode.dark,
                          onTap: () => ref
                              .read(themeProvider.notifier)
                              .setThemeMode(theme_service.ThemeMode.dark),
                        ),
                      ),
                      context.horizontalSpace(12),
                      Expanded(
                        child: _ThemeOption(
                          icon: LucideIcons.monitor,
                          label: 'System',
                          isSelected:
                              themeState.themeMode ==
                              theme_service.ThemeMode.system,
                          onTap: () => ref
                              .read(themeProvider.notifier)
                              .setThemeMode(theme_service.ThemeMode.system),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            context.verticalSpace(16),
            // Sync Section
            Container(
              padding: context.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: context.radius(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sync',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  context.verticalSpace(4),
                  Text(
                    'Sync your data with the server',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  context.verticalSpace(16),
                  const _SyncButton(),
                  context.verticalSpace(8),
                  const _SyncStatusIndicator(),
                ],
              ),
            ),
            context.verticalSpace(16),
            // About Section
            Container(
              padding: context.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: context.radius(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  context.verticalSpace(12),
                  FutureBuilder<Map<String, String>>(
                    future: _getAppInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }

                      final version = snapshot.data?['version'] ?? 'Unknown';

                      return Column(
                        children: [_InfoRow(label: 'Version', value: version)],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: context.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: context.radius(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).iconTheme.color,
            ),
            context.verticalSpace(8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : null,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

bool isDarkMode(BuildContext context) {
  return Theme.of(context).colorScheme.brightness == Brightness.dark;
}

class _SyncButton extends ConsumerStatefulWidget {
  const _SyncButton();

  @override
  ConsumerState<_SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends ConsumerState<_SyncButton> {
  bool _isSyncing = false;

  Future<void> _handleSync() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);

    try {
      // Manually fetch fresh data from server
      await ref.read(categoriesProvider.notifier).syncCategories();

      // Refresh expenses list (will fetch from Hive which should have latest data)
      await ref.read(expensesProvider.notifier).refreshExpenses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data refreshed successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refresh failed: $e'),
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

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (_isSyncing || !appState.canSync) ? null : _handleSync,
        icon: _isSyncing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(LucideIcons.refreshCw, size: 18),
        label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
        style: ElevatedButton.styleFrom(padding: context.all(16)),
      ),
    );
  }
}

class _SyncStatusIndicator extends ConsumerWidget {
  const _SyncStatusIndicator();

  String _formatTimeAgo(DateTime? time) {
    if (time == null) return 'Never';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Row(
      children: [
        Icon(
          appState.canSync ? LucideIcons.cloud : LucideIcons.cloudOff,
          size: 16,
          color: appState.canSync
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
        context.horizontalSpace(8),
        Expanded(
          child: Text(
            appState.canSync
                ? 'Last synced: ${_formatTimeAgo(appState.lastSyncTime)}'
                : 'Not signed in',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (appState.pendingSyncCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${appState.pendingSyncCount} pending',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

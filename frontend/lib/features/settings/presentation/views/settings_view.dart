import 'package:pocketly/core/core.dart';
import 'package:pocketly/core/providers/providers.dart';
import 'package:pocketly/core/services/theme_service.dart' as theme_service;
import 'package:pocketly/features/authentication/presentation/providers/providers.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final themeState = ref.watch(themeProvider);
    final name = user?.name ?? '';
    return SingleChildScrollView(
      child: Padding(
        padding: context.screenPadding(),
        child: Column(
          children: [
            // Profile Section
            Container(
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
                  Container(
                    padding: context.all(name.isEmpty ? 12 : 18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AvatarColorGenerator.generate(name),
                    ),
                    child: name.isEmpty
                        ? const Icon(
                            LucideIcons.user,
                            color: AppColors.surface,
                            size: 26,
                          )
                        : Text(
                            'A'.toUpperCase(),
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  // fontWeight: FontWeight.w500,
                                  color: AppColors.surface,
                                ),
                          ),
                  ),

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
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).iconTheme.color,
            ),
            context.verticalSpace(8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
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

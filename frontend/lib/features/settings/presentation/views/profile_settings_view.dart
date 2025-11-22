import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';
import 'package:pocketly/features/settings/presentation/components/edit_name_bottom_sheet.dart';

class ProfileSettingsView extends ConsumerStatefulWidget {
  const ProfileSettingsView({super.key});

  @override
  ConsumerState<ProfileSettingsView> createState() =>
      _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends ConsumerState<ProfileSettingsView> {
  bool isEditing = false;

  void _handleEditName() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => EditNameBottomSheet(currentName: user.name ?? ''),
      );
    }
  }

  void _handleChangePassword() {
    context.push('/settings/change-password');
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _confirmDeleteAccount();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    // Show password confirmation dialog
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your password to confirm account deletion:'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete Account',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      passwordController.dispose();
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .deleteAccount(
            password: passwordController.text.isNotEmpty
                ? passwordController.text
                : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        // Navigation will happen automatically via auth state listener
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      passwordController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    // Listen for logout completion
    ref.listen<AuthState>(authProvider, (previous, next) {
      // If user was authenticated and is now not authenticated, navigate to login
      if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        context.go(AppRoutes.login);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            padding: context.all(16),
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(
              LucideIcons.logOut,
              size: 20,
              color: AppColors.error,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: context.all(20),
        child: Column(
          children: [
            // Profile Card
            Container(
              width: double.infinity,
              padding: context.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: context.radius(24),
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section
                  const Center(child: UserAvatarWidget()),
                  context.verticalSpace(24),
                  ProfileItem(
                    label: 'Name',
                    value: user?.name ?? 'Not provided',
                    onEdit: () {
                      if (isEditing) {
                        _handleEditName();
                      }
                    },
                  ),
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    height: context.h(40),
                    thickness: 1,
                  ),
                  ProfileItem(
                    label: 'Email',
                    value: user?.email ?? 'Not provided',
                    onEdit: () {
                      if (isEditing) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const Text(
                              'Changing your email is not currently supported at this time.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => context.pop(),
                                child: const Text('Continue'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    height: context.h(40),
                    thickness: 1,
                  ),
                  ProfileItem(
                    label: 'Password',
                    value: '••••••••',
                    onEdit: () {
                      if (isEditing) {
                        _handleChangePassword();
                      }
                    },
                  ),
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    height: context.h(40),
                    thickness: 1,
                  ),

                  Padding(
                    padding: context.symmetric(horizontal: 24),
                    child: isEditing
                        ? Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() => isEditing = false);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: context.radius(16),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              ),
                              context.horizontalSpace(12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: context.radius(16),
                                    ),
                                  ),
                                  child: Text(
                                    'Save',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: AppColors.surface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Align(
                            child: ElevatedButton(
                              onPressed: () => setState(() => isEditing = true),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: context.radius(16),
                                ),
                              ),
                              child: Text(
                                'Edit Profile',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColors.surface,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            context.verticalSpace(24),
            if (!isEditing)
              Container(
                width: double.infinity,
                padding: context.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: context.radius(24),
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
                child: _buildDangerZone(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danger Zone',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.error),
        ),
        context.verticalSpace(24),
        OutlinedButton(
          onPressed: _handleDeleteAccount,
          style: OutlinedButton.styleFrom(
            elevation: 0,
            side: BorderSide(color: Theme.of(context).colorScheme.error),
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            shape: RoundedRectangleBorder(borderRadius: context.radius(16)),
          ),
          child: Text(
            'Delete Account',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

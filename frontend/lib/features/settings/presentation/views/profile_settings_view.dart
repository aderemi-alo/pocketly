import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class ProfileSettingsView extends ConsumerStatefulWidget {
  const ProfileSettingsView({super.key});

  @override
  ConsumerState<ProfileSettingsView> createState() =>
      _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends ConsumerState<ProfileSettingsView> {
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Form keys
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // State variables
  bool _editMode = false;
  bool _changePasswordMode = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final user = ref.read(authProvider).user;
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  Future<void> _handleUpdateProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    _setLoading(true);

    try {
      // TODO: Implement profile update API call
      // For now, just simulate success
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _editMode = false;
      });
    } catch (e) {
      // Handle error
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleUpdatePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      return;
    }

    _setLoading(true);

    try {
      // Show confirmation dialog
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Change Password'),
          content: const Text(
            'Your password will be changed and you\'ll be logged out for security. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

      if (shouldProceed != true) {
        _setLoading(false);
        return;
      }

      await ref
          .read(authProvider.notifier)
          .updatePassword(
            _currentPasswordController.text,
            _newPasswordController.text,
          );

      _handleCancelPasswordChange();
    } catch (e) {
      // Handle error
    } finally {
      _setLoading(false);
    }
  }

  void _handleCancelEdit() {
    _initializeFields();
    setState(() {
      _editMode = false;
    });
  }

  void _handleCancelPasswordChange() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _changePasswordMode = false;
      _showCurrentPassword = false;
      _showNewPassword = false;
      _showConfirmPassword = false;
    });
  }

  void _handleDeleteAccount() {
    // TODO: Implement delete account functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement actual delete account
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Card
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section
                  const Center(child: UserAvatarWidget()),
                  context.verticalSpace(24),

                  // Profile Information
                  if (!_changePasswordMode) _buildProfileSection(user),

                  // Change Password Section
                  if (!_editMode) _buildPasswordSection(),

                  // Danger Zone
                  if (!_editMode && !_changePasswordMode) _buildDangerZone(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(UserModel? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Account Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (!_editMode)
              TextButton.icon(
                onPressed: () => setState(() => _editMode = true),
                icon: Icon(
                  LucideIcons.pencil,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: Text(
                  'Edit',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),

        if (_editMode) ...[
          Form(
            key: _profileFormKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: LucideIcons.user,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleUpdateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.surface,
                                  ),
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _handleCancelEdit,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.outline),
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          _buildProfileInfoCard(user),
        ],
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (!_changePasswordMode)
              TextButton.icon(
                onPressed: () => setState(() => _changePasswordMode = true),
                icon: Icon(
                  LucideIcons.pencil,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: Text(
                  'Change',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),

        if (_changePasswordMode) ...[
          Form(
            key: _passwordFormKey,
            child: Column(
              children: [
                _buildPasswordField(
                  controller: _currentPasswordController,
                  label: 'Current Password',
                  showPassword: _showCurrentPassword,
                  onToggleVisibility: () => setState(
                    () => _showCurrentPassword = !_showCurrentPassword,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  showPassword: _showNewPassword,
                  onToggleVisibility: () =>
                      setState(() => _showNewPassword = !_showNewPassword),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  showPassword: _showConfirmPassword,
                  onToggleVisibility: () => setState(
                    () => _showConfirmPassword = !_showConfirmPassword,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleUpdatePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.surface,
                                  ),
                                ),
                              )
                            : const Text('Update Password'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : _handleCancelPasswordChange,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.outline),
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          _buildPasswordInfoCard(),
        ],
      ],
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Container(width: double.infinity, height: 1, color: AppColors.outline),
        const SizedBox(height: 24),
        Text(
          'Danger Zone',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _handleDeleteAccount,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.error, width: 2),
              foregroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Delete Account'),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: !showPassword,
            validator: validator,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              prefixIcon: Icon(
                LucideIcons.lock,
                color: AppColors.textSecondary,
                size: 20,
              ),
              suffixIcon: IconButton(
                onPressed: onToggleVisibility,
                icon: Icon(
                  showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoCard(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            'Full Name',
            user?.name ?? 'Not provided',
            LucideIcons.user,
          ),
          const SizedBox(height: 16),
          _buildEmailRow(user),
        ],
      ),
    );
  }

  Widget _buildPasswordInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.lock,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '••••••••',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailRow(UserModel? user) {
    final isVerified = user?.isEmailVerified ?? true;

    return Row(
      children: [
        Icon(
          LucideIcons.mail,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user?.email ?? 'Not provided',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (!isVerified)
                    GestureDetector(
                      onTap: () => context.push(
                        '/email-verification',
                        extra: user?.email,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.warning,
                          size: 16,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

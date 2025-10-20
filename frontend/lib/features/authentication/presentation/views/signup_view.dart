import 'package:flutter/gestures.dart';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class SignupView extends ConsumerStatefulWidget {
  const SignupView({super.key});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate passwords match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Passwords do not match'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      ref
          .read(authProvider.notifier)
          .register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  void _navigateToLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    // Listen for auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      // Navigate to dashboard on successful registration
      if (next.isAuthenticated && !next.isLoading) {
        context.go(AppRoutes.dashboard);
      }

      // Show error if any
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: context.symmetric(vertical: 20, horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo and Title
                        Text(
                          'Create Account',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start tracking your expenses today',
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Name Field
                        CustomTextField(
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          icon: LucideIcons.user,
                          controller: _nameController,
                          enabled: !authState.isLoading,
                          validator: Validator.validateName,
                        ),

                        const SizedBox(height: 16),

                        // Email Field
                        CustomTextField(
                          label: 'Email',
                          hint: 'Enter your email',
                          icon: LucideIcons.mail,
                          controller: _emailController,
                          enabled: !authState.isLoading,
                          validator: Validator.validateEmail,
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        CustomTextField(
                          label: 'Password',
                          hint: 'Create a password',
                          icon: LucideIcons.lock,
                          controller: _passwordController,
                          isPassword: true,
                          enabled: !authState.isLoading,
                          validator: Validator.validatePassword,
                        ),

                        const SizedBox(height: 16),

                        // Confirm Password Field
                        CustomTextField(
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          icon: LucideIcons.lock,
                          controller: _confirmPasswordController,
                          isPassword: true,
                          enabled: !authState.isLoading,
                          validator: (value) =>
                              Validator.validateConfirmPassword(
                                value,
                                _passwordController.text,
                              ),
                        ),

                        const SizedBox(height: 8),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            child: Text(
                              'Forgot Password?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: authState.isLoading
                                ? null
                                : _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              shadowColor: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            child: authState.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Create Account',
                                    style: theme.textTheme.titleMedium,
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Login Link
                        Center(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Already have an account? ',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _navigateToLogin,
                                  text: 'Login',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

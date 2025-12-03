import 'package:flutter/gestures.dart';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);
    }
  }

  // void _handleGoogleLogin() {
  //   // TODO: Implement Google OAuth
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(const SnackBar(content: Text('Google login coming soon!')));
  // }

  // void _handleAppleLogin() {
  //   // TODO: Implement Apple OAuth
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(const SnackBar(content: Text('Apple login coming soon!')));
  // }

  void _navigateToSignUp() {
    context.go('/signup');
  }

  void _navigateToForgotPassword() {
    context.push('/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      // Navigation happens automatically via GoRouter redirect
      // Only handle error display here
      if (next.error != null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
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
                          'Welcome Back',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue managing your expenses',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Email Field
                        Column(
                          children: [
                            CustomTextField(
                              label: 'Email',
                              hint: 'Enter your email',
                              icon: LucideIcons.mail,
                              controller: _emailController,
                              enabled: !authState.isLoading,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        CustomTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          icon: LucideIcons.lock,
                          controller: _passwordController,
                          isPassword: true,
                          enabled: !authState.isLoading,
                        ),

                        const SizedBox(height: 8),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _navigateToForgotPassword,
                            child: Text(
                              'Forgot Password?',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: authState.isLoading
                                ? null
                                : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              shadowColor: AppColors.primary.withValues(
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
                                    'Sign In',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // // Divider
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: Container(
                        //         height: 1,
                        //         color: AppColors.outline,
                        //       ),
                        //     ),
                        //     Padding(
                        //       padding: const EdgeInsets.symmetric(
                        //         horizontal: 16,
                        //       ),
                        //       child: Text(
                        //         'Or continue with',
                        //         style: AppTextTheme.bodyMedium.copyWith(
                        //           color: AppColors.textSecondary,
                        //         ),
                        //       ),
                        //     ),
                        //     Expanded(
                        //       child: Container(
                        //         height: 1,
                        //         color: AppColors.outline,
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        // const SizedBox(height: 24),

                        // // OAuth Buttons
                        // OAuthButton(
                        //   text: 'Sign in with Google',
                        //   icon: LucideIcons.globe,
                        //   onPressed: _handleGoogleLogin,
                        //   isLoading: authState.isLoading,
                        // ),

                        // const SizedBox(height: 12),

                        // OAuthButton(
                        //   text: 'Sign in with Apple',
                        //   icon: LucideIcons.apple,
                        //   onPressed: _handleAppleLogin,
                        //   isLoading: authState.isLoading,
                        // ),
                        // const SizedBox(height: 12),

                        // Sign Up Link
                        Center(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Don't have an account? ",
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _navigateToSignUp,
                                  text: 'Sign Up',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
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

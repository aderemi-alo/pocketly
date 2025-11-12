import 'dart:async';

import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';
import 'package:pocketly/features/authentication/data/repositories/password_reset_repository.dart';
import 'package:pocketly/features/shared/widgets/otp_input_widget.dart';

class ForgotPasswordView extends ConsumerStatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  ConsumerState<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends ConsumerState<ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _passwordResetRepo = PasswordResetRepository(locator<ApiClient>());

  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;
  String? _email;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _clearMessages() {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });
  }

  void _setError(String message) {
    setState(() {
      _errorMessage = message;
      _successMessage = null;
    });
  }

  void _setSuccess(String message) {
    setState(() {
      _successMessage = message;
      _errorMessage = null;
    });
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _setResending(bool resending) {
    setState(() {
      _isResending = resending;
    });
  }

  void _startResendCooldown() {
    _resendCooldown = 60; // 60 seconds cooldown
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCooldown--;
      });
      if (_resendCooldown <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _requestPasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    _clearMessages();
    _setLoading(true);

    try {
      await _passwordResetRepo.requestPasswordReset(
        _emailController.text.trim(),
      );
      _email = _emailController.text.trim();
      _setSuccess('Password reset code sent to $_email');
      _startResendCooldown();
    } catch (e) {
      _setError('Failed to send reset code: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _resendCode() async {
    if (_email == null) return;

    _clearMessages();
    _setResending(true);

    try {
      await _passwordResetRepo.requestPasswordReset(_email!);
      _setSuccess('Reset code resent to $_email');
      _startResendCooldown();
    } catch (e) {
      _setError('Failed to resend code: ${e.toString()}');
    } finally {
      _setResending(false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _setError('Passwords do not match');
      return;
    }

    if (_email == null) return;

    _clearMessages();
    _setLoading(true);

    try {
      await _passwordResetRepo.resetPassword(
        _email!,
        _otpController.text,
        _newPasswordController.text,
      );

      _setSuccess('Password reset successfully! Redirecting to login...');

      // Navigate to login after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.go('/login');
        }
      });
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Header
              Text(
                _email == null ? 'Reset Password' : 'Enter New Password',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _email == null
                    ? 'Enter your email address and we\'ll send you a code to reset your password'
                    : 'Enter the verification code and your new password',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 48),

              if (_email == null) ...[
                // Email Input Step
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        icon: LucideIcons.mail,
                        controller: _emailController,
                        enabled: !_isLoading,
                        validator: Validator.validateEmail,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _requestPasswordReset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
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
                              : const Text('Send Reset Code'),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // OTP + Password Step
                Form(
                  key: _passwordFormKey,
                  child: Column(
                    children: [
                      // OTP Input
                      Center(
                        child: OtpInputWidget(
                          onChanged: (otp) {
                            _otpController.text = otp;
                          },
                          onCompleted: (otp) {
                            _otpController.text = otp;
                          },
                          enabled: !_isLoading,
                          errorText: _errorMessage?.contains('code') == true
                              ? _errorMessage
                              : null,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // New Password
                      CustomTextField(
                        label: 'New Password',
                        hint: 'Enter new password',
                        icon: LucideIcons.lock,
                        controller: _newPasswordController,
                        isPassword: true,
                        enabled: !_isLoading,
                        validator: Validator.validatePassword,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      CustomTextField(
                        label: 'Confirm New Password',
                        hint: 'Confirm new password',
                        icon: LucideIcons.lock,
                        controller: _confirmPasswordController,
                        isPassword: true,
                        enabled: !_isLoading,
                        validator: (value) => Validator.validateConfirmPassword(
                          value,
                          _newPasswordController.text,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Reset Password Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
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
                              : const Text('Reset Password'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Resend Code
                      Center(
                        child: TextButton(
                          onPressed: _resendCooldown > 0 || _isResending
                              ? null
                              : _resendCode,
                          child: _isResending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _resendCooldown > 0
                                      ? 'Resend code in ${_resendCooldown}s'
                                      : 'Resend verification code',
                                  style: TextStyle(
                                    color: _resendCooldown > 0
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant
                                        : AppColors.primary,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Messages
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              if (_successMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    _successMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

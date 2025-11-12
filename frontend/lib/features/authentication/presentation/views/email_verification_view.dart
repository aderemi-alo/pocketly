import 'dart:async';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';
import 'package:pocketly/features/authentication/data/repositories/email_verification_repository.dart';
import 'package:pocketly/features/shared/widgets/otp_input_widget.dart';

class EmailVerificationView extends ConsumerStatefulWidget {
  final String email;

  const EmailVerificationView({super.key, required this.email});

  @override
  ConsumerState<EmailVerificationView> createState() =>
      _EmailVerificationViewState();
}

class _EmailVerificationViewState extends ConsumerState<EmailVerificationView> {
  final _otpController = TextEditingController();
  final _emailVerificationRepo = EmailVerificationRepository(
    locator<ApiClient>(),
  );

  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _requestVerificationCode();
  }

  @override
  void dispose() {
    _otpController.dispose();
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

  Future<void> _requestVerificationCode() async {
    _clearMessages();
    _setResending(true);

    try {
      await _emailVerificationRepo.requestEmailVerification(widget.email);
      _setSuccess('Verification code sent to ${widget.email}');
      _startResendCooldown();
    } catch (e) {
      _setError('Failed to send verification code: ${e.toString()}');
    } finally {
      _setResending(false);
    }
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

  Future<void> _verifyEmail() async {
    if (_otpController.text.length != 6) {
      _setError('Please enter a valid 6-digit code');
      return;
    }

    _clearMessages();
    _setLoading(true);

    try {
      await _emailVerificationRepo.verifyEmail(
        widget.email,
        _otpController.text,
      );

      // Update user verification status
      await ref.read(authProvider.notifier).updateUserEmailVerification(true);

      _setSuccess('Email verified successfully!');

      // Navigate back after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.pop();
        }
      });
    } catch (e) {
      _setError('Verification failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Header
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 48),

              // OTP Input
              Center(
                child: OtpInputWidget(
                  onChanged: (otp) {
                    _otpController.text = otp;
                  },
                  onCompleted: (otp) {
                    _otpController.text = otp;
                    _verifyEmail();
                  },
                  enabled: !_isLoading,
                  errorText: _errorMessage,
                ),
              ),

              const SizedBox(height: 32),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyEmail,
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
                      : const Text('Verify Email'),
                ),
              ),

              const SizedBox(height: 24),

              // Resend Code
              Center(
                child: TextButton(
                  onPressed: _resendCooldown > 0 || _isResending
                      ? null
                      : _requestVerificationCode,
                  child: _isResending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _resendCooldown > 0
                              ? 'Resend code in ${_resendCooldown}s'
                              : 'Resend verification code',
                          style: TextStyle(
                            color: _resendCooldown > 0
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : AppColors.primary,
                          ),
                        ),
                ),
              ),

              const Spacer(),

              // Success Message
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

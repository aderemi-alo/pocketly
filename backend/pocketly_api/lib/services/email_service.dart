import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pocketly_api/utils/utils.dart';

/// Service for sending emails via Brevo API
class EmailService {
  /// Creates an instance of [EmailService]
  const EmailService();

  static const _brevoApiUrl = 'https://api.brevo.com/v3/smtp/email';

  /// Sends an OTP email for email verification
  Future<bool> sendEmailVerificationOtp({
    required String toEmail,
    required String toName,
    required String otpCode,
  }) async {
    final subject = 'Verify Your Email - Pocketly';
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f5f5f7;">
  <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background-color: white; border-radius: 12px; padding: 40px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
      <h1 style="color: #1d1d1f; font-size: 28px; font-weight: 600; margin: 0 0 16px 0;">Verify Your Email</h1>
      <p style="color: #6e6e73; font-size: 16px; line-height: 1.5; margin: 0 0 24px 0;">Hi $toName,</p>
      <p style="color: #6e6e73; font-size: 16px; line-height: 1.5; margin: 0 0 24px 0;">Use this code to verify your email address:</p>
      <div style="background-color: #f5f5f7; border-radius: 8px; padding: 24px; text-align: center; margin: 0 0 24px 0;">
        <div style="font-size: 36px; font-weight: 700; letter-spacing: 8px; color: #1d1d1f;">$otpCode</div>
      </div>
      <p style="color: #6e6e73; font-size: 14px; line-height: 1.5; margin: 0 0 16px 0;">This code expires in 10 minutes.</p>
      <p style="color: #6e6e73; font-size: 14px; line-height: 1.5; margin: 0;">If you didn't request this code, you can safely ignore this email.</p>
      <hr style="border: none; border-top: 1px solid #e5e5ea; margin: 32px 0;">
      <p style="color: #86868b; font-size: 12px; line-height: 1.5; margin: 0;">Pocketly - Your Personal Finance Manager</p>
    </div>
  </div>
</body>
</html>
''';

    return _sendEmail(
      toEmail: toEmail,
      toName: toName,
      subject: subject,
      htmlContent: htmlContent,
    );
  }

  /// Sends an OTP email for password reset
  Future<bool> sendPasswordResetOtp({
    required String toEmail,
    required String toName,
    required String otpCode,
  }) async {
    final subject = 'Reset Your Password - Pocketly';
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f5f5f7;">
  <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background-color: white; border-radius: 12px; padding: 40px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
      <h1 style="color: #1d1d1f; font-size: 28px; font-weight: 600; margin: 0 0 16px 0;">Reset Your Password</h1>
      <p style="color: #6e6e73; font-size: 16px; line-height: 1.5; margin: 0 0 24px 0;">Hi $toName,</p>
      <p style="color: #6e6e73; font-size: 16px; line-height: 1.5; margin: 0 0 24px 0;">You requested to reset your password. Use this code to proceed:</p>
      <div style="background-color: #f5f5f7; border-radius: 8px; padding: 24px; text-align: center; margin: 0 0 24px 0;">
        <div style="font-size: 36px; font-weight: 700; letter-spacing: 8px; color: #1d1d1f;">$otpCode</div>
      </div>
      <p style="color: #6e6e73; font-size: 14px; line-height: 1.5; margin: 0 0 16px 0;">This code expires in 10 minutes.</p>
      <p style="color: #ff3b30; font-size: 14px; line-height: 1.5; margin: 0 0 16px 0;"><strong>If you didn't request this, your account may be at risk.</strong> Please change your password immediately.</p>
      <hr style="border: none; border-top: 1px solid #e5e5ea; margin: 32px 0;">
      <p style="color: #86868b; font-size: 12px; line-height: 1.5; margin: 0;">Pocketly - Your Personal Finance Manager</p>
    </div>
  </div>
</body>
</html>
''';

    return _sendEmail(
      toEmail: toEmail,
      toName: toName,
      subject: subject,
      htmlContent: htmlContent,
    );
  }

  /// Internal method to send email via Brevo API
  Future<bool> _sendEmail({
    required String toEmail,
    required String toName,
    required String subject,
    required String htmlContent,
  }) async {
    try {
      AppLogger.info('Sending email to $toEmail');
      AppLogger.info('Brevo API Key: ${Settings.brevoApiKey}');
      AppLogger.info('Brevo Sender Name: ${Settings.brevoSenderName}');
      AppLogger.info('Brevo Sender Email: ${Settings.brevoSenderEmail}');
      final response = await http.post(
        Uri.parse(_brevoApiUrl),
        headers: {
          'accept': 'application/json',
          'api-key': Settings.brevoApiKey,
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'sender': {
            'name': Settings.brevoSenderName,
            'email': Settings.brevoSenderEmail,
          },
          'to': [
            {
              'email': toEmail,
              'name': toName,
            },
          ],
          'subject': subject,
          'htmlContent': htmlContent,
        }),
      );

      if (response.statusCode == 201) {
        AppLogger.info('Email sent successfully to $toEmail');
        return true;
      } else {
        AppLogger.error(
          'Failed to send email. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Error sending email: $e');
      return false;
    }
  }
}

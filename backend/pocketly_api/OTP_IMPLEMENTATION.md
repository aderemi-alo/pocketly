# OTP Implementation for Email Verification & Password Reset

## Overview
This implementation provides secure OTP (One-Time Password) functionality for:
- Email verification
- Password reset

## Environment Variables Required

Add these to your environment before running the backend:

```bash
# Brevo Email Service
BREVO_API_KEY=your_brevo_api_key_here
BREVO_SENDER_EMAIL=noreply@yourdomain.com
BREVO_SENDER_NAME=Pocketly

# Existing variables
DB_NAME=gray-horst.db
JWT_SECRET_KEY=your_secret_key_here
```

## Features

### Security
- ✅ 6-digit numeric OTP codes
- ✅ OTPs hashed in database using bcrypt
- ✅ 10-minute expiration time
- ✅ Max 3 verification attempts per OTP
- ✅ Rate limiting: Max 3 OTP requests per 15 minutes
- ✅ Single-use OTPs (marked as used after successful verification)
- ✅ Automatic cleanup of expired/used OTPs

### OTP Cleanup Strategy
OTPs are automatically cleaned up through multiple methods:
1. **On successful verification**: OTP is marked as used
2. **On new OTP creation**: All old OTPs for that email/purpose are deleted
3. **During verification attempts**: All expired OTPs are deleted
4. **One OTP per user per purpose**: Creating new OTP replaces old ones

## API Endpoints

### 1. Request Email Verification
**Endpoint**: `POST /auth/request-email-verification`

**Authentication**: Not required

**Request Body**:
```json
{
  "email": "user@example.com"
}
```

**Response**:
```json
{
  "message": "Verification code sent successfully",
  "data": {
    "message": "Verification code sent to your email",
    "email": "user@example.com",
    "expiresInMinutes": 10
  }
}
```

**Error Responses**:
- `400` - Email already verified or missing
- `404` - User not found
- `429` - Too many requests (rate limit exceeded)
- `500` - Failed to send email

---

### 2. Verify Email
**Endpoint**: `POST /auth/verify-email`

**Authentication**: Not required

**Request Body**:
```json
{
  "email": "user@example.com",
  "otp": "123456"
}
```

**Response**:
```json
{
  "message": "Email verified successfully"
}
```

**Error Responses**:
- `400` - Invalid OTP, expired, or max attempts exceeded
- `404` - No valid verification code found or user not found

---

### 3. Request Password Reset
**Endpoint**: `POST /auth/request-password-reset`

**Authentication**: Not required

**Request Body**:
```json
{
  "email": "user@example.com"
}
```

**Response**:
```json
{
  "message": "Password reset code sent successfully",
  "data": {
    "message": "If an account exists with this email, a password reset code has been sent",
    "expiresInMinutes": 10
  }
}
```

**Note**: Always returns success to prevent email enumeration attacks.

---

### 4. Reset Password
**Endpoint**: `POST /auth/reset-password`

**Authentication**: Not required

**Request Body**:
```json
{
  "email": "user@example.com",
  "otp": "123456",
  "newPassword": "newSecurePassword123"
}
```

**Response**:
```json
{
  "message": "Password reset successfully"
}
```

**Error Responses**:
- `400` - Invalid email, OTP, or password requirements not met
- `404` - User not found or invalid OTP

---

## Email Templates

### Email Verification
- Clean, modern HTML email
- Large, easy-to-read OTP code
- 10-minute expiration warning
- Apple HIG-inspired design

### Password Reset
- Similar design to verification email
- Security warning if request wasn't made by user
- 10-minute expiration warning

## Database Schema

### Users Table (Updated)
Added field:
- `isEmailVerified` (BOOLEAN, default: false)

### OTPs Table (New)
```sql
CREATE TABLE otps (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL,
  otpCodeHash TEXT NOT NULL,
  purpose TEXT NOT NULL,  -- 'email_verification' or 'password_reset'
  expiresAt DATETIME NOT NULL,
  isUsed BOOLEAN DEFAULT 0,
  attemptCount INTEGER DEFAULT 0,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## Implementation Details

### Files Created/Modified

**New Files**:
- `lib/utils/otp_generator.dart` - Secure OTP generation
- `lib/services/email_service.dart` - Brevo email integration
- `lib/repositories/auth/otp_repository.dart` - OTP database operations
- `lib/models/otp_response.dart` - OTP response model
- `routes/auth/request_email_verification.dart` - Email verification request
- `routes/auth/verify_email.dart` - Email verification
- `routes/auth/request_password_reset.dart` - Password reset request
- `routes/auth/reset_password.dart` - Password reset

**Modified Files**:
- `lib/database/database.dart` - Added OTPs table, updated Users table
- `lib/repositories/auth/user_repository.dart` - Added email verification update method
- `lib/utils/settings.dart` - Added Brevo configuration
- `routes/auth/_middleware.dart` - Added OTP repository and email service providers
- `pubspec.yaml` - Added http package

### Usage Example

#### Email Verification Flow
1. User registers
2. Frontend calls `/auth/request-email-verification` with user's email
3. User receives OTP email
4. User enters OTP code
5. Frontend calls `/auth/verify-email` with email + OTP
6. User's email is marked as verified
7. User can now login

#### Password Reset Flow
1. User forgets password
2. Frontend calls `/auth/request-password-reset` with email
3. User receives OTP email
4. User enters OTP + new password
5. Frontend calls `/auth/reset-password` with email, OTP, and new password
6. Password is updated, user can login with new password

## Testing

### Manual Testing with cURL

**Request Email Verification**:
```bash
curl -X POST http://localhost:8080/auth/request-email-verification \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com"}'
```

**Verify Email**:
```bash
curl -X POST http://localhost:8080/auth/verify-email \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "otp": "123456"
  }'
```

**Request Password Reset**:
```bash
curl -X POST http://localhost:8080/auth/request-password-reset \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com"}'
```

**Reset Password**:
```bash
curl -X POST http://localhost:8080/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "otp": "123456",
    "newPassword": "newSecurePassword123"
  }'
```

## Production Considerations

1. **Rate Limiting**: Already implemented (3 OTPs per 15 minutes)
2. **Email Service**: Ensure Brevo account has sufficient email quota
3. **Monitoring**: Monitor OTP success/failure rates
4. **Cleanup**: OTPs auto-cleanup on operations (no scheduled jobs needed)
5. **Security**: Never log OTP codes in production
6. **HTTPS**: Always use HTTPS in production

## Next Steps

1. Set up Brevo account and get API key
2. Configure environment variables
3. Deploy backend
4. Implement frontend UI for OTP flows
5. Test thoroughly before production deployment

## Notes

- OTPs are 6 digits for good balance between security and usability
- 10-minute expiration is standard for OTP flows
- Rate limiting prevents abuse while allowing legitimate retries
- Database stays clean through automatic cleanup
- No scheduled jobs or cron tasks needed


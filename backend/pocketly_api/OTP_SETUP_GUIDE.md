# OTP Setup Guide - Quick Start

## ✅ What's Been Implemented

The OTP system for email verification and password reset is now fully implemented with:
- ✅ Database schema updated (Users table + new OTPs table)
- ✅ Brevo email integration
- ✅ 4 new API endpoints
- ✅ Secure OTP generation (6-digit codes)
- ✅ Automatic cleanup and rate limiting
- ✅ All dependencies installed

## 🚀 Quick Setup (3 Steps)

### Step 1: Get Brevo API Key

1. Go to [Brevo](https://app.brevo.com/account/register) and create a free account
2. Navigate to **Settings** → **SMTP & API** → **API Keys**
3. Create a new API key
4. Copy the API key

### Step 2: Set Environment Variables

Before running the backend, set these environment variables:

**On macOS/Linux:**
```bash
export BREVO_API_KEY="your_brevo_api_key_here"
export BREVO_SENDER_EMAIL="noreply@yourdomain.com"
export BREVO_SENDER_NAME="Pocketly"
```

**On Windows (PowerShell):**
```powershell
$env:BREVO_API_KEY="your_brevo_api_key_here"
$env:BREVO_SENDER_EMAIL="noreply@yourdomain.com"
$env:BREVO_SENDER_NAME="Pocketly"
```

**Or create a `.env` file** (if you're using a .env loader):
```env
BREVO_API_KEY=your_brevo_api_key_here
BREVO_SENDER_EMAIL=noreply@yourdomain.com
BREVO_SENDER_NAME=Pocketly
```

### Step 3: Start the Backend

```bash
cd backend/pocketly_api
dart_frog dev
```

That's it! 🎉

## 📱 API Endpoints Ready to Use

### 1. Email Verification (No Auth Required)
```bash
# Request verification code
POST /auth/request-email-verification
Body: {"email": "user@example.com"}

# Verify email with code
POST /auth/verify-email
Body: {"email": "user@example.com", "otp": "123456"}
```

### 2. Password Reset (No Auth Required)
```bash
# Request reset code
POST /auth/request-password-reset
Body: {"email": "user@example.com"}

# Reset password with code
POST /auth/reset-password
Body: {
  "email": "user@example.com",
  "otp": "123456",
  "newPassword": "newSecurePassword123"
}
```

## 🧪 Testing

**Quick Test with cURL:**

**Email Verification:**
```bash
# 1. Request verification code
curl -X POST http://localhost:8080/auth/request-email-verification \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'

# 2. Check your email for the OTP

# 3. Verify email
curl -X POST http://localhost:8080/auth/verify-email \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "otp": "123456"}'
```

**Password Reset:**
```bash
# 1. Request password reset
curl -X POST http://localhost:8080/auth/request-password-reset \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'

# 2. Check your email for the OTP

# 3. Reset password
curl -X POST http://localhost:8080/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "otp": "123456",
    "newPassword": "newPassword123"
  }'
```

## 📋 Features

- **Security**: OTPs are hashed, expire in 10 minutes, max 3 attempts
- **Rate Limiting**: Max 3 OTP requests per 15 minutes per email
- **Auto Cleanup**: Old/expired OTPs are automatically deleted
- **Beautiful Emails**: Modern HTML templates with Apple-inspired design
- **User Verification**: Users table now tracks email verification status

## 🎨 Email Preview

Your users will receive beautifully designed emails with:
- Large, easy-to-read 6-digit code
- Clear expiration warning (10 minutes)
- Professional branding
- Mobile-responsive design

## 📚 Full Documentation

For detailed API documentation, security features, and implementation details, see:
- `OTP_IMPLEMENTATION.md` - Complete technical documentation

## 🔧 Troubleshooting

**"Email not sending":**
- Verify your Brevo API key is correct
- Check that BREVO_SENDER_EMAIL is verified in your Brevo account
- Check backend logs for error messages

**"OTP expired":**
- OTPs expire after 10 minutes
- Request a new code

**"Too many requests":**
- Rate limit is 3 OTPs per 15 minutes per email
- Wait a few minutes and try again

## 🎯 Next Steps

1. **Frontend Integration**: Implement UI for OTP input
2. **Optional**: Add OTP to registration flow (send verification email on signup)
3. **Optional**: Require email verification for sensitive operations
4. **Production**: Use proper environment variable management

## 🔒 Production Checklist

Before deploying to production:
- ✅ Use strong Brevo API key
- ✅ Set proper sender email (verified domain)
- ✅ Enable HTTPS
- ✅ Monitor email delivery rates
- ✅ Set up proper logging
- ✅ Test all flows thoroughly

---

**Need Help?** Check the full documentation in `OTP_IMPLEMENTATION.md`


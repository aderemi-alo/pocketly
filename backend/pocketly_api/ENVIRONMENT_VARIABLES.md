# Environment Variables Configuration

## Required Environment Variables

Copy and set these environment variables before running the backend:

```bash
# Database Configuration
export DB_NAME="gray-horst.db"

# JWT Authentication
export JWT_SECRET_KEY="your_secret_key_change_in_production"

# Brevo Email Service (NEW - Required for OTP functionality)
export BREVO_API_KEY="your_brevo_api_key_here"
export BREVO_SENDER_EMAIL="noreply@yourdomain.com"
export BREVO_SENDER_NAME="Pocketly"
```

## How to Get Brevo Credentials

1. **Create Account**: Sign up at [Brevo](https://app.brevo.com/account/register)
2. **Get API Key**: 
   - Go to Settings → SMTP & API → API Keys
   - Click "Create a new API key"
   - Copy the key
3. **Verify Sender Email**: 
   - Go to Settings → Sender & IP
   - Add and verify your sender email address

## Setting Environment Variables

### macOS/Linux (Terminal)

```bash
# Add to your ~/.zshrc or ~/.bashrc for persistence
export BREVO_API_KEY="xkeysib-xxxxx"
export BREVO_SENDER_EMAIL="noreply@yourdomain.com"
export BREVO_SENDER_NAME="Pocketly"

# Reload shell configuration
source ~/.zshrc  # or source ~/.bashrc
```

### Windows (PowerShell)

```powershell
# Temporary (current session only)
$env:BREVO_API_KEY="xkeysib-xxxxx"
$env:BREVO_SENDER_EMAIL="noreply@yourdomain.com"
$env:BREVO_SENDER_NAME="Pocketly"

# Permanent (system-wide)
[System.Environment]::SetEnvironmentVariable('BREVO_API_KEY', 'xkeysib-xxxxx', 'User')
```

### IDE Configuration (VS Code / Cursor)

Create a launch configuration in `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Dart Frog Dev",
      "type": "dart",
      "request": "launch",
      "program": "main.dart",
      "env": {
        "DB_NAME": "gray-horst.db",
        "JWT_SECRET_KEY": "your_secret_key",
        "BREVO_API_KEY": "your_brevo_api_key",
        "BREVO_SENDER_EMAIL": "noreply@yourdomain.com",
        "BREVO_SENDER_NAME": "Pocketly"
      }
    }
  ]
}
```

## Verification

To verify your environment variables are set:

```bash
echo $BREVO_API_KEY
echo $BREVO_SENDER_EMAIL
echo $BREVO_SENDER_NAME
```

Should print the values you set.

## Default Values

If environment variables are not set, the following defaults will be used:

- `DB_NAME`: `gray-horst.db`
- `JWT_SECRET_KEY`: `secret-key` ⚠️ **Change in production!**
- `BREVO_API_KEY`: `""` (empty - will cause email sending to fail)
- `BREVO_SENDER_EMAIL`: `noreply@pocketly.app`
- `BREVO_SENDER_NAME`: `Pocketly`

## Security Notes

- ⚠️ **Never commit API keys to version control**
- ⚠️ **Use different API keys for development and production**
- ⚠️ **Rotate keys regularly**
- ⚠️ **Use strong, random JWT secret keys in production**

## Production Deployment

For production environments (Heroku, AWS, Docker, etc.), set environment variables through your hosting platform's configuration:

- **Heroku**: `heroku config:set BREVO_API_KEY=your_key`
- **Docker**: Use `-e` flag or `env_file`
- **AWS**: Use Secrets Manager or Parameter Store
- **Digital Ocean**: App Platform Environment Variables

---

✅ Once configured, your OTP email functionality will work automatically!


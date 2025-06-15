# Firebase Security Guide

This document provides guidance on securely handling Firebase credentials in your Teams Clone signaling server.

## Service Account Keys

Firebase service account keys grant administrative access to your Firebase project. They should be handled with the same level of security as database passwords or API keys.

### DO NOT:

- ❌ Commit service account keys to version control (Git)
- ❌ Share service account keys in public forums or chat
- ❌ Include service account keys in client-side code
- ❌ Use the same service account key for development and production
- ❌ Grant more permissions than necessary to service accounts

### DO:

- ✅ Store service account keys securely outside of your codebase
- ✅ Use environment variables to provide credentials to your application
- ✅ Restrict service account permissions to only what's needed
- ✅ Rotate service account keys periodically
- ✅ Revoke compromised keys immediately

## Setting Up Firebase Securely

### Option 1: Use the Setup Script

The recommended way to set up Firebase credentials is to use our setup script:

```bash
npm run setup-firebase
```

This script will:
1. Guide you through providing your service account JSON
2. Store it securely in a file that's excluded from Git
3. Configure your environment variables

### Option 2: Manual Setup

If you prefer to set up Firebase manually:

1. Save your service account JSON file as `firebase-service-account.json` in the server root directory
2. Ensure this file is listed in your `.gitignore`
3. Add the project ID to your `.env` file:
   ```
   FIREBASE_PROJECT_ID=your-project-id
   ```

### Option 3: Environment Variables (Recommended for Production)

For production environments, use environment variables instead of files:

1. Convert your service account JSON to a string
2. Set it as an environment variable:
   ```
   FIREBASE_SERVICE_ACCOUNT='{"type":"service_account","project_id":"...",...}'
   ```

## If a Key is Compromised

If you believe a service account key has been compromised:

1. Go to the Firebase Console > Project Settings > Service Accounts
2. Find the compromised key and click "Revoke"
3. Generate a new key if needed
4. Update your application with the new key
5. Investigate the potential security breach

## Resources

- [Firebase Admin SDK Documentation](https://firebase.google.com/docs/admin/setup)
- [Google Cloud Service Account Best Practices](https://cloud.google.com/iam/docs/best-practices-for-managing-service-account-keys)
- [OWASP Secrets Management Guide](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html) 
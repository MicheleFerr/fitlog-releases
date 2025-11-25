# 🔐 Security Setup for CI/CD (GitHub Actions)

This document explains how to configure environment variables in GitHub Actions to support the new environment-based Firebase configuration.

## ⚠️ IMPORTANT: Security Changes

As of **2025-11-23**, all Firebase API keys have been **removed from source code** and are now loaded from environment variables at runtime.

**Reason**: API keys hardcoded in source code are a critical security vulnerability (exposed via APK decompilation).

**Solution**: Use `.env` file locally + GitHub Secrets in CI/CD.

---

## 📋 Setup Steps (GitHub Actions)

### Step 1: Add Secrets to GitHub Repository

Navigate to: `Settings → Secrets and variables → Actions → New repository secret`

Add the following secrets:

#### iOS Secrets (Required)
```
FIREBASE_API_KEY_IOS = AIzaSyBrjfQYljHU-Gi-QnmaYcfPqdzDlITWBCo
FIREBASE_APP_ID_IOS = 1:206648824958:ios:6f2be076dc27deefbdf42f
FIREBASE_MESSAGING_SENDER_ID_IOS = 206648824958
FIREBASE_PROJECT_ID_IOS = gymprogressapp-184bc
FIREBASE_STORAGE_BUCKET_IOS = gymprogressapp-184bc.firebasestorage.app
```

#### Android Secrets (Required if building Android)
```
FIREBASE_API_KEY_ANDROID = your-android-api-key
FIREBASE_APP_ID_ANDROID = your-android-app-id
FIREBASE_MESSAGING_SENDER_ID_ANDROID = your-android-sender-id
FIREBASE_PROJECT_ID_ANDROID = your-android-project-id
FIREBASE_STORAGE_BUCKET_ANDROID = your-android-storage-bucket
```

#### Web Secrets (Optional)
```
FIREBASE_API_KEY_WEB = your-web-api-key
FIREBASE_APP_ID_WEB = your-web-app-id
FIREBASE_MESSAGING_SENDER_ID_WEB = your-web-sender-id
FIREBASE_PROJECT_ID_WEB = your-web-project-id
FIREBASE_STORAGE_BUCKET_WEB = your-web-storage-bucket
FIREBASE_MEASUREMENT_ID_WEB = your-web-measurement-id
```

---

### Step 2: Update Existing Workflows

Add the following step **BEFORE** any Flutter build step in your workflow files:

```yaml
- name: 🔐 Create .env file from secrets
  run: |
    cat > .env << EOF
    # Firebase iOS
    FIREBASE_API_KEY_IOS=${{ secrets.FIREBASE_API_KEY_IOS }}
    FIREBASE_APP_ID_IOS=${{ secrets.FIREBASE_APP_ID_IOS }}
    FIREBASE_MESSAGING_SENDER_ID_IOS=${{ secrets.FIREBASE_MESSAGING_SENDER_ID_IOS }}
    FIREBASE_PROJECT_ID_IOS=${{ secrets.FIREBASE_PROJECT_ID_IOS }}
    FIREBASE_STORAGE_BUCKET_IOS=${{ secrets.FIREBASE_STORAGE_BUCKET_IOS }}

    # Firebase Android
    FIREBASE_API_KEY_ANDROID=${{ secrets.FIREBASE_API_KEY_ANDROID }}
    FIREBASE_APP_ID_ANDROID=${{ secrets.FIREBASE_APP_ID_ANDROID }}
    FIREBASE_MESSAGING_SENDER_ID_ANDROID=${{ secrets.FIREBASE_MESSAGING_SENDER_ID_ANDROID }}
    FIREBASE_PROJECT_ID_ANDROID=${{ secrets.FIREBASE_PROJECT_ID_ANDROID }}
    FIREBASE_STORAGE_BUCKET_ANDROID=${{ secrets.FIREBASE_STORAGE_BUCKET_ANDROID }}

    # Environment
    ENV=production
    EOF

    echo "✅ .env file created (secrets injected)"
```

**Example workflow** (add after checkout step):

```yaml
name: Flutter Build

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: 📥 Checkout code
        uses: actions/checkout@v3

      # ========================================
      # 🔐 SECURITY: Inject environment variables
      # ========================================
      - name: 🔐 Create .env file from secrets
        run: |
          cat > .env << EOF
          FIREBASE_API_KEY_IOS=${{ secrets.FIREBASE_API_KEY_IOS }}
          FIREBASE_APP_ID_IOS=${{ secrets.FIREBASE_APP_ID_IOS }}
          FIREBASE_MESSAGING_SENDER_ID_IOS=${{ secrets.FIREBASE_MESSAGING_SENDER_ID_IOS }}
          FIREBASE_PROJECT_ID_IOS=${{ secrets.FIREBASE_PROJECT_ID_IOS }}
          FIREBASE_STORAGE_BUCKET_IOS=${{ secrets.FIREBASE_STORAGE_BUCKET_IOS }}
          FIREBASE_API_KEY_ANDROID=${{ secrets.FIREBASE_API_KEY_ANDROID }}
          FIREBASE_APP_ID_ANDROID=${{ secrets.FIREBASE_APP_ID_ANDROID }}
          FIREBASE_MESSAGING_SENDER_ID_ANDROID=${{ secrets.FIREBASE_MESSAGING_SENDER_ID_ANDROID }}
          FIREBASE_PROJECT_ID_ANDROID=${{ secrets.FIREBASE_PROJECT_ID_ANDROID }}
          FIREBASE_STORAGE_BUCKET_ANDROID=${{ secrets.FIREBASE_STORAGE_BUCKET_ANDROID }}
          ENV=production
          EOF

      # ========================================
      # 📱 Flutter Setup & Build
      # ========================================
      - name: 🔧 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: 📦 Install dependencies
        run: flutter pub get

      - name: 🏗️ Build APK
        run: flutter build apk --release
```

---

### Step 3: Verify Secrets Are Not Logged

**⚠️ IMPORTANT**: GitHub Actions automatically masks secrets in logs, but verify:

1. Check workflow logs for `***` (secrets are masked)
2. Never echo or print secrets directly
3. Use `echo "✅ .env created"` instead of `cat .env`

**Bad** ❌:
```yaml
- run: cat .env  # NEVER DO THIS - logs secrets!
```

**Good** ✅:
```yaml
- run: |
    cat > .env << EOF
    FIREBASE_API_KEY_IOS=${{ secrets.FIREBASE_API_KEY_IOS }}
    EOF
    echo "✅ .env file created"  # Safe - doesn't log content
```

---

## 🧪 Testing Locally vs CI

### Local Development
1. Copy `.env.example` to `.env`
2. Fill in your Firebase credentials
3. `.env` is gitignored (never committed)

### CI/CD (GitHub Actions)
1. Configure GitHub Secrets (Step 1 above)
2. Workflow creates `.env` from secrets at build time
3. No secrets ever committed to git

---

## 🔍 Troubleshooting

### Build fails with "Environment variable not found"

**Cause**: GitHub Secrets not configured or misspelled.

**Fix**:
1. Go to `Settings → Secrets and variables → Actions`
2. Verify all required secrets are present
3. Check spelling matches exactly: `FIREBASE_API_KEY_IOS` (not `FIREBASE_API_KEY_ios`)

### Build succeeds but Firebase fails at runtime

**Cause**: Invalid or placeholder API keys.

**Fix**:
1. Verify secrets contain **actual** Firebase credentials (not placeholders like `your-api-key-here`)
2. Check Firebase Console for correct project credentials

---

## 📚 Related Files

- **Local .env setup**: `.env.example` (template)
- **Environment loader**: `lib/core/config/environment_config.dart`
- **Firebase config**: `lib/core/config/firebase_config.dart`
- **Main app entry**: `lib/main.dart` (calls `EnvironmentConfig.load()`)

---

## ✅ Verification Checklist

After setup, verify:

- [ ] GitHub Secrets configured (all required keys)
- [ ] Workflow file updated with `.env` creation step
- [ ] Build logs show `✅ .env file created` (not secret values!)
- [ ] APK builds successfully in CI
- [ ] No secrets logged in workflow output
- [ ] `grep -r "AIzaSy" .github/` returns empty (no hardcoded keys)

---

**Last updated**: 2025-11-23
**Security vulnerability fix**: Task 1.3 - CI/CD Pipeline Update

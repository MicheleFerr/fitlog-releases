# Privacy Policy for GymBro TrackLog

**Last Updated: January 21, 2025**

## 1. Introduction

Welcome to GymBro TrackLog ("GymBro", "we", "our", or "us"). We respect your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, and safeguard your information when you use our mobile application.

**Contact Information:**
- Email: privacy@gymbro.app
- Developer: Michele Cozzolino
- Location: European Union (GDPR Compliant)

## 2. Information We Collect

### 2.1 Information You Provide
- **Account Information**: Email address, display name, profile photo (optional)
- **Workout Data**: Exercise records, sets, reps, weights, workout templates
- **Preferences**: App settings, language preference, theme selection
- **Premium Subscription**: Purchase history, subscription status

### 2.2 Information Collected Automatically
- **Usage Data**: App interactions, feature usage, crash reports
- **Device Information**: Device type, operating system, app version
- **Performance Data**: App performance metrics (anonymized)

### 2.3 Information We DON'T Collect
- ❌ Location data
- ❌ Health data from other apps (unless explicitly shared)
- ❌ Contacts or address book
- ❌ Camera roll or photos (except profile photo if chosen)
- ❌ Microphone recordings

## 3. How We Use Your Information

### 3.1 Primary Uses
- **Service Provision**: To provide workout tracking functionality
- **Cloud Sync**: To sync your data across devices (Premium feature)
- **Backup**: To backup your workout data (Premium feature)
- **Personalization**: To customize your app experience
- **Communication**: To send important service updates

### 3.2 Secondary Uses
- **Analytics**: To improve app performance and features (anonymized)
- **Support**: To respond to your requests and issues
- **Legal**: To comply with legal obligations

## 4. Data Storage and Security

### 4.1 Storage Locations
- **Local Storage**: Your device using encrypted Hive database
- **Cloud Storage**: Google Firebase (for Premium users only)
- **Servers Location**: EU and US data centers

### 4.2 Security Measures
- ✅ End-to-end encryption for sensitive data
- ✅ Secure HTTPS connections
- ✅ Firebase Security Rules
- ✅ Regular security audits
- ✅ Password authentication
- ✅ Optional biometric authentication

### 4.3 Data Retention
- **Active Accounts**: Data retained while account is active
- **Inactive Accounts**: Deleted after 2 years of inactivity
- **Deleted Accounts**: Data removed within 30 days
- **Backups**: Retained for 90 days after deletion

## 5. Data Sharing and Third Parties

### 5.1 We Share Data With:
- **Firebase (Google)**: For authentication and cloud storage
- **Apple/Google**: For in-app purchases only
- **Analytics (Anonymous)**: Crashlytics for crash reporting

### 5.2 We DON'T Share Data With:
- ❌ Advertisers
- ❌ Data brokers
- ❌ Social media platforms
- ❌ Marketing companies
- ❌ Any other third parties

### 5.3 Legal Disclosure
We may disclose your information if required by law, court order, or government request.

## 6. Your Rights (GDPR/CCPA)

You have the right to:
- ✅ **Access**: Request a copy of your data
- ✅ **Rectification**: Correct inaccurate data
- ✅ **Erasure**: Delete your account and data
- ✅ **Portability**: Export your workout data
- ✅ **Restriction**: Limit how we use your data
- ✅ **Object**: Opt-out of certain data uses

### How to Exercise Your Rights:
1. In-app: Settings → Privacy → Manage Data
2. Email: privacy@gymbro.app
3. Response time: Within 30 days

## 7. Children's Privacy

GymBro is not intended for children under 13 (or 16 in EU). We do not knowingly collect data from children. If you believe we have collected data from a child, please contact us immediately.

## 8. International Data Transfers

If you're located outside the United States or European Union, your data may be transferred to and processed in these regions. We ensure appropriate safeguards are in place for such transfers.

## 9. California Privacy Rights

California residents have additional rights under CCPA:
- Right to know what personal information is collected
- Right to know if personal information is sold (we don't sell data)
- Right to opt-out of sale (not applicable - we don't sell data)
- Right to non-discrimination

## 10. Premium Features and Payment

### 10.1 Payment Processing
- Payments are processed by Apple App Store or Google Play Store
- We don't store credit card information
- Purchase history is stored for subscription management

### 10.2 Cloud Sync (Premium Only)
- Premium users' data is synced to Firebase
- Free users' data remains only on device
- Upgrade/downgrade doesn't affect existing data

## 11. Data Breach Notification

In the unlikely event of a data breach:
- We will notify affected users within 72 hours
- Notification via email and in-app message
- Details about what data was affected
- Steps we're taking to address the breach
- Recommendations for users

## 12. Cookies and Tracking

The mobile app does not use cookies. We use:
- Local storage for app preferences
- Analytics SDK for anonymous usage data
- No advertising trackers
- No cross-app tracking

## 13. Changes to This Policy

We may update this policy periodically. We will notify you of material changes via:
- In-app notification
- Email (for registered users)
- Update notice in app store

## 14. Open Source and Transparency

GymBro believes in transparency:
- Our privacy practices are open for review
- We respond to all privacy inquiries
- Annual transparency report available upon request

## 15. Contact Us

For privacy concerns or questions:

**Data Protection Officer**
- Email: privacy@gymbro.app
- Response time: 24-48 hours

**Developer Contact**
- Michele Cozzolino
- Email: michele.cozzolino93@gmail.com
- GitHub: @michelecozzolino

**Mailing Address**
```
GymBro TrackLog
[Address to be provided]
European Union
```

## 16. Consent

By using GymBro TrackLog, you consent to this Privacy Policy. If you disagree with any part of this policy, please discontinue use of the application.

## Appendix: Body Measurements — GDPR Data Processing

### Data Collected

| Field | Type | Purpose | Encrypted |
|-------|------|---------|-----------|
| Metric Type | enum | Identify measurement category | No (needed for queries) |
| Value | double | User's body measurement | Yes (AES-256-GCM) |
| Unit | string | Unit of measurement (kg, cm, %) | Yes (AES-256-GCM) |
| Timestamp | datetime | When measurement was taken | No (needed for sorting) |
| Source | enum | Origin: manual, HealthKit, etc. | Yes (AES-256-GCM) |
| Notes | string | Optional user notes | Yes (AES-256-GCM) |

### Metric Groups & Consent

Body measurements use **granular, just-in-time consent** (GDPR Article 7):

- **Essential** (6 metrics): Weight, Body Fat, Height, Lean Mass, BMI, BMR — requested during onboarding
- **Measurements** (14 metrics): Circumferences (neck, chest, waist, etc.) — requested on first use
- **Vitals** (3 metrics): Body Temp, Water Mass, Bone Mass — requested on first use

Each group requires **explicit opt-in**. Default state is `notAsked` (no data collected until user consents).

### Encryption

All sensitive values are encrypted with **AES-256-GCM** before storage:
- **Local storage**: Encrypted Hive database
- **Cloud storage**: Encrypted Firestore documents
- **Key management**: Device Secure Enclave (iOS) / Keystore (Android)
- **Key rotation**: Every 90 days

### Retention Policy

- **Active measurements**: Retained while user account is active
- **Soft-deleted measurements**: Retained 30 days, then permanently deleted
- **Expired soft-deletes**: Cleaned up automatically via `cleanupExpiredMeasurements`
- **Audit logs**: Retained 2 years after account deletion (GDPR Article 30)

### User Rights

| Right | Implementation | How to Exercise |
|-------|---------------|-----------------|
| **Access** (Art. 15) | View all measurements in-app | Settings > Privacy > View Data |
| **Portability** (Art. 20) | `MeasurementExportService` exports JSON | Settings > Privacy > Export Data |
| **Erasure** (Art. 17) | `MeasurementDeletionService` cascade-deletes all data | Settings > Privacy > Delete Data |
| **Rectification** (Art. 16) | Edit any measurement in-app | Tap measurement > Edit |
| **Restriction** (Art. 18) | Revoke consent per metric group | Settings > Privacy > Consent |
| **Withdraw Consent** (Art. 7.3) | Revoke anytime, measurements scheduled for deletion | Settings > Privacy > Consent |

### Export Format

Data export (Right to Portability) produces a JSON file containing:
- All measurements (value, unit, type, timestamp, source, notes)
- Consent record (groups, granted dates, version)
- Export metadata (timestamp, format version, GDPR article reference)

### Firestore Security Rules

- Users can only read/write their **own** measurements
- Consent records are **never deletable** via client (audit trail preserved)
- Rate limits: max 100 measurements/day, max 10 consent changes/day
- Audit logs are **immutable** (append-only, no updates or deletes)

### Audit Trail (GDPR Article 30)

All data operations are logged with:
- Action type, timestamp (UTC), affected metrics
- IP address (masked: `192.168.1.***`)
- Tamper-evident hash chain (SHA-256)

---

## Appendix A: Data Categories (GDPR Article 13/14)

| Category | Examples | Purpose | Legal Basis |
|----------|----------|---------|-------------|
| Identity | Name, email | Account creation | Contract |
| Contact | Email | Communication | Consent |
| Technical | Device ID, OS | App functionality | Legitimate interest |
| Usage | Workout data | Service provision | Contract |
| Financial | Subscription status | Premium features | Contract |

## Appendix B: Third-Party Services

| Service | Purpose | Data Shared | Privacy Policy |
|---------|---------|-------------|----------------|
| Firebase Auth | Authentication | Email, UID | [Link](https://firebase.google.com/support/privacy) |
| Firebase Firestore | Cloud storage | Workout data (Premium) | [Link](https://firebase.google.com/support/privacy) |
| Crashlytics | Crash reporting | Anonymous crash data | [Link](https://firebase.google.com/support/privacy) |
| App Store/Play Store | Payments | Purchase info | Platform policies |

---

**Privacy Policy Version**: 1.0.0
**Effective Date**: January 21, 2025
**Language**: English (Translations available in Italian)
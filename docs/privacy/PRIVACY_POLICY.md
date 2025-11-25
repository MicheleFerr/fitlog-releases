# Privacy Policy

**Effective Date**: January 24, 2025
**Last Updated**: January 24, 2025
**Version**: 1.0

---

## 1. Introduction

This Privacy Policy describes how FitLog Pro ("we", "our", or "us") collects, uses, processes, and protects your personal information when you use our mobile application (the "App").

We are committed to protecting your privacy and complying with the General Data Protection Regulation (GDPR) EU 2016/679, the California Consumer Privacy Act (CCPA), and other applicable privacy laws.

**Controller Information**:
- **App Name**: FitLog Pro
- **Developer**: [Your Company Name]
- **Contact Email**: privacy@fitlogpro.com
- **Address**: [Your Address]

By using the App, you consent to the data practices described in this policy.

---

## 2. Information We Collect

### 2.1 Personal Information (Directly Provided)

When you use the App, you may voluntarily provide the following personal information:

#### Essential Metrics (Requested during onboarding)
- **Weight** (kg or lbs)
- **Body Fat Percentage** (%)
- **Height** (cm or inches)
- **Lean Mass** (kg)
- **BMI** (calculated)
- **BMR** (kcal/day, calculated)

#### Body Measurements (Requested on-demand, Just-in-Time consent)
- **Circumferences**: Neck, Shoulders, Chest, Waist, Abdomen, Hips, Biceps (L/R), Forearms (L/R), Thighs (L/R), Calves (L/R)

#### Vitals (Requested on-demand, Just-in-Time consent)
- **Body Temperature** (°C or °F)
- **Water Mass** (%)
- **Bone Mass** (kg)

#### Optional Information
- **Notes**: Text annotations for measurements (e.g., "Post-workout weight")
- **Photos**: Progress photos (stored locally only, not transmitted)

### 2.2 Technical Information (Automatically Collected)

- **Device Information**: Device model, operating system (iOS/Android), app version
- **Usage Data**: Features used, timestamps of actions (aggregated, anonymized)
- **Crash Reports**: Technical error logs (no personal data)

### 2.3 Health Platform Integration (Opt-In Only)

With your explicit consent, we may sync data with:

- **Apple HealthKit** (iOS): Weight, Body Fat %, Height
- **Google Health Connect** (Android): Weight, Body Fat %, Height

**Important**: You control which metrics are synced. We only access data you explicitly authorize.

---

## 3. Legal Basis for Processing (GDPR Article 6)

We process your personal data based on the following legal grounds:

1. **Consent (Article 6(1)(a))**: You explicitly consent to process specific metrics (Essential, Measurements, Vitals)
2. **Contractual Necessity (Article 6(1)(b))**: Processing is necessary to provide App functionality
3. **Legitimate Interests (Article 6(1)(f))**: Crash reporting and analytics to improve App performance (anonymized)

---

## 4. How We Use Your Information

We use your personal data for the following purposes:

### 4.1 Core Functionality
- **Progress Tracking**: Store and display your body measurements over time
- **Trend Analysis**: Calculate and visualize progress charts (weight loss/gain, body composition)
- **Health Sync**: Sync measurements with Apple HealthKit or Google Health Connect (with consent)

### 4.2 Analytics & Improvement (Anonymized)
- **App Usage Analytics**: Understand which features are most popular (aggregated, no PII)
- **Performance Monitoring**: Detect crashes and bugs (no personal measurements logged)

### 4.3 Security & Compliance
- **Data Encryption**: Encrypt all measurements at rest (AES-256-GCM)
- **Audit Logging**: Track consent changes, data exports, deletions (GDPR compliance)

---

## 5. Data Storage & Encryption (GDPR Article 32)

### 5.1 Encryption at Rest
All personal measurements are encrypted using **AES-256-GCM** (Advanced Encryption Standard with Galois/Counter Mode) before storage:

- **Encryption Keys**: Stored in iOS Secure Enclave or Android Keystore (hardware-backed)
- **Key Rotation**: Automatic key rotation every 90 days
- **Per-User Encryption**: Each user has a unique encryption key (data isolated)

### 5.2 Storage Locations

| Data Type | Storage Location | Encryption |
|-----------|------------------|------------|
| Measurements | Local device (Hive database) | AES-256-GCM |
| Measurements | Firebase Firestore (cloud backup) | AES-256-GCM + TLS |
| Encryption Keys | iOS Secure Enclave / Android Keystore | Hardware-backed |
| Photos | Local device only (never uploaded) | iOS/Android filesystem encryption |

### 5.3 Data Retention

- **Active Measurements**: Retained as long as your account is active
- **Deleted Measurements**: Soft-deleted with 30-day retention period (recoverable if accidental)
- **Permanently Deleted**: After 30 days, or immediately upon request
- **Audit Logs**: Retained for 2 years (GDPR Article 30 compliance)

---

## 6. Data Sharing & Third Parties

We do **NOT** sell your personal data to third parties.

We may share limited data with the following service providers:

### 6.1 Essential Service Providers

| Provider | Purpose | Data Shared | Privacy Policy |
|----------|---------|-------------|----------------|
| **Firebase (Google)** | Cloud database, authentication | User ID, encrypted measurements, email | [Firebase Privacy](https://firebase.google.com/support/privacy) |
| **Apple HealthKit** | Health data sync (iOS only) | Weight, Body Fat %, Height (opt-in) | [Apple Privacy](https://www.apple.com/privacy/) |
| **Google Health Connect** | Health data sync (Android only) | Weight, Body Fat %, Height (opt-in) | [Google Privacy](https://policies.google.com/privacy) |

### 6.2 Analytics (Anonymized)

| Provider | Purpose | Data Shared | Opt-Out |
|----------|---------|-------------|---------|
| **Firebase Analytics** | App usage trends (aggregated) | Device type, app version (no PII) | Settings → Privacy → Analytics |

**Data Minimization**: We strip all Personally Identifiable Information (PII) before analytics transmission. Analytics IDs are hashed and cannot be linked to your identity.

---

## 7. Your Rights Under GDPR (Articles 15-22)

You have the following rights regarding your personal data:

### 7.1 Right to Access (Article 15)
Request a copy of all data we hold about you.

**How**: Settings → Privacy → Export My Data (JSON format)

### 7.2 Right to Rectification (Article 16)
Correct inaccurate or incomplete data.

**How**: Edit measurements directly in the App

### 7.3 Right to Erasure ("Right to be Forgotten", Article 17)
Delete all your personal data.

**How**: Settings → Privacy → Delete All Data

**Options**:
- Soft Delete: 30-day recovery period
- Permanent Delete: Immediate and irreversible

### 7.4 Right to Data Portability (Article 20)
Receive your data in a machine-readable format (JSON).

**How**: Settings → Privacy → Export My Data → JSON format

### 7.5 Right to Restrict Processing (Article 18)
Limit how we process your data (e.g., revoke health sync consent).

**How**: Settings → Privacy → Manage Consent

### 7.6 Right to Object (Article 21)
Object to processing based on legitimate interests (e.g., analytics).

**How**: Settings → Privacy → Analytics → Disable

### 7.7 Right to Withdraw Consent (Article 7(3))
Revoke consent for specific metric groups anytime.

**How**: Settings → Privacy → Manage Consent → Revoke

**Effect**: We will stop syncing revoked metrics with health platforms and delete them within 30 days.

---

## 8. Consent Management (GDPR Article 7)

We implement **Just-in-Time Consent** for optimal user experience:

### 8.1 Consent Groups

| Group | Metrics Included | When Requested | Revocable |
|-------|------------------|----------------|-----------|
| **Essential** | Weight, Body Fat %, Height, Lean Mass, BMI, BMR | Onboarding (first app launch) | ✅ Yes |
| **Measurements** | 13 Circumferences (Neck, Chest, Waist, etc.) | When you tap "Track Body Measurements" | ✅ Yes |
| **Vitals** | Body Temp, Water Mass, Bone Mass | When you tap "Track Vitals" | ✅ Yes |

### 8.2 Consent State Machine

- **Not Asked**: Default state (no consent dialog shown)
- **Granted**: You explicitly accepted (checkbox checked, "Accept" tapped)
- **Denied**: You explicitly declined (consent dialog dismissed)

### 8.3 Consent Audit Trail

We log the following for compliance (GDPR Article 30):

- Timestamp of consent (ISO 8601 format)
- IP address (last octet masked: `192.168.1.***`)
- Device type and app version
- User agent string

**Purpose**: Prove compliance in case of regulatory audit.

---

## 9. Children's Privacy (COPPA)

FitLog Pro is **NOT** intended for children under 13 years old. We do not knowingly collect personal information from children.

If you are a parent and believe your child has provided us with personal data, contact us at privacy@fitlogpro.com and we will delete it within 30 days.

---

## 10. International Data Transfers (GDPR Article 44-50)

Your data may be transferred to and stored in countries outside the European Economic Area (EEA):

| Service | Location | Safeguards |
|---------|----------|------------|
| **Firebase (Google Cloud)** | USA (multi-region) | EU-U.S. Data Privacy Framework, Standard Contractual Clauses (SCCs) |

We ensure adequate protection through:
- **Standard Contractual Clauses** (EU Commission approved)
- **Encryption in Transit**: TLS 1.3
- **Encryption at Rest**: AES-256-GCM

---

## 11. Data Breach Notification (GDPR Article 33-34)

In the event of a data breach affecting your personal data:

- We will notify the relevant supervisory authority within **72 hours**
- We will notify you directly if the breach poses a **high risk** to your rights
- Notification will include: nature of breach, likely consequences, mitigation measures

**Contact**: privacy@fitlogpro.com

---

## 12. Automated Decision-Making (GDPR Article 22)

We do **NOT** use automated decision-making or profiling that produces legal effects or significantly affects you.

---

## 13. Cookies & Tracking Technologies

The App does **NOT** use cookies (web-based tracking).

We use the following local storage technologies:

| Technology | Purpose | Data Stored | Can Delete |
|-----------|---------|-------------|------------|
| **Hive** (local database) | Store measurements | Encrypted measurements | ✅ Yes (Settings → Delete Data) |
| **Secure Storage** | Store encryption keys | AES-256 keys | ❌ No (deleted with app) |
| **UserDefaults** (iOS) / SharedPreferences (Android) | App settings | Language preference, theme | ✅ Yes (Settings → Reset) |

---

## 14. Third-Party Links

The App may contain links to third-party websites (e.g., privacy policy links for Firebase, HealthKit).

We are **NOT** responsible for the privacy practices of these third parties. Please review their privacy policies.

---

## 15. Changes to This Privacy Policy

We may update this Privacy Policy from time to time. Changes will be effective immediately upon posting in the App.

**Notification**: You will be prompted to review and re-accept the updated policy upon next app launch.

**Version History**:
- **v1.0** (Jan 24, 2025): Initial GDPR-compliant policy

---

## 16. Contact Us

If you have any questions about this Privacy Policy or wish to exercise your rights, contact us:

**Email**: privacy@fitlogpro.com
**Subject Line**: "Privacy Request - [Your Request Type]"
**Response Time**: Within 30 days

**Supervisory Authority** (EU users):
You have the right to lodge a complaint with your local data protection authority if you believe we have violated GDPR.

- **Find your authority**: https://edpb.europa.eu/about-edpb/board/members_en

---

## 17. California Residents (CCPA)

If you are a California resident, you have additional rights under the California Consumer Privacy Act (CCPA):

- **Right to Know**: Categories of personal information collected
- **Right to Delete**: Delete personal information
- **Right to Opt-Out**: Opt-out of sale of personal information (we do not sell data)
- **Non-Discrimination**: We will not discriminate against you for exercising your rights

**Contact**: privacy@fitlogpro.com (Subject: "CCPA Request")

---

## 18. Acknowledgment

By using FitLog Pro, you acknowledge that you have read, understood, and agree to be bound by this Privacy Policy.

---

**Document Version**: 1.0
**Last Reviewed**: January 24, 2025
**Next Review Date**: July 24, 2025 (6-month review cycle)

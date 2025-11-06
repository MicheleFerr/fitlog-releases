# PRIVACY POLICY - FITlog Pro

**Last updated**: November 6, 2025
**Data Controller**: [Developer Name], Brescia (BS), Italy
**Email**: privacy@fitlogpro.com

---

## 1. INTRODUCTION

Pursuant to EU Regulation 2016/679 (GDPR) and Italian Legislative Decree 196/2003 (Italian Privacy Code), this privacy policy describes how FITlog Pro collects, uses, and protects your personal data.

**FITlog Pro is a workout tracking app**. It does NOT provide medical advice, workout plans, or templates. Users are responsible for their own safety during training.

---

## 2. DATA COLLECTED

### 2.1 Registration Data
- **Email**: For Firebase authentication (required)
- **Firebase UID**: Unique user identifier (auto-generated)
- **Registration date**: Account creation timestamp

### 2.2 Workout Data (Optional)
- **Exercise name**: Manually entered by user
- **Sets, reps, weight**: Numeric values manually entered
- **Workout notes**: Free text entered by user
- **Workout date/time**: Training timestamp

**⚠️ IMPORTANT**: This data is considered "personal data" but NOT "sensitive health data" under GDPR Art. 9, as users voluntarily enter it for tracking purposes, not for medical purposes.

### 2.3 Technical Data
- **IP Address**: Collected by Firebase for security (retained 30 days)
- **Device ID**: For app functionality (not shared)
- **App/OS version**: For technical support

### 2.4 Data NOT Collected
- ❌ Biometric data (heart rate, calories)
- ❌ Health data (injuries, conditions)
- ❌ Tracking cookies (no Analytics, no Ads)
- ❌ Geolocation
- ❌ Contacts, photos, microphone

---

## 3. PROCESSING PURPOSES AND LEGAL BASIS

| Purpose | Legal Basis (GDPR Art. 6) | Data Used |
|---------|---------------------------|-----------|
| User authentication | Contract performance | Email, UID |
| Workout saving | Contract performance | Workout data |
| Technical support | Legitimate interest | Email, device info |
| Account security | Legitimate interest | IP, login timestamp |

**No automated profiling** (GDPR Art. 22): FITlog Pro does NOT make automated decisions based on your data.

---

## 4. WHERE YOUR DATA IS STORED

### 4.1 Local Database (Hive)
- **Location**: On your smartphone (internal storage)
- **Content**: All workout logs, settings, preferences
- **Deletion**: App uninstall = automatic deletion

### 4.2 Firebase Cloud (Google)
- **Location**: Google Cloud servers (EU Region - Frankfurt)
- **Content**: Email, UID, authentication timestamps
- **Protection**: TLS 1.3 encryption in transit, AES-256 at rest
- **DPA**: Data Processing Agreement signed with Google (GDPR Art. 28)
- **Retention**: Data retained until account deletion

**⚠️ Extra-EU Transfers**: Google may transfer data to USA for server maintenance, using EU-approved Standard Contractual Clauses (SCC).

---

## 5. DATA SHARING WITH THIRD PARTIES

**FITlog Pro does NOT share your data with third parties**, except:

| Third Party | Purpose | Data Shared | Legal Basis |
|-------------|---------|-------------|-------------|
| Google Firebase | Authentication, database | Email, UID, IP | DPA Art. 28 GDPR |
| Apple/Google (IAP) | Subscription payments | Transaction ID (no personal data) | Contract performance |

**NO data selling**, **NO advertising**, **NO behavioral tracking**.

---

## 6. YOUR RIGHTS (GDPR Arts. 15-22)

You have the right to:

### 6.1 Access (Art. 15)
Request copy of all your data: **Settings → Privacy → Export Data**

### 6.2 Rectification (Art. 16)
Correct inaccurate data: Edit directly in app

### 6.3 Erasure (Art. 17 - "Right to be Forgotten")
Delete account and data: **Settings → Account → Delete Account**
- Effect: Immediate deletion of local database + Firebase (30 days for backups)

### 6.4 Restriction (Art. 18)
Temporarily suspend processing: Contact privacy@fitlogpro.com

### 6.5 Portability (Art. 20)
Export data in JSON format: **Settings → Privacy → Export Data**

### 6.6 Object (Art. 21)
Object to processing for legitimate interest: Contact privacy@fitlogpro.com

### 6.7 Complaint (Art. 77)
File complaint with: **Italian Privacy Authority (Garante)** - garante@gpdp.it - Tel. +39 06 696771

---

## 7. DATA SECURITY

Technical and organizational measures (GDPR Art. 32):
- ✅ End-to-end encryption (TLS 1.3)
- ✅ Firebase authentication (bcrypt password hashing)
- ✅ Firestore Security Rules (user data isolation)
- ✅ Rate limiting (brute-force protection)
- ✅ Daily backups (30-day retention)
- ✅ Audit logging (admin access)

**Data Breach Notification**: In case of data breach, notification within 72 hours to Privacy Authority + affected users.

---

## 8. DATA RETENTION

| Data Type | Retention | Reason |
|-----------|-----------|--------|
| Active account | Until deletion | Service execution |
| Inactive account | 24 months inactivity → deletion | GDPR minimization |
| Backups | 30 days | Disaster recovery |
| Security logs | 12 months | Legal compliance |

---

## 9. MINORS (Under-18)

**FITlog Pro prohibits registration under age 14** (GDPR Art. 8 + Italian Privacy Code).

**Ages 14-17**: Allowed with:
- Truthful age declaration
- **Parental responsibility**: Parents are responsible for minors' use of the app
- Enhanced disclaimer (injury risk)

If we discover a user under 14, we will immediately delete the account.

---

## 10. PRIVACY POLICY CHANGES

Updates: In-app notification 30 days before. Continuing to use app = acceptance of new policy.

**Current version**: 1.0 (November 6, 2025)
**Version history**: docs/legal/PRIVACY_POLICY_CHANGELOG.md

---

## 11. CONTACTS

**Data Controller**:
- Name: [Developer Name]
- Address: Via [Address], Brescia (BS), Italy
- Email: privacy@fitlogpro.com
- PEC: [PEC if available]

**Data Protection Officer (DPO)**: Not required (single developer, <10,000 users)

**Italian Privacy Authority (Garante)**:
- Website: https://www.garanteprivacy.it
- Email: garante@gpdp.it
- Phone: +39 06 696771

---

**EXPLICIT CONSENT**

By using FITlog Pro, you declare that you:
- ✅ Have read and understood this privacy policy
- ✅ Consent to the data processing described
- ✅ Are at least 14 years old (or have parental consent if 14-17)
- ✅ Accept the Terms of Service

**Consent date**: [Automatically recorded at registration]

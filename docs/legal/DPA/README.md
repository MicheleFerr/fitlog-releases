# Data Processing Agreement (DPA) Documentation

## Overview

This folder documents FitLog Pro's Data Processing Agreement with Google LLC for Firebase services, as required by GDPR Article 28.

---

## Google Firebase DPA Status

| Item | Status | Date |
|------|--------|------|
| **DPA Accepted** | Yes | Automatic on Firebase project creation |
| **SCCs Included** | Yes | Module 2 (Controller-to-Processor) |
| **EU-US DPF Certified** | Yes | Google certified July 2023 |

---

## How Google Firebase DPA Works

Unlike traditional DPAs that require manual signature, Google's Data Processing Terms are:

1. **Automatically Incorporated** when you create a Firebase project
2. **Updated by Google** with notice to customers
3. **Include SCCs** for international transfers

---

## Key Documents

### 1. Google Cloud Data Processing Addendum
- **URL**: https://cloud.google.com/terms/data-processing-addendum
- **Version**: As of your project creation date
- **Contains**:
  - Data processing obligations
  - Security measures
  - Sub-processor list
  - Audit rights
  - Standard Contractual Clauses (Appendix)

### 2. Firebase Data Processing Information
- **URL**: https://firebase.google.com/support/privacy
- **Contains**:
  - Data collected per Firebase service
  - Data retention periods
  - Data location information

### 3. Google Sub-processor List
- **URL**: https://cloud.google.com/terms/subprocessors
- **Contains**: List of all sub-processors used by Google Cloud/Firebase

### 4. Standard Contractual Clauses
- **URL**: https://cloud.google.com/terms/data-processing-addendum (Appendix 3)
- **Version**: EU Commission SCCs 2021 (Decision 2021/914)
- **Module**: Module 2 (Controller to Processor)

---

## Verification Steps

To verify DPA acceptance:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to Settings > Project Settings > Service Accounts
4. The Terms of Service link shows accepted terms

---

## Our Obligations Under the DPA

As the Data Controller, FitLog Pro must:

| Obligation | Implementation |
|------------|----------------|
| **Lawful Processing** | Consent flows for all data collection |
| **Data Subject Rights** | In-app access, export, delete features |
| **Breach Notification** | Monitor Firebase status, notify within 72h |
| **Security Measures** | Firestore Security Rules, app security |
| **Data Minimization** | Only collect necessary workout data |
| **Retention Limits** | 24-month retention policy |

---

## Google's Obligations Under the DPA

As the Data Processor, Google must:

| Obligation | Reference |
|------------|-----------|
| **Process only on instructions** | DPA Section 5.2 |
| **Confidentiality** | DPA Section 6 |
| **Security measures** | DPA Section 7 (SOC 2, ISO 27001) |
| **Sub-processor restrictions** | DPA Section 11 |
| **Assist with data subject rights** | DPA Section 9 |
| **Data deletion on termination** | DPA Section 10 |
| **Audit rights** | DPA Section 7.5 |

---

## Firebase Services Covered

| Service | Data Processed | DPA Coverage |
|---------|---------------|--------------|
| Firebase Authentication | Email, OAuth tokens | Yes |
| Cloud Firestore | User data, workouts | Yes |
| Firebase Storage | Progress photos | Yes |
| Firebase Analytics | Usage events | Yes |
| Firebase Crashlytics | Crash logs | Yes |
| Firebase Cloud Messaging | Push tokens | Yes |

---

## Monitoring Requirements

| Activity | Frequency | Owner |
|----------|-----------|-------|
| Check Google DPA updates | Quarterly | Data Protection |
| Review sub-processor changes | Per notification | Data Protection |
| Verify EU-US DPF status | Quarterly | Legal |
| Security posture review | Annual | Technical |

---

## Related Documents

- [Transfer Impact Assessment (TIA)](../TIA_FIREBASE.md)
- [Privacy Policy](../PRIVACY_POLICY_EN.md)
- [Terms of Service](../TERMS_OF_SERVICE_EN.md)

---

## Audit Trail

| Date | Event | Actor |
|------|-------|-------|
| [Project Creation Date] | Firebase DPA accepted | Developer |
| 2025-01-01 | DPA documentation created | Compliance |

---

## Contact

For DPA-related inquiries:
- **FitLog Pro**: privacy@fitlogpro.app
- **Google**: https://firebase.google.com/support

---

*Last updated: 2025-01-01*

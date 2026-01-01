# Transfer Impact Assessment (TIA) - Firebase Services

**Document Version**: 1.0
**Created**: 2025-01-01
**Last Updated**: 2025-01-01
**Owner**: FitLog Pro Data Protection Team
**Status**: Active

---

## 1. Executive Summary

This Transfer Impact Assessment (TIA) documents the legal basis, risks, and supplementary measures for transferring personal data from the European Union (EU) to the United States (US) via Google Firebase services, in compliance with:

- **GDPR Articles 44-49** (Transfers to third countries)
- **Schrems II judgment** (CJEU Case C-311/18, July 2020)
- **EDPB Recommendations 01/2020** (Supplementary measures)

---

## 2. Data Controller Information

| Field | Value |
|-------|-------|
| **Controller Name** | FitLog Pro (FitLog TrackLog) |
| **Controller Type** | Mobile Application Developer |
| **Data Protection Contact** | privacy@fitlogpro.app |
| **EU Representative** | N/A (single user testing phase) |

---

## 3. Data Processor Information

| Field | Value |
|-------|-------|
| **Processor Name** | Google LLC (Firebase) |
| **Processor Address** | 1600 Amphitheatre Parkway, Mountain View, CA 94043, USA |
| **Privacy Contact** | https://firebase.google.com/support/privacy |
| **DPA Status** | Standard Data Processing Terms accepted |

---

## 4. Categories of Data Transferred

### 4.1 Personal Data (GDPR Art. 6)

| Data Category | Examples | Legal Basis |
|--------------|----------|-------------|
| **Account Data** | Email, display name, profile photo URL | Contract (Art. 6(1)(b)) |
| **Authentication Data** | Hashed passwords, OAuth tokens | Contract (Art. 6(1)(b)) |
| **Workout Data** | Exercise names, sets, reps, weights | Consent (Art. 6(1)(a)) |
| **Template Data** | Custom workout templates | Consent (Art. 6(1)(a)) |
| **Device Data** | Device type, OS version, app version | Legitimate Interest (Art. 6(1)(f)) |
| **Analytics Data** | App usage patterns (anonymized) | Consent (Art. 6(1)(a)) |

### 4.2 Special Category Data (GDPR Art. 9)

| Data Category | Examples | Legal Basis |
|--------------|----------|-------------|
| **Health Data** | Body weight, body fat %, BMI, circumferences | Explicit Consent (Art. 9(2)(a)) |
| **HealthKit Data** | Heart rate, steps, sleep (if synced) | Explicit Consent (Art. 9(2)(a)) |
| **Progress Photos** | Body photos (potential biometric data) | Explicit Consent (Art. 9(2)(a)) |

---

## 5. Firebase Services Used

| Service | Purpose | Data Location | Encryption |
|---------|---------|---------------|------------|
| **Firebase Authentication** | User login/registration | us-central1 | TLS 1.2+, AES-256 |
| **Cloud Firestore** | Data storage | us-central1 | TLS 1.2+, AES-256 |
| **Firebase Storage** | Progress photos | us-central1 | TLS 1.2+, AES-256 |
| **Firebase Analytics** | Usage analytics | US | TLS 1.2+, aggregated |
| **Firebase Crashlytics** | Crash reporting | US | TLS 1.2+, anonymized |
| **Firebase Cloud Messaging** | Push notifications | US | TLS 1.2+ |

---

## 6. Legal Basis for Transfer

### 6.1 Primary Mechanism: Standard Contractual Clauses (SCCs)

Google Firebase operates under the EU-approved **Standard Contractual Clauses (SCCs)** as updated in 2021 (Commission Decision 2021/914).

**Reference**: [Google Cloud Data Processing Terms](https://cloud.google.com/terms/data-processing-addendum)

### 6.2 Supplementary Legal Framework

Since the EU-US Privacy Shield invalidation (Schrems II), we rely on:

1. **SCCs (Module 2: Controller-to-Processor)** - Primary basis
2. **EU-US Data Privacy Framework (DPF)** - Google is certified (July 2023)
3. **Supplementary Technical Measures** - See Section 8

---

## 7. Risk Assessment

### 7.1 Risk: US Government Access (FISA 702, EO 12333)

| Factor | Assessment |
|--------|------------|
| **Probability** | Low - Fitness app data unlikely target |
| **Impact** | Medium - Health data involved |
| **Overall Risk Level** | **MEDIUM** |

**Justification**:
- FitLog Pro is a consumer fitness app, not a surveillance target
- No political, financial, or national security data processed
- Data is primarily workout logs and body measurements
- No enterprise or government customers

### 7.2 Risk: Data Breach

| Factor | Assessment |
|--------|------------|
| **Probability** | Low - Google's security posture |
| **Impact** | High - Health data exposure |
| **Overall Risk Level** | **MEDIUM** |

**Justification**:
- Google maintains SOC 2 Type II, ISO 27001 certifications
- Data encrypted at rest and in transit
- Firebase has no history of major breaches

### 7.3 Risk: Unauthorized Access by Google

| Factor | Assessment |
|--------|------------|
| **Probability** | Very Low |
| **Impact** | Medium |
| **Overall Risk Level** | **LOW** |

**Justification**:
- Google DPA explicitly prohibits unauthorized access
- Contractual obligations enforceable in EU courts
- Google's business model doesn't rely on fitness data

---

## 8. Supplementary Measures

### 8.1 Technical Measures (Implemented)

| Measure | Description | Status |
|---------|-------------|--------|
| **Encryption in Transit** | TLS 1.2+ for all API calls | Active |
| **Encryption at Rest** | AES-256 on Firestore/Storage | Active (Google default) |
| **Data Minimization** | Only collect necessary data | Active |
| **Pseudonymization** | Firebase UIDs instead of emails in logs | Active |
| **Access Controls** | Firestore Security Rules | Active |
| **Consent Management** | Granular consent per data type | Active |

### 8.2 Technical Measures (Planned)

| Measure | Description | Timeline |
|---------|-------------|----------|
| **End-to-End Encryption** | Client-side encryption for progress photos | Q2 2025 |
| **Data Residency** | Move to Firebase eu-west1 region | Q3 2025 |
| **Zero-Knowledge Backup** | Encrypted backups with user-held keys | Q4 2025 |

### 8.3 Organizational Measures

| Measure | Description | Status |
|---------|-------------|--------|
| **DPA with Google** | Standard Data Processing Terms signed | Active |
| **Privacy Policy** | Transparent data transfer disclosure | Active |
| **Consent Flow** | Art. 9 explicit consent for health data | Active |
| **Data Retention** | 24-month retention policy | Implementing |
| **Right to Erasure** | Delete Account functionality | Implemented |
| **Data Portability** | Export data feature | Implemented |

### 8.4 Contractual Measures

| Measure | Description | Status |
|---------|-------------|--------|
| **SCCs (2021 version)** | Module 2 incorporated via Google DPA | Active |
| **EU-US DPF Certification** | Google LLC certified | Active |
| **Audit Rights** | Per Google DPA Section 7 | Active |
| **Sub-processor List** | Published by Google | Monitored |

---

## 9. Data Subject Rights

Users retain full GDPR rights despite US transfer:

| Right | Implementation |
|-------|----------------|
| **Access (Art. 15)** | In-app data view + export |
| **Rectification (Art. 16)** | Profile edit functionality |
| **Erasure (Art. 17)** | Delete Account feature |
| **Restriction (Art. 18)** | Planned for Q2 2025 |
| **Portability (Art. 20)** | JSON export feature |
| **Object (Art. 21)** | Consent withdrawal in Settings |

---

## 10. Monitoring and Review

| Activity | Frequency | Owner |
|----------|-----------|-------|
| **TIA Review** | Annual | Data Protection |
| **Google DPA Changes** | Per notification | Data Protection |
| **SCCs Validity Check** | Per EDPB guidance | Legal |
| **Security Audit** | Annual | Technical Team |
| **Sub-processor Changes** | Per Google notification | Data Protection |

---

## 11. Decision

Based on this Transfer Impact Assessment:

**DECISION**: The transfer of personal data to Google Firebase (US) is **APPROVED** with the following conditions:

1. **Continue using SCCs** as primary legal basis
2. **Maintain supplementary measures** listed in Section 8
3. **Implement planned measures** per timeline
4. **Review annually** or upon significant legal changes
5. **Monitor EU-US DPF validity** for any Schrems III developments

---

## 12. Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Data Protection | [To be signed] | 2025-01-01 | __________ |
| Technical Lead | [To be signed] | 2025-01-01 | __________ |
| Legal Review | [To be signed] | 2025-01-01 | __________ |

---

## 13. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-01 | FitLog Team | Initial TIA creation |

---

## 14. References

1. **GDPR**: Regulation (EU) 2016/679
2. **Schrems II**: CJEU Case C-311/18 (July 16, 2020)
3. **SCCs 2021**: Commission Decision 2021/914 (June 4, 2021)
4. **EDPB Recommendations 01/2020**: Supplementary measures (November 10, 2020)
5. **EU-US Data Privacy Framework**: Adequacy Decision (July 10, 2023)
6. **Google Cloud DPA**: https://cloud.google.com/terms/data-processing-addendum
7. **Firebase Privacy**: https://firebase.google.com/support/privacy

---

*This document is for internal compliance purposes and should be reviewed by legal counsel before publication.*

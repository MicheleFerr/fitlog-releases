# Legal Compliance Master Checklist - FITlog Pro

**Last updated**: 2025-11-06
**Status**: 🚧 In Progress
**Target**: ✅ Launch-Ready

---

## 🔴 CRITICAL (Before Launch)

### 1. Firebase DPA

- [ ] ✅ Signed Data Processing Agreement with Google Firebase
- [ ] ✅ Downloaded PDF stored in `docs/legal/signed/`
- [ ] ✅ Verified Standard Contractual Clauses (SCC) included
- [ ] 📄 Reference: `docs/legal/DPA_FIREBASE_CHECKLIST.md`

**Deadline**: BEFORE any production user data
**Risk if missing**: €10M-€20M GDPR fine

---

### 2. Privacy Policy

- [ ] ✅ Italian version completed (`docs/legal/PRIVACY_POLICY_IT.md`)
- [ ] ✅ English version completed (`docs/legal/PRIVACY_POLICY_EN.md`)
- [ ] ✅ Published in-app (Settings → Privacy Policy)
- [ ] ✅ Published on website (if exists): [URL]
- [ ] ✅ All placeholders replaced ([Developer Name], [Email], etc.)

**Deadline**: BEFORE launch
**Risk if missing**: €10M GDPR fine + user complaints

---

### 3. Terms of Service

- [ ] ✅ Italian ToS completed (`docs/legal/TERMS_OF_SERVICE_IT.md`)
- [ ] ✅ English ToS completed (`docs/legal/TERMS_OF_SERVICE_EN.md`)
- [ ] ✅ Published in-app (Settings → Terms of Service)
- [ ] ✅ Liability limitation clauses verified
- [ ] ✅ Disclaimer section verified

**Deadline**: BEFORE launch
**Risk if missing**: Difficult legal defense if user dispute

---

### 4. Disclaimer Modal (In-App)

- [ ] ✅ Implemented `LegalDisclaimerModal` widget
- [ ] ✅ Shown during onboarding (first-time users)
- [ ] ✅ Cannot be dismissed by tapping outside (barrierDismissible: false)
- [ ] ✅ Consent tracked with timestamp in Hive
- [ ] ✅ Tested on iOS + Android

**Deadline**: BEFORE launch
**Risk if missing**: Weak legal defense if injury claim

---

### 5. Age Gate

- [ ] ✅ Implemented `AgeGateScreen` widget
- [ ] ✅ Blocks under-14 registration (GDPR Art. 8)
- [ ] ✅ Shows minor warning for 14-17 (parental consent)
- [ ] ✅ Birth date saved in Hive
- [ ] ✅ Tested edge cases (today's date, leap years)

**Deadline**: BEFORE launch
**Risk if missing**: €10M GDPR fine + minor safety liability

---

## 🟠 HIGH PRIORITY (Within 1 Month)

### 6. P.IVA (Partita IVA)

- [ ] ✅ Opened P.IVA Regime Forfettario
- [ ] ✅ Codice ATECO: 62.01.00 (Software production)
- [ ] ✅ Registered with Agenzia Entrate
- [ ] ✅ Subscribed to Gestione Separata INPS

**Deadline**: Before monetization (subscription launch)
**Risk if missing**: €1k-€3k fine + IVA recovery

---

### 7. Assicurazione RC Professionale

- [ ] ✅ Requested quote from 3 companies:
  - [ ] Allianz Tutela Professionale IT
  - [ ] Generali RC Informatici
  - [ ] HDI Polizza IT
- [ ] ✅ Selected policy: [Company Name]
- [ ] ✅ Massimale: €[Amount] (recommended: €500k)
- [ ] ✅ Policy signed and active
- [ ] ✅ Certificate stored: `docs/legal/insurance/`

**Deadline**: Before launch (strongly recommended) OR within 1 month
**Risk if missing**: Unlimited personal liability for user injuries

---

### 8. Consent Tracking System

- [ ] ✅ Implemented `ConsentRepository` (Hive)
- [ ] ✅ Tracks disclaimer acceptance
- [ ] ✅ Tracks Privacy Policy acceptance
- [ ] ✅ Tracks ToS acceptance
- [ ] ✅ Tracks age verification
- [ ] ✅ Records timestamps + IP (optional)
- [ ] ✅ Export function for user data requests (GDPR Art. 15)

**Deadline**: Before launch
**Risk if missing**: Cannot prove user consent (GDPR Art. 7)

---

### 9. Firebase Data Minimization

- [ ] ✅ Disabled Google Analytics (if not needed)
- [ ] ✅ Disabled Crashlytics automatic collection
- [ ] ✅ Disabled Performance Monitoring (if not needed)
- [ ] ✅ Firestore Security Rules: users can only read/write own data
- [ ] ✅ Audit: Verified what data Firebase actually collects

**Deadline**: Before launch
**Risk if missing**: Collecting unnecessary data (GDPR Art. 5 violation)

---

## 🟡 NICE-TO-HAVE (Can Defer)

### 10. Lawyer Review

- [ ] ✅ Privacy Policy reviewed by GDPR lawyer
- [ ] ✅ Terms of Service reviewed
- [ ] ✅ Disclaimer adequacy reviewed
- [ ] ✅ Received written opinion letter
- [ ] 💰 Cost: €[Amount] (budget: €500-€1,000)

**Deadline**: Optional (if budget allows)
**Benefit**: 100% legal certainty

---

### 11. Commercialista (Accountant)

- [ ] ✅ Initial consultation for P.IVA setup
- [ ] ✅ Tax optimization advice (regime forfettario)
- [ ] ✅ INPS contribution calculation
- [ ] ✅ Subscribed for annual tax filing
- [ ] 💰 Cost: €[Amount] (budget: €500-€1k/year)

**Deadline**: Before earning revenue
**Benefit**: Tax optimization, compliance

---

### 12. Changelog & Version Control

- [ ] ✅ Created `docs/legal/PRIVACY_POLICY_CHANGELOG.md`
- [ ] ✅ Created `docs/legal/TERMS_OF_SERVICE_CHANGELOG.md`
- [ ] ✅ Git tags for legal doc versions (e.g., `legal-v1.0`)

**Deadline**: After first version published
**Benefit**: Audit trail for changes

---

## 📊 Completion Status

**Critical (Before Launch)**: 0 / 5 completed (0%)
**High Priority**: 0 / 4 completed (0%)
**Nice-to-Have**: 0 / 3 completed (0%)

**TOTAL**: 0 / 12 completed (0%)

---

## 🚀 Launch Readiness

**Can launch when**:
- ✅ All 5 Critical items completed
- ✅ Privacy Policy + ToS published
- ✅ Disclaimer + Age Gate tested
- ✅ Firebase DPA signed

**Recommended to defer launch if missing**:
- ⚠️ Assicurazione RC (high liability risk)
- ⚠️ P.IVA (if monetizing immediately)

---

## Next Steps

1. Start with Task 1: Firebase DPA (3 hours)
2. Complete Task 2-3: Privacy Policy + ToS (1 day)
3. Implement Task 4-5: Disclaimer + Age Gate (1 day)
4. Test everything thoroughly (1 day)
5. Request insurance quotes (1 week wait)
6. **LAUNCH** (after critical items complete)

**Estimated Total Time**: 2 weeks from now

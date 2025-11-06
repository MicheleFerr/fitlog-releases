# Legal Compliance Master Checklist - FITlog Pro

**Last updated**: 2025-11-06
**Status**: 🚧 In Progress
**Target**: ✅ Launch-Ready

---

## 🔴 CRITICAL (Before Launch)

### 1. Firebase DPA

- [x] ✅ Signed Data Processing Agreement with Google Firebase
- [x] ✅ Downloaded PDF stored in `docs/legal/signed/`
- [x] ✅ Verified Standard Contractual Clauses (SCC) included
- [x] 📄 Reference: `docs/legal/DPA_FIREBASE_CHECKLIST.md`

**Status**: ✅ **COMPLETED** (2025-11-06)
**Signed by**: finalcash26@gmail.com
**DPA URL**: https://cloud.google.com/terms/data-processing-addendum

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

- [x] ✅ Disabled Google Analytics (if not needed)
- [x] ✅ Disabled Crashlytics automatic collection
- [x] ✅ Disabled Performance Monitoring (if not needed)
- [x] ✅ Firestore Security Rules: users can only read/write own data
- [x] ✅ Audit: Verified what data Firebase actually collects

**Status**: ✅ **COMPLETED** (2025-11-06)
**Details**:
- Firestore Security Rules deployed (1,259 lines)
- All collections isolated by `userId`
- Fallback rule: `allow read, write: if false` (deny all unknowns)
- Data Location: `eur3` (Europe - GDPR compliant)

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

**Critical (Before Launch)**: 1 / 5 completed (20%)
- ✅ Task 1: Firebase DPA
- ⏳ Task 2: Privacy Policy (in-app publication pending)
- ⏳ Task 3: Terms of Service (in-app publication pending)
- ⏳ Task 4: Disclaimer Modal (implementation done, testing pending)
- ⏳ Task 5: Age Gate (implementation done, testing pending)

**High Priority**: 2 / 4 completed (50%)
- ⏳ Task 6: P.IVA (user responsibility)
- ⏳ Task 7: Assicurazione RC (user responsibility)
- ✅ Task 8: Consent Tracking System (fully implemented)
- ✅ Task 9: Firebase Data Minimization (rules deployed)

**Nice-to-Have**: 0 / 3 completed (0%)
- ⏳ Task 10: Lawyer Review (optional)
- ⏳ Task 11: Commercialista (optional)
- ⏳ Task 12: Changelog (optional)

**TOTAL**: 3 / 12 completed (25%)

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

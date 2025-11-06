# Firebase Data Processing Agreement (DPA) - Checklist

## Overview

**What**: Data Processing Agreement between FITlog Pro (Controller) and Google Firebase (Processor)
**Why**: GDPR Art. 28 requires written contract with any data processor
**Consequence if not signed**: €10M-€20M fine (GDPR Art. 83)

---

## Step-by-Step Process

### 1. Access Firebase Console

URL: https://console.firebase.google.com/

Login with: [Your Google Account]

---

### 2. Navigate to DPA Settings

1. Select your project: `[Your Project ID]`
2. Click ⚙️ **Settings** (top left)
3. Go to **Project Settings** → **Legal**
4. Find section: **Data Processing and Security Terms**

---

### 3. Review DPA Terms

**Document**: Google Cloud Data Processing Terms
**URL**: https://firebase.google.com/terms/data-processing-terms

**Key Sections to Review**:
- Section 2: Data Processing
- Section 5: Data Security
- Section 6: Subprocessors (list of Google's subprocessors)
- Section 7: International Data Transfers (Standard Contractual Clauses)
- Annex 1: Description of Processing
- Annex 2: Security Measures
- Annex 3: Subprocessor List

**⚠️ READ CAREFULLY**: You're legally binding yourself to these terms.

---

### 4. Accept Terms

1. Check box: ☑️ **"I accept Google Cloud Data Processing Terms"**
2. Click **Save**
3. Confirmation message appears: "Terms accepted"

---

### 5. Download Signed Copy

1. Click **Download** button next to accepted terms
2. Save PDF: `Firebase_DPA_Signed_[Date].pdf`
3. Store in: `docs/legal/signed/Firebase_DPA_Signed_2025-11-06.pdf`

**⚠️ CRITICAL**: Keep this PDF for 10 years (GDPR Art. 30 - Records of Processing)

---

### 6. Verify SCC (Standard Contractual Clauses)

**Why**: Firebase may transfer data to USA (Google servers)
**What**: SCC = EU-approved contract for safe data transfers outside EU

**Verify**:
1. In DPA document, find **Annex 3: Transfers of Personal Data**
2. Confirm: ✓ Standard Contractual Clauses (Module 2: Controller-to-Processor)
3. Confirm: ✓ EU Commission Implementing Decision 2021/914

If SCC not mentioned, contact Firebase support: firebase-support@google.com

---

### 7. Update Privacy Policy

After signing DPA, update Privacy Policy section:

**Add to section "4. Where Your Data Is Stored"**:

```markdown
### Data Processing Agreement

We have signed a Data Processing Agreement (DPA) with Google Firebase (GDPR Art. 28).
This agreement ensures:
- Google processes data only on our instructions
- Data security measures (encryption, access controls)
- Notification of data breaches within 24 hours
- Right to audit Google's security practices

**Standard Contractual Clauses**: Data transfers to USA (if any) are protected by EU-approved Standard Contractual Clauses (EU Implementing Decision 2021/914).

**DPA Reference**: Available upon request (privacy@fitlogpro.com)
```

---

## Completion Checklist

- [ ] ✅ Logged into Firebase Console
- [ ] ✅ Navigated to Settings → Legal
- [ ] ✅ Read Google Cloud Data Processing Terms
- [ ] ✅ Accepted terms (checkbox + Save)
- [ ] ✅ Downloaded signed PDF
- [ ] ✅ Stored PDF in `docs/legal/signed/`
- [ ] ✅ Verified SCC included (Annex 3)
- [ ] ✅ Updated Privacy Policy with DPA reference
- [ ] ✅ Committed to git (if not sensitive)

---

## Renewal

**Frequency**: Check annually (Google may update terms)
**Notification**: Firebase sends email if terms change
**Action**: Review changes, accept new version, download new PDF

---

## Questions?

**Firebase Support**: firebase-support@google.com
**GDPR Guidance**: https://firebase.google.com/support/privacy

**Lawyer Review** (optional but recommended):
- Cost: €200-€500
- Contact: Avvocato specializzato in GDPR (Brescia)

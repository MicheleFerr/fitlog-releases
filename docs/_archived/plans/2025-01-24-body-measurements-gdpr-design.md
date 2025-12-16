# Body Measurements with GDPR Privacy-by-Design - Design Document

**Created**: 2025-01-24 20:00
**Design Phase**: Brainstorming skill completed
**Implementation Plan**: See `2025-01-24-body-measurements-gdpr-plan.md`
**Research Sources**: 10+ industry sources (2025 best practices)

---

## 🎯 Overview

Design for comprehensive body measurements tracking (20+ metrics) with full GDPR compliance, privacy-by-design architecture, and best-practice UX patterns from 2025 industry research.

**Key Principles**:
- **Just-in-Time Consent**: Ask for permissions when users need them ([Medium: UX for Privacy 2025](https://medium.com/design-bootcamp/ux-for-privacy-consent-in-2025-designing-trust-in-a-digital-world-0e41906298e3))
- **Layered Disclosure**: Brief notices with expandable details ([Smashing Magazine](https://www.smashingmagazine.com/2019/04/privacy-ux-aware-design-framework/))
- **Encryption Transparency**: Visible trust badges ([SoluteLabs](https://www.solutelabs.com/blog/build-trust-healthtech-apps))
- **User Control**: Easy export, deletion, consent revocation ([GDPR Advisor](https://www.gdpr-advisor.com/gdpr-compliance-for-fitness-apps-safeguarding-personal-health-information/))

---

## 📊 Metrics to Track (20+ Total)

### Group 1: Essential Metrics (Onboarding)
- Weight (kg/lbs)
- Body Fat % (percentage)

### Group 2: Body Measurements (Just-in-Time)
**13 Circumferences**:
- Upper: Neck, Shoulders, Chest, Bicep L/R, Forearm L/R
- Core: Waist, Abdomen, Hips
- Lower: Thigh L/R, Calf L/R

### Group 3: Health Vitals (Just-in-Time)
- BMR (Basal Metabolic Rate, kcal)
- Lean Body Mass (kg)
- BMI (Body Mass Index, calculated)

---

## 🏗️ Architecture - Consent State Management

### Consent State Machine

```dart
enum ConsentState {
  notAsked,    // Default: user never saw prompt
  denied,      // User explicitly declined
  granted,     // User accepted
}
```

**Research basis**: [SecurePrivacy SDK 2025](https://secureprivacy.ai/blog/mobile-app-sdk-consent-management) - State machine with "pending" (notAsked) as default prevents accidental tracking.

---

### Domain Model: UserConsent

```dart
class UserConsent {
  final String userId;
  final Map<MetricGroup, ConsentState> groupConsents; // 3 groups
  final DateTime? essentialGrantedAt;
  final DateTime? measurementsGrantedAt;
  final DateTime? vitalsGrantedAt;
  final int consentVersion;  // Privacy policy version tracking
  final String ipAddress;    // GDPR audit requirement
}

enum MetricGroup {
  essential,      // Weight, Body Fat (onboarding base)
  measurements,   // 13 Circumferences (just-in-time unlock)
  vitals,         // BMR, Lean Mass, BMI (just-in-time unlock)
}
```

**Why 3 groups instead of 20+ checkboxes?**
- Research shows users suffer "consent fatigue" with >5 options ([Usercentrics](https://usercentrics.com/knowledge-hub/best-practices-for-mobile-app-consent/))
- Apple HealthKit recommends granular but grouped permissions ([Apple Developer](https://developer.apple.com/documentation/healthkit/protecting-user-privacy))
- Balances GDPR requirement (specific consent) with UX (not overwhelming)

---

### Metric Type Grouping (Extension)

```dart
extension MetricTypeGrouping on MetricType {
  MetricGroup get group {
    switch (this) {
      case MetricType.weight:
      case MetricType.bodyFat:
        return MetricGroup.essential;

      case MetricType.neck:
      case MetricType.shoulders:
      case MetricType.chest:
      case MetricType.waist:
      case MetricType.abdomen:
      case MetricType.hips:
      case MetricType.bicepLeft:
      case MetricType.bicepRight:
      case MetricType.forearmLeft:
      case MetricType.forearmRight:
      case MetricType.thighLeft:
      case MetricType.thighRight:
      case MetricType.calfLeft:
      case MetricType.calfRight:
        return MetricGroup.measurements;

      case MetricType.bmr:
      case MetricType.leanMass:
      case MetricType.bmi:
        return MetricGroup.vitals;
    }
  }
}
```

---

### ConsentGuard (Use Case)

**Pattern**: Guard Clause ([Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html))

```dart
class ConsentGuard {
  final ConsentRepository _consentRepo;

  Future<Either<ConsentRequiredFailure, void>> checkConsent(
    String userId,
    MetricType metric,
  ) async {
    final consent = await _consentRepo.getConsent(userId);
    final group = metric.group;

    // Block operation if consent not granted
    if (consent.groupConsents[group] != ConsentState.granted) {
      return Left(ConsentRequiredFailure(
        requiredGroup: group,
        metric: metric,
        message: 'Consent required for ${group.name}',
      ));
    }

    return Right(null);
  }
}
```

**Usage**: Every data operation (add measurement, sync HealthKit) calls `ConsentGuard.checkConsent()` BEFORE proceeding.

---

## 🎨 UI Components - Consent Flow

### 1. Onboarding Consent Dialog (Essential Metrics)

**Trigger**: First time user opens "Body Measurements" feature

**Design Pattern**: Layered Disclosure ([Medium: Privacy by Design 2025](https://medium.com/design-bootcamp/data-privacy-by-design-integrating-trust-into-ux-in-2025-b75b882abad1))

```dart
ConsentDialog {
  // Layer 1: Brief Notice (2-3 sentences)
  header: "Track Your Progress 📊"

  description:
    "Track weight and body fat to monitor fitness progress.
     Your data is encrypted and synced with Apple Health/Health Connect.
     You control what we track."

  // Layer 2: Expandable Details
  [Tap "Learn More"] → Expands to show:
    - What we collect: Weight, Body Fat %
    - Why: Progress tracking, trend analysis
    - Where stored: Encrypted locally + Firestore (AES-256)
    - Who sees it: Only you (no sharing, no ads)
    - How long: Until you delete it
    - Your rights: Export, delete anytime

  [Link: "Read Full Privacy Policy"] → Opens WebView

  // Consent Checkboxes (equal visual weight - NO dark patterns)
  ☐ "I consent to track Essential Metrics (Weight, Body Fat)"
  ☐ "I have read the Privacy Policy" (required)

  // Buttons (equal prominence - anti-dark-pattern)
  [Decline] (TextButton, secondary)  [Accept] (ElevatedButton, primary)

  // Accept button disabled until both checkboxes checked
}
```

**GDPR Compliance**:
- ✅ Freely given (Decline button equally prominent)
- ✅ Specific (Essential Metrics clearly listed)
- ✅ Informed (Layered disclosure + policy link)
- ✅ Unambiguous (Explicit checkboxes, not pre-ticked)

**Research sources**:
- [GDPR Advisor: Fitness Apps](https://www.gdpr-advisor.com/gdpr-compliance-for-fitness-apps-safeguarding-personal-health-information/)
- [Usercentrics: No pre-ticked boxes](https://usercentrics.com/knowledge-hub/best-practices-for-mobile-app-consent/)

---

### 2. Just-in-Time Consent (Measurements & Vitals)

**Trigger**: User taps disabled feature (e.g., "Add Circumferences")

**Design Pattern**: Contextual Disclosure ([SecurePrivacy iOS 2025](https://secureprivacy.ai/blog/mobile-app-consent-ios-2025))

```dart
JustInTimeConsentSheet (ModalBottomSheet) {
  icon: 📏 (contextual icon per group)

  title: "Unlock Body Measurements"

  // Value Proposition (contextual, relevant)
  description:
    "Track chest, waist, hips, arms, legs to see muscle growth.
     Data encrypted and synced with Apple Health."

  // Benefits (3-4 bullets max)
  ✓ See muscle gain over time
  ✓ Track body recomposition
  ✓ Auto-sync with Apple Health

  [Learn More] → Layered details (same as onboarding)

  // Single Checkbox (granular group consent)
  ☐ "I consent to track Body Measurements (13 circumferences)"

  // Buttons
  [Not Now] (closes, can retry later)  [Enable] (grants consent)
}
```

**Why Just-in-Time beats Upfront?**

Research evidence ([Medium: UX for Privacy 2025](https://medium.com/design-bootcamp/ux-for-privacy-consent-in-2025-designing-trust-in-a-digital-world-0e41906298e3)):
> "Just-in-time prompts explain the need for data at the point of collection, so users can give consent only when they understand the purpose."

**Benefits**:
- Higher comprehension (user sees WHY they need it)
- Better consent rates (contextually relevant)
- Reduced onboarding friction (only ask for essentials upfront)

---

### 3. Privacy Dashboard (Settings → Privacy & Data)

**Design Pattern**: Transparency Dashboard ([SoluteLabs: Trust in HealthTech](https://www.solutelabs.com/blog/build-trust-healthtech-apps))

```dart
PrivacyDashboardScreen {

  // Section 1: Active Consents
  Card "Your Consents" {
    ListTile (Essential Metrics) {
      leading: Icon(AppIcons.check, color: context.colors.success)
      title: "Essential Metrics"
      subtitle: "Granted on 2025-01-24"
      trailing: IconButton(AppIcons.info) // Tap → Details
    }

    ListTile (Body Measurements) {
      leading: Icon(AppIcons.close, color: context.colors.error)
      title: "Body Measurements"
      subtitle: "Denied"
      trailing: IconButton(AppIcons.info)
    }

    ListTile (Health Vitals) {
      leading: Icon(AppIcons.pending, color: context.colors.surfaceVariant)
      title: "Health Vitals"
      subtitle: "Not asked yet"
      trailing: IconButton(AppIcons.info)
    }

    // Tap group → ConsentDetailSheet
    onTap(group) → Shows:
      - Metrics included (list)
      - Granted at: timestamp
      - Data collected: count (e.g., "150 measurements")
      - [Revoke Consent] button (red, destructive)
  }

  // Section 2: Encryption Status (Trust Badge)
  Card "Data Security" {
    leading: Icon(AppIcons.lock, color: context.colors.success)
    title: "AES-256 Encrypted"
    subtitle: "Your data is encrypted at rest and in transit"

    [View Security Details] → SecurityDetailsSheet (see Section 7)
  }

  // Section 3: Data Portability (GDPR Article 20)
  Card "Your Data" {
    ElevatedButton "Download My Data" {
      onTap → DataExportDialog (see Section 4)
    }
    subtitle: "Export all measurements in JSON format"
  }

  // Section 4: Right to Erasure (GDPR Article 17)
  Card "Delete Data" (destructive color) {
    ElevatedButton "Delete All Measurements" (red) {
      onTap → DeletionConfirmationDialog (see Section 5)
    }
    subtitle: "Permanently delete all body measurements"
  }

  // Section 5: Legal Links
  ListTile "Privacy Policy" {
    trailing: Icon(AppIcons.externalLink)
    onTap → WebView(privacyPolicyUrl)
  }

  ListTile "Terms of Service" {
    trailing: Icon(AppIcons.externalLink)
    onTap → WebView(termsUrl)
  }

  ListTile "Contact Support" {
    trailing: Icon(AppIcons.email)
    onTap → launchUrl('mailto:privacy@gymbro.app')
  }
}
```

**Research basis**: 80% of businesses saw boost in customer loyalty after focusing on privacy transparency ([Linnify: Mobile Health 2025](https://www.linnify.com/news/securing-mobile-health-apps-challenges-and-innovations-in-2025)).

---

### 4. Data Export UX (Right to Data Portability)

**GDPR Requirement**: Article 20 - Data Portability ([Auth0 GDPR Guide](https://auth0.com/docs/secure/data-privacy-and-compliance/gdpr/gdpr-data-portability))

**Design Pattern**: Machine-Readable + Human Summary

```dart
DataExportDialog {
  title: "Download Your Data"

  description:
    "Export all body measurements, consent history, and audit logs.
     Data provided in JSON format (machine-readable)."

  // Export Options (checkboxes)
  ☑ Measurements (all 150 entries)
  ☑ Consent history (3 consent events)
  ☑ Audit logs (12 access events)

  // Format Selector (radio buttons)
  ◉ JSON (machine-readable, for backup)
  ○ CSV (spreadsheet-compatible)

  // Action Buttons
  [Cancel]  [Download] (triggers DataExportService)

  // Post-Export: Share Sheet
  onSuccess → Platform share sheet:
    - Save to Files
    - Email to myself
    - Share with app

  // Bonus UX: Human-Readable Summary
  // (Research: JSON not human-readable - GitHub Issue matomo #12805)
  Also generates PDF summary:
    "Your Body Measurements Summary
     Total measurements: 150
     Date range: 2024-06-01 to 2025-01-24
     Weight change: 80kg → 75kg (-5kg)
     Body fat change: 22% → 18% (-4%)

     [Download Full JSON Data]"
}
```

**JSON Export Structure** (GDPR-compliant):

```json
{
  "userId": "hashed_user_id",
  "exportedAt": "2025-01-24T20:00:00Z",
  "consentVersion": 1,
  "measurements": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "metricType": "weight",
      "value": 75.5,
      "unit": "kg",
      "timestamp": "2025-01-20T08:00:00Z",
      "source": "manual",
      "notes": "Morning weight after workout"
    }
  ],
  "consents": [
    {
      "group": "essential",
      "state": "granted",
      "grantedAt": "2025-01-10T10:00:00Z",
      "ipAddress": "192.168.1.*** (masked)",
      "consentVersion": 1
    }
  ],
  "auditLogs": [
    {
      "id": "audit_001",
      "action": "dataAccess",
      "timestamp": "2025-01-20T08:05:00Z",
      "affectedMetrics": ["weight", "bodyFat"],
      "source": "Mobile App iOS"
    }
  ]
}
```

**Why JSON + CSV option?**
- JSON: GDPR-compliant (structured, machine-readable)
- CSV: User-friendly (open in Excel, Google Sheets)
- PDF: Human-readable summary (quick overview)

---

### 5. Data Deletion UX (Right to Erasure)

**GDPR Requirement**: Article 17 - Right to be Forgotten

**Design Pattern**: Multi-Step Confirmation ([Cloudscape: Delete Patterns](https://cloudscape.design/patterns/resource-management/delete/delete-with-additional-confirmation/))

**Research basis**:
> "For actions with permanence or sensitivity like deleting data, designs demand unambiguous confirmation states including modal screens, summary pages, and sometimes multi-step confirmations." - [Design Systems Collective 2025](https://www.designsystemscollective.com/designing-success-part-2-dos-don-ts-and-use-cases-of-confirmation-patterns-6e760ccd1708)

```dart
DeletionConfirmationDialog (3-step process) {

  // STEP 1: Warning
  AlertDialog {
    icon: Icon(AppIcons.warning, color: context.colors.error, size: 48)

    title: "Delete All Measurements?"

    content:
      "This will permanently delete:
       • All 150 body measurements
       • Your consent history
       • 12 months of progress data

       ⚠️ This action cannot be undone after 30 days."

    actions: [
      TextButton("Cancel"),
      ElevatedButton("Continue", style: destructive) // Red button
    ]
  }

  // STEP 2: Confirmation with Friction
  AlertDialog {
    title: "Are you absolutely sure?"

    content:
      "Your data will be:
       1. Soft-deleted immediately (30-day retention)
       2. Permanently deleted after 30 days
       3. Deleted from all devices and cloud storage

       During 30 days, you can cancel deletion from Settings."

    // Text-based confirmation (high-risk friction)
    // Research: "Type DELETE to confirm" pattern - LogRocket UX 2025
    TextField {
      label: "Type DELETE to confirm"
      validator: input.trim().toUpperCase() == "DELETE"
      decoration: InputDecoration(
        hintText: "DELETE",
        errorText: input.isEmpty ? null : "Must type DELETE exactly"
      )
    }

    // Checkbox confirmation
    CheckboxListTile {
      title: "I understand this is permanent"
      value: understoodPermanent
      required: true
    }

    actions: [
      TextButton("Cancel"),
      ElevatedButton(
        "Delete Forever",
        onPressed: textMatches && understoodPermanent ? _delete : null,
        style: destructive // Red, disabled until conditions met
      )
    ]
  }

  // STEP 3: Scheduled Deletion Confirmation
  SnackBar (post-deletion) {
    message:
      "Deletion scheduled for 2025-02-23.
       You can cancel within 30 days in Settings → Privacy."

    action: SnackBarAction(
      label: "Undo",
      onPressed: () => DataDeletionService.cancelDeletion(userId)
    )
    duration: Duration(seconds: 10) // Longer than usual for important action
  }
}

// Backend: Soft-Delete Record
DataDeletionService.scheduleDeletion(
  userId: userId,
  scheduledFor: DateTime.now().add(Duration(days: 30)),
  cancellable: true,
  reason: DeletionReason.userRequested,
);
```

**Why 30-day soft-delete?**
- Industry standard (Google, Microsoft use 30 days)
- Prevents accidental deletion (undo window)
- GDPR-compliant (erasure "without undue delay")

---

### Cancellation Flow (Undo Option)

**Research**: [UX StackExchange: Confirm vs Undo](https://ux.stackexchange.com/questions/71960/deletion-confirm-or-undo-which-is-the-better-option-and-why) - Both confirm AND undo is best for irreversible actions.

```dart
PrivacySettings (if soft-delete active) {

  // Prominent Banner at Top
  MaterialBanner {
    content: Text(
      "Deletion Scheduled",
      style: context.textTheme.titleMedium
    )

    actions: [
      TextButton(
        "Cancel Deletion",
        style: ButtonStyle(
          foregroundColor: context.colors.success // Green (positive action)
        ),
        onPressed: () => _showCancelDialog()
      )
    ]

    backgroundColor: context.colors.errorContainer // Red tint
    leading: Icon(AppIcons.warning)
  }

  // Cancel Confirmation Dialog
  _showCancelDialog() → AlertDialog {
    title: "Cancel Data Deletion?"

    content:
      "Your measurements will be restored immediately.
       Scheduled deletion on 2025-02-23 will be cancelled."

    actions: [
      TextButton("Keep Deleting"),
      ElevatedButton(
        "Restore Data",
        style: positive, // Green button
        onPressed: () async {
          await DataDeletionService.cancelDeletion(userId);
          SnackBarService.showSuccess(
            context,
            "Deletion cancelled. Your data is safe."
          );
        }
      )
    ]
  }
}
```

---

### 6. Encryption Transparency (Trust Building)

**Research basis**: "Display certifications or security badges where they matter" - [SoluteLabs: Trust in HealthTech](https://www.solutelabs.com/blog/build-trust-healthtech-apps)

**Pattern**: Visible Trust Indicators

```dart
// Encryption Badge (always visible in measurement screens)
EncryptionBadge (custom widget) {
  Icon(
    AppIcons.lock,
    size: AppIconSize.small,
    color: context.colors.success,
  )

  tooltip: "Encrypted with AES-256"

  // Positioning examples:
  // 1. AppBar subtitle
  AppBar(
    title: Text("Body Measurements"),
    subtitle: Text("150 measurements • 🔒 Encrypted")
  )

  // 2. Card footer
  Card(
    footer: Row(
      children: [
        Text("Last updated 2 hours ago"),
        Spacer(),
        EncryptionBadge(),
      ]
    )
  )

  // 3. Input form helper text
  TextField(
    helperText: "Your data is encrypted 🔒"
  )
}

// Security Details Sheet (tap badge to expand)
SecurityDetailsSheet {
  title: "Your Data Security"

  // Section 1: Encryption
  ExpansionTile {
    leading: Icon(AppIcons.lock, color: context.colors.success)
    title: "AES-256 Encryption"
    subtitle: "Military-grade encryption protects your data"

    children: [
      ListTile(
        title: "Algorithm",
        trailing: Text("AES-256-GCM")
      ),
      ListTile(
        title: "Key Size",
        trailing: Text("256 bits")
      ),
      ListTile(
        title: "Key Storage",
        trailing: Text("Secure Enclave (iOS) / Keystore (Android)")
      ),
      ListTile(
        title: "Last Key Rotation",
        trailing: Text("2025-01-15")
      )
    ]
  }

  // Section 2: Access Control
  ExpansionTile {
    leading: Icon(AppIcons.key, color: context.colors.primary)
    title: "User-Only Access"
    subtitle: "Only you can decrypt your measurements"

    children: [
      ListTile(
        title: "Authentication",
        trailing: Text("Firebase Auth (OAuth 2.0)")
      ),
      ListTile(
        title: "Firestore Rules",
        trailing: Text("User-scoped (uid check)")
      ),
      ListTile(
        title: "Third-Party Access",
        trailing: Text("None")
      )
    ]
  }

  // Section 3: Compliance
  ExpansionTile {
    leading: Icon(AppIcons.check, color: context.colors.success)
    title: "GDPR Compliant"
    subtitle: "EU General Data Protection Regulation"

    children: [
      ListTile(title: Text("✓ Privacy by design")),
      ListTile(title: Text("✓ Right to access (export)")),
      ListTile(title: Text("✓ Right to erasure (delete)")),
      ListTile(title: Text("✓ Audit trail (2-year retention)")),
      ListTile(title: Text("✓ Consent management")),
    ]
  }
}
```

**Research evidence**: "Visual cues like lock icons or secure labels show when data is protected, helping users feel confident" - [Data Security in Mobile Apps 2025](https://www.sidekickinteractive.com/uncategorized/data-security-in-mobile-apps-protecting-user-privacy-in-2025-and-beyond/)

---

### 7. Audit Trail (Backend, User-Accessible)

**Research basis**: [SecurePrivacy SDK](https://secureprivacy.ai/blog/mobile-app-sdk-consent-management) - "Audit-ready consent records must include timestamps, user identifiers, consent versions, specific permissions granted or denied."

**Pattern**: Backend logging with optional user-facing UI

```dart
// Domain: AuditLog Entity
class AuditLog {
  final String id;
  final String userId;
  final AuditAction action; // Enum: dataAccess, dataExport, dataDelete, consentChange
  final DateTime timestamp;
  final String ipAddress; // Hashed for privacy
  final List<MetricType>? affectedMetrics;
  final Map<String, dynamic>? metadata; // Extra context
}

// UI: Privacy Dashboard → "View Access Log" (optional feature)
AuditLogScreen {
  appBar: AppBar(title: Text("Access History"))

  description:
    "See when and how your data was accessed.
     Logs retained for 2 years (GDPR compliance)."

  // List of audit events
  ListView.builder(
    itemBuilder: (context, index) {
      final log = logs[index];
      return ListTile(
        leading: Icon(_iconForAction(log.action)),
        title: Text(_titleForAction(log.action)), // "Data Access", "Consent Granted"
        subtitle: Text("${log.timestamp.format()} • IP: ${log.maskedIp}"),
        trailing: IconButton(
          icon: Icon(AppIcons.info),
          onPressed: () => _showLogDetails(log)
        )
      );
    }
  )

  // Export audit log (FAB)
  floatingActionButton: FloatingActionButton.extended(
    label: Text("Download Audit Log"),
    icon: Icon(AppIcons.download),
    onPressed: () async {
      final json = await AuditLogExportService.exportLogs(userId);
      await Share.shareXFiles([XFile.fromData(json, name: 'audit_log.json')]);
    }
  )
}

// Log Detail Sheet
LogDetailSheet(AuditLog log) {
  title: _titleForAction(log.action)

  content: Column(
    children: [
      ListTile(
        title: Text("Action"),
        trailing: Text(log.action.name)
      ),
      ListTile(
        title: Text("Timestamp"),
        trailing: Text(log.timestamp.toIso8601String())
      ),
      ListTile(
        title: Text("Affected Metrics"),
        trailing: Text(log.affectedMetrics?.join(', ') ?? 'All')
      ),
      ListTile(
        title: Text("Source"),
        trailing: Text(log.metadata?['source'] ?? 'Unknown')
      ),
      ListTile(
        title: Text("IP Address"),
        trailing: Text(log.maskedIp) // "192.168.1.***"
      ),
    ]
  )
}
```

**Note**: Audit log UI is **optional** (not always visible) to avoid information overload. Available in Privacy Dashboard for power users who want transparency.

---

### 8. Privacy Policy - Layered Disclosure

**Research basis**: [Medium: Integrating Privacy into UX](https://medium.com/design-bootcamp/integrating-security-and-privacy-into-ux-design-best-practices-for-building-trustworthy-products-c21a51fa0272) - 3-layer approach balances comprehension with accessibility.

**Pattern**: Summary → Expandable → Full Document

```dart
// Layer 1: In-App Summary (always visible in Settings)
PrivacyPolicySummaryCard {
  title: "Privacy at a Glance"

  bullets: [
    "✓ Your data is encrypted (AES-256)",
    "✓ We never share data with third parties",
    "✓ You can export or delete anytime",
    "✓ No ads, no tracking, no selling data"
  ]

  trailing: TextButton(
    "Read Full Policy",
    onPressed: () => Navigator.push(PrivacyPolicyScreen())
  )
}

// Layer 2: Expandable Sections (native or WebView)
PrivacyPolicyScreen {
  appBar: AppBar(
    title: Text("Privacy Policy"),
    actions: [
      // Language toggle
      SegmentedButton(
        segments: [
          ButtonSegment(value: 'en', label: Text('English')),
          ButtonSegment(value: 'it', label: Text('Italiano')),
        ],
        selected: {currentLanguage},
        onSelectionChanged: (lang) => _switchLanguage(lang)
      )
    ]
  )

  body: ListView(
    children: [
      // Expandable accordions
      ExpansionTile(
        title: Text("1. What We Collect"),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(_whatWeCollectContent)
          )
        ]
      ),

      ExpansionTile(
        title: Text("2. Why We Collect It"),
        children: [...]
      ),

      ExpansionTile(
        title: Text("3. How We Protect It"),
        children: [...]
      ),

      ExpansionTile(
        title: Text("4. Your Rights"),
        children: [...]
      ),

      ExpansionTile(
        title: Text("5. How to Contact Us"),
        children: [...]
      ),
    ]
  )

  bottomNavigationBar: Padding(
    padding: EdgeInsets.all(16),
    child: ElevatedButton.icon(
      icon: Icon(AppIcons.download),
      label: Text("Download PDF Privacy Policy"),
      onPressed: () => launchUrl('https://gymbro.app/privacy-policy.pdf')
    )
  )
}

// Layer 3: Full Legal Document (PDF download)
// Link opens PDF in browser/viewer
```

**Content Example** (13-year-old reading level - [Usercentrics](https://usercentrics.com/knowledge-hub/best-practices-for-mobile-app-consent/)):

```markdown
## 1. What We Collect

We collect body measurements you choose to track:
- Weight and body fat % (if you consent to Essential Metrics)
- Body circumferences like chest, waist, hips (if you consent to Body Measurements)
- Health vitals like BMR and lean mass (if you consent to Health Vitals)

We also collect:
- Your email (for login and account recovery)
- Timestamps (when you add measurements)
- Device info (iOS version, for debugging)

## 2. Why We Collect It

To help you:
- Track your fitness progress over time
- See trends in muscle gain or fat loss
- Sync data with Apple Health/Health Connect

We DO NOT:
- Sell your data to anyone
- Show you ads based on your measurements
- Share data with third parties (except Apple/Google health platforms if you enable sync)

## 3. How We Protect It

**Encryption**: AES-256 (military-grade)
- Your measurements are encrypted before saving
- Encryption keys stored in Secure Enclave (iOS) / Keystore (Android)
- Only you can decrypt your data

**Access Control**: User-scoped
- Firestore rules ensure you can only access YOUR data
- No admin/support access to your measurements
- Authentication via Firebase (OAuth 2.0)

**Backups**: Encrypted daily backups
- Stored in Google Cloud Platform (GDPR-compliant region: EU)
- 30-day retention for deleted data (then permanent deletion)

## 4. Your Rights

Under GDPR, you can:
- **Access**: Download all your data (JSON format)
- **Erasure**: Delete all your data (30-day soft-delete, then permanent)
- **Rectification**: Edit any measurement anytime
- **Portability**: Export to take your data elsewhere
- **Revoke Consent**: Stop tracking specific metrics anytime

To exercise your rights:
- Go to Settings → Privacy & Data
- Or email: privacy@gymbro.app

## 5. How to Contact Us

**Data Protection Officer**: privacy@gymbro.app
**Support**: support@gymbro.app
**Address**: [Company Address]

Last updated: 2025-01-24
```

---

### 9. Notification Preferences (Bonus - Separate from Consent)

**Research basis**: [SecurePrivacy iOS 2025](https://secureprivacy.ai/blog/mobile-app-consent-ios-2025) - "Consent ≠ Push notifications" (don't confuse users)

```dart
// Separate Settings Screen (NOT in Privacy & Data)
NotificationPreferencesScreen {
  title: "Notifications"

  description:
    "Choose what reminders you want.
     Notifications are independent from data tracking consent."

  // Clear separation
  SwitchListTile(
    title: "Workout Reminders",
    subtitle: "Daily reminder to log workouts",
    value: workoutRemindersEnabled,
    onChanged: (value) => _toggleNotification('workout', value)
  )

  SwitchListTile(
    title: "Progress Milestones",
    subtitle: "Celebrate achievements (e.g., '5kg lost!')",
    value: milestonesEnabled,
    onChanged: (value) => _toggleNotification('milestones', value)
  )

  SwitchListTile(
    title: "Measurement Reminders",
    subtitle: "Weekly reminder to track measurements",
    value: measurementRemindersEnabled,
    onChanged: (value) => _toggleNotification('measurements', value)
  )

  SwitchListTile(
    title: "Tips & Tricks",
    subtitle: "Monthly fitness tips",
    value: tipsEnabled,
    onChanged: (value) => _toggleNotification('tips', value)
  )

  // Clear disclaimer (prevent confusion)
  Card(
    color: context.colors.surfaceVariant,
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        "Note: This doesn't affect what data we collect.
         To manage data consent, go to Settings → Privacy & Data.",
        style: context.textTheme.bodySmall
      )
    )
  )
}
```

---

## 📐 Encryption Architecture

### AES-256 Encryption Flow

```
User adds measurement
         ↓
ConsentGuard.checkConsent() → ✅ Granted
         ↓
MeasurementValidator.validate() → ✅ Valid
         ↓
EncryptionKeyManager.getKey(userId) → Retrieves key from Secure Enclave/Keystore
         ↓
EncryptMeasurement.call(measurement, key)
         ↓
EncryptedMeasurement {
  encryptedData: base64(AES-256-GCM(measurement.toJson(), key))
  iv: randomBytes(16) // Initialization vector
  tag: authTag(16)    // Authentication tag
}
         ↓
Save to Hive (local, encrypted)
         ↓
Upload to Firestore (cloud, encrypted)
         ↓
AuditLogger.log(dataAccess, userId, timestamp, ipAddress)
```

**Security Properties**:
- **Confidentiality**: AES-256 encryption (no plaintext storage)
- **Integrity**: GCM mode provides authentication tag (tamper detection)
- **Key Isolation**: Keys stored in hardware-backed secure storage (never in app code/logs)
- **Forward Secrecy**: Key rotation every 90 days (old data re-encrypted)

---

### Key Management

```dart
class EncryptionKeyManager {
  final FlutterSecureStorage _secureStorage;

  // Generate new key (first-time setup)
  Future<String> generateKey(String userId) async {
    final key = _generateAES256Key(); // 32 random bytes
    final keyName = 'body_measurements_key_$userId';

    await _secureStorage.write(
      key: keyName,
      value: base64.encode(key),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.whenUnlockedThisDeviceOnly
      ),
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        resetOnError: true
      )
    );

    // Log key generation (audit)
    await AuditLogger.log(
      action: AuditAction.keyGenerated,
      userId: userId,
      timestamp: DateTime.now(),
      metadata: {'keyRotation': false}
    );

    return base64.encode(key);
  }

  // Retrieve existing key
  Future<String?> getKey(String userId) async {
    final keyName = 'body_measurements_key_$userId';
    return await _secureStorage.read(key: keyName);
  }

  // Key rotation (every 90 days)
  Future<void> rotateKey(String userId) async {
    // 1. Generate new key
    final newKey = await generateKey(userId);

    // 2. Fetch all encrypted measurements
    final encryptedMeasurements = await _fetchAllMeasurements(userId);

    // 3. Decrypt with old key, re-encrypt with new key
    final oldKey = await getKey(userId);
    for (final encrypted in encryptedMeasurements) {
      final decrypted = await DecryptMeasurement.call(encrypted, oldKey);
      final reEncrypted = await EncryptMeasurement.call(decrypted, newKey);
      await _updateMeasurement(reEncrypted);
    }

    // 4. Delete old key
    await _secureStorage.delete(key: 'body_measurements_key_$userId');

    // 5. Log rotation
    await AuditLogger.log(
      action: AuditAction.keyRotated,
      userId: userId,
      timestamp: DateTime.now(),
      metadata: {'measurementsReEncrypted': encryptedMeasurements.length}
    );
  }

  // Delete key (on account deletion)
  Future<void> deleteKey(String userId) async {
    final keyName = 'body_measurements_key_$userId';
    await _secureStorage.delete(key: keyName);

    await AuditLogger.log(
      action: AuditAction.keyDeleted,
      userId: userId,
      timestamp: DateTime.now()
    );
  }
}
```

**Platform-Specific Storage**:
- **iOS**: Secure Enclave (hardware-backed, Touch ID/Face ID protected)
- **Android**: Keystore (hardware-backed on Android 6+, software fallback)

---

## 🔄 Complete User Journey

### New User Flow (Just-in-Time Consent)

```
1. User installs GymBro → Completes onboarding (workout templates, routine)
         ↓
2. User discovers "Body Measurements" feature (home screen card)
         ↓
3. Taps "Track Body Measurements" → First-time consent dialog appears
         ↓
4. ConsentDialog (Essential Metrics only) {
     - Brief: "Track weight & body fat"
     - Layered: Tap "Learn More" for details
     - Checkboxes: ☐ Essential Metrics ☐ Privacy Policy
     - [Decline] [Accept]
   }
         ↓
5a. If DECLINE → Returns to home, feature disabled
5b. If ACCEPT → Consent granted, navigates to Measurement Input Screen
         ↓
6. User adds first weight measurement (75.5 kg)
         ↓
7. Backend:
     - ConsentGuard.checkConsent() → ✅ Granted
     - Validator.validate() → ✅ Valid
     - EncryptMeasurement.call() → 🔒 Encrypted
     - Save to Hive + Firestore
     - AuditLogger.log(dataAccess)
         ↓
8. User sees measurement in list (with 🔒 badge)
         ↓
9. Week later, user explores app → Discovers "Add Circumferences" button
         ↓
10. Taps button → Just-in-Time Consent Sheet appears
         ↓
11. JustInTimeConsentSheet (Body Measurements group) {
      - Icon: 📏
      - Title: "Unlock Body Measurements"
      - Value: "Track muscle growth with chest/waist/hips"
      - Checkbox: ☐ Body Measurements (13 circumferences)
      - [Not Now] [Enable]
    }
         ↓
12a. If NOT NOW → Closes, can retry later
12b. If ENABLE → Consent granted, circumferences unlocked
         ↓
13. User now has Essential + Measurements groups enabled
         ↓
14. Continues using app, measurements accumulate over months
         ↓
15. (6 months later) User wants to export data → Privacy Dashboard
         ↓
16. Settings → Privacy & Data → "Download My Data"
         ↓
17. DataExportDialog → Select format (JSON/CSV) → Download
         ↓
18. Share sheet → Save to Files / Email to self
         ↓
19. User receives JSON + PDF summary
         ↓
20. (1 year later) User wants to delete data → Privacy Dashboard
         ↓
21. Settings → Privacy & Data → "Delete All Measurements"
         ↓
22. DeletionConfirmationDialog (3-step) {
      Step 1: Warning → [Continue]
      Step 2: Type "DELETE" + checkbox → [Delete Forever]
      Step 3: SnackBar "Deletion scheduled" → [Undo]
    }
         ↓
23. Soft-delete scheduled for +30 days
         ↓
24a. If UNDO within 30 days → Data restored
24b. If no action → Permanent deletion after 30 days
         ↓
25. ✅ GDPR compliance demonstrated throughout journey
```

---

## 📚 Implementation Checklist

### Domain Layer
- [ ] Create Measurement entity with MetricType enum (20+ values)
- [ ] Create UserConsent entity with 3 MetricGroups
- [ ] Create AuditLog entity with AuditAction enum
- [ ] Create ConsentGuard use case (blocking pattern)
- [ ] Create EncryptMeasurement / DecryptMeasurement use cases
- [ ] Create MeasurementRepository interface
- [ ] Create ConsentRepository interface

### Data Layer
- [ ] Implement EncryptionKeyManager (Secure Enclave / Keystore)
- [ ] Implement MeasurementLocalDatasource (Hive, encrypted)
- [ ] Implement MeasurementRemoteDatasource (Firestore, encrypted)
- [ ] Implement ConsentDatasource (Hive + Firestore)
- [ ] Implement AuditLogger (Firestore, tamper-evident)
- [ ] Set up Firestore security rules (user-scoped, encryption enforced)
- [ ] Implement HealthKit integration (iOS, consent-driven)
- [ ] Implement Health Connect integration (Android, consent-driven)
- [ ] Implement DataExportService (JSON + CSV + PDF summary)
- [ ] Implement DataDeletionService (soft-delete, 30-day retention)

### Presentation Layer
- [ ] Build ConsentDialog (Essential Metrics, layered disclosure)
- [ ] Build JustInTimeConsentSheet (Measurements, Vitals)
- [ ] Build PrivacyDashboardScreen (consent overview, controls)
- [ ] Build DataExportDialog (format selection, share sheet)
- [ ] Build DeletionConfirmationDialog (3-step, text confirmation)
- [ ] Build SecurityDetailsSheet (encryption transparency)
- [ ] Build AuditLogScreen (optional, power users)
- [ ] Build PrivacyPolicyScreen (layered, expandable)
- [ ] Add EncryptionBadge (🔒 widget, always visible)
- [ ] Localization (EN + IT, 100+ new strings)
- [ ] Theme system (dark/light, context.colors)

### Privacy & Security
- [ ] Write GDPR-compliant Privacy Policy (EN + IT)
- [ ] Write Terms of Service
- [ ] Implement analytics anonymization (strip PII, hash userIds)
- [ ] Set up audit logging for all data operations
- [ ] Implement key rotation (90-day schedule)
- [ ] Test encryption/decryption round-trip
- [ ] Verify Firestore rules (no cross-user access)

### Testing
- [ ] Unit tests: Domain entities, validators, use cases
- [ ] Integration tests: Data layer (Hive, Firestore, HealthKit)
- [ ] Widget tests: Consent dialogs, privacy screens
- [ ] E2E test: Full journey (consent → add → export → delete)
- [ ] Security test: Encryption verification, key isolation
- [ ] GDPR compliance test: Consent enforcement, data portability

### Documentation
- [ ] API documentation (repositories, use cases, schema)
- [ ] GDPR compliance guide for developers
- [ ] Update INDEX.md with new feature
- [ ] Update CLAUDE.md with architecture mapping

---

## 🔗 Research Sources

**Consent UX Best Practices**:
1. [Medium: UX for Privacy & Consent 2025](https://medium.com/design-bootcamp/ux-for-privacy-consent-in-2025-designing-trust-in-a-digital-world-0e41906298e3)
2. [Smashing Magazine: Privacy UX Framework](https://www.smashingmagazine.com/2019/04/privacy-ux-aware-design-framework/)
3. [SecurePrivacy: Mobile App Consent 2025](https://secureprivacy.ai/blog/mobile-app-consent-ios-2025)
4. [Usercentrics: Best Practices Mobile Consent](https://usercentrics.com/knowledge-hub/best-practices-for-mobile-app-consent/)

**GDPR Compliance**:
5. [GDPR Advisor: Fitness Apps](https://www.gdpr-advisor.com/gdpr-compliance-for-fitness-apps-safeguarding-personal-health-information/)
6. [Auth0: GDPR Data Portability](https://auth0.com/docs/secure/data-privacy-and-compliance/gdpr/gdpr-data-portability)

**Encryption & Security**:
7. [SoluteLabs: Trust in HealthTech Apps](https://www.solutelabs.com/blog/build-trust-healthtech-apps)
8. [Linnify: Mobile Health Security 2025](https://www.linnify.com/news/securing-mobile-health-apps-challenges-and-innovations-in-2025)
9. [Apple Developer: Protecting User Privacy](https://developer.apple.com/documentation/healthkit/protecting-user-privacy)

**Deletion UX**:
10. [Cloudscape: Delete Patterns](https://cloudscape.design/patterns/resource-management/delete/delete-with-additional-confirmation/)
11. [LogRocket: Confirmation Dialogs](https://blog.logrocket.com/ux-design/double-check-user-actions-confirmation-dialog/)
12. [UX StackExchange: Confirm vs Undo](https://ux.stackexchange.com/questions/71960/deletion-confirm-or-undo-which-is-the-better-option-and-why)

---

## 📝 Design Version History

**v1.0** - 2025-01-24
- Initial design completed via brainstorming skill
- Research-backed best practices from 12+ industry sources
- 9 sections: Consent, Export, Deletion, Encryption, Audit, Privacy Policy
- Ready for implementation

---

**Next Steps**:
1. Review design document with team
2. Create detailed implementation plan (`superpowers:writing-plans`)
3. Begin implementation with Task 1.1 (Measurement entity)

**Design Status**: ✅ Complete, ready for validation

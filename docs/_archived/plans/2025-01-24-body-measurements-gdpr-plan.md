# Body Measurements Tracking System with GDPR Compliance - Task Plan

**Generated**: 2025-01-24 19:30
**Source**: task-master.dev (WebFetch) + Claude enrichment
**Complexity Score**: HIGH
**Reason**: New feature + Multi-system integration + GDPR compliance + 33 tasks + 20+ metrics
**Total Tasks**: 33
**Estimated Time**: ~19 hours
**Plan Version**: 1.0

**Context Snapshot**:
- Flutter Version: 1.0.0+49
- Key Packages: riverpod ^2.4.9, firebase_core ^4.2.0, health ^13.2.1
- Target Platforms: iOS 14+ (HealthKit), Android 8+ (Health Connect)
- Related PRs/Issues: None
- Parent Milestone: None
- Last Commit: 29d6d4aa feat(templates): implement 5 template quota for free users

---

## 📋 Original Request

> Implement comprehensive body measurements tracking with GDPR compliance
>
> **Metrics to track** (20+ total):
> - Base: Weight, Body Fat %, Lean Mass, BMR, BMI
> - Circumferences: Neck, Shoulders, Chest, Waist, Abdomen, Hips, Biceps (L/R), Forearms (L/R), Thighs (L/R), Calves (L/R)
> - Sync: Bi-directional with HealthKit (iOS) + Health Connect (Android)
> - GDPR: Privacy by design, explicit consent, right to be forgotten, data export, encryption

---

## 🔒 GDPR Compliance Framework

**Critical Requirements**:
1. ✅ **Explicit Consent** - Per-metric granular permissions (Task 14)
2. ✅ **Data Minimization** - Collect only consented metrics (Task 3)
3. ✅ **Encryption at Rest** - AES-256 for local + Firestore (Tasks 5, 25)
4. ✅ **Right to Access** - User-initiated data export (Task 12)
5. ✅ **Right to Erasure** - Complete data deletion (Task 13)
6. ✅ **Audit Trail** - All data access logged (Task 24)
7. ✅ **Privacy Policy** - Legal compliance docs (Task 26)
8. ✅ **Anonymization** - Analytics PII-free (Task 27)

**12 Critical GDPR Checkpoints** marked in tasks below.

---

## 🎯 Task Breakdown

### **Domain Layer** (5 tasks, ~1.75h)

#### Task 1.1: Create Measurement Entity Model
- **Layer**: Domain
- **Files**:
  - `lib/features/body_measurements/domain/entities/measurement.dart`
  - `lib/features/body_measurements/domain/enums/metric_type.dart`
- **Dependencies**: None
- **Est. Time**: 20 min
- **Blocking**: Yes (blocks Tasks 1.2, 1.4, 2.1, 2.3)
- **Verification**:
  - ✅ MetricType enum has 20+ values (weight, bodyFat, leanMass, bmr, bmi, neck, shoulders, chest, waist, abdomen, hips, bicepLeft, bicepRight, forearmLeft, forearmRight, thighLeft, thighRight, calfLeft, calfRight)
  - ✅ Measurement entity has: id, userId, metricType, value, unit, timestamp, source (manual/healthkit/healthconnect)
  - ✅ freezed + json_serializable annotations
  - ✅ Entity compiles + generated code exists
- **GDPR**: ✅ Minimal data model design principle (no excessive PII fields)
- **Code Prompt**:
  ```dart
  Create Measurement entity with freezed + json_serializable:
  - id: String (UUID)
  - userId: String (Firebase auth UID)
  - metricType: MetricType enum (20+ values)
  - value: double (measurement value)
  - unit: String (kg, cm, %, kcal)
  - timestamp: DateTime
  - source: MeasurementSource enum (manual, healthkit, healthconnect)
  - notes: String? (optional user notes)

  Create MetricType enum with all 20+ body measurements listed above.
  ```

---

#### Task 1.2: Build Measurement Repository Interface
- **Layer**: Domain
- **Files**: `lib/features/body_measurements/domain/repositories/measurement_repository.dart`
- **Dependencies**: Task 1.1
- **Est. Time**: 15 min
- **Blocking**: Yes (blocks Tasks 2.2, 2.3)
- **Verification**:
  - ✅ Abstract class MeasurementRepository defined
  - ✅ Methods: addMeasurement(), getMeasurements(), updateMeasurement(), deleteMeasurement(), syncWithHealthPlatform()
  - ✅ Returns Either<Failure, Success> (fpdart pattern)
  - ✅ No implementation (interface only)
- **GDPR**: 🔒 **CHECKPOINT** - Repository enforces consent check before any data access (add requiresConsent parameter)
- **Code Prompt**:
  ```dart
  Create abstract MeasurementRepository interface:
  - Future<Either<Failure, void>> addMeasurement(Measurement measurement, {required bool hasConsent});
  - Future<Either<Failure, List<Measurement>>> getMeasurements(String userId, MetricType? filterByType);
  - Future<Either<Failure, void>> updateMeasurement(Measurement measurement);
  - Future<Either<Failure, void>> deleteMeasurement(String measurementId);
  - Future<Either<Failure, void>> syncWithHealthPlatform(String userId, List<MetricType> consentedMetrics);

  Add hasConsent check to prevent operations without user consent.
  ```

---

#### Task 1.3: Implement Consent & Privacy Domain Models
- **Layer**: Domain
- **Files**:
  - `lib/features/body_measurements/domain/entities/user_consent.dart`
  - `lib/features/body_measurements/domain/enums/permission_scope.dart`
  - `lib/features/body_measurements/domain/entities/audit_log.dart`
- **Dependencies**: None
- **Est. Time**: 25 min
- **Blocking**: Yes (blocks Tasks 2.1, 2.6)
- **Verification**:
  - ✅ UserConsent entity: userId, consentedMetrics (List<MetricType>), consentVersion, timestamp, ipAddress
  - ✅ PermissionScope enum: perMetricGranularity
  - ✅ AuditLog entity: userId, action (access/export/delete), timestamp, ipAddress, metricType
  - ✅ All entities use freezed + json_serializable
- **GDPR**: 🔒 **CRITICAL** - Models support explicit opt-in per metric + audit trail
- **Code Prompt**:
  ```dart
  Create UserConsent entity:
  - userId: String
  - consentedMetrics: List<MetricType> (granular per-metric consent)
  - consentVersion: int (track privacy policy version)
  - acceptedAt: DateTime
  - ipAddress: String (GDPR audit requirement)

  Create AuditLog entity:
  - id: String
  - userId: String
  - action: AuditAction enum (dataAccess, dataExport, dataDelete, consentChange)
  - timestamp: DateTime
  - ipAddress: String
  - affectedMetrics: List<MetricType>?
  ```

---

#### Task 1.4: Create Measurement Validators
- **Layer**: Domain
- **Files**: `lib/features/body_measurements/domain/validators/measurement_validator.dart`
- **Dependencies**: Task 1.1
- **Est. Time**: 20 min
- **Blocking**: No
- **Verification**:
  - ✅ Validate weight: 20-300 kg
  - ✅ Validate body fat: 3-60%
  - ✅ Validate circumferences: 10-200 cm (realistic ranges)
  - ✅ Validate BMR: 800-5000 kcal
  - ✅ Reject outliers (>3 std deviations from user's history)
  - ✅ Unit tests for all validators
- **GDPR**: ✅ Data minimization through quality gates (reject junk data)
- **Code Prompt**:
  ```dart
  Create MeasurementValidator class:
  - validateWeight(double kg): bool (range 20-300)
  - validateBodyFat(double percentage): bool (range 3-60)
  - validateCircumference(double cm, MetricType type): bool (range 10-200)
  - validateBMR(double kcal): bool (range 800-5000)
  - isOutlier(Measurement measurement, List<Measurement> history): bool (3 std dev check)
  ```

---

#### Task 1.5: Define Data Encryption/Decryption Use Cases
- **Layer**: Domain
- **Files**: `lib/features/body_measurements/domain/usecases/encrypt_measurement.dart`
- **Dependencies**: Task 1.1
- **Est. Time**: 25 min
- **Blocking**: Yes (blocks Task 2.3)
- **Verification**:
  - ✅ EncryptMeasurement use case defined (interface)
  - ✅ DecryptMeasurement use case defined
  - ✅ Uses AES-256 encryption contract
  - ✅ Key management interface specified (no implementation yet)
- **GDPR**: 🔒 **CRITICAL** - Encryption by design (domain-level contract)
- **Code Prompt**:
  ```dart
  Create EncryptMeasurement use case:
  - call(Measurement measurement, String encryptionKey): Either<Failure, EncryptedMeasurement>

  Create DecryptMeasurement use case:
  - call(EncryptedMeasurement encrypted, String encryptionKey): Either<Failure, Measurement>

  Define EncryptedMeasurement value object with:
  - encryptedData: String (base64 encoded)
  - iv: String (initialization vector)
  - tag: String (authentication tag)
  ```

---

### **Data Layer** (8 tasks, ~5.5h)

#### Task 2.1: Implement Local Storage Adapter (Hive)
- **Layer**: Data
- **Files**:
  - `lib/features/body_measurements/data/datasources/measurement_local_datasource.dart`
  - `lib/features/body_measurements/data/models/measurement_model.dart`
- **Dependencies**: Tasks 1.1, 1.3
- **Est. Time**: 35 min
- **Blocking**: Yes (blocks Tasks 2.6, 2.8)
- **Verification**:
  - ✅ Hive box initialized: 'body_measurements'
  - ✅ CRUD methods implemented (create, read, update, delete)
  - ✅ Data persists encrypted (verify with Hive encryption enabled)
  - ✅ Queries work (filter by userId, metricType, dateRange)
- **GDPR**: 🔒 **CHECKPOINT** - Verify no unencrypted PII at rest (enable Hive encryption with AES-256)
- **Code Prompt**:
  ```dart
  Create MeasurementLocalDatasource with Hive:
  - Initialize box with encryption: Hive.openBox('body_measurements', encryptionCipher: HiveAesCipher(encryptionKey))
  - addMeasurement(MeasurementModel): Future<void>
  - getMeasurements(String userId, MetricType? filter): Future<List<MeasurementModel>>
  - updateMeasurement(MeasurementModel): Future<void>
  - deleteMeasurement(String id): Future<void>
  - clearAllMeasurements(String userId): Future<void> (for GDPR deletion)
  ```

---

#### Task 2.2: Set Up Firestore Security Rules
- **Layer**: Infrastructure
- **Files**: `firestore.rules` (update existing file)
- **Dependencies**: None
- **Est. Time**: 40 min
- **Blocking**: Yes (blocks Task 2.3)
- **Verification**:
  - ✅ Rules added for collection: `users/{userId}/bodyMeasurements/{measurementId}`
  - ✅ User-scoped access control (request.auth.uid == userId)
  - ✅ Field-level encryption enforced (encryptedData field required)
  - ✅ Test rules deny cross-user access (Firebase emulator test)
- **GDPR**: 🔒 **CRITICAL** - Prevents unauthorized data exposure (encryption + access control)
- **Code Prompt**:
  ```dart
  Add to firestore.rules (after existing user rules):

  match /users/{userId}/bodyMeasurements/{measurementId} {
    // Only authenticated user can access their own measurements
    allow read, write: if request.auth != null && request.auth.uid == userId;

    // Validate encrypted data structure on write
    allow create, update: if request.auth != null
      && request.auth.uid == userId
      && request.resource.data.keys().hasAll(['encryptedData', 'iv', 'tag', 'metricType', 'timestamp']);
  }

  // Consent subcollection
  match /users/{userId}/bodyMeasurements/consent/{docId} {
    allow read, write: if request.auth != null && request.auth.uid == userId;
  }
  ```

---

#### Task 2.3: Implement Firestore Repository
- **Layer**: Data
- **Files**:
  - `lib/features/body_measurements/data/repositories/measurement_repository_impl.dart`
  - `lib/features/body_measurements/data/datasources/measurement_remote_datasource.dart`
- **Dependencies**: Tasks 1.5, 2.1, 2.2
- **Est. Time**: 45 min
- **Blocking**: No
- **Verification**:
  - ✅ Implements MeasurementRepository interface
  - ✅ Data uploads encrypted (encryptedData field)
  - ✅ Queries decrypt transparently (using DecryptMeasurement use case)
  - ✅ Batch operations work (syncMeasurements for multi-upload)
  - ✅ Error handling (network failures, auth errors)
- **GDPR**: 🔒 **CHECKPOINT** - Audit log records all Firestore access (integrate Task 2.9 logger)
- **Code Prompt**:
  ```dart
  Create MeasurementRepositoryImpl:
  - Inject MeasurementLocalDatasource, MeasurementRemoteDatasource, EncryptMeasurement, DecryptMeasurement
  - Override addMeasurement: encrypt → save local → upload Firestore → log audit
  - Override getMeasurements: fetch Firestore → decrypt → merge with local → deduplicate
  - Override deleteMeasurement: delete local + Firestore → log audit
  - Override syncWithHealthPlatform: (implemented in Tasks 2.4, 2.5)
  ```

---

#### Task 2.4: Create HealthKit Integration Service
- **Layer**: Data
- **Files**: `lib/features/body_measurements/data/datasources/healthkit_datasource.dart`
- **Dependencies**: Task 1.3 (consent must exist first)
- **Est. Time**: 50 min
- **Blocking**: No
- **Verification**:
  - ✅ Uses health package ^13.2.1
  - ✅ Bi-directional sync: read weight/bodyFat from HealthKit, write measurements back
  - ✅ Respects iOS permissions (request per data type)
  - ✅ Only syncs metrics user consented to (check UserConsent.consentedMetrics)
  - ✅ Handles permission denials gracefully
- **GDPR**: 🔒 **CHECKPOINT** - Only syncs metrics user consented to (explicit check before read/write)
- **Code Prompt**:
  ```dart
  Create HealthKitDatasource:
  - requestPermissions(List<MetricType> consentedMetrics): Future<bool>
  - readMeasurements(List<MetricType> consentedMetrics, DateTime from, DateTime to): Future<List<Measurement>>
  - writeMeasurement(Measurement measurement): Future<void>

  Map MetricType to HealthDataType:
  - weight → HealthDataType.WEIGHT
  - bodyFat → HealthDataType.BODY_FAT_PERCENTAGE
  - leanMass → HealthDataType.LEAN_BODY_MASS

  IMPORTANT: Wrap all health.readHealthData() calls with consent check:
  if (!consentedMetrics.contains(metricType)) return [];
  ```

---

#### Task 2.5: Implement Health Connect Adapter (Android)
- **Layer**: Data
- **Files**: `lib/features/body_measurements/data/datasources/health_connect_datasource.dart`
- **Dependencies**: Task 1.3
- **Est. Time**: 50 min
- **Blocking**: No
- **Verification**:
  - ✅ Android 8+ compatible (Health Connect SDK)
  - ✅ Bi-directional sync (read + write)
  - ✅ Granular read/write permissions per metric
  - ✅ Handles Health Connect app not installed (graceful fallback)
  - ✅ Only syncs consented metrics
- **GDPR**: 🔒 **CHECKPOINT** - Consent-driven sync (same as HealthKit)
- **Code Prompt**:
  ```dart
  Create HealthConnectDatasource (Android-specific):
  - Platform check: if (!Platform.isAndroid) throw UnsupportedError
  - requestPermissions(List<MetricType> consentedMetrics): Future<bool>
  - readMeasurements(List<MetricType> consentedMetrics, DateTime from, DateTime to): Future<List<Measurement>>
  - writeMeasurement(Measurement measurement): Future<void>

  Handle Health Connect not installed:
  - Catch HealthConnectNotInstalledException
  - Return Either.left(HealthConnectNotAvailableFailure())
  ```

---

#### Task 2.6: Build Consent & Permission Manager
- **Layer**: Data
- **Files**:
  - `lib/features/body_measurements/data/datasources/consent_datasource.dart`
  - `lib/features/body_measurements/data/repositories/consent_repository_impl.dart`
- **Dependencies**: Tasks 1.3, 2.1
- **Est. Time**: 40 min
- **Blocking**: Yes (blocks Tasks 3.1, 3.2)
- **Verification**:
  - ✅ Store/retrieve UserConsent from Hive + Firestore
  - ✅ Enforce consent checks before data collection (hasConsentFor(MetricType) method)
  - ✅ Track consent version (privacy policy updates)
  - ✅ Log consent events to AuditLog
- **GDPR**: 🔒 **CRITICAL** - Explicit consent enforcement (blocks all operations without consent)
- **Code Prompt**:
  ```dart
  Create ConsentRepository:
  - saveConsent(UserConsent consent): Future<Either<Failure, void>>
  - getConsent(String userId): Future<Either<Failure, UserConsent?>>
  - hasConsentFor(String userId, MetricType metric): Future<bool>
  - revokeConsent(String userId, List<MetricType> metrics): Future<void>
  - updateConsentVersion(String userId, int newVersion): Future<void>

  IMPORTANT: All data operations must call hasConsentFor() first:
  if (!await consentRepo.hasConsentFor(userId, metric)) {
    return Either.left(ConsentRequiredFailure());
  }
  ```

---

#### Task 2.7: Implement Data Export Service (JSON)
- **Layer**: Data
- **Files**: `lib/features/body_measurements/data/services/data_export_service.dart`
- **Dependencies**: Tasks 1.1, 1.3, 2.1, 2.3
- **Est. Time**: 35 min
- **Blocking**: No
- **Verification**:
  - ✅ Export all measurements for userId (from Hive + Firestore)
  - ✅ Include consent history in export
  - ✅ Include audit logs (if user requests)
  - ✅ Valid JSON format (validate with json.decode)
  - ✅ User-downloadable (share via platform share sheet or save to files)
- **GDPR**: 🔒 **CRITICAL** - Right to data portability (must export ALL user data in machine-readable format)
- **Code Prompt**:
  ```dart
  Create DataExportService:
  - exportUserData(String userId): Future<Either<Failure, String>> (returns JSON string)

  JSON structure:
  {
    "userId": "...",
    "exportedAt": "2025-01-24T19:30:00Z",
    "measurements": [
      {"id": "...", "metricType": "weight", "value": 75.5, "unit": "kg", "timestamp": "..."}
    ],
    "consent": {
      "consentedMetrics": ["weight", "bodyFat"],
      "consentVersion": 1,
      "acceptedAt": "..."
    },
    "auditLogs": [
      {"action": "dataAccess", "timestamp": "...", "ipAddress": "..."}
    ]
  }

  Method: shareExportedData(String jsonData): Future<void> (use share_plus package)
  ```

---

#### Task 2.8: Create Data Deletion Service
- **Layer**: Data
- **Files**: `lib/features/body_measurements/data/services/data_deletion_service.dart`
- **Dependencies**: Tasks 1.3, 2.1, 2.3
- **Est. Time**: 30 min
- **Blocking**: No
- **Verification**:
  - ✅ Soft-delete with 30-day retention (mark deleted=true, schedule permanent deletion)
  - ✅ Permanent deletion after retention period (delete from Hive + Firestore)
  - ✅ Audit trail logged (deletion action + timestamp)
  - ✅ Confirmation flow (multi-step, see Task 3.7)
- **GDPR**: 🔒 **CRITICAL** - Right to be forgotten (complete data removal)
- **Code Prompt**:
  ```dart
  Create DataDeletionService:
  - softDeleteMeasurements(String userId): Future<Either<Failure, void>> (mark deleted=true, retention until timestamp)
  - permanentDeleteMeasurements(String userId): Future<Either<Failure, void>> (remove from Hive + Firestore)
  - scheduleDeletion(String userId, Duration retentionPeriod): Future<void> (use WorkManager for scheduled deletion)

  IMPORTANT: Log to AuditLog:
  - auditLogger.log(AuditAction.dataDelete, userId, DateTime.now(), ipAddress);
  ```

---

#### Task 2.9: Implement Audit Logging System
- **Layer**: Data
- **Files**: `lib/features/body_measurements/data/services/audit_logger.dart`
- **Dependencies**: Tasks 1.3, 2.3
- **Est. Time**: 40 min
- **Blocking**: No (but should be integrated in Tasks 2.3, 2.7, 2.8)
- **Verification**:
  - ✅ Log events: dataAccess, dataExport, dataDelete, consentChange
  - ✅ Include: userId, timestamp, ipAddress, affectedMetrics
  - ✅ Store logs in Firestore (separate collection: `users/{userId}/auditLogs/{logId}`)
  - ✅ Logs are query-able (user can view their own audit trail)
  - ✅ Tamper-evident (hash each log entry, verify chain)
- **GDPR**: 🔒 **CRITICAL** - Audit trail requirement (must log all data processing activities)
- **Code Prompt**:
  ```dart
  Create AuditLogger:
  - log(AuditAction action, String userId, DateTime timestamp, String ipAddress, List<MetricType>? affectedMetrics): Future<void>
  - getLogs(String userId, DateTime from, DateTime to): Future<List<AuditLog>>
  - verifyIntegrity(List<AuditLog> logs): bool (verify hash chain)

  Hash chain implementation:
  - Each log entry has: hash = SHA256(previousHash + userId + action + timestamp)
  - First log has previousHash = "GENESIS"
  - verifyIntegrity() recomputes hashes and checks chain continuity
  ```

---

### **Presentation Layer** (10 tasks, ~5.75h)

#### Task 3.1: Build Explicit Consent Dialog
- **Layer**: Presentation
- **Files**: `lib/features/body_measurements/presentation/widgets/consent_dialog.dart`
- **Dependencies**: Task 2.6
- **Est. Time**: 35 min
- **Blocking**: Yes (blocks all UI tasks - must get consent first)
- **Verification**:
  - ✅ Per-metric granular checkboxes (20+ metrics, user can select individually)
  - ✅ Privacy policy acceptance checkbox (required, link to full policy)
  - ✅ Localized (EN/IT) - context.l10n.consentDialogTitle, etc.
  - ✅ Dialog blocks further access until accepted (can't dismiss without accept/decline)
  - ✅ "Decline" button closes dialog, returns to previous screen
- **GDPR**: 🔒 **CRITICAL** - First user interaction (explicit consent before ANY data collection)
- **Code Prompt**:
  ```dart
  Create ConsentDialog (AlertDialog):
  - Title: context.l10n.consentDialogTitle ("Body Measurements Consent")
  - Content:
    - Privacy policy summary (3-4 sentences)
    - Link to full policy (Task 3.6)
    - Checkbox list for each MetricType (20+)
    - "Select All" / "Deselect All" buttons
    - Privacy policy acceptance checkbox (required)
  - Actions:
    - "Decline" button (ElevatedButton, secondary color)
    - "Accept" button (ElevatedButton, primary color, disabled until privacy policy checked)

  On Accept:
  - Create UserConsent entity with selected metrics
  - Save via ConsentRepository
  - Close dialog, return true

  Localization keys:
  - consentDialogTitle
  - consentDialogDescription
  - consentMetricWeight, consentMetricBodyFat, etc. (20+ keys)
  - consentPrivacyPolicyAcceptance
  - consentAcceptButton, consentDeclineButton
  ```

---

#### Task 3.2: Create Measurement Input Form
- **Layer**: Presentation
- **Files**: `lib/features/body_measurements/presentation/screens/measurement_input_screen.dart`
- **Dependencies**: Tasks 1.4, 3.1
- **Est. Time**: 40 min
- **Blocking**: No
- **Verification**:
  - ✅ 20+ metric input fields (only show metrics user consented to)
  - ✅ Input validation UI feedback (red border if invalid, error message)
  - ✅ Local draft saving (auto-save every 30s or on pause)
  - ✅ Unit dropdowns (kg/lbs for weight, cm/in for circumferences)
  - ✅ Date/time picker (defaults to now, user can change)
  - ✅ Notes field (optional, max 500 chars)
- **GDPR**: 🔒 **CHECKPOINT** - Only shows consented metrics (fetch UserConsent, hide non-consented fields)
- **Code Prompt**:
  ```dart
  Create MeasurementInputScreen (ConsumerWidget):
  - Fetch UserConsent: ref.watch(consentProvider)
  - Display only consented metrics (filter MetricType.values by consent.consentedMetrics)
  - For each consented metric:
    - TextFormField with validator (use Task 1.4 validators)
    - Unit dropdown (weight: kg/lbs, circumferences: cm/in, bodyFat: %)
    - Real-time validation (onChanged callback)
  - Date/time picker (DateTime.now() default)
  - Notes TextField (maxLength: 500)
  - Save button (disabled until all required fields valid)

  Auto-save draft:
  - Timer.periodic(Duration(seconds: 30), (_) => _saveDraft())
  - Save to Hive with key: 'draft_measurement_${userId}'

  Localization keys:
  - measurementInputTitle
  - measurementInputWeightLabel, measurementInputBodyFatLabel, etc.
  - measurementInputNotesPlaceholder
  - measurementInputSaveButton
  ```

---

#### Task 3.3: Implement Measurement List Screen
- **Layer**: Presentation
- **Files**: `lib/features/body_measurements/presentation/screens/measurement_list_screen.dart`
- **Dependencies**: Tasks 1.1, 2.1, 2.3
- **Est. Time**: 35 min
- **Blocking**: No
- **Verification**:
  - ✅ Displays all measurements chronologically (newest first)
  - ✅ Filter by metric (dropdown: All, Weight, Body Fat, etc.)
  - ✅ Edit/Delete actions (swipe-to-delete, tap-to-edit)
  - ✅ Last sync timestamp shown (from HealthKit/Health Connect)
  - ✅ Pagination (load 50 at a time, infinite scroll)
- **GDPR**: ✅ No sensitive data in logs/analytics (ensure debugPrint statements don't log values)
- **Code Prompt**:
  ```dart
  Create MeasurementListScreen (ConsumerWidget):
  - Fetch measurements: ref.watch(measurementsProvider.select((state) => state.measurements))
  - Filter dropdown (MetricType.all + individual metrics)
  - ListView.builder with Dismissible for swipe-to-delete
  - Each ListTile shows:
    - Leading: Icon for metric type (AppIcons.weight, AppIcons.bodyFat, etc.)
    - Title: "${metricType.name}: ${value} ${unit}"
    - Subtitle: "${timestamp.format()} • Source: ${source.name}"
    - Trailing: IconButton (edit)
  - Pagination: NotificationListener<ScrollNotification> to load more
  - Last sync timestamp in AppBar subtitle

  Localization keys:
  - measurementListTitle
  - measurementListFilterAll, measurementListFilterWeight, etc.
  - measurementListLastSync
  - measurementListDeleteConfirm
  ```

---

#### Task 3.4: Build Progress Charts Screen
- **Layer**: Presentation
- **Files**:
  - `lib/features/body_measurements/presentation/screens/progress_charts_screen.dart`
  - `lib/features/body_measurements/presentation/widgets/weight_trend_chart.dart`
  - `lib/features/body_measurements/presentation/widgets/body_fat_chart.dart`
  - `lib/features/body_measurements/presentation/widgets/circumference_comparison_chart.dart`
- **Dependencies**: Task 1.1
- **Est. Time**: 50 min
- **Blocking**: No
- **Verification**:
  - ✅ Weight trend chart (fl_chart line chart, 6-month/1-year views)
  - ✅ Body fat % trajectory (line chart with goal line)
  - ✅ Circumference comparisons (radar chart for 13 circumferences)
  - ✅ Charts render correctly (data points, axes, legends)
  - ✅ Touch interactions responsive (tap point to see details)
  - ✅ Empty state (if no data, show illustration + CTA)
- **GDPR**: 🔒 **CHECKPOINT** - Charts are user-only, not shared (no social features, no leaderboards)
- **Code Prompt**:
  ```dart
  Create ProgressChartsScreen with 3 tabs:
  1. Weight Trend (LineChart from fl_chart):
     - X-axis: Date (last 6 months or 1 year, toggle)
     - Y-axis: Weight (kg or lbs)
     - Show trend line (linear regression)
     - Touch callback to show exact value

  2. Body Fat % (LineChart):
     - Similar to weight, with goal line (user sets target %)

  3. Circumference Comparison (RadarChart):
     - 13 axes for each circumference
     - Compare current vs. baseline (user selects baseline date)
     - Show % change per metric

  Use fl_chart package (already in pubspec.yaml)

  Localization keys:
  - progressChartsTitle
  - progressChartsWeightTab, progressChartsBodyFatTab, progressChartsCircumferencesTab
  - progressChartsEmptyState
  ```

---

#### Task 3.5: Create Sync Status Indicator
- **Layer**: Presentation
- **Files**: `lib/features/body_measurements/presentation/widgets/sync_status_widget.dart`
- **Dependencies**: Tasks 2.4, 2.5
- **Est. Time**: 20 min
- **Blocking**: No
- **Verification**:
  - ✅ Shows last sync timestamp (HealthKit or Health Connect)
  - ✅ Manual sync button (IconButton with sync icon)
  - ✅ Offline queue indicator (if measurements pending upload)
  - ✅ Updates in real-time (StreamBuilder or ref.listen)
  - ✅ Loading spinner during sync
- **GDPR**: ✅ No sensitive data exposed in status (only "Last synced: X minutes ago", not values)
- **Code Prompt**:
  ```dart
  Create SyncStatusWidget (ConsumerWidget):
  - Watch sync state: ref.watch(syncStatusProvider)
  - Display:
    - Icon (AppIcons.sync or AppIcons.cloudDone based on state)
    - Text: "Last synced: ${timeAgo}" (use timeago package)
    - If syncing: CircularProgressIndicator + "Syncing..."
    - If offline queue: Badge with count "3 pending"
  - Manual sync button:
    - IconButton(icon: AppIcons.refresh, onPressed: () => ref.read(syncProvider).syncNow())

  Localization keys:
  - syncStatusLastSync
  - syncStatusSyncing
  - syncStatusPendingCount
  - syncStatusOffline
  ```

---

#### Task 3.6: Implement Settings/Privacy Screen
- **Layer**: Presentation
- **Files**: `lib/features/body_measurements/presentation/screens/measurement_privacy_screen.dart`
- **Dependencies**: Tasks 2.6, 2.7, 2.8, 3.1
- **Est. Time**: 45 min
- **Blocking**: No
- **Verification**:
  - ✅ View/revoke metric consent (show current consent, tap to revoke)
  - ✅ Download data button (triggers Task 2.7 export)
  - ✅ Delete account confirmation (triggers Task 3.7 dialog)
  - ✅ Privacy policy link (opens in-app WebView or browser)
  - ✅ Localized content (EN/IT)
  - ✅ All privacy controls functional
- **GDPR**: 🔒 **CRITICAL** - User controls dashboard (centralized privacy management)
- **Code Prompt**:
  ```dart
  Create MeasurementPrivacyScreen:
  - Section 1: Current Consent
    - List consented metrics (read from UserConsent)
    - Each metric has "Revoke" button
    - On revoke: confirm dialog → update consent → delete metric data

  - Section 2: Data Export
    - ElevatedButton "Download My Data"
    - On tap: call DataExportService → show share sheet

  - Section 3: Data Deletion
    - ElevatedButton "Delete All Measurements" (red, destructive)
    - On tap: show Task 3.7 confirmation dialog

  - Section 4: Legal
    - TextButton "Privacy Policy" → open URL in WebView
    - TextButton "Terms of Service" → open URL

  Localization keys:
  - privacyScreenTitle
  - privacyScreenCurrentConsent
  - privacyScreenRevokeButton
  - privacyScreenDownloadDataButton
  - privacyScreenDeleteDataButton
  - privacyScreenPrivacyPolicyLink
  ```

---

#### Task 3.7: Build Data Deletion Confirmation Dialog
- **Layer**: Presentation
- **Files**: `lib/features/body_measurements/presentation/widgets/deletion_confirmation_dialog.dart`
- **Dependencies**: Task 2.8
- **Est. Time**: 20 min
- **Blocking**: No
- **Verification**:
  - ✅ Multi-step confirmation (3 steps to prevent accidental deletion)
  - ✅ Warning message (explains data is irrecoverable after 30 days)
  - ✅ Email confirmation (optional: send confirmation code to user email)
  - ✅ Irrevocable notice (bold text: "This action cannot be undone after retention period")
  - ✅ Final confirmation checkbox ("I understand my data will be deleted")
- **GDPR**: 🔒 **CRITICAL** - Right to be forgotten UI (must be clear and intentional)
- **Code Prompt**:
  ```dart
  Create DeletionConfirmationDialog (multi-step):
  - Step 1: Warning
    - Title: context.l10n.deletionWarningTitle ("Are you sure?")
    - Content: "All measurements will be deleted. This cannot be undone after 30 days."
    - Buttons: "Cancel" (secondary), "Continue" (red, primary)

  - Step 2: Final Confirmation
    - Checkbox: "I understand my data will be permanently deleted"
    - TextField: "Type 'DELETE' to confirm" (must match exactly)
    - Buttons: "Cancel", "Delete My Data" (red, disabled until checkbox + text match)

  On confirm:
  - Call DataDeletionService.softDeleteMeasurements()
  - Show SnackBar: "Deletion scheduled. You have 30 days to cancel."
  - Navigate back to settings

  Localization keys:
  - deletionWarningTitle, deletionWarningDescription
  - deletionFinalCheckbox, deletionFinalTextField
  - deletionConfirmButton, deletionCancelButton
  - deletionScheduledSnackbar
  ```

---

#### Task 3.8: Create Sync Conflict Resolution Screen
- **Layer**: Presentation
- **Files**: `lib/features/body_measurements/presentation/screens/sync_conflict_screen.dart`
- **Dependencies**: Tasks 2.1, 2.3
- **Est. Time**: 30 min
- **Blocking**: No
- **Verification**:
  - ✅ Shows conflicts when local ≠ cloud (side-by-side comparison)
  - ✅ User can choose: device data, cloud data, or manual merge
  - ✅ Manual override option (edit values before resolving)
  - ✅ Conflict resolved without data loss (keep both as separate entries if chosen)
- **GDPR**: 🔒 **CHECKPOINT** - Resolution logged to audit trail (record which source user chose)
- **Code Prompt**:
  ```dart
  Create SyncConflictScreen:
  - Detect conflicts: measurements with same metricType + timestamp but different values
  - Display conflicting measurements side-by-side:
    - Left card: "Device Data" (value, timestamp, source)
    - Right card: "Cloud Data" (value, timestamp, source)
  - Resolution options:
    - Radio buttons: "Keep Device", "Keep Cloud", "Keep Both (as separate entries)"
    - If "Keep Both": increment timestamp by 1 second to avoid duplicate
  - Manual override button: opens edit dialog to change values before saving
  - Resolve button: saves chosen option → logs to audit trail

  Localization keys:
  - syncConflictTitle
  - syncConflictDeviceData, syncConflictCloudData
  - syncConflictKeepDevice, syncConflictKeepCloud, syncConflictKeepBoth
  - syncConflictResolveButton
  ```

---

#### Task 3.9: Implement Localization Context (EN/IT)
- **Layer**: Presentation
- **Files**:
  - `assets/i18n/app_en.arb` (update)
  - `assets/i18n/app_it.arb` (update)
- **Dependencies**: None
- **Est. Time**: 25 min
- **Blocking**: No (but should be done early for parallel work)
- **Verification**:
  - ✅ All strings in .arb files (100+ new keys for body measurements)
  - ✅ context.l10n usage throughout (no hardcoded strings)
  - ✅ App switches languages (test in device settings)
  - ✅ No hardcoded strings (run scripts/find_hardcoded_strings.sh)
  - ✅ Privacy policy translations provided (EN + IT)
- **GDPR**: ✅ Privacy policy translations (legal requirement in EU)
- **Code Prompt**:
  ```dart
  Add to app_en.arb (and translate to app_it.arb):

  // Consent Dialog
  "consentDialogTitle": "Body Measurements Consent",
  "consentDialogDescription": "We collect body measurements to track your fitness progress...",
  "consentMetricWeight": "Weight",
  "consentMetricBodyFat": "Body Fat %",
  ... (20+ metric names)
  "consentPrivacyPolicyAcceptance": "I have read and accept the Privacy Policy",
  "consentAcceptButton": "Accept",
  "consentDeclineButton": "Decline",

  // Measurement Input
  "measurementInputTitle": "Add Measurement",
  ... (20+ input labels)

  // Privacy Screen
  "privacyScreenTitle": "Privacy & Data",
  "privacyScreenDownloadDataButton": "Download My Data",
  "privacyScreenDeleteDataButton": "Delete All Measurements",
  ... (10+ privacy strings)

  // Deletion Confirmation
  "deletionWarningTitle": "Are you sure?",
  "deletionWarningDescription": "All measurements will be deleted...",
  ... (5+ deletion strings)

  After adding, run: flutter gen-l10n
  ```

---

#### Task 3.10: Apply Theme System (Dark/Light)
- **Layer**: Presentation
- **Files**: All UI files from Tasks 3.1-3.9
- **Est. Time**: 20 min
- **Blocking**: No (can be done after UI tasks)
- **Verification**:
  - ✅ All colors use context.colors (no hardcoded Colors.blue, etc.)
  - ✅ Respect system preference (check MediaQuery.platformBrightness)
  - ✅ Persist theme choice (save to Hive)
  - ✅ Both themes functional (test light + dark)
  - ✅ Consistent across screens (no theme leaks)
- **GDPR**: ✅ No impact, accessibility improvement
- **Code Prompt**:
  ```dart
  Review all UI files (Tasks 3.1-3.9) and replace:
  - Colors.blue → context.colors.primary
  - Colors.red → context.colors.error
  - Colors.green → context.colors.success
  - Colors.grey → context.colors.surfaceVariant

  Ensure all Text widgets use:
  - context.textTheme.titleMedium, bodyMedium, etc.

  Test in both themes:
  - Open device Settings → Display → Dark Mode (toggle on/off)
  - Verify all screens adapt correctly
  ```

---

### **Privacy & Security** (4 tasks, ~2.5h)

#### Task 4.1: Set Up Encryption Key Management
- **Layer**: Infrastructure
- **Files**: `lib/features/body_measurements/data/services/encryption_key_manager.dart`
- **Dependencies**: Task 1.5
- **Est. Time**: 40 min
- **Blocking**: Yes (blocks Tasks 2.1, 2.3)
- **Verification**:
  - ✅ Per-user encryption keys stored in Secure Enclave (iOS) / Keystore (Android)
  - ✅ Keys never exposed to app code (use flutter_secure_storage)
  - ✅ Key rotation policy (rotate every 90 days or on demand)
  - ✅ Decryption succeeds with rotated keys (backward compatibility)
  - ✅ Key deletion on account deletion (GDPR right to be forgotten)
- **GDPR**: 🔒 **CRITICAL** - Encryption at rest (AES-256, keys isolated from data)
- **Code Prompt**:
  ```dart
  Create EncryptionKeyManager:
  - Use flutter_secure_storage package
  - generateKey(String userId): Future<String> (AES-256 key, store in Keystore/Enclave)
  - getKey(String userId): Future<String?> (retrieve from secure storage)
  - rotateKey(String userId): Future<void> (generate new key, re-encrypt all data with new key)
  - deleteKey(String userId): Future<void> (remove from secure storage)

  Key format:
  - AES-256 key (32 bytes)
  - Store as base64 string in flutter_secure_storage
  - Key name: 'body_measurements_encryption_key_${userId}'

  Rotation logic:
  - Check last rotation timestamp (store in Hive)
  - If >90 days, trigger rotation:
    1. Generate new key
    2. Fetch all encrypted measurements
    3. Decrypt with old key, re-encrypt with new key
    4. Update all records
    5. Delete old key
  ```

---

#### Task 4.2: Implement Audit Logging System
- **Layer**: Data (already covered in Task 2.9, but re-stated here for clarity)
- **Files**: `lib/features/body_measurements/data/services/audit_logger.dart`
- **Dependencies**: Tasks 1.3, 2.3
- **Est. Time**: 40 min
- **Blocking**: No
- **Verification**:
  - ✅ (Same as Task 2.9)
- **GDPR**: 🔒 **CRITICAL** - (Same as Task 2.9)
- **Code Prompt**: (Same as Task 2.9)

**Note**: This task is a duplicate of Task 2.9 for organizational clarity. Implement only once.

---

#### Task 4.3: Create Privacy Policy & Legal Documents
- **Layer**: Documentation
- **Files**:
  - `docs/PRIVACY_POLICY_BODY_MEASUREMENTS.md`
  - `docs/TERMS_OF_SERVICE_BODY_MEASUREMENTS.md`
- **Dependencies**: None
- **Est. Time**: 30 min
- **Blocking**: Yes (blocks Task 3.1 - privacy policy must exist before consent dialog)
- **Verification**:
  - ✅ GDPR-compliant privacy policy (covers all 20+ metrics, consent, encryption, deletion)
  - ✅ Data processing agreement (DPA) for cloud storage
  - ✅ Accessible in-app (link from consent dialog + settings)
  - ✅ Legal review (external - marked as TODO)
  - ✅ Translations (EN + IT)
- **GDPR**: 🔒 **CRITICAL** - Must exist pre-launch (GDPR Article 13 transparency requirement)
- **Code Prompt**:
  ```markdown
  Create PRIVACY_POLICY_BODY_MEASUREMENTS.md with sections:

  1. Introduction
     - What data we collect (20+ body measurements)
     - Why we collect it (fitness tracking, progress visualization)

  2. Data Collection & Consent
     - Explicit consent required per metric
     - How to revoke consent
     - Granular permissions (user controls each metric)

  3. Data Storage & Security
     - Encryption at rest (AES-256)
     - Secure key management (Keystore/Enclave)
     - Firestore access controls

  4. Data Usage
     - Local storage (Hive)
     - Cloud sync (Firestore)
     - Health platform integration (HealthKit/Health Connect)
     - No third-party sharing (except Apple/Google health platforms)

  5. User Rights (GDPR)
     - Right to access (data export)
     - Right to erasure (deletion with 30-day retention)
     - Right to portability (JSON export)
     - Right to rectification (edit measurements)

  6. Data Retention
     - Active data: indefinite (until user deletes)
     - Deleted data: 30-day soft-delete retention, then permanent deletion
     - Audit logs: 2-year retention for compliance

  7. Contact
     - Data protection officer email
     - Support contact

  Add link to privacy policy in consent dialog (Task 3.1) and settings (Task 3.6).

  Translate to Italian in PRIVACY_POLICY_BODY_MEASUREMENTS_IT.md
  ```

---

#### Task 4.4: Implement Analytics Anonymization Layer
- **Layer**: Data
- **Files**: `lib/features/body_measurements/data/services/anonymized_analytics.dart`
- **Dependencies**: None
- **Est. Time**: 30 min
- **Blocking**: No
- **Verification**:
  - ✅ Strip PII before sending to Firebase Analytics
  - ✅ Pseudo-anonymized user IDs (hash userId before logging)
  - ✅ No measurement values logged (only event counts, not actual kg/cm/%)
  - ✅ Events: 'measurement_added', 'consent_granted', 'data_exported' (no values)
  - ✅ Verify in Firebase Analytics console (no PII visible)
- **GDPR**: 🔒 **CHECKPOINT** - Data minimization for analytics (no personal data in logs)
- **Code Prompt**:
  ```dart
  Create AnonymizedAnalytics wrapper:
  - logMeasurementAdded(MetricType type): logs event 'measurement_added' with metricType (no value, no userId)
  - logConsentGranted(int metricCount): logs 'consent_granted' with count (no specific metrics)
  - logDataExported(): logs 'data_exported' (no userId, no content)
  - logDataDeleted(): logs 'data_deleted' (no userId)

  User ID anonymization:
  - Hash userId with SHA256 before logging
  - Store hashed ID in analytics user property 'pseudo_user_id'

  NEVER log:
  - Measurement values (75.5 kg, 35% body fat, etc.)
  - User email, name, or identifiable info
  - Specific metric lists (only counts)

  Allowed analytics:
  - Event counts (how many measurements added per day)
  - Metric popularity (which metrics are most tracked)
  - Feature usage (consent dialog shown, export used, etc.)
  ```

---

### **Testing** (4 tasks, ~3h)

#### Task 5.1: Unit Tests - Domain & Use Cases
- **Layer**: Testing
- **Files**:
  - `test/features/body_measurements/domain/entities/measurement_test.dart`
  - `test/features/body_measurements/domain/validators/measurement_validator_test.dart`
  - `test/features/body_measurements/domain/usecases/encrypt_measurement_test.dart`
- **Dependencies**: Tasks 1.1-1.5
- **Est. Time**: 40 min
- **Blocking**: No
- **Verification**:
  - ✅ Test Measurement entity (freezed equality, json serialization)
  - ✅ Test validators (all edge cases: valid ranges, outliers, invalid inputs)
  - ✅ Test encryption contracts (mock encryption/decryption)
  - ✅ 80%+ coverage for domain layer
- **GDPR**: ✅ Consent logic tested thoroughly (validate hasConsent checks)
- **Code Prompt**:
  ```dart
  Create measurement_test.dart:
  - Test Measurement.fromJson() / toJson() (round-trip)
  - Test Measurement equality (two instances with same data)
  - Test MetricType enum (all 20+ values present)

  Create measurement_validator_test.dart:
  - testValidateWeight: valid (20-300 kg), invalid (<20, >300)
  - testValidateBodyFat: valid (3-60%), invalid (<3, >60)
  - testValidateCircumference: valid (10-200 cm), invalid (<10, >200)
  - testIsOutlier: measurement >3 std dev from history → true

  Create encrypt_measurement_test.dart:
  - Mock EncryptMeasurement use case
  - Test encrypt → decrypt round-trip (data integrity)
  - Test decryption fails with wrong key
  ```

---

#### Task 5.2: Integration Tests - Data Layer
- **Layer**: Testing
- **Files**:
  - `test/features/body_measurements/data/repositories/measurement_repository_impl_test.dart`
  - `test/features/body_measurements/data/datasources/healthkit_datasource_test.dart`
- **Dependencies**: Tasks 2.1-2.5
- **Est. Time**: 45 min
- **Blocking**: No
- **Verification**:
  - ✅ Test local storage CRUD (Hive operations)
  - ✅ Test Firestore sync (mock Firestore, verify encryption)
  - ✅ Test HealthKit/Health Connect mock integration (verify consent checks)
  - ✅ Test data flows work (domain → data → storage)
  - ✅ Test encryption transparent (encrypt on save, decrypt on read)
- **GDPR**: ✅ Verify no consent bypass possible (all operations blocked without consent)
- **Code Prompt**:
  ```dart
  Create measurement_repository_impl_test.dart:
  - Mock MeasurementLocalDatasource, MeasurementRemoteDatasource
  - Test addMeasurement: encrypts → saves local → uploads Firestore
  - Test getMeasurements: fetches Firestore → decrypts → merges with local
  - Test deleteMeasurement: deletes local + Firestore → logs audit
  - Test consent enforcement: addMeasurement without consent → throws ConsentRequiredFailure

  Create healthkit_datasource_test.dart:
  - Mock health package (use mockito)
  - Test readMeasurements: only reads consented metrics
  - Test writeMeasurement: writes to HealthKit
  - Test permission denial: readMeasurements with denied permission → empty list
  ```

---

#### Task 5.3: UI Widget Tests - Privacy Dialogs
- **Layer**: Testing
- **Files**:
  - `test/features/body_measurements/presentation/widgets/consent_dialog_test.dart`
  - `test/features/body_measurements/presentation/widgets/deletion_confirmation_dialog_test.dart`
- **Dependencies**: Tasks 3.1, 3.7, 2.7
- **Est. Time**: 35 min
- **Blocking**: No
- **Verification**:
  - ✅ Test consent dialog interactions (select metrics, accept/decline)
  - ✅ Test deletion confirmation (multi-step flow)
  - ✅ Test export functionality (triggers download)
  - ✅ All flows functional (user can't skip required steps)
  - ✅ Localization tested (EN + IT strings render)
- **GDPR**: 🔒 **CRITICAL** - Ensure GDPR UX works (consent can't be bypassed, deletion is intentional)
- **Code Prompt**:
  ```dart
  Create consent_dialog_test.dart:
  - Test dialog shows 20+ metric checkboxes
  - Test "Select All" / "Deselect All" buttons
  - Test "Accept" button disabled until privacy policy checked
  - Test "Decline" button closes dialog without saving
  - Test "Accept" button saves consent and closes dialog

  Create deletion_confirmation_dialog_test.dart:
  - Test Step 1: warning shown, "Cancel" closes dialog
  - Test Step 2: checkbox + "DELETE" text field required
  - Test "Delete My Data" button disabled until both conditions met
  - Test final confirm triggers DataDeletionService.softDeleteMeasurements()
  ```

---

#### Task 5.4: End-to-End Test - Full Measurement Workflow
- **Layer**: Testing
- **Files**: `integration_test/body_measurements_e2e_test.dart`
- **Dependencies**: All previous tasks
- **Est. Time**: 50 min
- **Blocking**: No
- **Verification**:
  - ✅ New user → consent dialog → input measurement → sync → export → delete journey
  - ✅ Complete user flow works (no crashes, no data loss)
  - ✅ Consent enforced at every step (can't add measurement without consent)
  - ✅ Encryption verified (data stored encrypted in Hive + Firestore)
  - ✅ Deletion works (soft-delete → permanent delete after retention)
- **GDPR**: 🔒 **CHECKPOINT** - Verify full compliance path (consent → collection → export → deletion)
- **Code Prompt**:
  ```dart
  Create body_measurements_e2e_test.dart (use integration_test package):

  testWidgets('Full measurement workflow', (tester) async {
    // 1. Launch app
    await tester.pumpWidget(MyApp());

    // 2. Navigate to body measurements
    await tester.tap(find.text('Body Measurements'));
    await tester.pumpAndSettle();

    // 3. Consent dialog appears (first time)
    expect(find.text('Body Measurements Consent'), findsOneWidget);

    // 4. Select metrics (weight + body fat)
    await tester.tap(find.byType(Checkbox).at(0)); // Weight
    await tester.tap(find.byType(Checkbox).at(1)); // Body Fat
    await tester.tap(find.text('I accept the Privacy Policy')); // Privacy policy
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    // 5. Input measurement
    await tester.tap(find.text('Add Measurement'));
    await tester.enterText(find.byKey(Key('weight_input')), '75.5');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // 6. Verify measurement saved
    expect(find.text('75.5 kg'), findsOneWidget);

    // 7. Export data
    await tester.tap(find.text('Settings'));
    await tester.tap(find.text('Download My Data'));
    await tester.pumpAndSettle();
    // Verify share sheet appears (platform-specific)

    // 8. Delete data
    await tester.tap(find.text('Delete All Measurements'));
    await tester.pumpAndSettle();
    // Multi-step confirmation
    await tester.tap(find.text('Continue'));
    await tester.tap(find.byType(Checkbox).last); // "I understand" checkbox
    await tester.enterText(find.byKey(Key('delete_confirm_field')), 'DELETE');
    await tester.tap(find.text('Delete My Data'));
    await tester.pumpAndSettle();

    // 9. Verify deletion scheduled
    expect(find.text('Deletion scheduled'), findsOneWidget);
  });
  ```

---

### **Documentation** (2 tasks, ~1h)

#### Task 6.1: Write API Documentation
- **Layer**: Documentation
- **Files**: `docs/BODY_MEASUREMENTS_API_DOCUMENTATION.md`
- **Dependencies**: Tasks 1.1-2.9
- **Est. Time**: 30 min
- **Blocking**: No
- **Verification**:
  - ✅ All repository interfaces documented (methods, parameters, returns)
  - ✅ Use case contracts documented (input/output)
  - ✅ Firestore schema documented (collections, fields, encryption)
  - ✅ All public APIs documented (no undocumented public methods)
  - ✅ Examples provided (code snippets for common operations)
- **GDPR**: ✅ Include data retention policy in docs (30-day soft-delete, 2-year audit logs)
- **Code Prompt**:
  ```markdown
  Create BODY_MEASUREMENTS_API_DOCUMENTATION.md with sections:

  1. Overview
     - Feature description
     - Architecture (Clean Architecture layers)
     - Key entities (Measurement, UserConsent, AuditLog)

  2. Repository Interfaces
     - MeasurementRepository:
       - addMeasurement(Measurement, hasConsent): Future<Either<Failure, void>>
       - getMeasurements(userId, filterByType): Future<Either<Failure, List<Measurement>>>
       - ...
     - ConsentRepository:
       - saveConsent(UserConsent): Future<Either<Failure, void>>
       - hasConsentFor(userId, metric): Future<bool>
       - ...

  3. Use Cases
     - EncryptMeasurement:
       - Input: Measurement + encryptionKey
       - Output: EncryptedMeasurement
       - Example:
         ```dart
         final encrypted = await encryptMeasurement.call(measurement, key);
         ```

  4. Firestore Schema
     - Collection: users/{userId}/bodyMeasurements/{measurementId}
       - Fields: encryptedData (String), iv (String), tag (String), metricType (String), timestamp (Timestamp)
     - Collection: users/{userId}/bodyMeasurements/consent/{docId}
       - Fields: consentedMetrics (List<String>), consentVersion (int), acceptedAt (Timestamp)

  5. Data Retention Policy
     - Active data: Indefinite (until user deletes)
     - Soft-deleted data: 30-day retention, then permanent deletion
     - Audit logs: 2-year retention for GDPR compliance

  6. Examples
     - Add measurement with consent check
     - Export user data
     - Delete all measurements
  ```

---

#### Task 6.2: Create Developer GDPR Compliance Guide
- **Layer**: Documentation
- **Files**: `docs/GDPR_COMPLIANCE_GUIDE_BODY_MEASUREMENTS.md`
- **Dependencies**: Tasks 4.1-4.4
- **Est. Time**: 35 min
- **Blocking**: No
- **Verification**:
  - ✅ Checklist for adding new metrics (consent, encryption, audit)
  - ✅ Consent flow requirements documented
  - ✅ Encryption standards documented (AES-256, key management)
  - ✅ Audit logging requirements documented (what to log, retention)
  - ✅ Guide complete (team can follow it for future features)
- **GDPR**: 🔒 **CRITICAL** - Ensures ongoing compliance (future features follow same standards)
- **Code Prompt**:
  ```markdown
  Create GDPR_COMPLIANCE_GUIDE_BODY_MEASUREMENTS.md with sections:

  1. Introduction
     - Why GDPR compliance matters
     - Legal requirements (EU General Data Protection Regulation)
     - Penalties for non-compliance

  2. Adding New Metrics - Checklist
     - [ ] Add metric to MetricType enum
     - [ ] Update consent dialog to include new metric (checkbox)
     - [ ] Add localization strings (EN + IT) for metric name
     - [ ] Update validators (add range check for new metric)
     - [ ] Update encryption (ensure new metric data is encrypted)
     - [ ] Update export service (include new metric in JSON export)
     - [ ] Update deletion service (ensure new metric deleted)
     - [ ] Add audit logging for new metric operations
     - [ ] Update privacy policy (mention new metric)
     - [ ] Test consent flow with new metric

  3. Consent Flow Requirements
     - Explicit opt-in required (pre-checked boxes NOT allowed)
     - Granular per-metric consent (user controls each metric)
     - Privacy policy acceptance required (separate checkbox)
     - Consent version tracking (update version when policy changes)
     - Revocation must be easy (single-tap revoke in settings)

  4. Encryption Standards
     - Algorithm: AES-256 (symmetric encryption)
     - Key management: Per-user keys in Keystore/Enclave (never in code/logs)
     - Key rotation: Every 90 days or on-demand
     - Encrypted fields: measurement value, notes (all PII)
     - Unencrypted fields: metricType, timestamp, userId (for queries)

  5. Audit Logging Requirements
     - What to log:
       - dataAccess (when measurements read)
       - dataExport (when user exports data)
       - dataDelete (when user deletes data)
       - consentChange (when user grants/revokes consent)
     - Required fields: userId, timestamp, ipAddress, action, affectedMetrics
     - Retention: 2 years (GDPR compliance)
     - Tamper-evidence: Hash chain (verify integrity)

  6. Data Retention Policy
     - Active data: Indefinite (until user deletes)
     - Soft-deleted: 30-day retention (user can cancel)
     - Permanent deletion: After 30 days (irrecoverable)
     - Audit logs: 2-year retention (legal requirement)

  7. User Rights Implementation
     - Right to access: Data export (JSON format)
     - Right to erasure: Deletion with confirmation
     - Right to portability: JSON export (machine-readable)
     - Right to rectification: Edit measurements
     - Right to object: Revoke consent per metric

  8. Testing GDPR Compliance
     - Test consent can't be bypassed (all operations fail without consent)
     - Test data export includes ALL user data (measurements + consent + audit logs)
     - Test deletion is complete (verify no data left in Hive + Firestore)
     - Test encryption (verify data stored encrypted, no plaintext)
     - Test audit trail (verify all operations logged)
  ```

---

## 📊 Implementation Order

**PHASE 1: Foundation (MUST DO FIRST)** - Blocking tasks, ~3.5h:
→ Task 1.1 (Measurement entity) - 20 min
→ Task 1.2 (Repository interface) - 15 min
→ Task 1.3 (Consent models) - 25 min
→ Task 1.5 (Encryption contracts) - 25 min
→ Task 4.1 (Encryption key management) - 40 min
→ Task 4.3 (Privacy policy) - 30 min
→ Task 2.2 (Firestore security rules) - 40 min
→ Task 2.6 (Consent manager) - 40 min

**PHASE 2: Data Layer (Parallel Workable)** - ~3.5h:
→ Task 2.1 (Local storage) - 35 min
→ Task 2.3 (Firestore repository) - 45 min
→ Task 2.4 (HealthKit) - 50 min
→ Task 2.5 (Health Connect) - 50 min
→ Task 2.9 (Audit logging) - 40 min

**PHASE 3: Presentation Layer (Parallel Workable)** - ~5.75h:
→ Task 3.1 (Consent dialog) - 35 min
→ Task 3.9 (Localization) - 25 min (do early for parallel work)
→ Task 3.2 (Input form) - 40 min
→ Task 3.3 (Measurement list) - 35 min
→ Task 3.4 (Progress charts) - 50 min
→ Task 3.5 (Sync status) - 20 min
→ Task 3.6 (Privacy screen) - 45 min
→ Task 3.7 (Deletion dialog) - 20 min
→ Task 3.8 (Sync conflict) - 30 min
→ Task 3.10 (Theme system) - 20 min

**PHASE 4: Privacy & Testing (FINALLY)** - ~5.5h:
→ Task 2.7 (Data export) - 35 min
→ Task 2.8 (Data deletion) - 30 min
→ Task 4.4 (Analytics anonymization) - 30 min
→ Task 5.1 (Unit tests) - 40 min
→ Task 5.2 (Integration tests) - 45 min
→ Task 5.3 (Widget tests) - 35 min
→ Task 5.4 (E2E test) - 50 min
→ Task 6.1 (API docs) - 30 min
→ Task 6.2 (GDPR guide) - 35 min

**Total Critical Path**: ~19 hours

---

## 🔗 Cross-Dependencies

**Task 3.1 (Consent dialog) BLOCKS**:
- All UI tasks (3.2-3.8) - can't show UI without consent
- All data collection tasks (2.4, 2.5) - can't sync without consent

**Task 2.2 (Firestore rules) BLOCKS**:
- Task 2.3 (Firestore repository) - can't access Firestore without rules
- All cloud operations - entire system fails if rules misconfigured

**Task 4.1 (Encryption keys) BLOCKS**:
- Task 2.1 (Local storage) - Hive encryption requires keys
- Task 2.3 (Firestore repository) - cloud encryption requires keys

**Critical Risk**: Firestore security rules (Task 2.2) must be deployed early and tested thoroughly. Misconfigured rules block entire feature.

---

## ✅ Validation Checklist

Before marking this plan complete, verify:

**GDPR Compliance**:
- [ ] Explicit consent implemented (per-metric granular)
- [ ] Encryption at rest (AES-256, keys in Keystore/Enclave)
- [ ] Data export working (JSON format, all data included)
- [ ] Data deletion working (soft-delete + permanent)
- [ ] Audit trail complete (all operations logged)
- [ ] Privacy policy accessible (in-app + translations)
- [ ] Analytics anonymized (no PII logged)

**Functionality**:
- [ ] 20+ metrics supported (weight, body fat, 13 circumferences, BMR, lean mass)
- [ ] HealthKit sync working (bi-directional, iOS)
- [ ] Health Connect sync working (bi-directional, Android)
- [ ] Manual input working (all metrics, validation)
- [ ] Progress charts rendering (weight, body fat, circumferences)
- [ ] Conflict resolution working (device vs. cloud)

**Code Quality**:
- [ ] Localized (EN + IT, no hardcoded strings)
- [ ] Theme support (dark + light)
- [ ] flutter analyze passes (0 errors)
- [ ] Tests passing (unit + integration + widget + E2E)
- [ ] Documentation complete (API docs + GDPR guide)

**Security**:
- [ ] Firestore rules deployed and tested (no cross-user access)
- [ ] Encryption verified (no plaintext PII in storage)
- [ ] Keys isolated (never logged or exposed)
- [ ] Audit logs tamper-evident (hash chain verified)

---

## 📝 Notes & Decisions

**Why 33 tasks?**
- GDPR compliance requires extensive privacy infrastructure (consent, encryption, audit, deletion)
- 20+ metrics means significant data modeling and validation work
- Bi-directional health platform sync (HealthKit + Health Connect) is complex
- Testing requirements are high due to GDPR criticality

**Why 19 hours estimate?**
- Similar features in production apps take 15-25 hours
- GDPR compliance adds ~40% overhead (privacy features, legal docs, audit)
- Health platform integration is time-consuming (platform-specific APIs, permissions)

**Future Enhancements** (out of scope for v1.0):
- Photo progress tracking (before/after photos)
- Body composition scale integration (Bluetooth)
- AI-powered recommendations based on measurements
- Social features (share progress with friends)
- Premium analytics (body recomposition predictions)

---

**Plan Version**: 1.0
**Last Updated**: 2025-01-24 19:30
**Status**: Ready for implementation

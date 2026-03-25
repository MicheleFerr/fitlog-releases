/// 🔐 SECURITY: Template Cloud Service for Server-Side Quota Enforcement
///
/// This service provides secure template creation through Cloud Functions.
/// **Client-side writes are BLOCKED** by Firestore Security Rules - all template
/// creation MUST go through this service.
///
/// **Quota Tiers**:
/// - Free: 4 editable templates in Library
/// - Premium: 999 editable templates in Library (effectively unlimited)
///
/// **Why Cloud Functions?**
/// - Atomic quota check + creation (no race conditions)
/// - Server-side validation (cannot be bypassed)
/// - Rate limited to prevent abuse
/// - Audit trail for all operations
///
/// **Usage**:
/// ```dart
/// // Create a template
/// final result = await TemplateCloudService.createTemplate(
///   name: 'Push Day',
///   description: 'My push workout',
///   exercises: exercises,
/// );
///
/// // Check quota
/// final quota = await TemplateCloudService.getTemplateQuota();
/// print('Remaining: ${quota.privateRemaining}');
/// ```
///
/// @see functions/src/templates/createTemplate.ts (Cloud Function)
library;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:gymbro_flutter_new/shared/domain/services/request_throttler.dart';
import 'package:gymbro_flutter_new/core/utils/app_logger.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

/// Result of creating a template via Cloud Function
class CreateTemplateResult {
  const CreateTemplateResult({
    required this.success,
    required this.templateId,
    required this.templateName,
    required this.quota,
    this.error,
  });

  factory CreateTemplateResult.fromResponse(Map<String, dynamic> data) {
    // Firebase Cloud Functions return _Map<Object?, Object?>, need to convert
    final templateData = data['template'] != null
        ? Map<String, dynamic>.from(data['template'] as Map)
        : <String, dynamic>{};
    final quotaData = data['quota'] != null
        ? Map<String, dynamic>.from(data['quota'] as Map)
        : <String, dynamic>{};

    return CreateTemplateResult(
      success: data['success'] == true,
      templateId: data['templateId'] as String? ?? '',
      templateName: templateData['name'] as String? ?? '',
      quota: TemplateQuotaInfo.fromResponse(quotaData),
    );
  }

  factory CreateTemplateResult.error(String errorMessage) {
    return CreateTemplateResult(
      success: false,
      templateId: '',
      templateName: '',
      quota: TemplateQuotaInfo.empty(),
      error: errorMessage,
    );
  }

  final bool success;
  final String templateId;
  final String templateName;
  final TemplateQuotaInfo quota;
  final String? error;
}

class TemplateMutationResult {
  const TemplateMutationResult({required this.templateId, required this.quota});

  factory TemplateMutationResult.fromResponse(Map<String, dynamic> data) {
    final quotaData = data['quota'] != null
        ? Map<String, dynamic>.from(data['quota'] as Map)
        : <String, dynamic>{};

    return TemplateMutationResult(
      templateId: data['templateId'] as String? ?? '',
      quota: TemplateQuotaInfo.fromResponse(quotaData),
    );
  }

  final String templateId;
  final TemplateQuotaInfo quota;
}

/// Template quota information
class TemplateQuotaInfo {
  const TemplateQuotaInfo({
    required this.accountTier,
    required this.libraryUsed,
    required this.libraryMax,
    required this.libraryRemaining,
    required this.distributionUsed,
    required this.distributionMax,
    required this.distributionRemaining,
    this.distributionMetered = false,
  });

  factory TemplateQuotaInfo.fromResponse(Map<String, dynamic> data) {
    // Firebase Cloud Functions return _Map<Object?, Object?>, need to convert
    final libraryData = data['library'] != null
        ? Map<String, dynamic>.from(data['library'] as Map)
        : data['private'] != null
        ? Map<String, dynamic>.from(data['private'] as Map)
        : <String, dynamic>{};
    final distributionData = data['distribution'] != null
        ? Map<String, dynamic>.from(data['distribution'] as Map)
        : data['shared'] != null
        ? Map<String, dynamic>.from(data['shared'] as Map)
        : data['public'] != null
        ? Map<String, dynamic>.from(data['public'] as Map)
        : <String, dynamic>{};

    return TemplateQuotaInfo(
      accountTier: data['accountTier'] as String? ?? 'free',
      libraryUsed:
          libraryData['used'] as int? ??
          data['libraryUsed'] as int? ??
          data['privateUsed'] as int? ??
          0,
      libraryMax:
          libraryData['max'] as int? ??
          data['libraryMax'] as int? ??
          data['privateMax'] as int? ??
          4,
      libraryRemaining:
          libraryData['remaining'] as int? ??
          data['libraryRemaining'] as int? ??
          ((data['libraryMax'] as int? ?? data['privateMax'] as int? ?? 4) -
              (data['libraryUsed'] as int? ??
                  data['privateUsed'] as int? ??
                  0)),
      distributionUsed:
          distributionData['used'] as int? ??
          data['distributionUsed'] as int? ??
          data['sharedUsed'] as int? ??
          data['publicUsed'] as int? ??
          0,
      distributionMax:
          distributionData['max'] as int? ??
          data['distributionMax'] as int? ??
          data['sharedMax'] as int? ??
          data['publicMax'] as int? ??
          999,
      distributionRemaining:
          distributionData['remaining'] as int? ??
          data['distributionRemaining'] as int? ??
          ((data['distributionMax'] as int? ??
                  data['sharedMax'] as int? ??
                  data['publicMax'] as int? ??
                  999) -
              (data['distributionUsed'] as int? ??
                  data['sharedUsed'] as int? ??
                  data['publicUsed'] as int? ??
                  0)),
      distributionMetered:
          distributionData['metered'] as bool? ??
          data['distributionMetered'] as bool? ??
          false,
    );
  }

  factory TemplateQuotaInfo.empty() {
    return const TemplateQuotaInfo(
      accountTier: 'free',
      libraryUsed: 0,
      libraryMax: 4,
      libraryRemaining: 4,
      distributionUsed: 0,
      distributionMax: 999,
      distributionRemaining: 999,
    );
  }

  final String accountTier;
  final int libraryUsed;
  final int libraryMax;
  final int libraryRemaining;
  final int distributionUsed;
  final int distributionMax;
  final int distributionRemaining;
  final bool distributionMetered;

  int get privateUsed => libraryUsed;

  int get privateMax => libraryMax;

  int get privateRemaining => libraryRemaining;

  int get sharedUsed => distributionUsed;

  int get sharedMax => distributionMax;

  int get sharedRemaining => distributionRemaining;

  int get publicUsed => distributionUsed;

  int get publicMax => distributionMax;

  int get publicRemaining => distributionRemaining;

  bool get canSaveToLibrary => libraryRemaining > 0;

  /// Check if user can save another editable template to Library.
  bool get canCreatePrivate => canSaveToLibrary;

  /// Distribution is free in the store-first model.
  bool get canCreatePublic => true;

  /// Check if user is at quota limit
  bool get isAtLimit => !canSaveToLibrary;

  /// Check if user is close to the Library limit (<=2 remaining)
  bool get isNearPrivateLimit => libraryRemaining <= 2 && libraryRemaining > 0;
}

/// Template quota exception for quota-related errors
class TemplateQuotaExceededException implements Exception {
  const TemplateQuotaExceededException({
    required this.message,
    required this.quota,
  });

  final String message;
  final TemplateQuotaInfo quota;

  @override
  String toString() => 'TemplateQuotaExceededException: $message';
}

/// Cloud service for template operations with server-side quota enforcement
class TemplateCloudService {
  // Private constructor (utility class)
  TemplateCloudService._();

  // 🔐 SECURITY: Rate limit handler for Cloud Function calls
  static final _rateLimitHandler = RateLimitHandler(
    maxRetries: 2,
    retryMultiplier: 1.5,
  );

  /// Create a new template via Cloud Function
  ///
  /// **Security**:
  /// - Server-side quota enforcement (cannot be bypassed)
  /// - Atomic operation (no race conditions)
  /// - Rate limited to prevent abuse
  /// - All operations logged to audit trail
  ///
  /// **Parameters**:
  /// - `name`: Template name (required, max 100 chars)
  /// - `description`: Template description (optional, max 500 chars)
  /// - `exercises`: List of exercises (required, 1-50 exercises)
  /// - `tags`: List of tags (optional, max 10 tags)
  /// - `isPublic`: Whether template is public (default: false)
  ///
  /// **Returns**: `CreateTemplateResult` with template ID and quota info
  ///
  /// **Throws**:
  /// - `TemplateQuotaExceededException` if quota exceeded
  /// - `FirebaseFunctionsException` for other errors
  ///
  /// **Example**:
  /// ```dart
  /// try {
  ///   final result = await TemplateCloudService.createTemplate(
  ///     name: 'Push Day',
  ///     description: 'Chest, shoulders, triceps',
  ///     exercises: workoutExercises,
  ///     tags: ['push', 'upper'],
  ///   );
  ///
  ///   if (result.success) {
  ///     print('Created template: ${result.templateId}');
  ///     print('Remaining quota: ${result.quota.privateRemaining}');
  ///   }
  /// } on TemplateQuotaExceededException catch (e) {
  ///   // Show upgrade dialog
  ///   showUpgradeDialog(context, e.quota);
  /// }
  /// ```
  static Future<CreateTemplateResult> createTemplate({
    required String name,
    String? description,
    required List<Exercise> exercises,
    List<String> tags = const [],
    bool isPublic = false,
  }) async {
    try {
      AppLogger.info(
        'Creating template via Cloud Function: "$name" (${exercises.length} exercises)',
        tag: 'TemplateCloudService',
      );

      // Convert exercises to JSON-serializable format
      final exercisesJson = exercises.map((e) => _exerciseToJson(e)).toList();

      // 🔐 SECURITY: Call Cloud Function with rate limit handling
      // 🔧 FIX: Add 30s timeout to prevent infinite hanging on network issues
      final result = await _rateLimitHandler
          .executeWithRetry<HttpsCallableResult<Map<String, dynamic>>>(
            () => FirebaseFunctions.instance
                .httpsCallable(
                  'createTemplate',
                  options: HttpsCallableOptions(
                    timeout: const Duration(seconds: 30),
                  ),
                )
                .call<Map<String, dynamic>>({
                  'name': name,
                  'description': description ?? '',
                  'exercises': exercisesJson,
                  'tags': tags,
                  'isPublic': isPublic,
                }),
            onRateLimited: (retryAfter) {
              AppLogger.warning(
                'Rate limited. Retrying createTemplate in $retryAfter seconds...',
                tag: 'TemplateCloudService',
              );
            },
            maxDelay: const Duration(minutes: 2),
          );

      final createResult = CreateTemplateResult.fromResponse(result.data);

      AppLogger.info(
        'Template created successfully: ${createResult.templateId}',
        tag: 'TemplateCloudService',
      );

      return createResult;
    } on FirebaseFunctionsException catch (e) {
      AppLogger.error(
        'Cloud Function error: ${e.code} - ${e.message}',
        tag: 'TemplateCloudService',
        error: e,
      );

      // Check if it's a quota exceeded error
      if (e.code == 'resource-exhausted') {
        // Parse quota info from error details if available
        final quota = TemplateQuotaInfo.empty();
        throw TemplateQuotaExceededException(
          message: e.message ?? 'Template quota exceeded',
          quota: quota,
        );
      }

      rethrow;
    } catch (e) {
      AppLogger.error(
        'Unexpected error creating template: $e',
        tag: 'TemplateCloudService',
        error: e,
      );
      rethrow;
    }
  }

  /// Create a new template from pre-serialized JSON exercises.
  ///
  /// 🔐 SECURITY FIX 2025-02-09: This variant accepts exercises already in JSON format,
  /// useful when creating templates from WorkoutTemplate (which uses ExerciseTemplate).
  ///
  /// **Parameters**:
  /// - `name`: Template name (required)
  /// - `description`: Optional description
  /// - `exercisesJson`: List of exercises already serialized to JSON
  /// - `tags`: List of tags for categorization
  /// - `isPublic`: Whether template is public (default: false)
  ///
  /// **Returns**: `CreateTemplateResult` with template ID and quota info
  static Future<CreateTemplateResult> createTemplateFromJson({
    required String name,
    String? description,
    required List<Map<String, dynamic>> exercisesJson,
    List<String> tags = const [],
    bool isPublic = false,
  }) async {
    try {
      AppLogger.info(
        'Creating template via Cloud Function (JSON): "$name" (${exercisesJson.length} exercises)',
        tag: 'TemplateCloudService',
      );

      // 🔐 SECURITY: Call Cloud Function with rate limit handling
      final result = await _rateLimitHandler
          .executeWithRetry<HttpsCallableResult<Map<String, dynamic>>>(
            () => FirebaseFunctions.instance
                .httpsCallable(
                  'createTemplate',
                  options: HttpsCallableOptions(
                    timeout: const Duration(seconds: 30),
                  ),
                )
                .call<Map<String, dynamic>>({
                  'name': name,
                  'description': description ?? '',
                  'exercises': exercisesJson,
                  'tags': tags,
                  'isPublic': isPublic,
                }),
            onRateLimited: (retryAfter) {
              AppLogger.warning(
                'Rate limited. Retrying createTemplate in $retryAfter seconds...',
                tag: 'TemplateCloudService',
              );
            },
            maxDelay: const Duration(minutes: 2),
          );

      final createResult = CreateTemplateResult.fromResponse(result.data);

      AppLogger.info(
        'Template created successfully: ${createResult.templateId}',
        tag: 'TemplateCloudService',
      );

      return createResult;
    } on FirebaseFunctionsException catch (e) {
      AppLogger.error(
        'Cloud Function error: ${e.code} - ${e.message}',
        tag: 'TemplateCloudService',
        error: e,
      );

      if (e.code == 'resource-exhausted') {
        final quota = TemplateQuotaInfo.empty();
        throw TemplateQuotaExceededException(
          message: e.message ?? 'Template quota exceeded',
          quota: quota,
        );
      }

      rethrow;
    } catch (e) {
      AppLogger.error(
        'Unexpected error creating template: $e',
        tag: 'TemplateCloudService',
        error: e,
      );
      rethrow;
    }
  }

  /// Share an existing template privately via unlisted visibility.
  static Future<TemplateMutationResult> shareTemplateUnlisted({
    required String templateId,
    bool isAnonymous = false,
  }) async {
    try {
      AppLogger.info(
        'Sharing template unlisted via Cloud Function: $templateId',
        tag: 'TemplateCloudService',
      );

      final result = await _rateLimitHandler
          .executeWithRetry<HttpsCallableResult<Map<String, dynamic>>>(
            () => FirebaseFunctions.instance
                .httpsCallable(
                  'shareTemplateUnlisted',
                  options: HttpsCallableOptions(
                    timeout: const Duration(seconds: 30),
                  ),
                )
                .call<Map<String, dynamic>>({
                  'templateId': templateId,
                  'isAnonymous': isAnonymous,
                }),
            onRateLimited: (retryAfter) {
              AppLogger.warning(
                'Rate limited. Retrying shareTemplateUnlisted in $retryAfter seconds...',
                tag: 'TemplateCloudService',
              );
            },
            maxDelay: const Duration(minutes: 2),
          );

      return TemplateMutationResult.fromResponse(result.data);
    } on FirebaseFunctionsException catch (e) {
      AppLogger.error(
        'Cloud Function error: ${e.code} - ${e.message}',
        tag: 'TemplateCloudService',
        error: e,
      );

      if (e.code == 'resource-exhausted') {
        throw TemplateQuotaExceededException(
          message: e.message ?? 'Template quota exceeded',
          quota: TemplateQuotaInfo.empty(),
        );
      }

      rethrow;
    }
  }

  /// Publish an existing template via Cloud Function.
  ///
  /// Publishing turns a private Library template into a Store template.
  /// Distribution is free, so this does not consume monetized quota.
  static Future<TemplateQuotaInfo> publishTemplate({
    required String templateId,
    bool isAnonymous = false,
  }) async {
    try {
      AppLogger.info(
        'Publishing template via Cloud Function: $templateId',
        tag: 'TemplateCloudService',
      );

      final result = await _rateLimitHandler
          .executeWithRetry<HttpsCallableResult<Map<String, dynamic>>>(
            () => FirebaseFunctions.instance
                .httpsCallable(
                  'publishTemplate',
                  options: HttpsCallableOptions(
                    timeout: const Duration(seconds: 30),
                  ),
                )
                .call<Map<String, dynamic>>({
                  'templateId': templateId,
                  'isAnonymous': isAnonymous,
                }),
            onRateLimited: (retryAfter) {
              AppLogger.warning(
                'Rate limited. Retrying publishTemplate in $retryAfter seconds...',
                tag: 'TemplateCloudService',
              );
            },
            maxDelay: const Duration(minutes: 2),
          );

      final quotaData = result.data['quota'] != null
          ? Map<String, dynamic>.from(result.data['quota'] as Map)
          : <String, dynamic>{};

      return TemplateQuotaInfo.fromResponse(quotaData);
    } on FirebaseFunctionsException catch (e) {
      AppLogger.error(
        'Cloud Function error: ${e.code} - ${e.message}',
        tag: 'TemplateCloudService',
        error: e,
      );

      if (e.code == 'resource-exhausted') {
        throw TemplateQuotaExceededException(
          message: e.message ?? 'Template quota exceeded',
          quota: TemplateQuotaInfo.empty(),
        );
      }

      rethrow;
    } catch (e) {
      AppLogger.error(
        'Unexpected error publishing template: $e',
        tag: 'TemplateCloudService',
        error: e,
      );
      rethrow;
    }
  }

  /// Save a shared Store template into the current user's Library.
  static Future<TemplateMutationResult> forkTemplate({
    required String templateId,
  }) async {
    try {
      AppLogger.info(
        'Saving Store template to Library via Cloud Function: $templateId',
        tag: 'TemplateCloudService',
      );

      final result = await _rateLimitHandler
          .executeWithRetry<HttpsCallableResult<Map<String, dynamic>>>(
            () => FirebaseFunctions.instance
                .httpsCallable(
                  'forkTemplate',
                  options: HttpsCallableOptions(
                    timeout: const Duration(seconds: 30),
                  ),
                )
                .call<Map<String, dynamic>>({'templateId': templateId}),
            onRateLimited: (retryAfter) {
              AppLogger.warning(
                'Rate limited. Retrying forkTemplate in $retryAfter seconds...',
                tag: 'TemplateCloudService',
              );
            },
            maxDelay: const Duration(minutes: 2),
          );

      return TemplateMutationResult.fromResponse(result.data);
    } on FirebaseFunctionsException catch (e) {
      AppLogger.error(
        'Cloud Function error: ${e.code} - ${e.message}',
        tag: 'TemplateCloudService',
        error: e,
      );

      if (e.code == 'resource-exhausted') {
        throw TemplateQuotaExceededException(
          message: e.message ?? 'Template quota exceeded',
          quota: TemplateQuotaInfo.empty(),
        );
      }

      rethrow;
    }
  }

  /// Create a new private editable copy from a shared template owned by the user.
  static Future<TemplateMutationResult> createTemplateDraftFromShared({
    required String templateId,
  }) async {
    try {
      AppLogger.info(
        'Creating editable Library copy from distributed template: $templateId',
        tag: 'TemplateCloudService',
      );

      final result = await _rateLimitHandler
          .executeWithRetry<HttpsCallableResult<Map<String, dynamic>>>(
            () => FirebaseFunctions.instance
                .httpsCallable(
                  'createTemplateDraftFromShared',
                  options: HttpsCallableOptions(
                    timeout: const Duration(seconds: 30),
                  ),
                )
                .call<Map<String, dynamic>>({'templateId': templateId}),
            onRateLimited: (retryAfter) {
              AppLogger.warning(
                'Rate limited. Retrying createTemplateDraftFromShared in $retryAfter seconds...',
                tag: 'TemplateCloudService',
              );
            },
            maxDelay: const Duration(minutes: 2),
          );

      return TemplateMutationResult.fromResponse(result.data);
    } on FirebaseFunctionsException catch (e) {
      AppLogger.error(
        'Cloud Function error: ${e.code} - ${e.message}',
        tag: 'TemplateCloudService',
        error: e,
      );

      if (e.code == 'resource-exhausted') {
        throw TemplateQuotaExceededException(
          message: e.message ?? 'Template quota exceeded',
          quota: TemplateQuotaInfo.empty(),
        );
      }

      rethrow;
    }
  }

  /// Report a shared template for moderation.
  static Future<void> reportTemplate({
    required String templateId,
    required String reason,
    String? details,
  }) async {
    try {
      AppLogger.info(
        'Reporting template via Cloud Function: $templateId',
        tag: 'TemplateCloudService',
      );

      await FirebaseFunctions.instance
          .httpsCallable(
            'reportTemplate',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
          )
          .call<Map<String, dynamic>>({
            'templateId': templateId,
            'reason': reason,
            'details': details ?? '',
          });
    } on FirebaseFunctionsException catch (e) {
      AppLogger.error(
        'Cloud Function error: ${e.code} - ${e.message}',
        tag: 'TemplateCloudService',
        error: e,
      );
      rethrow;
    }
  }

  /// Get current template quota status
  ///
  /// **Returns**: `TemplateQuotaInfo` with current quota status
  ///
  /// **Example**:
  /// ```dart
  /// final quota = await TemplateCloudService.getTemplateQuota();
  ///
  /// if (!quota.canCreatePrivate) {
  ///   showUpgradeDialog(context, quota);
  /// } else if (quota.isNearPrivateLimit) {
  ///   showQuotaWarning(context, quota);
  /// }
  /// ```
  static Future<TemplateQuotaInfo> getTemplateQuota() async {
    try {
      AppLogger.info(
        'Fetching template quota from Cloud Function',
        tag: 'TemplateCloudService',
      );

      // 🔧 FIX: Add 15s timeout to prevent infinite hanging on network issues
      final result = await FirebaseFunctions.instance
          .httpsCallable(
            'getTemplateQuota',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
          )
          .call<Map<String, dynamic>>();

      final quota = TemplateQuotaInfo.fromResponse(result.data);

      AppLogger.info(
        'Quota fetched: ${quota.accountTier} tier, '
        '${quota.libraryUsed}/${quota.libraryMax} in Library, '
        '${quota.distributionUsed} distributed',
        tag: 'TemplateCloudService',
      );

      return quota;
    } on FirebaseFunctionsException catch (e) {
      AppLogger.error(
        'Cloud Function error getting quota: ${e.code} - ${e.message}',
        tag: 'TemplateCloudService',
        error: e,
      );
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Unexpected error getting quota: $e',
        tag: 'TemplateCloudService',
        error: e,
      );
      // Return default quota on error
      return TemplateQuotaInfo.empty();
    }
  }

  /// Convert Exercise entity to JSON-serializable format for Cloud Function
  ///
  /// The Cloud Function stores the exercise data as-is in Firestore.
  /// We use the base Exercise properties that all exercise types share.
  static Map<String, dynamic> _exerciseToJson(Exercise exercise) {
    // Base properties that all exercise types have
    // IMPORTANT: Use 'exerciseId' and 'exerciseName' to match ExerciseTemplate.fromJson
    final baseJson = <String, dynamic>{
      'exerciseId': exercise.id,
      'exerciseName': exercise.name,
      'type': exercise.type.name,
      'category': exercise.category.name,
      'restTime': exercise.restTime,
      'notes': exercise.notes,
      'tut': exercise.tut, // ⌚ Time Under Tension (e.g., "3-1-2-0")
      'countingMode': exercise.countingMode.name,
    };

    // Handle different exercise types with their specific data
    if (exercise is SupersetExercise) {
      // Save superset metadata
      final supersetSets = exercise.supersetSets.map((s) {
        // Include exercise data for each round
        final exerciseDataJson = <String, dynamic>{};
        s.exerciseData.forEach((key, data) {
          exerciseDataJson[key] = {
            'exerciseId': data.exerciseId,
            'exerciseName': data.exerciseName,
            'targetWeight': data.targetWeight,
            'targetReps': data.targetReps,
            if (data.targetMinReps != null) 'targetMinReps': data.targetMinReps,
            if (data.targetMaxReps != null) 'targetMaxReps': data.targetMaxReps,
          };
        });

        return <String, dynamic>{
          'id': s.id,
          'setNumber': s.setNumber,
          'isCompleted': s.isCompleted,
          'isWarmup': s.isWarmup,
          'exerciseData': exerciseDataJson,
        };
      }).toList();

      // ✅ FIX: Also create 'sets' array with one SetTemplate per round
      // This ensures sets.length matches supersetSets.length when reloading
      final setsForRounds = exercise.supersetSets.asMap().entries.map((entry) {
        final index = entry.key;
        final round = entry.value;
        // Use data from first exercise in the round as representative
        final firstExerciseData = round.exerciseData.values.isNotEmpty
            ? round.exerciseData.values.first
            : null;
        return <String, dynamic>{
          'setNumber': index + 1,
          'targetWeight': firstExerciseData?.targetWeight,
          'targetReps': firstExerciseData?.targetReps,
          if (firstExerciseData?.targetMinReps != null)
            'targetMinReps': firstExerciseData?.targetMinReps,
          if (firstExerciseData?.targetMaxReps != null)
            'targetMaxReps': firstExerciseData?.targetMaxReps,
        };
      }).toList();

      return {
        ...baseJson,
        'exercises': exercise.exercises.map(_exerciseToJson).toList(),
        'supersetSets': supersetSets,
        'sets': setsForRounds, // ✅ FIX: Include sets for proper round count
      };
    } else if (exercise is DropSetExercise) {
      final stages = exercise.stages.map((stage) {
        return <String, dynamic>{
          'weight': stage.weight,
          'reps': stage.reps,
          if (stage.minReps != null) 'minReps': stage.minReps,
          if (stage.maxReps != null) 'maxReps': stage.maxReps,
          'isCompleted': stage.isCompleted,
        };
      }).toList();

      return {...baseJson, 'stages': stages};
    } else if (exercise is RestPauseExercise) {
      final restPauseSets = exercise.restPauseSets.map((s) {
        return <String, dynamic>{
          'reps': s.reps,
          'restSeconds': s.restSeconds,
          if (s.minReps != null) 'minReps': s.minReps,
          if (s.maxReps != null) 'maxReps': s.maxReps,
          'isCompleted': s.isCompleted,
        };
      }).toList();

      return {
        ...baseJson,
        'targetReps': exercise.targetReps,
        if (exercise.targetMinReps != null)
          'targetMinReps': exercise.targetMinReps,
        if (exercise.targetMaxReps != null)
          'targetMaxReps': exercise.targetMaxReps,
        'restPauseSets': restPauseSets,
      };
    } else {
      // Standard exercise or base Exercise - use sets from base class
      // IMPORTANT: Map to SetTemplate format (targetWeight/targetReps/targetRpe)
      return {
        ...baseJson,
        'sets': exercise.sets
            .map(
              (s) => <String, dynamic>{
                'setNumber': s.setNumber,
                'targetWeight': s.weight,
                'targetReps': s.reps,
                if (s.minReps != null) 'targetMinReps': s.minReps,
                if (s.maxReps != null) 'targetMaxReps': s.maxReps,
                'targetRpe': s.rpe,
                'notes': s.notes,
              },
            )
            .toList(),
      };
    }
  }
}

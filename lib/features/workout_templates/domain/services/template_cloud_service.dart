/// 🔐 SECURITY: Template Cloud Service for Server-Side Quota Enforcement
///
/// This service provides secure template creation through Cloud Functions.
/// **Client-side writes are BLOCKED** by Firestore Security Rules - all template
/// creation MUST go through this service.
///
/// **Quota Tiers**:
/// - Free: 4 private templates, 2 public templates
/// - Premium: 20 private templates, 10 public templates
/// - Pro: 999 private templates (effectively unlimited)
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
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Result of creating a template via Cloud Function
class CreateTemplateResult {
  const CreateTemplateResult({
    required this.success,
    required this.templateId,
    required this.templateName,
    required this.quota,
    this.error,
  });

  final bool success;
  final String templateId;
  final String templateName;
  final TemplateQuotaInfo quota;
  final String? error;

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
}

/// Template quota information
class TemplateQuotaInfo {
  const TemplateQuotaInfo({
    required this.accountTier,
    required this.privateUsed,
    required this.privateMax,
    required this.privateRemaining,
    required this.publicUsed,
    required this.publicMax,
    required this.publicRemaining,
  });

  final String accountTier;
  final int privateUsed;
  final int privateMax;
  final int privateRemaining;
  final int publicUsed;
  final int publicMax;
  final int publicRemaining;

  /// Check if user can create more private templates
  bool get canCreatePrivate => privateRemaining > 0;

  /// Check if user can create more public templates
  bool get canCreatePublic => publicRemaining > 0;

  /// Check if user is at quota limit
  bool get isAtLimit => !canCreatePrivate && !canCreatePublic;

  /// Check if user is close to private template limit (<=2 remaining)
  bool get isNearPrivateLimit => privateRemaining <= 2 && privateRemaining > 0;

  factory TemplateQuotaInfo.fromResponse(Map<String, dynamic> data) {
    // Firebase Cloud Functions return _Map<Object?, Object?>, need to convert
    final privateData = data['private'] != null
        ? Map<String, dynamic>.from(data['private'] as Map)
        : <String, dynamic>{};
    final publicData = data['public'] != null
        ? Map<String, dynamic>.from(data['public'] as Map)
        : <String, dynamic>{};

    return TemplateQuotaInfo(
      accountTier: data['accountTier'] as String? ?? 'free',
      privateUsed: privateData['used'] as int? ?? data['privateUsed'] as int? ?? 0,
      privateMax: privateData['max'] as int? ?? data['privateMax'] as int? ?? 4,
      privateRemaining: privateData['remaining'] as int? ??
          ((data['privateMax'] as int? ?? 4) - (data['privateUsed'] as int? ?? 0)),
      publicUsed: publicData['used'] as int? ?? data['publicUsed'] as int? ?? 0,
      publicMax: publicData['max'] as int? ?? data['publicMax'] as int? ?? 2,
      publicRemaining: publicData['remaining'] as int? ??
          ((data['publicMax'] as int? ?? 2) - (data['publicUsed'] as int? ?? 0)),
    );
  }

  factory TemplateQuotaInfo.empty() {
    return const TemplateQuotaInfo(
      accountTier: 'free',
      privateUsed: 0,
      privateMax: 4,
      privateRemaining: 4,
      publicUsed: 0,
      publicMax: 2,
      publicRemaining: 2,
    );
  }
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
      final result = await _rateLimitHandler.executeWithRetry<
          HttpsCallableResult<Map<String, dynamic>>>(
        () => FirebaseFunctions.instance
            .httpsCallable('createTemplate')
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

      final result = await FirebaseFunctions.instance
          .httpsCallable('getTemplateQuota')
          .call<Map<String, dynamic>>();

      final quota = TemplateQuotaInfo.fromResponse(result.data);

      AppLogger.info(
        'Quota fetched: ${quota.accountTier} tier, '
        '${quota.privateUsed}/${quota.privateMax} private, '
        '${quota.publicUsed}/${quota.publicMax} public',
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
          'isCompleted': stage.isCompleted,
        };
      }).toList();

      return {
        ...baseJson,
        'stages': stages,
      };
    } else if (exercise is RestPauseExercise) {
      final restPauseSets = exercise.restPauseSets.map((s) {
        return <String, dynamic>{
          'reps': s.reps,
          'restSeconds': s.restSeconds,
          'isCompleted': s.isCompleted,
        };
      }).toList();

      return {
        ...baseJson,
        'targetReps': exercise.targetReps,
        'restPauseSets': restPauseSets,
      };
    } else {
      // Standard exercise or base Exercise - use sets from base class
      // IMPORTANT: Map to SetTemplate format (targetWeight/targetReps/targetRpe)
      return {
        ...baseJson,
        'sets': exercise.sets.map((s) => <String, dynamic>{
          'setNumber': s.setNumber,
          'targetWeight': s.weight,
          'targetReps': s.reps,
          'targetRpe': s.rpe,
          'notes': s.notes,
        }).toList(),
      };
    }
  }
}

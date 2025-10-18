/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain
/// 🎯 Feature: workout_templates
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Service for exporting workout templates to JSON with analytics data for premium users
library;

import 'dart:convert';

import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/template_import_export.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/export_format.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/account_tier.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/analytics_service.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';

/// Service for exporting workout templates
class TemplateExportService {
  
  TemplateExportService(this._analyticsService);
  final AnalyticsService _analyticsService;
  
  /// Export single template
  Future<String> exportTemplate(
    WorkoutTemplate template,
    UserProfile user, {
    ExportFormat format = ExportFormat.json,
    bool includeAnalytics = false,
  }) async {
    // Check if user has access to advanced export features
    final canIncludeAnalytics = _canIncludeAnalytics(user, includeAnalytics);
    
    final exportData = await _convertToExportData(
      template,
      user,
      includeAnalytics: canIncludeAnalytics,
    );
    
    return _formatExport([exportData], format);
  }
  
  /// Export multiple templates (batch export)
  Future<String> exportTemplates(
    List<WorkoutTemplate> templates,
    UserProfile user, {
    ExportFormat format = ExportFormat.json,
    bool includeAnalytics = false,
  }) async {
    // Check if user has access to batch export
    if (!_canBatchExport(user)) {
      throw UnauthorizedExportException('Batch export requires premium subscription');
    }
    
    final canIncludeAnalytics = _canIncludeAnalytics(user, includeAnalytics);
    
    final exportDataList = <WorkoutTemplateExportData>[];
    
    for (final template in templates) {
      final exportData = await _convertToExportData(
        template,
        user,
        includeAnalytics: canIncludeAnalytics,
      );
      exportDataList.add(exportData);
    }
    
    return _formatBatchExport(exportDataList, user, format);
  }
  
  /// Convert template to export format
  Future<WorkoutTemplateExportData> _convertToExportData(
    WorkoutTemplate template,
    UserProfile user, {
    bool includeAnalytics = false,
  }) async {
    final importData = WorkoutTemplateImportData(
      name: template.name,
      description: template.description,
      exercises: template.exercises.map(_convertExercise).toList(),
      category: template.category.name,
      difficulty: template.difficultyLevel,
      estimatedDurationMinutes: template.estimatedDurationMinutes,
      tags: template.tags,
      requiredEquipment: template.requiredEquipment,
      targetMuscles: template.targetMuscles,
    );
    
    Map<String, dynamic>? analytics;
    
    if (includeAnalytics) {
      analytics = await _collectAnalytics(template, user.uid);
    }
    
    return WorkoutTemplateExportData(
      template: importData,
      analytics: analytics,
      exportedAt: DateTime.now(),
      exportedBy: user.uid,
      version: '1.0',
    );
  }
  
  /// Convert domain exercise to import format
  ExerciseImportData _convertExercise(Exercise exercise) {
    return ExerciseImportData(
      name: exercise.name,
      category: exercise.category.name,
      type: exercise.type.name,
      sets: exercise.sets.map(_convertSet).toList(),
      notes: exercise.notes,
      restTimeSeconds: exercise.restTime,
    );
  }
  
  /// Convert domain set to import format
  SetImportData _convertSet(ExerciseSet set) {
    return SetImportData(
      setNumber: set.setNumber,
      weight: set.weight != null ? '${set.weight}kg' : null,
      reps: set.reps?.toString() ?? set.actualReps?.toString(),
      notes: set.notes,
      isWarmup: set.isWarmup,
    );
  }
  
  /// Collect analytics data for template
  Future<Map<String, dynamic>> _collectAnalytics(
    WorkoutTemplate template,
    String userId,
  ) async {
    final analytics = <String, dynamic>{};
    
    try {
      // Get template usage statistics
      final usageStats = await _analyticsService.getTemplateUsageStats(
        templateId: template.id,
        userId: userId,
      );
      
      if (usageStats != null) {
        analytics['usage'] = {
          'totalUses': usageStats['totalUses'],
          'lastUsed': usageStats['lastUsed']?.toIso8601String(),
          'averageDuration': usageStats['averageDuration'],
          'completionRate': usageStats['completionRate'],
        };
      }
      
      // Get exercise-specific analytics
      final exerciseAnalytics = <String, dynamic>{};
      
      for (final exercise in template.exercises) {
        final exerciseStats = await _analyticsService.getExerciseAnalytics(
          userId: userId,
          exerciseName: exercise.name,
        );
        
        if (exerciseStats.isNotEmpty) {
          exerciseAnalytics[exercise.name] = {
            'personalBests': exerciseStats
                .map((stat) => {
                      'weight': stat.weight,
                      'reps': stat.reps,
                      'date': stat.date.toIso8601String(),
                    })
                .toList(),
            'progressTrend': _calculateProgressTrend(exerciseStats),
            'averageVolume': _calculateAverageVolume(exerciseStats),
            'oneRepMax': _calculateEstimatedOneRepMax(exerciseStats),
          };
        }
      }
      
      if (exerciseAnalytics.isNotEmpty) {
        analytics['exercises'] = exerciseAnalytics;
      }
      
      // Add export metadata
      analytics['metadata'] = {
        'exportedAt': DateTime.now().toIso8601String(),
        'dataTimeRange': {
          'from': DateTime.now().subtract(const Duration(days: 365)).toIso8601String(),
          'to': DateTime.now().toIso8601String(),
        },
        'analyticsVersion': '1.0',
      };
      
    } catch (e) {
      // If analytics collection fails, continue without analytics
      analytics['error'] = 'Failed to collect analytics: $e';
    }
    
    return analytics;
  }
  
  /// Calculate progress trend for exercise
  String _calculateProgressTrend(List<dynamic> exerciseStats) {
    if (exerciseStats.length < 2) return 'insufficient_data';
    
    // Compare first and last entries
    final first = exerciseStats.first;
    final last = exerciseStats.last;
    
    final firstVolume = (first['weight'] ?? 0) * (first['reps'] ?? 0);
    final lastVolume = (last['weight'] ?? 0) * (last['reps'] ?? 0);
    
    if (lastVolume > firstVolume * 1.1) return 'improving';
    if (lastVolume < firstVolume * 0.9) return 'declining';
    return 'stable';
  }
  
  /// Calculate average volume
  double _calculateAverageVolume(List<dynamic> exerciseStats) {
    if (exerciseStats.isEmpty) return 0.0;
    
    final totalVolume = exerciseStats.fold<double>(0, (sum, stat) {
      final weight = (stat['weight'] ?? 0).toDouble();
      final reps = (stat['reps'] ?? 0).toDouble();
      return sum + (weight * reps);
    });
    
    return totalVolume / exerciseStats.length;
  }
  
  /// Calculate estimated 1RM
  double? _calculateEstimatedOneRepMax(List<dynamic> exerciseStats) {
    if (exerciseStats.isEmpty) return null;
    
    // Find heaviest set and use Epley formula
    var maxWeight = 0.0;
    var repsAtMax = 1;
    
    for (final stat in exerciseStats) {
      final weight = (stat['weight'] ?? 0).toDouble();
      if (weight > maxWeight) {
        maxWeight = weight;
        repsAtMax = (stat['reps'] ?? 1).toInt();
      }
    }
    
    if (maxWeight == 0) return null;
    
    // Epley formula: 1RM = weight * (1 + reps/30)
    return maxWeight * (1 + repsAtMax / 30);
  }
  
  /// Format export data
  String _formatExport(
    List<WorkoutTemplateExportData> exportDataList,
    ExportFormat format,
  ) {
    final data = exportDataList.length == 1 
        ? exportDataList.first.toJson()
        : exportDataList.map((e) => e.toJson()).toList();
    
    switch (format) {
      case ExportFormat.json:
        return const JsonEncoder.withIndent('  ').convert(data);
      
      case ExportFormat.jsonMinified:
        return json.encode(data);
      
      case ExportFormat.jsonWithAnalytics:
        return const JsonEncoder.withIndent('  ').convert(data);
    }
  }
  
  /// Format batch export
  String _formatBatchExport(
    List<WorkoutTemplateExportData> exportDataList,
    UserProfile user,
    ExportFormat format,
  ) {
    final batchExport = WorkoutTemplatesBatchExport(
      templates: exportDataList,
      format: format,
      exportedAt: DateTime.now(),
      exportedBy: user.uid,
      metadata: {
        'userTier': user.accountTier.name,
        'exportedTemplatesCount': exportDataList.length,
        'appVersion': '1.0.0', // Should come from app config
      },
    );
    
    switch (format) {
      case ExportFormat.json:
      case ExportFormat.jsonWithAnalytics:
        return const JsonEncoder.withIndent('  ').convert(batchExport.toJson());
      
      case ExportFormat.jsonMinified:
        return json.encode(batchExport.toJson());
    }
  }
  
  /// Check if user can include analytics in export
  bool _canIncludeAnalytics(UserProfile user, bool requested) {
    if (!requested) return false;
    
    // Only premium and pro users can export with analytics
    return user.accountTier == AccountTier.premium || 
           user.accountTier == AccountTier.pro;
  }
  
  /// Check if user can perform batch export
  bool _canBatchExport(UserProfile user) {
    // Only premium and pro users can batch export
    return user.accountTier == AccountTier.premium || 
           user.accountTier == AccountTier.pro;
  }
  
  /// Get export limits for user
  ExportLimits getExportLimits(UserProfile user) {
    switch (user.accountTier) {
      case AccountTier.free:
        return const ExportLimits(
          maxTemplatesPerExport: 1,
          maxExportsPerDay: 3,
          canIncludeAnalytics: false,
          canBatchExport: false,
        );
      
      case AccountTier.premium:
        return const ExportLimits(
          maxTemplatesPerExport: 10,
          maxExportsPerDay: 20,
          canIncludeAnalytics: true,
          canBatchExport: true,
        );
      
      case AccountTier.pro:
        return const ExportLimits(
          maxTemplatesPerExport: -1, // Unlimited
          maxExportsPerDay: -1, // Unlimited
          canIncludeAnalytics: true,
          canBatchExport: true,
        );
    }
  }
}

/// Export limitations based on user tier
class ExportLimits {
  
  const ExportLimits({
    required this.maxTemplatesPerExport,
    required this.maxExportsPerDay,
    required this.canIncludeAnalytics,
    required this.canBatchExport,
  });
  final int maxTemplatesPerExport; // -1 for unlimited
  final int maxExportsPerDay; // -1 for unlimited
  final bool canIncludeAnalytics;
  final bool canBatchExport;
}

/// Exception for unauthorized export operations
class UnauthorizedExportException implements Exception {
  
  UnauthorizedExportException(this.message);
  final String message;
  
  @override
  String toString() => 'UnauthorizedExportException: $message';
}
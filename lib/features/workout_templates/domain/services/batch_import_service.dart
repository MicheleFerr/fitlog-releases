/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain
/// 🎯 Feature: workout_templates
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Service for handling batch import of multiple workout templates with validation and error recovery
library;

import 'dart:convert';
import 'dart:io';

import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/template_import_export.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/services/template_parsing_service.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/services/exercise_matching_service.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/services/percentage_conversion_service.dart';

/// Service for batch importing multiple workout templates
class BatchImportService {
  
  BatchImportService(
    this._parsingService,
    this._exerciseMatchingService,
    this._percentageService,
  );
  final TemplateParsingService _parsingService;
  final ExerciseMatchingService _exerciseMatchingService;
  final PercentageConversionService _percentageService;
  
  /// Import multiple templates from various sources
  Future<BatchImportResult> importMultipleTemplates({
    String? textContent,
    String? jsonContent,
    List<String>? filePaths,
    AIParsingInstructions? instructions,
    String? userId,
  }) async {
    final allResults = <ImportParsingResult>[];
    final batchErrors = <BatchImportError>[];
    final sourceInfo = <String, String>{};
    
    try {
      // Process text content if provided
      if (textContent != null && textContent.isNotEmpty) {
        await _processTextContent(
          textContent,
          instructions,
          allResults,
          batchErrors,
          sourceInfo,
        );
      }
      
      // Process JSON content if provided
      if (jsonContent != null && jsonContent.isNotEmpty) {
        await _processJsonContent(
          jsonContent,
          allResults,
          batchErrors,
          sourceInfo,
        );
      }
      
      // Process files if provided
      if (filePaths != null && filePaths.isNotEmpty) {
        await _processFiles(
          filePaths,
          instructions,
          allResults,
          batchErrors,
          sourceInfo,
        );
      }
      
      // Validate and deduplicate results
      final validatedResults = await _validateAndDeduplicateResults(
        allResults,
        batchErrors,
      );
      
      // Process exercise matching for all templates
      final allDisambiguations = <ExerciseDisambiguation>[];
      await _processExerciseMatchingBatch(
        validatedResults,
        allDisambiguations,
      );
      
      // Process percentage conversions for all templates
      final allConversions = <PercentageConversion>[];
      if (userId != null) {
        await _processPercentageConversionsBatch(
          validatedResults,
          userId,
          allConversions,
        );
      }
      
      return BatchImportResult(
        templates: validatedResults,
        exerciseDisambiguations: allDisambiguations,
        percentageConversions: allConversions,
        errors: batchErrors,
        sourceInfo: sourceInfo,
        totalProcessed: allResults.length,
        successfulImports: validatedResults.length,
        failedImports: batchErrors.length,
      );
      
    } catch (e) {
      return BatchImportResult(
        templates: allResults,
        errors: [
          BatchImportError(
            message: 'Batch import failed: $e',
            severity: ErrorSeverity.critical,
            source: 'batch_service',
          ),
        ],
        sourceInfo: sourceInfo,
        totalProcessed: 0,
        successfulImports: 0,
        failedImports: 1,
      );
    }
  }
  
  /// Process natural language text content
  Future<void> _processTextContent(
    String content,
    AIParsingInstructions? instructions,
    List<ImportParsingResult> results,
    List<BatchImportError> errors,
    Map<String, String> sourceInfo,
  ) async {
    try {
      final textResults = await _parsingService.parseMultipleWorkouts(
        content,
        instructions: instructions,
      );
      
      for (int i = 0; i < textResults.length; i++) {
        final result = textResults[i];
        results.add(result);
        sourceInfo[result.template.name] = 'text_input_${i + 1}';
        
        // Add any critical errors to batch errors
        final criticalErrors = result.errors.where((e) => e.isBlocking == true);
        for (final error in criticalErrors) {
          errors.add(BatchImportError(
            message: error.message,
            severity: ErrorSeverity.high,
            source: 'text_parsing',
            templateName: result.template.name,
            field: error.field,
          ));
        }
      }
    } catch (e) {
      errors.add(BatchImportError(
        message: 'Failed to process text content: $e',
        severity: ErrorSeverity.high,
        source: 'text_processing',
      ));
    }
  }
  
  /// Process JSON content
  Future<void> _processJsonContent(
    String jsonContent,
    List<ImportParsingResult> results,
    List<BatchImportError> errors,
    Map<String, String> sourceInfo,
  ) async {
    try {
      final jsonData = json.decode(jsonContent);
      
      // Handle different JSON formats
      if (jsonData is Map<String, dynamic>) {
        if (jsonData.containsKey('templates')) {
          // Batch import format
          final batchImport = WorkoutTemplatesBatchImport.fromJson(jsonData);
          for (int i = 0; i < batchImport.templates.length; i++) {
            final template = batchImport.templates[i];
            results.add(ImportParsingResult(template: template));
            sourceInfo[template.name] = 'batch_json_${i + 1}';
          }
        } else {
          // Single template
          final template = WorkoutTemplateImportData.fromJson(jsonData);
          results.add(ImportParsingResult(template: template));
          sourceInfo[template.name] = 'single_json';
        }
      } else if (jsonData is List) {
        // Array of templates
        for (int i = 0; i < jsonData.length; i++) {
          try {
            final template = WorkoutTemplateImportData.fromJson(jsonData[i]);
            results.add(ImportParsingResult(template: template));
            sourceInfo[template.name] = 'array_json_${i + 1}';
          } catch (e) {
            errors.add(BatchImportError(
              message: 'Failed to parse template ${i + 1}: $e',
              severity: ErrorSeverity.medium,
              source: 'json_array_parsing',
            ));
          }
        }
      } else {
        errors.add(BatchImportError(
          message: 'Invalid JSON format',
          severity: ErrorSeverity.high,
          source: 'json_validation',
        ));
      }
    } catch (e) {
      errors.add(BatchImportError(
        message: 'Failed to parse JSON: $e',
        severity: ErrorSeverity.high,
        source: 'json_parsing',
      ));
    }
  }
  
  /// Process multiple files
  Future<void> _processFiles(
    List<String> filePaths,
    AIParsingInstructions? instructions,
    List<ImportParsingResult> results,
    List<BatchImportError> errors,
    Map<String, String> sourceInfo,
  ) async {
    for (final filePath in filePaths) {
      try {
        // Read file content (implementation depends on platform)
        final content = await _readFileContent(filePath);
        final fileName = _extractFileName(filePath);
        
        // Determine file type and process accordingly
        if (filePath.toLowerCase().endsWith('.json')) {
          await _processJsonContent(content, results, errors, sourceInfo);
          // Update source info with file names
          _updateSourceInfoWithFileName(sourceInfo, fileName, results.length);
        } else {
          // Treat as text content
          final textResults = await _parsingService.parseMultipleWorkouts(
            content,
            instructions: instructions,
          );
          
          for (int i = 0; i < textResults.length; i++) {
            final result = textResults[i];
            results.add(result);
            sourceInfo[result.template.name] = '${fileName}_${i + 1}';
          }
        }
      } catch (e) {
        errors.add(BatchImportError(
          message: 'Failed to process file $filePath: $e',
          severity: ErrorSeverity.medium,
          source: 'file_processing',
          filePath: filePath,
        ));
      }
    }
  }
  
  /// Validate and deduplicate results
  Future<List<ImportParsingResult>> _validateAndDeduplicateResults(
    List<ImportParsingResult> results,
    List<BatchImportError> errors,
  ) async {
    final validResults = <ImportParsingResult>[];
    final seenNames = <String>{};
    
    for (final result in results) {
      // Check for duplicate names
      if (seenNames.contains(result.template.name)) {
        errors.add(BatchImportError(
          message: 'Duplicate template name: ${result.template.name}',
          severity: ErrorSeverity.medium,
          source: 'validation',
          templateName: result.template.name,
        ));
        
        // Rename duplicate with suffix
        var newName = result.template.name;
        var counter = 2;
        while (seenNames.contains(newName)) {
          newName = '${result.template.name} ($counter)';
          counter++;
        }
        
        final renamedTemplate = result.template.copyWith(name: newName);
        final renamedResult = result.copyWith(template: renamedTemplate);
        validResults.add(renamedResult);
        seenNames.add(newName);
      } else {
        validResults.add(result);
        seenNames.add(result.template.name);
      }
      
      // Validate template structure
      final validationErrors = _validateTemplate(result.template);
      if (validationErrors.isNotEmpty) {
        errors.addAll(validationErrors.map((error) => BatchImportError(
          message: error,
          severity: ErrorSeverity.medium,
          source: 'template_validation',
          templateName: result.template.name,
        )));
      }
    }
    
    return validResults;
  }
  
  /// Process exercise matching for all templates in batch
  Future<void> _processExerciseMatchingBatch(
    List<ImportParsingResult> results,
    List<ExerciseDisambiguation> allDisambiguations,
  ) async {
    for (final result in results) {
      for (final exercise in result.template.exercises) {
        final disambiguation = await _exerciseMatchingService.findExerciseMatches(
          exercise.name,
          '${result.template.name}_${exercise.name}',
        );
        
        if (disambiguation != null) {
          allDisambiguations.add(disambiguation);
        }
      }
    }
  }
  
  /// Process percentage conversions for all templates in batch
  Future<void> _processPercentageConversionsBatch(
    List<ImportParsingResult> results,
    String userId,
    List<PercentageConversion> allConversions,
  ) async {
    for (final result in results) {
      final conversions = await _percentageService.processPercentageConversions(
        result.template,
        userId,
      );
      allConversions.addAll(conversions);
    }
  }
  
  /// Validate individual template
  List<String> _validateTemplate(WorkoutTemplateImportData template) {
    final errors = <String>[];
    
    if (template.name.isEmpty) {
      errors.add('Template name cannot be empty');
    }
    
    if (template.exercises.isEmpty) {
      errors.add('Template must have at least one exercise');
    }
    
    for (final exercise in template.exercises) {
      if (exercise.name.isEmpty) {
        errors.add('Exercise name cannot be empty');
      }
      
      if (exercise.sets.isEmpty) {
        errors.add('Exercise "${exercise.name}" must have at least one set');
      }
    }
    
    return errors;
  }
  
  /// Read file content from file path
  Future<String> _readFileContent(String filePath) async {
    try {
      final file = File(filePath);

      // Check if file exists
      if (!await file.exists()) {
        throw FileSystemException('File not found', filePath);
      }

      // Check file size (max 5MB)
      final fileSize = await file.length();
      const maxSize = 5 * 1024 * 1024; // 5MB
      if (fileSize > maxSize) {
        throw Exception('File too large (max 5MB)');
      }

      // Read file content
      final content = await file.readAsString();

      // Check if file is empty
      if (content.trim().isEmpty) {
        throw Exception('File is empty');
      }

      return content;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Extract filename from path
  String _extractFileName(String filePath) {
    return filePath.split('/').last.split('\\').last;
  }
  
  /// Update source info with file names
  void _updateSourceInfoWithFileName(
    Map<String, String> sourceInfo,
    String fileName,
    int currentResultCount,
  ) {
    // Update recent entries with file name
    final entriesToUpdate = sourceInfo.entries
        .where((e) => e.value.startsWith('single_json') || e.value.startsWith('batch_json'))
        .toList();
    
    for (final entry in entriesToUpdate) {
      sourceInfo[entry.key] = '${fileName}_${entry.value}';
    }
  }
  
  /// Get import statistics
  BatchImportStats getImportStats(BatchImportResult result) {
    return BatchImportStats(
      totalTemplates: result.totalProcessed,
      successfulImports: result.successfulImports,
      failedImports: result.failedImports,
      duplicatesFound: result.errors.where((e) => e.message.contains('Duplicate')).length,
      exercisesNeedingDisambiguation: result.exerciseDisambiguations.length,
      percentageConversionsNeeded: result.percentageConversions.length,
      criticalErrors: result.errors.where((e) => e.severity == ErrorSeverity.critical).length,
      warnings: result.errors.where((e) => e.severity == ErrorSeverity.low).length,
    );
  }
}

/// Result of batch import operation
class BatchImportResult {
  
  BatchImportResult({
    this.templates = const [],
    this.exerciseDisambiguations = const [],
    this.percentageConversions = const [],
    this.errors = const [],
    this.sourceInfo = const {},
    this.totalProcessed = 0,
    this.successfulImports = 0,
    this.failedImports = 0,
  });
  final List<ImportParsingResult> templates;
  final List<ExerciseDisambiguation> exerciseDisambiguations;
  final List<PercentageConversion> percentageConversions;
  final List<BatchImportError> errors;
  final Map<String, String> sourceInfo;
  final int totalProcessed;
  final int successfulImports;
  final int failedImports;
}

/// Error during batch import with additional context
class BatchImportError {
  
  BatchImportError({
    required this.message,
    required this.severity,
    required this.source,
    this.templateName,
    this.field,
    this.filePath,
  });
  final String message;
  final ErrorSeverity severity;
  final String source;
  final String? templateName;
  final String? field;
  final String? filePath;
}

/// Error severity levels
enum ErrorSeverity {
  low,    // Warnings that don't prevent import
  medium, // Issues that may affect functionality
  high,   // Errors that prevent specific templates from importing
  critical, // Errors that prevent entire batch from importing
}

/// Statistics about batch import operation
class BatchImportStats {
  
  BatchImportStats({
    required this.totalTemplates,
    required this.successfulImports,
    required this.failedImports,
    required this.duplicatesFound,
    required this.exercisesNeedingDisambiguation,
    required this.percentageConversionsNeeded,
    required this.criticalErrors,
    required this.warnings,
  });
  final int totalTemplates;
  final int successfulImports;
  final int failedImports;
  final int duplicatesFound;
  final int exercisesNeedingDisambiguation;
  final int percentageConversionsNeeded;
  final int criticalErrors;
  final int warnings;
  
  double get successRate => totalTemplates > 0 
      ? successfulImports / totalTemplates 
      : 0.0;
      
  bool get hasIssues => failedImports > 0 || criticalErrors > 0;
  
  bool get requiresUserInput => exercisesNeedingDisambiguation > 0 || 
                                percentageConversionsNeeded > 0;
}
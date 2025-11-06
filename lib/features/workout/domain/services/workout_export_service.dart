/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain/services
/// 🎯 Feature: workout
/// 🔧 Type: service
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Domain entities
/// - File system access
/// - JSON/CSV serialization
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:intl/intl.dart';

/// Formati di export supportati
enum ExportFormat {
  json,
  csv,
  markdown,
}

/// Opzioni per l'export
class ExportOptions {
  
  ExportOptions({
    this.workoutIds,
    this.startDate,
    this.endDate,
    this.format = ExportFormat.json,
    this.includeIncomplete = false,
    this.includeNotes = true,
    this.includeRPE = true,
    this.includeSetDurations = true,
    this.compressJson = false,
  });
  final List<String>? workoutIds; // null = tutti
  final DateTime? startDate;
  final DateTime? endDate;
  final ExportFormat format;
  final bool includeIncomplete;
  final bool includeNotes;
  final bool includeRPE;
  final bool includeSetDurations;
  final bool compressJson;
}

/// Service per esportare workout in vari formati
class WorkoutExportService {
  
  /// Esporta workout con le opzioni specificate
  Future<ExportResult> exportWorkouts({
    required List<Workout> workouts,
    required ExportOptions options,
  }) async {
    try {
      // Filtra workout in base alle opzioni
      final filteredWorkouts = _filterWorkouts(workouts, options);
      
      if (filteredWorkouts.isEmpty) {
        return ExportResult(
          success: false,
          message: 'No workouts to export',
        );
      }
      
      // Genera contenuto in base al formato
      String content;
      String fileExtension;
      
      switch (options.format) {
        case ExportFormat.json:
          content = _generateJson(filteredWorkouts, options);
          fileExtension = 'json';
          break;
        case ExportFormat.csv:
          content = _generateCsv(filteredWorkouts, options);
          fileExtension = 'csv';
          break;
        case ExportFormat.markdown:
          content = _generateMarkdown(filteredWorkouts, options);
          fileExtension = 'md';
          break;
      }
      
      // Salva file temporaneo
      final fileName = 'gymbro_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.$fileExtension';
      final file = await _saveToFile(content, fileName);
      
      return ExportResult(
        success: true,
        message: 'Export completed successfully',
        filePath: file.path,
        workoutCount: filteredWorkouts.length,
        fileSize: file.lengthSync(),
      );
      
    } catch (e) {
      debugPrint('Export failed: $e');
      return ExportResult(
        success: false,
        message: 'Export failed: $e',
      );
    }
  }
  
  /// Filtra workout in base alle opzioni
  List<Workout> _filterWorkouts(List<Workout> workouts, ExportOptions options) {
    var filtered = workouts;
    
    // Filtra per IDs
    if (options.workoutIds != null && options.workoutIds!.isNotEmpty) {
      filtered = filtered.where((w) => options.workoutIds!.contains(w.id)).toList();
    }
    
    // Filtra per date
    if (options.startDate != null) {
      filtered = filtered.where((w) => 
        w.createdAt.isAfter(options.startDate!)
      ).toList();
    }
    
    if (options.endDate != null) {
      filtered = filtered.where((w) => 
        w.createdAt.isBefore(options.endDate!)
      ).toList();
    }
    
    // Filtra per completamento
    if (!options.includeIncomplete) {
      filtered = filtered.where((w) => w.isCompleted).toList();
    }
    
    // Ordina per data (più recenti prima)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return filtered;
  }
  
  /// Genera JSON export
  String _generateJson(List<Workout> workouts, ExportOptions options) {
    final exportData = {
      'version': '1.0.0',
      'app': 'GymBro TrackLog',
      'exportDate': DateTime.now().toIso8601String(),
      'options': {
        'includeNotes': options.includeNotes,
        'includeRPE': options.includeRPE,
        'includeSetDurations': options.includeSetDurations,
      },
      'stats': {
        'totalWorkouts': workouts.length,
        'completedWorkouts': workouts.where((w) => w.isCompleted).length,
        'totalExercises': workouts.fold(0, (sum, w) => sum + w.exercises.length),
        'totalSets': workouts.fold(0, (sum, w) => sum + w.totalSets),
      },
      'workouts': workouts.map((w) => _workoutToJson(w, options)).toList(),
    };
    
    if (options.compressJson) {
      // Compact JSON (no indentation)
      return jsonEncode(exportData);
    } else {
      // Pretty print JSON
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(exportData);
    }
  }
  
  /// Converte workout in JSON con opzioni
  Map<String, dynamic> _workoutToJson(Workout workout, ExportOptions options) {
    final json = workout.toJson();
    
    // Rimuovi campi non richiesti
    if (!options.includeNotes) {
      json.remove('notes');
      for (var exercise in json['exercises']) {
        exercise.remove('notes');
        for (var set in exercise['sets']) {
          set.remove('notes');
        }
      }
    }
    
    if (!options.includeRPE) {
      for (var exercise in json['exercises']) {
        for (var set in exercise['sets']) {
          set.remove('rpe');
        }
      }
    }
    
    if (!options.includeSetDurations) {
      for (var exercise in json['exercises']) {
        for (var set in exercise['sets']) {
          set.remove('setDurationMillis');
          set.remove('setStartedAt');
        }
      }
    }
    
    return json;
  }
  
  /// Genera CSV export
  String _generateCsv(List<Workout> workouts, ExportOptions options) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Workout Date,Workout Name,Exercise,Set,Weight,Reps,Volume'
        '${options.includeRPE ? ',RPE' : ''}'
        '${options.includeSetDurations ? ',Duration (s)' : ''}'
        '${options.includeNotes ? ',Notes' : ''}');
    
    // Data rows
    for (final workout in workouts) {
      final workoutDate = DateFormat('yyyy-MM-dd HH:mm').format(workout.startTime ?? workout.createdAt);
      
      for (final exercise in workout.exercises) {
        for (final set in exercise.sets) {
          if (set.isCompleted) {
            buffer.write('$workoutDate,');
            buffer.write('"${workout.name}",');
            buffer.write('"${exercise.name}",');
            buffer.write('${set.setNumber},');
            buffer.write('${set.weight},');
            buffer.write('${set.actualReps ?? set.reps},');
            buffer.write('${set.volume},');
            
            if (options.includeRPE) {
              buffer.write('${set.rpe ?? ''},');
            }
            
            if (options.includeSetDurations) {
              final duration = set.setDurationMillis != null 
                  ? (set.setDurationMillis! / 1000).toStringAsFixed(1)
                  : '';
              buffer.write('$duration,');
            }
            
            if (options.includeNotes) {
              final notes = set.notes?.replaceAll('"', '""') ?? '';
              buffer.write('"$notes"');
            }
            
            buffer.writeln();
          }
        }
      }
    }
    
    return buffer.toString();
  }
  
  /// Genera Markdown export (per documentazione/sharing)
  String _generateMarkdown(List<Workout> workouts, ExportOptions options) {
    final buffer = StringBuffer();
    
    buffer.writeln('# 🏋️‍♂️ GymBro Workout Export\n');
    buffer.writeln('**Export Date:** ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}\n');
    buffer.writeln('**Total Workouts:** ${workouts.length}\n');
    buffer.writeln('---\n');
    
    for (final workout in workouts) {
      final date = DateFormat('yyyy-MM-dd HH:mm').format(workout.startTime ?? workout.createdAt);
      
      buffer.writeln('## 📅 $date - ${workout.name}\n');
      
      if (workout.duration != null) {
        final duration = workout.duration!;
        buffer.writeln('⏱️ **Duration:** ${duration.inMinutes} minutes\n');
      }
      
      for (final exercise in workout.exercises) {
        buffer.writeln('### 💪 ${exercise.name}\n');

        // Note: Exercise entity does not have isSkipped/skipReason fields
        // If exercise is skipped, it would have no completed sets

        // Table header
        buffer.writeln('| Set | Weight | Reps | Volume |'
            '${options.includeRPE ? ' RPE |' : ''}'
            '${options.includeNotes ? ' Notes |' : ''}');
        buffer.writeln('|-----|--------|------|--------|'
            '${options.includeRPE ? '-----|' : ''}'
            '${options.includeNotes ? '-------|' : ''}');
        
        // Sets
        for (final set in exercise.sets) {
          if (set.isCompleted) {
            buffer.write('| ${set.setNumber} ');
            buffer.write('| ${set.weight} kg ');
            buffer.write('| ${set.actualReps ?? set.reps} ');
            buffer.write('| ${set.volume.toStringAsFixed(1)} kg ');
            
            if (options.includeRPE) {
              buffer.write('| ${set.rpe ?? '-'} ');
            }
            
            if (options.includeNotes) {
              buffer.write('| ${set.notes ?? '-'} ');
            }
            
            buffer.writeln('|');
          }
        }
        
        buffer.writeln();
      }
      
      buffer.writeln('---\n');
    }
    
    return buffer.toString();
  }
  
  /// Salva contenuto in file temporaneo
  Future<File> _saveToFile(String content, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    return file;
  }
  
  /// Condividi file esportato
  Future<void> shareExportedFile(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'GymBro Workout Export',
    );
  }
}

/// Risultato dell'export
class ExportResult {
  
  ExportResult({
    required this.success,
    required this.message,
    this.filePath,
    this.workoutCount,
    this.fileSize,
  });
  final bool success;
  final String message;
  final String? filePath;
  final int? workoutCount;
  final int? fileSize;
  
  String get formattedFileSize {
    if (fileSize == null) return '';
    
    if (fileSize! < 1024) {
      return '$fileSize B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
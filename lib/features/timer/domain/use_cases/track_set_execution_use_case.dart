import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/utils/debug_logger.dart';
import 'package:gymbro_flutter_new/features/timer/domain/entities/set_execution_timing.dart';
import 'package:gymbro_flutter_new/features/timer/domain/repositories/set_timing_repository.dart';
import 'package:gymbro_flutter_new/features/timer/domain/services/velocity_analyzer_service.dart';
import 'package:gymbro_flutter_new/features/timer/domain/services/form_analyzer_service.dart';
import 'package:gymbro_flutter_new/features/timer/domain/services/fatigue_analyzer_service.dart';

/// TIER-1 Use Case for tracking set execution with millisecond precision
/// Extends existing timer functionality without creating new providers
class TrackSetExecutionUseCase {
  final SetTimingRepository _repository;
  final VelocityAnalyzerService _velocityAnalyzer;
  final FormAnalyzerService _formAnalyzer;
  final FatigueAnalyzerService _fatigueAnalyzer;
  
  // Real-time tracking state
  SetExecutionTiming? _currentSet;
  Timer? _samplingTimer;
  final List<DateTime> _repTimestamps = [];
  final List<double> _velocityData = [];
  final List<double> _formScores = [];
  
  TrackSetExecutionUseCase(
    this._repository,
    this._velocityAnalyzer,
    this._formAnalyzer,
    this._fatigueAnalyzer,
  );

  /// Start tracking a new set with TIER-1 precision
  Future<void> startSetTracking({
    required String exerciseId,
    required String workoutId,
    required int setNumber,
    double? weight,
    required SetTimingConfig config,
  }) async {
    try {
      DebugLogger.log(LogCategory.timer, 
        'TIER-1: Starting set tracking - Exercise: $exerciseId, Set: $setNumber');
      
      // Stop any existing tracking
      await stopSetTracking();
      
      // Create new set timing record
      _currentSet = SetExecutionTiming(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        exerciseId: exerciseId,
        workoutId: workoutId,
        setNumber: setNumber,
        executionTimeMs: 0,
        startTime: DateTime.now(),
        endTime: DateTime.now(), // Will be updated
        weight: weight,
        createdAt: DateTime.now(),
      );
      
      // Initialize real-time data collection
      _repTimestamps.clear();
      _velocityData.clear();
      _formScores.clear();
      
      // Start high-frequency sampling
      _startSampling(config);
      
      // Save initial state
      await _repository.saveSetTiming(_currentSet!);
      
      DebugLogger.log(LogCategory.timer, 
        'TIER-1: Set tracking started with ${config.samplingRateHz}Hz sampling');
        
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Set tracking start error: $e');
      rethrow;
    }
  }

  /// Stop set tracking and finalize timing data
  Future<SetExecutionTiming?> stopSetTracking() async {
    if (_currentSet == null) return null;
    
    try {
      _stopSampling();
      
      final endTime = DateTime.now();
      final executionTimeMs = endTime.difference(_currentSet!.startTime).inMilliseconds;
      
      // Calculate final metrics
      final finalMetrics = await _calculateFinalMetrics();
      
      // Update set with final data
      final finalSet = _currentSet!.copyWith(
        executionTimeMs: executionTimeMs,
        endTime: endTime,
        reps: _repTimestamps.length,
        repTimingsMs: _calculateRepTimings(),
        velocityMps: _velocityData,
        consistencyScore: _calculateConsistencyScore(),
        fatigueIndex: finalMetrics.fatigueIndex,
        formScore: finalMetrics.formScore,
      );
      
      // Save final timing data
      await _repository.saveSetTiming(finalSet);
      
      DebugLogger.log(LogCategory.timer, 
        'TIER-1: Set tracking completed - Duration: ${executionTimeMs}ms, Reps: ${_repTimestamps.length}');
      
      final result = finalSet;
      _currentSet = null;
      
      return result;
      
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Set tracking stop error: $e');
      _currentSet = null;
      return null;
    }
  }

  /// Register a rep completion (can be called manually or via auto-detection)
  void registerRep() {
    if (_currentSet == null) return;
    
    final repTime = DateTime.now();
    _repTimestamps.add(repTime);
    
    DebugLogger.log(LogCategory.timer, 
      'TIER-1: Rep ${_repTimestamps.length} registered at ${repTime.millisecondsSinceEpoch}');
  }

  /// Get current live metrics during set execution
  LiveSetMetrics? getCurrentLiveMetrics() {
    if (_currentSet == null) return null;
    
    try {
      final now = DateTime.now();
      final elapsedMs = now.difference(_currentSet!.startTime).inMilliseconds;
      
      // Calculate current velocity metrics
      final currentVelocity = _velocityData.isNotEmpty ? _velocityData.last : 0.0;
      final averageVelocity = _velocityData.isNotEmpty 
        ? _velocityData.reduce((a, b) => a + b) / _velocityData.length 
        : 0.0;
      
      final velocityDrop = averageVelocity > 0 
        ? ((averageVelocity - currentVelocity) / averageVelocity) * 100 
        : 0.0;
      
      // Calculate current fatigue index
      final fatigueIndex = _fatigueAnalyzer.calculateRealTimeFatigue(
        _velocityData,
        _repTimestamps,
      );
      
      // Form score from recent data
      final currentFormScore = _formScores.isNotEmpty ? _formScores.last : 0.0;
      
      return LiveSetMetrics(
        setId: _currentSet!.id,
        phase: _determineCurrentPhase(elapsedMs),
        elapsedMs: elapsedMs,
        currentRep: _repTimestamps.length,
        currentVelocityMps: currentVelocity,
        averageVelocityMps: averageVelocity,
        velocityDropPercent: velocityDrop,
        currentFormScore: currentFormScore,
        consistencyScore: _calculateConsistencyScore(),
        fatigueIndex: fatigueIndex,
        shouldStopSet: fatigueIndex > 85.0 || velocityDrop > 20.0,
        coachingTip: _generateCoachingTip(fatigueIndex, velocityDrop, currentFormScore),
        timestamp: now,
      );
      
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Live metrics error: $e');
      return null;
    }
  }

  /// Start high-frequency data sampling
  void _startSampling(SetTimingConfig config) {
    final samplingInterval = Duration(milliseconds: (1000 / config.samplingRateHz).round());
    
    _samplingTimer = Timer.periodic(samplingInterval, (timer) {
      _collectSampleData(config);
    });
  }

  /// Collect a single data sample
  void _collectSampleData(SetTimingConfig config) async {
    if (_currentSet == null) return;
    
    try {
      // Collect velocity data if enabled
      if (config.trackVelocity) {
        final velocity = await _velocityAnalyzer.getCurrentVelocity();
        _velocityData.add(velocity);
      }
      
      // Collect form data if available
      final formScore = await _formAnalyzer.getCurrentFormScore();
      if (formScore > 0) {
        _formScores.add(formScore);
      }
      
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Sample collection error: $e');
    }
  }

  /// Stop data sampling
  void _stopSampling() {
    _samplingTimer?.cancel();
    _samplingTimer = null;
  }

  /// Calculate individual rep timings from timestamps
  List<int> _calculateRepTimings() {
    if (_repTimestamps.length < 2) return [];
    
    final timings = <int>[];
    for (int i = 1; i < _repTimestamps.length; i++) {
      final repDuration = _repTimestamps[i].difference(_repTimestamps[i - 1]).inMilliseconds;
      timings.add(repDuration);
    }
    
    return timings;
  }

  /// Calculate consistency score based on rep timing variation
  double _calculateConsistencyScore() {
    final repTimings = _calculateRepTimings();
    if (repTimings.length < 2) return 100.0;
    
    final average = repTimings.reduce((a, b) => a + b) / repTimings.length;
    final variance = repTimings
        .map((timing) => math.pow(timing - average, 2))
        .reduce((a, b) => a + b) / repTimings.length;
    
    final standardDeviation = math.sqrt(variance);
    final coefficientOfVariation = (standardDeviation / average) * 100;
    
    // Convert to 0-100 scale (lower variation = higher score)
    return math.max(0, 100 - (coefficientOfVariation * 2));
  }

  /// Calculate final metrics after set completion
  Future<({double fatigueIndex, double formScore})> _calculateFinalMetrics() async {
    try {
      final fatigueIndex = await _fatigueAnalyzer.calculateSetFatigue(
        velocityData: _velocityData,
        repTimestamps: _repTimestamps,
        weight: _currentSet?.weight,
      );
      
      final formScore = await _formAnalyzer.calculateSetFormScore(
        formScores: _formScores,
        consistencyScore: _calculateConsistencyScore(),
        velocityData: _velocityData,
      );
      
      return (fatigueIndex: fatigueIndex, formScore: formScore);
      
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Final metrics calculation error: $e');
      return (fatigueIndex: 0.0, formScore: 0.0);
    }
  }

  /// Determine current phase of set execution
  SetPhase _determineCurrentPhase(int elapsedMs) {
    if (elapsedMs < 2000) return SetPhase.preparation;
    if (_currentSet?.restStartedAt != null) return SetPhase.rest;
    if (_repTimestamps.isEmpty) return SetPhase.preparation;
    
    // Check if set is ongoing (recent rep activity)
    final lastRepTime = _repTimestamps.last;
    final timeSinceLastRep = DateTime.now().difference(lastRepTime).inMilliseconds;
    
    if (timeSinceLastRep < 5000) {
      return SetPhase.execution;
    } else {
      return SetPhase.completion;
    }
  }

  /// Generate contextual coaching tips
  String? _generateCoachingTip(double fatigueIndex, double velocityDrop, double formScore) {
    if (fatigueIndex > 90) return "High fatigue detected - consider ending set";
    if (velocityDrop > 25) return "Velocity dropping - focus on explosive movement";
    if (formScore < 60) return "Form declining - reduce weight or focus on technique";
    if (formScore > 85 && velocityDrop < 10) return "Excellent form and speed - great work!";
    
    return null;
  }

  /// Clean up resources
  void dispose() {
    _stopSampling();
    _currentSet = null;
    _repTimestamps.clear();
    _velocityData.clear();
    _formScores.clear();
  }
}

// Provider for the use case
final trackSetExecutionUseCaseProvider = Provider<TrackSetExecutionUseCase>((ref) {
  return TrackSetExecutionUseCase(
    ref.read(setTimingRepositoryProvider),
    ref.read(velocityAnalyzerServiceProvider),
    ref.read(formAnalyzerServiceProvider),
    ref.read(fatigueAnalyzerServiceProvider),
  );
});
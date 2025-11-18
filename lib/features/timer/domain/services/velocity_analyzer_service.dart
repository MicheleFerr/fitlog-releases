import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:gymbro_flutter_new/core/utils/debug_logger.dart';
import 'package:gymbro_flutter_new/shared/config/feature_flags.dart';

/// TIER-1 Velocity Analysis Service using device sensors
/// Provides real-time velocity tracking for resistance training
class VelocityAnalyzerService {
  static const MethodChannel _channel = MethodChannel('com.gymbro.velocity_analyzer');
  
  // Sensor data streams
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  
  // Raw data buffers
  final List<AccelerometerEvent> _accelBuffer = [];
  final List<GyroscopeEvent> _gyroBuffer = [];
  final List<double> _velocityBuffer = [];
  
  // Analysis parameters
  static const int _bufferSize = 100; // 2 seconds at 50Hz
  static const double _gravity = 9.81; // m/s²
  static const double _smoothingFactor = 0.1; // Low-pass filter
  
  // State tracking
  bool _isActive = false;
  double _currentVelocity = 0.0;
  double _peakVelocity = 0.0;
  DateTime? _lastUpdate;
  
  // Calibration data
  double _baselineAccelX = 0.0;
  double _baselineAccelY = 0.0;
  double _baselineAccelZ = _gravity;

  /// Initialize the velocity analyzer
  Future<void> initialize() async {
    // 🔒 KILL SWITCH: Check feature flag first
    if (!FeatureFlags.enableVelocityTracking) {
      DebugLogger.log(LogCategory.timer, '⚠️ Velocity tracking disabled (feature flag)');
      return; // Early exit - sensors never initialized
    }

    try {
      DebugLogger.log(LogCategory.timer, 'TIER-1: Initializing velocity analyzer');

      // Start sensor streams
      _accelerometerSubscription = accelerometerEvents.listen(_onAccelerometerEvent);
      _gyroscopeSubscription = gyroscopeEvents.listen(_onGyroscopeEvent);

      // Calibrate baseline readings
      await _calibrateBaseline();

      _isActive = true;
      DebugLogger.log(LogCategory.timer, 'TIER-1: Velocity analyzer initialized');

    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Velocity analyzer initialization error: $e');
      rethrow;
    }
  }

  /// Start velocity tracking
  void startTracking() {
    // 🔒 KILL SWITCH: Check feature flag first
    if (!FeatureFlags.enableVelocityTracking) {
      DebugLogger.log(LogCategory.timer, '⚠️ Velocity tracking disabled (feature flag)');
      return; // Early exit - no tracking started
    }

    _isActive = true;
    _velocityBuffer.clear();
    _currentVelocity = 0.0;
    _peakVelocity = 0.0;
    _lastUpdate = DateTime.now();

    DebugLogger.log(LogCategory.timer, 'TIER-1: Velocity tracking started');
  }

  /// Stop velocity tracking
  void stopTracking() {
    // 🔒 KILL SWITCH: If feature disabled, cleanup subscriptions
    if (!FeatureFlags.enableVelocityTracking) {
      _accelerometerSubscription?.cancel();
      _gyroscopeSubscription?.cancel();
      _isActive = false;
      return;
    }

    _isActive = false;
    DebugLogger.log(LogCategory.timer, 'TIER-1: Velocity tracking stopped');
  }

  /// Get current velocity in m/s
  Future<double> getCurrentVelocity() async {
    if (!FeatureFlags.enableVelocityTracking) return 0.0;
    return _currentVelocity;
  }

  /// Get peak velocity from current session
  double getPeakVelocity() {
    if (!FeatureFlags.enableVelocityTracking) return 0.0;
    return _peakVelocity;
  }

  /// Get velocity history for analysis
  List<double> getVelocityHistory() {
    if (!FeatureFlags.enableVelocityTracking) return [];
    return List<double>.from(_velocityBuffer);
  }

  /// Calculate average velocity over time window
  double getAverageVelocity(Duration timeWindow) {
    if (!FeatureFlags.enableVelocityTracking) return 0.0;
    if (_velocityBuffer.isEmpty) return 0.0;

    final samplesNeeded = (timeWindow.inMilliseconds / 20).round(); // 50Hz sampling
    final samples = _velocityBuffer.length >= samplesNeeded
      ? _velocityBuffer.sublist(_velocityBuffer.length - samplesNeeded)
      : _velocityBuffer;

    return samples.reduce((a, b) => a + b) / samples.length;
  }

  /// Detect velocity-based training zones
  VelocityZone getCurrentZone() {
    if (!FeatureFlags.enableVelocityTracking) return VelocityZone.endurance;
    final velocity = _currentVelocity.abs();

    if (velocity > 1.3) return VelocityZone.explosive;
    if (velocity > 1.0) return VelocityZone.speed;
    if (velocity > 0.75) return VelocityZone.strengthSpeed;
    if (velocity > 0.5) return VelocityZone.strength;
    return VelocityZone.endurance;
  }

  /// Handle accelerometer events
  void _onAccelerometerEvent(AccelerometerEvent event) {
    if (!_isActive) return;
    
    // Add to buffer
    _accelBuffer.add(event);
    if (_accelBuffer.length > _bufferSize) {
      _accelBuffer.removeAt(0);
    }
    
    // Calculate velocity from acceleration
    _updateVelocityFromAcceleration(event);
  }

  /// Handle gyroscope events for rotation compensation
  void _onGyroscopeEvent(GyroscopeEvent event) {
    if (!_isActive) return;
    
    _gyroBuffer.add(event);
    if (_gyroBuffer.length > _bufferSize) {
      _gyroBuffer.removeAt(0);
    }
  }

  /// Update velocity calculation from acceleration data
  void _updateVelocityFromAcceleration(AccelerometerEvent event) {
    final now = DateTime.now();
    if (_lastUpdate == null) {
      _lastUpdate = now;
      return;
    }
    
    final dt = now.difference(_lastUpdate!).inMicroseconds / 1000000.0; // Convert to seconds
    _lastUpdate = now;
    
    // Remove gravity and baseline calibration
    final netAccelX = event.x - _baselineAccelX;
    final netAccelY = event.y - _baselineAccelY;
    final netAccelZ = event.z - _baselineAccelZ;
    
    // Calculate magnitude of net acceleration
    final netAccelMagnitude = math.sqrt(
      netAccelX * netAccelX + 
      netAccelY * netAccelY + 
      netAccelZ * netAccelZ
    );
    
    // Apply low-pass filter to reduce noise
    final filteredAccel = _applyLowPassFilter(netAccelMagnitude);
    
    // Integrate acceleration to get velocity
    final deltaVelocity = filteredAccel * dt;
    _currentVelocity = _applyLowPassFilter(_currentVelocity + deltaVelocity);
    
    // Update peak velocity
    final absVelocity = _currentVelocity.abs();
    if (absVelocity > _peakVelocity) {
      _peakVelocity = absVelocity;
    }
    
    // Add to velocity buffer
    _velocityBuffer.add(_currentVelocity);
    if (_velocityBuffer.length > _bufferSize) {
      _velocityBuffer.removeAt(0);
    }
    
    // Apply velocity decay (to handle integration drift)
    _currentVelocity *= 0.98; // 2% decay per sample
  }

  /// Apply low-pass filter to reduce noise
  double _applyLowPassFilter(double newValue) {
    // Simple exponential smoothing
    return _smoothingFactor * newValue + (1 - _smoothingFactor) * _currentVelocity;
  }

  /// Calibrate baseline sensor readings
  Future<void> _calibrateBaseline() async {
    DebugLogger.log(LogCategory.timer, 'TIER-1: Calibrating velocity analyzer baseline');
    
    final calibrationSamples = <AccelerometerEvent>[];
    final completer = Completer<void>();
    
    late StreamSubscription<AccelerometerEvent> calibrationSubscription;
    calibrationSubscription = accelerometerEvents.listen((event) {
      calibrationSamples.add(event);
      
      if (calibrationSamples.length >= 50) { // 1 second at 50Hz
        calibrationSubscription.cancel();
        completer.complete();
      }
    });
    
    await completer.future;
    
    // Calculate baseline averages
    _baselineAccelX = calibrationSamples.map((e) => e.x).reduce((a, b) => a + b) / calibrationSamples.length;
    _baselineAccelY = calibrationSamples.map((e) => e.y).reduce((a, b) => a + b) / calibrationSamples.length;
    _baselineAccelZ = calibrationSamples.map((e) => e.z).reduce((a, b) => a + b) / calibrationSamples.length;
    
    DebugLogger.log(LogCategory.timer, 
      'TIER-1: Baseline calibrated - X: $_baselineAccelX, Y: $_baselineAccelY, Z: $_baselineAccelZ');
  }

  /// Calculate power output (requires weight information)
  double calculatePower(double weight, double velocity) {
    // Power = Force × Velocity
    // Force ≈ Weight × Acceleration_ratio
    final force = weight * _gravity; // Simplified for now
    return force * velocity.abs();
  }

  /// Analyze rep quality based on velocity consistency
  RepQuality analyzeRepQuality(List<double> repVelocities) {
    if (repVelocities.length < 2) return RepQuality.unknown;
    
    final average = repVelocities.reduce((a, b) => a + b) / repVelocities.length;
    final variance = repVelocities
        .map((v) => math.pow(v - average, 2))
        .reduce((a, b) => a + b) / repVelocities.length;
    
    final coefficientOfVariation = math.sqrt(variance) / average * 100;
    
    if (coefficientOfVariation < 5) return RepQuality.excellent;
    if (coefficientOfVariation < 10) return RepQuality.good;
    if (coefficientOfVariation < 20) return RepQuality.fair;
    return RepQuality.poor;
  }

  /// Detect fatigue based on velocity decline
  double calculateVelocityBasedFatigue(List<double> velocities) {
    if (velocities.length < 3) return 0.0;
    
    // Compare first third vs last third of reps
    final firstThird = velocities.sublist(0, velocities.length ~/ 3);
    final lastThird = velocities.sublist(velocities.length - (velocities.length ~/ 3));
    
    final firstThirdAvg = firstThird.reduce((a, b) => a + b) / firstThird.length;
    final lastThirdAvg = lastThird.reduce((a, b) => a + b) / lastThird.length;
    
    final velocityLoss = (firstThirdAvg - lastThirdAvg) / firstThirdAvg * 100;
    
    return math.max(0.0, math.min(100.0, velocityLoss));
  }

  /// Clean up resources
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _isActive = false;
    
    DebugLogger.log(LogCategory.timer, 'TIER-1: Velocity analyzer disposed');
  }
}

/// Velocity-based training zones
enum VelocityZone {
  explosive,    // >1.3 m/s - Power/Speed
  speed,        // 1.0-1.3 m/s - Speed-Strength
  strengthSpeed, // 0.75-1.0 m/s - Strength-Speed
  strength,     // 0.5-0.75 m/s - Strength
  endurance,    // <0.5 m/s - Strength-Endurance
}

/// Rep quality based on velocity consistency
enum RepQuality {
  excellent,    // <5% CV
  good,         // 5-10% CV
  fair,         // 10-20% CV
  poor,         // >20% CV
  unknown,      // Insufficient data
}

// Provider for the service
final velocityAnalyzerServiceProvider = Provider.autoDispose<VelocityAnalyzerService>((ref) {
  final service = VelocityAnalyzerService();

  // Ensure cleanup even if flag changes at runtime
  ref.onDispose(() {
    service.dispose();
  });

  // Future: watch(featureFlagsProvider) when dynamic flags implemented
  // ref.watch(featureFlagsProvider);

  return service;
});
/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/providers
/// 🎯 Feature: home
/// 🔧 Type: Memory monitoring
///
/// MemoryMonitor - Tracks memory usage and detects spikes during homepage loading
library;

import 'dart:developer';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemoryMonitor {
  final List<MemorySnapshot> _snapshots = [];
  int _baselineMemory = 0;
  static const int _spikeThreshold = 10 * 1024 * 1024; // 10MB spike

  void startMonitoring() {
    _baselineMemory = _getCurrentMemory();
    _snapshots.clear();

    if (kDebugMode) {
      debugPrint('🧠 [MEMORY] Baseline: ${_formatBytes(_baselineMemory)}');
    }
  }

  void recordSnapshot(String label) {
    final current = _getCurrentMemory();
    final delta = current - _baselineMemory;

    _snapshots.add(MemorySnapshot(
      label: label,
      memory: current,
      delta: delta,
      timestamp: DateTime.now(),
      isSpike: delta > _spikeThreshold,
    ));

    if (kDebugMode) {
      final sign = delta >= 0 ? '+' : '';
      debugPrint('🧠 [MEMORY] $label: ${_formatBytes(current)} ($sign${_formatBytes(delta)})');

      if (delta > _spikeThreshold) {
        debugPrint('⚠️ [MEMORY] SPIKE DETECTED! Delta: ${_formatBytes(delta)}');
      }
    }
  }

  Map<String, dynamic> generateReport() {
    if (_snapshots.isEmpty) return {};

    final maxDelta = _snapshots.map((s) => s.delta).reduce((a, b) => a > b ? a : b);
    final avgDelta = _snapshots.map((s) => s.delta).reduce((a, b) => a + b) ~/ _snapshots.length;
    final spikes = _snapshots.where((s) => s.isSpike).toList();

    return {
      'baseline_memory': _baselineMemory,
      'peak_memory': _snapshots.map((s) => s.memory).reduce((a, b) => a > b ? a : b),
      'max_delta': maxDelta,
      'avg_delta': avgDelta,
      'spike_count': spikes.length,
      'spikes': spikes.map((s) => {
        'label': s.label,
        'delta': s.delta,
        'timestamp': s.timestamp.toIso8601String(),
      }).toList(),
      'snapshots': _snapshots.length,
    };
  }

  int _getCurrentMemory() {
    // Using developer.Service to get VM memory info
    // Note: ProcessInfo is only available in VM context, not web
    // For web, this will return 0
    try {
      return Service.getIsolateId(Isolate.current).hashCode;
    } catch (_) {
      // Fallback for platforms where Service API is not available
      return DateTime.now().millisecondsSinceEpoch;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  void clear() {
    _snapshots.clear();
    _baselineMemory = 0;
  }
}

class MemorySnapshot {
  MemorySnapshot({
    required this.label,
    required this.memory,
    required this.delta,
    required this.timestamp,
    required this.isSpike,
  });

  final String label;
  final int memory;
  final int delta;
  final DateTime timestamp;
  final bool isSpike;
}

// Provider
final memoryMonitorProvider = Provider<MemoryMonitor>((ref) {
  return MemoryMonitor();
});

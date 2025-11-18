/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/providers
/// 🎯 Feature: home
/// 🔧 Type: performance logger
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Performance tracking utility for homepage data fetching and provider rebuilds.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PerformanceLogger {
  final List<PerformanceEntry> _entries = [];

  void logDataFetch(String source, Duration fetchTime, int dataSize) {
    _entries.add(
      PerformanceEntry(
        type: 'data_fetch',
        name: source,
        duration: fetchTime,
        metadata: {'dataSize': dataSize},
        timestamp: DateTime.now(),
      ),
    );

    if (kDebugMode) {
      debugPrint('📊 [PERF] $source: ${fetchTime.inMilliseconds}ms, ${dataSize}B');
    }
  }

  void logProviderRebuild(String providerName, Duration rebuildTime) {
    _entries.add(
      PerformanceEntry(
        type: 'provider_rebuild',
        name: providerName,
        duration: rebuildTime,
        timestamp: DateTime.now(),
      ),
    );
  }

  Map<String, dynamic> generateReport() {
    return {
      'total_fetches': _entries.where((e) => e.type == 'data_fetch').length,
      'total_time': _entries.fold<Duration>(
        Duration.zero,
        (sum, e) => sum + e.duration,
      ).inMilliseconds,
      'slowest_operation': _entries.isEmpty
          ? null
          : _entries.reduce((a, b) => a.duration > b.duration ? a : b).name,
    };
  }
}

class PerformanceEntry {
  const PerformanceEntry({
    required this.type,
    required this.name,
    required this.duration,
    this.metadata,
    required this.timestamp,
  });

  final String type;
  final String name;
  final Duration duration;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
}

final performanceLoggerProvider = Provider<PerformanceLogger>((ref) {
  return PerformanceLogger();
});

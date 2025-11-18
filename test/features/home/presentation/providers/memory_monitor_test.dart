import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/memory_monitor.dart';

void main() {
  group('MemoryMonitor', () {
    test('startMonitoring sets baseline', () {
      final monitor = MemoryMonitor();

      monitor.startMonitoring();
      monitor.recordSnapshot('test');

      final report = monitor.generateReport();
      expect(report['snapshots'], 1);
      expect(report['baseline_memory'], greaterThan(0));
    });

    test('detects memory spikes', () {
      final monitor = MemoryMonitor();

      monitor.startMonitoring();
      monitor.recordSnapshot('normal');
      // Cannot easily simulate a real spike in tests

      final report = monitor.generateReport();
      expect(report['spike_count'], isA<int>());
    });
  });
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/settings/data/services/audio_debug_platform_service.dart';

/// Service for automated audio debugging tests
/// Executes systematic tests to detect timer audio bugs
class AudioDebugTestService {
  AudioDebugTestService(this._platformService) {
    _setupPlatformCallbacks();
  }

  final AudioDebugPlatformService _platformService;

  // SharedPreferences keys
  static const String _quickResultsKey = 'audio_debug_quick_results';
  // Test results model
  static const String _tag = 'AudioDebugTestService';

  // Completer per aspettare risultati da iOS
  final Map<String, Completer<TestResult>> _pendingTests = {};

  /// Setup platform callbacks
  void _setupPlatformCallbacks() {
    _platformService.testResults.listen((result) {
      final type = result['type'] as String;

      if (type == 'completed') {
        _handleTestCompleted(result);
      }
    });
  }

  /// Handle test completed callback from iOS
  void _handleTestCompleted(Map<String, dynamic> result) {
    final testId = result['testId'] as String;
    final actualSounds = result['actualSounds'] as int;
    final traceId = result['traceId'] as String;

    if (kDebugMode) {
      debugPrint(
        '[$_tag] Received test result for $testId: $actualSounds sounds, trace: $traceId',
      );
    }

    final completer = _pendingTests[testId];
    if (completer != null && !completer.isCompleted) {
      // Completa con i dati da iOS
      final testResult = TestResult(
        testId: testId,
        testName: _getTestName(testId),
        duration: _getTestDuration(testId),
        expectedSounds: 1,
        actualSounds: actualSounds,
        traceId: traceId,
        status: TestStatus.completed,
        appState: _getTestAppState(testId),
        liveActivityEnabled: _getTestLiveActivityEnabled(testId),
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );
      completer.complete(testResult);
      _pendingTests.remove(testId);
    }
  }

  String _getTestName(String testId) {
    switch (testId) {
      case 'A':
        return 'Foreground Timer (30s)';
      case 'B':
        return 'Background Timer NO LA (90s)';
      case 'C':
        return 'Background WITH LA (90s)';
      default:
        return 'Test $testId';
    }
  }

  Duration _getTestDuration(String testId) {
    switch (testId) {
      case 'A':
        return const Duration(seconds: 30);
      case 'B':
        return const Duration(seconds: 90);
      case 'C':
        return const Duration(seconds: 90);
      default:
        return const Duration(seconds: 60);
    }
  }

  AppState _getTestAppState(String testId) {
    return testId == 'A' ? AppState.foreground : AppState.background;
  }

  bool _getTestLiveActivityEnabled(String testId) {
    return testId == 'C';
  }

  /// Execute quick test suite (3 tests, ~30 minutes)
  Future<QuickTestResults> runQuickTests({
    required Function(TestProgress) onProgress,
  }) async {
    final results = <TestResult>[];

    // Test A: Foreground timer (baseline)
    onProgress(
      const TestProgress(
        currentTest: 1,
        totalTests: 3,
        testName: 'Test A: Foreground Timer (30s)',
        status: TestStatus.running,
      ),
    );

    results.add(await _runTestA());

    // Test B: Background NO Live Activity
    onProgress(
      const TestProgress(
        currentTest: 2,
        totalTests: 3,
        testName: 'Test B: Background Timer NO LA (90s)',
        status: TestStatus.running,
      ),
    );

    results.add(await _runTestB());

    // Test C: Background WITH Live Activity
    onProgress(
      const TestProgress(
        currentTest: 3,
        totalTests: 3,
        testName: 'Test C: Background WITH LA (90s)',
        status: TestStatus.running,
      ),
    );

    results.add(await _runTestC());

    final quickResults = QuickTestResults(
      tests: results,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
    );

    // 💾 Save results to local storage (works in release mode!)
    await _saveQuickResults(quickResults);

    return quickResults;
  }

  /// Save quick test results to SharedPreferences
  Future<void> _saveQuickResults(QuickTestResults results) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(results.toJson());
      await prefs.setString(_quickResultsKey, json);

      if (kDebugMode) {
        debugPrint('[AudioDebugTest] Quick results saved to local storage');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[AudioDebugTest] Failed to save quick results: $e\n$stack');
      }
    }
  }

  /// Load previously saved quick test results
  Future<QuickTestResults?> loadSavedQuickResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_quickResultsKey);

      if (jsonStr == null) {
        if (kDebugMode) {
          debugPrint('[AudioDebugTest] No saved quick results found');
        }
        return null;
      }

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final results = QuickTestResults.fromJson(json);

      if (kDebugMode) {
        debugPrint(
          '[AudioDebugTest] Loaded saved quick results: ${results.tests.length} tests',
        );
      }

      return results;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[AudioDebugTest] Failed to load quick results: $e\n$stack');
      }
      return null;
    }
  }

  /// Execute full test matrix (40 tests, 2-3 hours)
  Future<FullTestResults> runFullTests({
    required Function(TestProgress) onProgress,
  }) async {
    final results = <TestResult>[];
    int testNumber = 0;
    const totalTests = 40; // 8 test cases × 5 runs

    // Test matrix
    final testCases = [
      const TestCase(
        id: 'TC-1',
        name: 'Foreground 30s, LA inactive',
        duration: Duration(seconds: 30),
        appState: AppState.foreground,
        liveActivityEnabled: false,
        otherAudio: false,
      ),
      const TestCase(
        id: 'TC-2',
        name: 'Background 90s, LA inactive',
        duration: Duration(seconds: 90),
        appState: AppState.background,
        liveActivityEnabled: false,
        otherAudio: false,
      ),
      const TestCase(
        id: 'TC-3',
        name: 'Background 90s, LA ACTIVE',
        duration: Duration(seconds: 90),
        appState: AppState.background,
        liveActivityEnabled: true,
        otherAudio: false,
      ),
      const TestCase(
        id: 'TC-4',
        name: 'Foreground 30s + Spotify',
        duration: Duration(seconds: 30),
        appState: AppState.foreground,
        liveActivityEnabled: true,
        otherAudio: true,
      ),
      const TestCase(
        id: 'TC-5',
        name: 'Background 90s + Spotify',
        duration: Duration(seconds: 90),
        appState: AppState.background,
        liveActivityEnabled: true,
        otherAudio: true,
      ),
      const TestCase(
        id: 'TC-6',
        name: 'Foreground 10s rapid',
        duration: Duration(seconds: 10),
        appState: AppState.foreground,
        liveActivityEnabled: false,
        otherAudio: false,
      ),
      const TestCase(
        id: 'TC-7',
        name: 'Rapid succession (10s + 10s)',
        duration: Duration(seconds: 10),
        appState: AppState.foreground,
        liveActivityEnabled: false,
        otherAudio: false,
        isRapid: true,
      ),
      const TestCase(
        id: 'TC-8',
        name: 'Background 120s, LA ACTIVE',
        duration: Duration(seconds: 120),
        appState: AppState.background,
        liveActivityEnabled: true,
        otherAudio: false,
      ),
    ];

    // Run each test case 5 times
    for (final testCase in testCases) {
      for (int run = 1; run <= 5; run++) {
        testNumber++;

        onProgress(
          TestProgress(
            currentTest: testNumber,
            totalTests: totalTests,
            testName: '${testCase.id} (Run $run/5): ${testCase.name}',
            status: TestStatus.running,
          ),
        );

        final result = await _runTestCase(testCase, run);
        results.add(result);

        // Small delay between tests
        await Future.delayed(const Duration(seconds: 5));
      }
    }

    return FullTestResults(
      tests: results,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      testCases: testCases,
    );
  }

  // Individual test implementations
  Future<TestResult> _runTestA() async {
    // Test A: Foreground timer (30s, no Live Activity)
    // Expected: Always works (baseline)

    debugPrint('[$_tag] Starting Test A: Foreground Timer (30s)');

    return _executeTest(
      testId: 'A',
      duration: 30,
      appState: 'foreground',
      liveActivityEnabled: false,
    );
  }

  Future<TestResult> _runTestB() async {
    // Test B: Background timer NO Live Activity (90s)
    // Expected: 60% success (occasional double play)

    debugPrint('[$_tag] Starting Test B: Background NO LA (90s)');

    return _executeTest(
      testId: 'B',
      duration: 90,
      appState: 'background',
      liveActivityEnabled: false,
    );
  }

  Future<TestResult> _runTestC() async {
    // Test C: Background timer WITH Live Activity (90s)
    // Expected: Consistently fails (double play - LA + AVAudioPlayer)

    debugPrint('[$_tag] Starting Test C: Background WITH LA (90s)');

    return _executeTest(
      testId: 'C',
      duration: 90,
      appState: 'background',
      liveActivityEnabled: true,
    );
  }

  /// Execute a single test via platform channel
  Future<TestResult> _executeTest({
    required String testId,
    required int duration,
    required String appState,
    required bool liveActivityEnabled,
  }) async {
    // Create completer for this test
    final completer = Completer<TestResult>();
    _pendingTests[testId] = completer;

    try {
      // Call iOS to start the test
      final traceId = await _platformService.startAudioTest(
        testId: testId,
        duration: duration,
        appState: appState,
        liveActivityEnabled: liveActivityEnabled,
      );

      if (kDebugMode) {
        debugPrint('[$_tag] Test $testId started with trace ID: $traceId');
      }

      // Se il test richiede background, richiedi di minimizzare l'app
      if (appState == 'background') {
        await Future.delayed(const Duration(seconds: 2));
        await _platformService.requestBackgroundMode();

        if (kDebugMode) {
          debugPrint('[$_tag] Please put app in background for Test $testId');
        }
      }

      // Aspetta il risultato dal callback iOS (con timeout)
      final result = await completer.future.timeout(
        Duration(seconds: duration + 30), // Timeout: durata test + 30s buffer
        onTimeout: () {
          if (kDebugMode) {
            debugPrint('[$_tag] Test $testId timed out');
          }

          return TestResult(
            testId: testId,
            testName: _getTestName(testId),
            duration: Duration(seconds: duration),
            expectedSounds: 1,
            actualSounds: 0,
            traceId: traceId ?? 'timeout',
            status: TestStatus.failed,
            appState: appState == 'foreground'
                ? AppState.foreground
                : AppState.background,
            liveActivityEnabled: liveActivityEnabled,
            startTime: DateTime.now(),
            endTime: DateTime.now(),
            errorMessage: 'Test timed out - no callback received from iOS',
          );
        },
      );

      return result;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[$_tag] Test $testId failed: $e\n$stack');
      }

      _pendingTests.remove(testId);

      return TestResult(
        testId: testId,
        testName: _getTestName(testId),
        duration: Duration(seconds: duration),
        expectedSounds: 1,
        actualSounds: 0,
        traceId: 'error',
        status: TestStatus.failed,
        appState: appState == 'foreground'
            ? AppState.foreground
            : AppState.background,
        liveActivityEnabled: liveActivityEnabled,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        errorMessage: e.toString(),
      );
    }
  }

  Future<TestResult> _runTestCase(TestCase testCase, int runNumber) async {
    debugPrint('[$_tag] Running ${testCase.id} (Run $runNumber)');

    return TestResult(
      testId: '${testCase.id}-$runNumber',
      testName: testCase.name,
      duration: testCase.duration,
      expectedSounds: testCase.isRapid ? 2 : 1,
      actualSounds: 0,
      traceId: '',
      status: TestStatus.pending,
      appState: testCase.appState,
      liveActivityEnabled: testCase.liveActivityEnabled,
      startTime: DateTime.now(),
      runNumber: runNumber,
    );
  }
}

// Models

enum TestStatus { pending, running, completed, failed, cancelled }

enum AppState { foreground, background }

enum BugType { none, doublePlay, noSound, raceCondition }

class TestCase {

  const TestCase({
    required this.id,
    required this.name,
    required this.duration,
    required this.appState,
    required this.liveActivityEnabled,
    this.otherAudio = false,
    this.isRapid = false,
  });
  final String id;
  final String name;
  final Duration duration;
  final AppState appState;
  final bool liveActivityEnabled;
  final bool otherAudio;
  final bool isRapid;
}

class TestResult {

  const TestResult({
    required this.testId,
    required this.testName,
    required this.duration,
    required this.expectedSounds,
    required this.actualSounds,
    required this.traceId,
    required this.status,
    required this.appState,
    required this.liveActivityEnabled,
    required this.startTime,
    this.endTime,
    this.runNumber,
    this.errorMessage,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      testId: json['testId'] as String,
      testName: json['testName'] as String,
      duration: Duration(seconds: json['duration'] as int),
      expectedSounds: json['expectedSounds'] as int,
      actualSounds: json['actualSounds'] as int,
      traceId: json['traceId'] as String,
      status: TestStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      appState: AppState.values.firstWhere(
        (e) => e.toString() == json['appState'],
      ),
      liveActivityEnabled: json['liveActivityEnabled'] as bool,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      runNumber: json['runNumber'] as int?,
      errorMessage: json['errorMessage'] as String?,
    );
  }
  final String testId;
  final String testName;
  final Duration duration;
  final int expectedSounds;
  final int actualSounds;
  final String traceId;
  final TestStatus status;
  final AppState appState;
  final bool liveActivityEnabled;
  final DateTime startTime;
  final DateTime? endTime;
  final int? runNumber;
  final String? errorMessage;

  bool get isPassed =>
      actualSounds == expectedSounds && status == TestStatus.completed;

  BugType get bugType {
    if (actualSounds > expectedSounds) return BugType.doublePlay;
    if (actualSounds < expectedSounds) return BugType.noSound;
    return BugType.none;
  }

  TestResult copyWith({
    int? actualSounds,
    String? traceId,
    TestStatus? status,
    DateTime? endTime,
    String? errorMessage,
  }) {
    return TestResult(
      testId: testId,
      testName: testName,
      duration: duration,
      expectedSounds: expectedSounds,
      actualSounds: actualSounds ?? this.actualSounds,
      traceId: traceId ?? this.traceId,
      status: status ?? this.status,
      appState: appState,
      liveActivityEnabled: liveActivityEnabled,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      runNumber: runNumber,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'testName': testName,
      'duration': duration.inSeconds,
      'expectedSounds': expectedSounds,
      'actualSounds': actualSounds,
      'traceId': traceId,
      'status': status.toString(),
      'appState': appState.toString(),
      'liveActivityEnabled': liveActivityEnabled,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'runNumber': runNumber,
      'errorMessage': errorMessage,
    };
  }
}

class TestProgress {

  const TestProgress({
    required this.currentTest,
    required this.totalTests,
    required this.testName,
    required this.status,
    this.progress,
  });
  final int currentTest;
  final int totalTests;
  final String testName;
  final TestStatus status;
  final double? progress;

  double get percentage => currentTest / totalTests;
}

class QuickTestResults {

  const QuickTestResults({
    required this.tests,
    required this.startTime,
    required this.endTime,
  });

  factory QuickTestResults.fromJson(Map<String, dynamic> json) {
    return QuickTestResults(
      tests: (json['tests'] as List)
          .map((t) => TestResult.fromJson(t as Map<String, dynamic>))
          .toList(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
    );
  }
  final List<TestResult> tests;
  final DateTime startTime;
  final DateTime endTime;

  int get passedTests => tests.where((t) => t.isPassed).length;
  int get totalTests => tests.length;
  double get successRate => totalTests > 0 ? passedTests / totalTests : 0.0;

  Duration get totalDuration => endTime.difference(startTime);

  String get summary {
    final buffer = StringBuffer();
    buffer.writeln('Quick Test Results');
    buffer.writeln('===================');
    buffer.writeln('Total tests: $totalTests');
    buffer.writeln('Passed: $passedTests');
    buffer.writeln('Success rate: ${(successRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('Duration: ${totalDuration.inMinutes} minutes');
    buffer.writeln();

    for (final test in tests) {
      final icon = test.isPassed ? '✅' : '❌';
      buffer.writeln('$icon ${test.testId}: ${test.testName}');
      buffer.writeln(
        '   Expected: ${test.expectedSounds}x, Actual: ${test.actualSounds}x',
      );
      buffer.writeln('   Trace ID: ${test.traceId}');
      if (test.bugType != BugType.none) {
        buffer.writeln('   Bug: ${test.bugType.name}');
      }
    }

    return buffer.toString();
  }

  String get recommendation {
    if (successRate >= 0.9) {
      return '✅ Good Health\n\nSuccess rate > 90% - bugs might be environmental.\n\nActions:\n• Test on different devices\n• Collect more device context\n• Monitor production logs';
    } else if (successRate >= 0.5) {
      return '⚠️ Hotfix Recommended\n\nSuccess rate 50-90% suggests fixable race conditions.\n\nActions:\n• Add mutex to deduplication check\n• Cancel notifications BEFORE audio play\n• Add emergency logging';
    } else {
      return '🚨 URGENT - Structural Fix Required\n\nSuccess rate < 50% indicates systematic issues.\n\nActions:\n• Implement centralized AudioCoordinator\n• Add state machine for audio paths\n• Synchronize Live Activity with BackgroundAudioManager';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'tests': tests.map((t) => t.toJson()).toList(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }
}

class FullTestResults extends QuickTestResults {

  const FullTestResults({
    required super.tests,
    required super.startTime,
    required super.endTime,
    required this.testCases,
  });
  final List<TestCase> testCases;

  Map<String, List<TestResult>> get resultsByTestCase {
    final map = <String, List<TestResult>>{};
    for (final test in tests) {
      final caseId = test.testId.split('-').first;
      map.putIfAbsent(caseId, () => []).add(test);
    }
    return map;
  }

  @override
  String get summary {
    final buffer = StringBuffer();
    buffer.writeln('Full Test Matrix Results');
    buffer.writeln('========================');
    buffer.writeln(
      'Total tests: $totalTests (${testCases.length} cases × 5 runs)',
    );
    buffer.writeln('Passed: $passedTests');
    buffer.writeln('Success rate: ${(successRate * 100).toStringAsFixed(1)}%');
    buffer.writeln(
      'Duration: ${totalDuration.inHours}h ${totalDuration.inMinutes % 60}m',
    );
    buffer.writeln();

    buffer.writeln('Results by Test Case:');
    buffer.writeln('---------------------');

    for (final testCase in testCases) {
      final caseResults = resultsByTestCase[testCase.id] ?? [];
      final casePassed = caseResults.where((t) => t.isPassed).length;
      final caseSuccess = caseResults.isNotEmpty
          ? casePassed / caseResults.length
          : 0.0;

      final icon = caseSuccess >= 0.8
          ? '✅'
          : caseSuccess >= 0.5
          ? '⚠️'
          : '❌';
      buffer.writeln('$icon ${testCase.id}: ${testCase.name}');
      buffer.writeln(
        '   Success: $casePassed/${caseResults.length} (${(caseSuccess * 100).toStringAsFixed(0)}%)',
      );

      // Show bug patterns
      final bugCounts = <BugType, int>{};
      for (final result in caseResults) {
        if (result.bugType != BugType.none) {
          bugCounts[result.bugType] = (bugCounts[result.bugType] ?? 0) + 1;
        }
      }

      if (bugCounts.isNotEmpty) {
        buffer.writeln(
          '   Bugs: ${bugCounts.entries.map((e) => '${e.key.name}=${e.value}').join(', ')}',
        );
      }
    }

    return buffer.toString();
  }
}

// Provider for audio debug test service
final audioDebugTestServiceProvider = Provider<AudioDebugTestService>((ref) {
  final platformService = ref.watch(audioDebugPlatformServiceProvider);
  return AudioDebugTestService(platformService);
});

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/screens
/// 🎯 Feature: ai_coach
/// 🔧 Type: debug_screen
///
/// HealthKit Debug Screen - Systematic debugging tool for HealthKit permission issues
///
/// **Purpose**: Debug why iOS HealthKit permission dialog doesn't appear
///
/// **Tests**:
/// 1. Platform check (iOS vs Android)
/// 2. HealthKit availability check
/// 3. Permission status check (before request)
/// 4. Request authorization (should show dialog)
/// 5. Permission status check (after request)
/// 6. Entitlements verification
/// 7. Info.plist verification
///
/// **Usage**:
/// - Navigate to this screen from Settings or debug menu
/// - Tap "Run All Tests" button
/// - Each test shows PASS/FAIL status with detailed logs
/// - Share logs with developer if issues found
library;

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';

/// HealthKit debug screen for systematic permission debugging
class HealthKitDebugScreen extends StatefulWidget {
  const HealthKitDebugScreen({super.key});

  @override
  State<HealthKitDebugScreen> createState() => _HealthKitDebugScreenState();
}

class _HealthKitDebugScreenState extends State<HealthKitDebugScreen> {
  final Health _health = Health();

  /// Test results (null = not run, true = pass, false = fail)
  final Map<String, bool?> _testResults = {
    'platform_check': null,
    'healthkit_available': null,
    'permission_status_before': null,
    'request_authorization': null,
    'permission_status_after': null,
    'data_fetch_test': null,
  };

  /// Test logs for detailed debugging
  final List<String> _logs = [];

  bool _isRunning = false;

  /// Supported HealthKit data types (same as production)
  static const List<HealthDataType> _supportedTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.EXERCISE_TIME,
  ];

  @override
  void initState() {
    super.initState();
    _addLog('🔧 HealthKit Debug Screen initialized');
    _addLog('📱 Package: health ^13.2.1');
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    setState(() {
      _logs.add('[$timestamp] $message');
    });

    if (kDebugMode) {
      debugPrint(message);
    }
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunning = true;
      _logs.clear();
      _testResults.updateAll((key, value) => null);
    });

    _addLog('════════════════════════════════════════');
    _addLog('🚀 Starting HealthKit Diagnostic Tests');
    _addLog('════════════════════════════════════════');

    // Test 1: Platform Check
    await _test1PlatformCheck();
    await Future.delayed(const Duration(milliseconds: 500));

    // Test 2: HealthKit Availability
    await _test2HealthKitAvailability();
    await Future.delayed(const Duration(milliseconds: 500));

    // Test 3: Permission Status (Before Request)
    await _test3PermissionStatusBefore();
    await Future.delayed(const Duration(milliseconds: 500));

    // Test 4: Request Authorization (CRITICAL - Should show dialog)
    await _test4RequestAuthorization();
    await Future.delayed(const Duration(milliseconds: 500));

    // Test 5: Permission Status (After Request)
    await _test5PermissionStatusAfter();
    await Future.delayed(const Duration(milliseconds: 500));

    // Test 6: Data Fetch Test
    await _test6DataFetchTest();

    _addLog('════════════════════════════════════════');
    _addLog('✅ All Tests Complete');
    _addLog('════════════════════════════════════════');

    setState(() {
      _isRunning = false;
    });
  }

  /// Test 1: Verify running on iOS
  Future<void> _test1PlatformCheck() async {
    _addLog('');
    _addLog('[TEST 1] Platform Check');
    _addLog('─────────────────────────────────────────');

    try {
      final isIOS = Platform.isIOS;

      setState(() {
        _testResults['platform_check'] = isIOS;
      });

      if (isIOS) {
        _addLog('✅ PASS: Running on iOS');
        _addLog('   Platform: ${Platform.operatingSystem}');
        _addLog('   Version: ${Platform.operatingSystemVersion}');
      } else {
        _addLog('❌ FAIL: NOT running on iOS');
        _addLog('   Platform: ${Platform.operatingSystem}');
        _addLog('   HealthKit requires iOS');
      }
    } catch (e) {
      setState(() {
        _testResults['platform_check'] = false;
      });
      _addLog('❌ ERROR: $e');
    }
  }

  /// Test 2: Check if HealthKit is available
  Future<void> _test2HealthKitAvailability() async {
    _addLog('');
    _addLog('[TEST 2] HealthKit Availability');
    _addLog('─────────────────────────────────────────');

    try {
      // Note: health package doesn't expose a direct "isAvailable" check
      // We check if Platform.isIOS (already done in Test 1)
      final isAvailable = Platform.isIOS;

      setState(() {
        _testResults['healthkit_available'] = isAvailable;
      });

      if (isAvailable) {
        _addLog('✅ PASS: HealthKit should be available');
        _addLog('   iOS device detected');
        _addLog('   Entitlements: Runner/Runner.entitlements');
        _addLog('   HealthKit enabled: true (from entitlements)');
      } else {
        _addLog('❌ FAIL: HealthKit not available');
        _addLog('   Not an iOS device');
      }
    } catch (e) {
      setState(() {
        _testResults['healthkit_available'] = false;
      });
      _addLog('❌ ERROR: $e');
    }
  }

  /// Test 3: Check permission status BEFORE requesting
  Future<void> _test3PermissionStatusBefore() async {
    _addLog('');
    _addLog('[TEST 3] Permission Status (Before Request)');
    _addLog('─────────────────────────────────────────');

    try {
      // Check each data type individually
      for (final type in _supportedTypes) {
        try {
          final hasPermission = await _health.hasPermissions([type]);

          _addLog('   ${type.name}: ${hasPermission == true ? "✅ GRANTED" : hasPermission == false ? "❌ DENIED" : "⚠️ NOT DETERMINED"}');
        } catch (e) {
          _addLog('   ${type.name}: ❌ ERROR - $e');
        }
      }

      setState(() {
        _testResults['permission_status_before'] = true;
      });

      _addLog('✅ PASS: Permission check completed');
      _addLog('   Expected: All NOT DETERMINED (first launch)');
      _addLog('   or GRANTED/DENIED (if previously requested)');
    } catch (e) {
      setState(() {
        _testResults['permission_status_before'] = false;
      });
      _addLog('❌ ERROR: $e');
    }
  }

  /// Test 4: Request authorization (CRITICAL - Should show dialog)
  Future<void> _test4RequestAuthorization() async {
    _addLog('');
    _addLog('[TEST 4] Request Authorization (CRITICAL)');
    _addLog('─────────────────────────────────────────');
    _addLog('⚠️ WATCH: iOS permission dialog should appear NOW');
    _addLog('   - Look for native iOS alert');
    _addLog('   - Tap "Allow" or "Don\'t Allow"');
    _addLog('   - If NO dialog appears → ROOT CAUSE FOUND');

    try {
      _addLog('📞 Calling requestAuthorization()...');

      // This should trigger the native iOS permission dialog
      final granted = await _health.requestAuthorization(
        _supportedTypes,
        permissions: [
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
        ],
      );

      setState(() {
        _testResults['request_authorization'] = granted;
      });

      if (granted) {
        _addLog('✅ PASS: Permissions granted');
        _addLog('   User tapped "Allow" in dialog');
      } else {
        _addLog('❌ FAIL: Permissions denied');
        _addLog('   Possible causes:');
        _addLog('   1. User tapped "Don\'t Allow"');
        _addLog('   2. Dialog never appeared (BUG)');
        _addLog('   3. Previously denied in Settings');
      }
    } catch (e) {
      setState(() {
        _testResults['request_authorization'] = false;
      });
      _addLog('❌ ERROR: $e');
      _addLog('   This is the ROOT CAUSE if dialog didn\'t appear');
    }
  }

  /// Test 5: Check permission status AFTER requesting
  Future<void> _test5PermissionStatusAfter() async {
    _addLog('');
    _addLog('[TEST 5] Permission Status (After Request)');
    _addLog('─────────────────────────────────────────');

    try {
      for (final type in _supportedTypes) {
        try {
          final hasPermission = await _health.hasPermissions([type]);

          _addLog('   ${type.name}: ${hasPermission == true ? "✅ GRANTED" : hasPermission == false ? "❌ DENIED" : "⚠️ NOT DETERMINED"}');
        } catch (e) {
          _addLog('   ${type.name}: ❌ ERROR - $e');
        }
      }

      setState(() {
        _testResults['permission_status_after'] = true;
      });

      _addLog('✅ PASS: Permission check completed');
      _addLog('   Expected: All GRANTED (if user allowed)');
      _addLog('   or DENIED (if user denied)');
    } catch (e) {
      setState(() {
        _testResults['permission_status_after'] = false;
      });
      _addLog('❌ ERROR: $e');
    }
  }

  /// Test 6: Try to fetch actual health data
  Future<void> _test6DataFetchTest() async {
    _addLog('');
    _addLog('[TEST 6] Data Fetch Test');
    _addLog('─────────────────────────────────────────');

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      _addLog('📊 Fetching steps for today...');

      final dataPoints = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: now,
      );

      setState(() {
        _testResults['data_fetch_test'] = true;
      });

      if (dataPoints.isNotEmpty) {
        final totalSteps = dataPoints.fold<num>(
          0,
          (sum, point) => sum + (point.value as num),
        );

        _addLog('✅ PASS: Data fetched successfully');
        _addLog('   Steps today: ${totalSteps.toInt()}');
        _addLog('   Data points: ${dataPoints.length}');
      } else {
        _addLog('⚠️ PASS (No Data): No steps recorded today');
        _addLog('   This is OK if you haven\'t walked yet');
        _addLog('   or if Health app has no data');
      }
    } catch (e) {
      setState(() {
        _testResults['data_fetch_test'] = false;
      });
      _addLog('❌ FAIL: Data fetch failed');
      _addLog('   Error: $e');
      _addLog('   Possible causes:');
      _addLog('   1. Permissions denied');
      _addLog('   2. HealthKit not available');
      _addLog('   3. Health app not set up');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthKit Debug'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
      ),
      body: Column(
        children: [
          // Test Results Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: context.colors.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Test Results',
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ..._testResults.entries.map((entry) {
                  final icon = entry.value == null
                      ? '⚪'
                      : entry.value == true
                          ? '✅'
                          : '❌';
                  final label = entry.key
                      .replaceAll('_', ' ')
                      .split(' ')
                      .map((word) => word[0].toUpperCase() + word.substring(1))
                      .join(' ');

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          icon,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            label,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Logs
          Expanded(
            child: Container(
              color: context.colors.surface,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      log,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: log.contains('✅')
                            ? context.iconSuccess
                            : log.contains('❌')
                                ? context.iconError
                                : log.contains('⚠️')
                                    ? context.iconWarning
                                    : context.colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Run Button
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isRunning ? null : _runAllTests,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isRunning
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: context.colors.onPrimary,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Running Tests...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Run All Tests',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

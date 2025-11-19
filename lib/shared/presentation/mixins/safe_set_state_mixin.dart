/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/mixins
/// 🎯 Feature: shared (memory management)
/// 🔧 Type: mixin
///
/// SafeSetStateMixin - Prevents setState() crashes after widget disposal
///
/// **Purpose**: Wrap setState() calls to check mounted status before executing
///
/// **Problem It Solves**:
/// ```dart
/// // ❌ UNSAFE - Can crash if widget disposed after await
/// Future<void> loadData() async {
///   final data = await fetchData(); // Widget might be disposed here
///   setState(() => _data = data);   // CRASH if disposed!
/// }
/// ```
///
/// **Solution**:
/// ```dart
/// // ✅ SAFE - Checks mounted before setState
/// Future<void> loadData() async {
///   final data = await fetchData();
///   safeSetState(() => _data = data); // No crash, silently skips if disposed
/// }
/// ```
///
/// **Usage**:
/// ```dart
/// class MyWidgetState extends State<MyWidget> with SafeSetStateMixin {
///   Future<void> _asyncOperation() async {
///     final result = await someAsyncCall();
///     safeSetState(() {
///       // This is safe - won't crash if widget disposed
///       _myState = result;
///     });
///   }
/// }
/// ```
///
/// **When to Use**:
/// - Any setState() call after an await
/// - Any setState() in callbacks that might fire after disposal
/// - Any setState() in timer callbacks
/// - Any setState() in stream listeners
///
/// **Reference**: MEMORY_AUDIT_REPORT.md → Fix #7
library;

import 'package:flutter/material.dart';

/// Mixin that provides safe setState method
///
/// **Prevents**: "setState() called after dispose()" crashes
/// **How**: Checks mounted status before calling setState
mixin SafeSetStateMixin<T extends StatefulWidget> on State<T> {
  /// Safe version of setState that checks mounted status first
  ///
  /// **Usage**:
  /// ```dart
  /// safeSetState(() {
  ///   _myState = newValue;
  /// });
  /// ```
  ///
  /// **Behavior**:
  /// - If mounted: Calls setState normally
  /// - If disposed: Silently skips (no crash, no error)
  ///
  /// **Note**: This is intentionally lenient. If you need to know
  /// whether setState was called, check the return value:
  /// ```dart
  /// final didUpdate = safeSetState(() => _state = value);
  /// if (!didUpdate) {
  ///   // Widget was disposed, handle accordingly
  /// }
  /// ```
  bool safeSetState(VoidCallback fn) {
    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(fn);
      return true;
    }
    return false;
  }
}

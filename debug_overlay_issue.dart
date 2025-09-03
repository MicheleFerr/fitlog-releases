import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Debug utility to identify gray overlay issue
/// 
/// ISSUE ANALYSIS:
/// 1. DiagnosticsProperty<void> exceptions occur during timer start
/// 2. Gray semi-transparent overlay appears over entire screen
/// 3. Overlay blocks all interactions except timer controls
/// 4. Problem persists even with features disabled
///
/// ROOT CAUSE HYPOTHESIS:
/// - Flutter's ErrorWidget.builder is being triggered by diagnostic exceptions
/// - Some widget is failing during debugFillProperties()
/// - The error widget is being rendered as a full-screen modal/barrier
/// 
/// DEBUGGING STRATEGY:
/// 1. Hook into Flutter's error handling system
/// 2. Track widget tree changes during timer start
/// 3. Identify which widget triggers the overlay
/// 4. Fix the underlying cause
class OverlayIssueDebugger {
  static bool _isDebugging = false;
  static List<String> _errorLog = [];
  static Widget? _originalErrorBuilder;
  
  /// Enable debugging mode with custom error widget
  static void enableDebugging() {
    if (_isDebugging) return;
    _isDebugging = true;
    
    // Store original error builder
    _originalErrorBuilder = ErrorWidget.builder;
    
    // Replace with debugging version
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Log the error
      final errorMsg = 'ERROR WIDGET CREATED: ${details.exception}';
      print('🚨 $errorMsg');
      _errorLog.add(errorMsg);
      
      // Check if this is a DiagnosticsProperty error
      if (details.exception.toString().contains('DiagnosticsProperty')) {
        print('🎯 FOUND DIAGNOSTICS ERROR - This might be causing the overlay!');
        print('Context: ${details.context}');
        print('Library: ${details.library}');
        print('Stack: ${details.stack}');
        
        // Return a minimal error widget instead of full-screen overlay
        return Container(
          width: 100,
          height: 50,
          color: Colors.red.withOpacity(0.5),
          child: const Center(
            child: Text(
              'DEBUG ERROR',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        );
      }
      
      // For other errors, use original behavior
      if (_originalErrorBuilder != null) {
        return _originalErrorBuilder!(details);
      }
      
      return ErrorWidget(details.exception);
    };
    
    // Also hook into FlutterError.onError
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      print('🔥 FlutterError.onError triggered:');
      print('Exception: ${details.exception}');
      print('Context: ${details.context}');
      
      // Check for modal/overlay related errors
      final exceptionStr = details.exception.toString();
      if (exceptionStr.contains('Modal') || 
          exceptionStr.contains('Overlay') || 
          exceptionStr.contains('Barrier') ||
          exceptionStr.contains('DiagnosticsProperty')) {
        print('🎯 POTENTIAL OVERLAY-CAUSING ERROR DETECTED!');
        print('Full stack: ${details.stack}');
      }
      
      // Call original handler
      originalOnError?.call(details);
    };
    
    print('🔍 Overlay debugging enabled');
  }
  
  /// Disable debugging and restore original error handling
  static void disableDebugging() {
    if (!_isDebugging) return;
    
    if (_originalErrorBuilder != null) {
      ErrorWidget.builder = _originalErrorBuilder!;
    }
    
    _isDebugging = false;
    print('🔍 Overlay debugging disabled');
  }
  
  /// Get collected error logs
  static List<String> getErrorLog() => List.unmodifiable(_errorLog);
  
  /// Clear error log
  static void clearErrorLog() {
    _errorLog.clear();
  }
  
  /// Print current error summary
  static void printErrorSummary() {
    print('=== OVERLAY DEBUG SUMMARY ===');
    print('Total errors logged: ${_errorLog.length}');
    for (int i = 0; i < _errorLog.length; i++) {
      print('[$i] ${_errorLog[i]}');
    }
    print('=============================');
  }
}

/// Widget inspector helper to track widget builds during timer start
class WidgetBuildTracker extends StatelessWidget {
  final Widget child;
  final String name;
  
  const WidgetBuildTracker({
    super.key,
    required this.child,
    required this.name,
  });
  
  @override
  Widget build(BuildContext context) {
    if (OverlayIssueDebugger._isDebugging) {
      print('🏗️  Building widget: $name');
    }
    
    return child;
  }
}

/// Modal/Overlay tracker to detect when overlays are created
class OverlayTracker {
  static int _overlayCount = 0;
  static List<String> _overlayLog = [];
  
  static void logOverlayCreation(String source) {
    _overlayCount++;
    final msg = 'OVERLAY #$_overlayCount created from: $source';
    print('👻 $msg');
    _overlayLog.add(msg);
  }
  
  static void logModalCreation(String source) {
    final msg = 'MODAL created from: $source';
    print('🚪 $msg');
    _overlayLog.add(msg);
  }
  
  static List<String> getOverlayLog() => List.unmodifiable(_overlayLog);
  
  static void clearOverlayLog() {
    _overlayLog.clear();
    _overlayCount = 0;
  }
}

/// Extension on BuildContext to help debug overlay issues
extension OverlayDebugExtension on BuildContext {
  /// Check if this context has any overlays above it
  bool hasActiveOverlays() {
    final overlay = Overlay.of(this);
    return overlay.toString().contains('entries');
  }
  
  /// Log current widget tree path
  void logWidgetPath(String action) {
    if (!OverlayIssueDebugger._isDebugging) return;
    
    final elements = <String>[];
    void visitor(Element element) {
      elements.add(element.widget.runtimeType.toString());
    }
    
    visitAncestorElements((element) {
      visitor(element);
      return false;
    });
    
    print('🗺️  Widget path during $action: ${elements.join(' > ')}');
  }
}

/// Usage instructions and integration points
/// 
/// TO USE THIS DEBUGGER:
/// 
/// 1. In main.dart, add:
///    ```dart
///    if (kDebugMode) {
///      OverlayIssueDebugger.enableDebugging();
///    }
///    ```
/// 
/// 2. Wrap problematic widgets with WidgetBuildTracker:
///    ```dart
///    WidgetBuildTracker(
///      name: 'TimerBottomSheet',
///      child: TimerBottomSheet(),
///    )
///    ```
/// 
/// 3. In timer start code, add:
///    ```dart
///    context.logWidgetPath('timer_start');
///    ```
/// 
/// 4. Replace showModalBottomSheet calls with tracked version:
///    ```dart
///    OverlayTracker.logModalCreation('timer_start');
///    showModalBottomSheet(...);
///    ```
/// 
/// 5. After reproducing the issue:
///    ```dart
///    OverlayIssueDebugger.printErrorSummary();
///    ```
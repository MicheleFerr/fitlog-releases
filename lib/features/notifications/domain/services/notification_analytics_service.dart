import 'dart:async';
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';
import 'package:flutter/foundation.dart';
// Debug logging (temporarily using print statements)

/// Analytics event types for notifications
enum NotificationAnalyticsEvent {
  scheduled,
  delivered,
  displayed,
  clicked,
  dismissed,
  failed,
  cancelled,
  expired,
}

/// Analytics data point for a notification event
class NotificationAnalyticsDataPoint {
  
  NotificationAnalyticsDataPoint({
    required this.notificationId,
    required this.notificationType,
    required this.event,
    required this.timestamp,
    this.metadata,
    this.errorMessage,
  });
  final String notificationId;
  final NotificationType notificationType;
  final NotificationAnalyticsEvent event;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final String? errorMessage;
  
  Map<String, dynamic> toJson() => {
    'notificationId': notificationId,
    'notificationType': notificationType.toString(),
    'event': event.toString(),
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
    'errorMessage': errorMessage,
  };
}

/// Analytics metrics for notifications
class NotificationAnalyticsMetrics {
  
  const NotificationAnalyticsMetrics({
    this.totalScheduled = 0,
    this.totalDelivered = 0,
    this.totalClicked = 0,
    this.totalDismissed = 0,
    this.totalFailed = 0,
    this.totalCancelled = 0,
    this.deliveryRate = 0,
    this.clickRate = 0,
    this.dismissRate = 0,
    this.failureRate = 0,
    this.averageTimeToClick = Duration.zero,
    this.averageTimeToDisplay = Duration.zero,
    this.scheduledByType = const {},
    this.deliveredByType = const {},
    this.clickedByType = const {},
    this.clickRateByType = const {},
    this.scheduledByHour = const {},
    this.clickedByHour = const {},
    this.recentErrors = const [],
    this.lastUpdateTime,
  });
  final int totalScheduled;
  final int totalDelivered;
  final int totalClicked;
  final int totalDismissed;
  final int totalFailed;
  final int totalCancelled;
  
  final double deliveryRate;
  final double clickRate;
  final double dismissRate;
  final double failureRate;
  
  final Duration averageTimeToClick;
  final Duration averageTimeToDisplay;
  
  final Map<NotificationType, int> scheduledByType;
  final Map<NotificationType, int> deliveredByType;
  final Map<NotificationType, int> clickedByType;
  final Map<NotificationType, double> clickRateByType;
  
  final Map<int, int> scheduledByHour; // Hour of day distribution
  final Map<int, int> clickedByHour;
  
  final List<String> recentErrors;
  final DateTime? lastUpdateTime;
  
  Map<String, dynamic> toJson() => {
    'totalScheduled': totalScheduled,
    'totalDelivered': totalDelivered,
    'totalClicked': totalClicked,
    'totalDismissed': totalDismissed,
    'totalFailed': totalFailed,
    'totalCancelled': totalCancelled,
    'deliveryRate': deliveryRate,
    'clickRate': clickRate,
    'dismissRate': dismissRate,
    'failureRate': failureRate,
    'averageTimeToClick': averageTimeToClick.inSeconds,
    'averageTimeToDisplay': averageTimeToDisplay.inSeconds,
    'scheduledByType': scheduledByType.map((k, v) => MapEntry(k.toString(), v)),
    'deliveredByType': deliveredByType.map((k, v) => MapEntry(k.toString(), v)),
    'clickedByType': clickedByType.map((k, v) => MapEntry(k.toString(), v)),
    'clickRateByType': clickRateByType.map((k, v) => MapEntry(k.toString(), v)),
    'scheduledByHour': scheduledByHour,
    'clickedByHour': clickedByHour,
    'recentErrors': recentErrors,
    'lastUpdateTime': lastUpdateTime?.toIso8601String(),
  };
}

/// Service for tracking and analyzing notification metrics
class NotificationAnalyticsService {
  
  factory NotificationAnalyticsService() {
    _instance ??= NotificationAnalyticsService._internal();
    return _instance!;
  }
  
  NotificationAnalyticsService._internal() {
    _startPeriodicCalculation();
  }
  static NotificationAnalyticsService? _instance;
  
  // In-memory storage for analytics data
  final Queue<NotificationAnalyticsDataPoint> _dataPoints = Queue();
  final Map<String, List<NotificationAnalyticsDataPoint>> _notificationHistory = {};
  
  // Limits for memory management
  static const int _maxDataPoints = 10000;
  static const int _maxHistoryPerNotification = 20;
  static const int _maxRecentErrors = 50;
  
  // Stream controller for real-time metrics
  final StreamController<NotificationAnalyticsMetrics> _metricsStreamController = 
      StreamController<NotificationAnalyticsMetrics>.broadcast();
  
  // Periodic calculation timer
  Timer? _calculationTimer;
  
  // Cached metrics
  NotificationAnalyticsMetrics _cachedMetrics = const NotificationAnalyticsMetrics();
  DateTime? _lastCalculation;
  
  /// Stream of analytics metrics
  Stream<NotificationAnalyticsMetrics> get metricsStream => _metricsStreamController.stream;
  
  /// Current metrics snapshot
  NotificationAnalyticsMetrics get currentMetrics => _cachedMetrics;
  
  /// Track a notification event
  void trackEvent({
    required String notificationId,
    required NotificationType notificationType,
    required NotificationAnalyticsEvent event,
    Map<String, dynamic>? metadata,
    String? errorMessage,
  }) {
    final dataPoint = NotificationAnalyticsDataPoint(
      notificationId: notificationId,
      notificationType: notificationType,
      event: event,
      timestamp: DateTime.now(),
      metadata: metadata,
      errorMessage: errorMessage,
    );
    
    // Add to queue
    _dataPoints.add(dataPoint);
    
    // Maintain size limit
    while (_dataPoints.length > _maxDataPoints) {
      _dataPoints.removeFirst();
    }
    
    // Add to notification history
    _notificationHistory.putIfAbsent(notificationId, () => []);
    _notificationHistory[notificationId]!.add(dataPoint);
    
    // Maintain history size
    if (_notificationHistory[notificationId]!.length > _maxHistoryPerNotification) {
      _notificationHistory[notificationId]!.removeAt(0);
    }
    
    // Log for debugging
    if (kDebugMode) {
      debugPrint('[Analytics] ${event.name} for ${notificationType.name} notification $notificationId');
    }
    
    // Trigger metrics recalculation if significant event
    if (event == NotificationAnalyticsEvent.clicked || 
        event == NotificationAnalyticsEvent.failed) {
      _calculateMetrics();
    }
  }
  
  /// Track notification scheduled
  void trackScheduled(String id, NotificationType type, {Map<String, dynamic>? metadata}) {
    trackEvent(
      notificationId: id,
      notificationType: type,
      event: NotificationAnalyticsEvent.scheduled,
      metadata: metadata,
    );
  }
  
  /// Track notification delivered
  void trackDelivered(String id, NotificationType type) {
    trackEvent(
      notificationId: id,
      notificationType: type,
      event: NotificationAnalyticsEvent.delivered,
    );
  }
  
  /// Track notification clicked
  void trackClicked(String id, NotificationType type) {
    trackEvent(
      notificationId: id,
      notificationType: type,
      event: NotificationAnalyticsEvent.clicked,
    );
  }
  
  /// Track notification dismissed
  void trackDismissed(String id, NotificationType type) {
    trackEvent(
      notificationId: id,
      notificationType: type,
      event: NotificationAnalyticsEvent.dismissed,
    );
  }
  
  /// Track notification failed
  void trackFailed(String id, NotificationType type, String error) {
    trackEvent(
      notificationId: id,
      notificationType: type,
      event: NotificationAnalyticsEvent.failed,
      errorMessage: error,
    );
  }
  
  /// Start periodic metrics calculation
  void _startPeriodicCalculation() {
    _calculationTimer?.cancel();
    _calculationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _calculateMetrics();
    });
    
    // Initial calculation
    _calculateMetrics();
  }
  
  /// Calculate analytics metrics
  void _calculateMetrics() {
    if (_dataPoints.isEmpty) return;
    
    // Count events
    int totalScheduled = 0;
    int totalDelivered = 0;
    int totalClicked = 0;
    int totalDismissed = 0;
    int totalFailed = 0;
    int totalCancelled = 0;
    
    final Map<NotificationType, int> scheduledByType = {};
    final Map<NotificationType, int> deliveredByType = {};
    final Map<NotificationType, int> clickedByType = {};
    final Map<int, int> scheduledByHour = {};
    final Map<int, int> clickedByHour = {};
    
    final List<Duration> timesToClick = [];
    final List<Duration> timesToDisplay = [];
    final List<String> recentErrors = [];
    
    // Process all data points
    for (final point in _dataPoints) {
      switch (point.event) {
        case NotificationAnalyticsEvent.scheduled:
          totalScheduled++;
          scheduledByType[point.notificationType] = 
              (scheduledByType[point.notificationType] ?? 0) + 1;
          scheduledByHour[point.timestamp.hour] = 
              (scheduledByHour[point.timestamp.hour] ?? 0) + 1;
          break;
          
        case NotificationAnalyticsEvent.delivered:
          totalDelivered++;
          deliveredByType[point.notificationType] = 
              (deliveredByType[point.notificationType] ?? 0) + 1;
          break;
          
        case NotificationAnalyticsEvent.clicked:
          totalClicked++;
          clickedByType[point.notificationType] = 
              (clickedByType[point.notificationType] ?? 0) + 1;
          clickedByHour[point.timestamp.hour] = 
              (clickedByHour[point.timestamp.hour] ?? 0) + 1;
          
          // Calculate time to click
          final history = _notificationHistory[point.notificationId];
          if (history != null) {
            final scheduledEvent = history.firstWhere(
              (p) => p.event == NotificationAnalyticsEvent.scheduled,
              orElse: () => point,
            );
            timesToClick.add(point.timestamp.difference(scheduledEvent.timestamp));
          }
          break;
          
        case NotificationAnalyticsEvent.dismissed:
          totalDismissed++;
          break;
          
        case NotificationAnalyticsEvent.failed:
          totalFailed++;
          if (point.errorMessage != null && recentErrors.length < _maxRecentErrors) {
            recentErrors.add('${point.timestamp}: ${point.errorMessage}');
          }
          break;
          
        case NotificationAnalyticsEvent.cancelled:
          totalCancelled++;
          break;
          
        case NotificationAnalyticsEvent.displayed:
          // Calculate time to display
          final history = _notificationHistory[point.notificationId];
          if (history != null) {
            final scheduledEvent = history.firstWhere(
              (p) => p.event == NotificationAnalyticsEvent.scheduled,
              orElse: () => point,
            );
            timesToDisplay.add(point.timestamp.difference(scheduledEvent.timestamp));
          }
          break;
          
        case NotificationAnalyticsEvent.expired:
          // Handle expired notifications
          break;
      }
    }
    
    // Calculate rates
    final double deliveryRate = totalScheduled > 0 ? totalDelivered / totalScheduled : 0;
    final double clickRate = totalDelivered > 0 ? totalClicked / totalDelivered : 0;
    final double dismissRate = totalDelivered > 0 ? totalDismissed / totalDelivered : 0;
    final double failureRate = totalScheduled > 0 ? totalFailed / totalScheduled : 0;
    
    // Calculate click rates by type
    final Map<NotificationType, double> clickRateByType = {};
    for (final type in NotificationType.values) {
      final delivered = deliveredByType[type] ?? 0;
      final clicked = clickedByType[type] ?? 0;
      if (delivered > 0) {
        clickRateByType[type] = clicked / delivered;
      }
    }
    
    // Calculate average times
    Duration averageTimeToClick = Duration.zero;
    if (timesToClick.isNotEmpty) {
      final totalSeconds = timesToClick.fold<int>(
        0, 
        (sum, duration) => sum + duration.inSeconds,
      );
      averageTimeToClick = Duration(seconds: totalSeconds ~/ timesToClick.length);
    }
    
    Duration averageTimeToDisplay = Duration.zero;
    if (timesToDisplay.isNotEmpty) {
      final totalSeconds = timesToDisplay.fold<int>(
        0,
        (sum, duration) => sum + duration.inSeconds,
      );
      averageTimeToDisplay = Duration(seconds: totalSeconds ~/ timesToDisplay.length);
    }
    
    // Create metrics object
    _cachedMetrics = NotificationAnalyticsMetrics(
      totalScheduled: totalScheduled,
      totalDelivered: totalDelivered,
      totalClicked: totalClicked,
      totalDismissed: totalDismissed,
      totalFailed: totalFailed,
      totalCancelled: totalCancelled,
      deliveryRate: deliveryRate,
      clickRate: clickRate,
      dismissRate: dismissRate,
      failureRate: failureRate,
      averageTimeToClick: averageTimeToClick,
      averageTimeToDisplay: averageTimeToDisplay,
      scheduledByType: scheduledByType,
      deliveredByType: deliveredByType,
      clickedByType: clickedByType,
      clickRateByType: clickRateByType,
      scheduledByHour: scheduledByHour,
      clickedByHour: clickedByHour,
      recentErrors: recentErrors,
      lastUpdateTime: DateTime.now(),
    );
    
    _lastCalculation = DateTime.now();
    
    // Emit new metrics
    _metricsStreamController.add(_cachedMetrics);
    
    if (kDebugMode) {
      debugPrint('[Analytics] Metrics updated: ${totalScheduled}S/${totalDelivered}D/${totalClicked}C (${(clickRate * 100).toStringAsFixed(1)}% CTR)');
    }
  }
  
  /// Get notification history
  List<NotificationAnalyticsDataPoint>? getNotificationHistory(String notificationId) {
    return _notificationHistory[notificationId];
  }
  
  /// Clear all analytics data
  void clearData() {
    _dataPoints.clear();
    _notificationHistory.clear();
    _cachedMetrics = const NotificationAnalyticsMetrics();
    _metricsStreamController.add(_cachedMetrics);
    
    if (kDebugMode) {
      debugPrint('[Analytics] Data cleared');
    }
  }
  
  /// Export analytics data as JSON
  Map<String, dynamic> exportData() {
    return {
      'metrics': _cachedMetrics.toJson(),
      'dataPoints': _dataPoints.map((p) => p.toJson()).toList(),
      'exportTime': DateTime.now().toIso8601String(),
    };
  }
  
  /// Dispose the service
  void dispose() {
    _calculationTimer?.cancel();
    _metricsStreamController.close();
    _dataPoints.clear();
    _notificationHistory.clear();
  }
}

/// Provider for notification analytics service
final notificationAnalyticsServiceProvider = Provider<NotificationAnalyticsService>((ref) {
  final service = NotificationAnalyticsService();
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Provider for current analytics metrics
final notificationAnalyticsMetricsProvider = StreamProvider<NotificationAnalyticsMetrics>((ref) {
  final service = ref.watch(notificationAnalyticsServiceProvider);
  return service.metricsStream;
});
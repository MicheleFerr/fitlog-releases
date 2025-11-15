/// Result of scheduling decision for workout reminder notifications
///
/// Contains scheduling decision + timing + reasoning
/// Part of P3 habit formation (+15-20% stickiness improvement)
class ScheduleResult {
  const ScheduleResult({
    required this.shouldSchedule,
    required this.scheduledTime,
    required this.reason,
  });

  /// Whether notification should be scheduled
  final bool shouldSchedule;

  /// When the notification should be sent
  final DateTime scheduledTime;

  /// Transparent reasoning for the scheduling decision
  final String reason;
}

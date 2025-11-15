/// Decision result for whether to send workout reminder notification
///
/// Contains boolean decision + transparent reasoning
/// Part of P3 habit formation (+15-20% stickiness improvement)
class NotificationDecision {
  const NotificationDecision({
    required this.shouldNotify,
    required this.reason,
  });

  /// Whether notification should be sent
  final bool shouldNotify;

  /// Transparent reasoning for the decision (for debugging/UX)
  final String reason;
}

library;

class SubscriptionStatus {
  const SubscriptionStatus({
    required this.isActive,
    this.expirationDate,
    this.willRenew = false,
    this.isLifetime = false,
    this.managementUrl,
    this.productId,
  });

  factory SubscriptionStatus.free() => const SubscriptionStatus(isActive: false);

  final bool isActive;
  final DateTime? expirationDate;
  final bool willRenew;
  final bool isLifetime;
  final String? managementUrl;
  final String? productId;

  bool get isExpired =>
      !isActive &&
      expirationDate != null &&
      expirationDate!.isBefore(DateTime.now());
}

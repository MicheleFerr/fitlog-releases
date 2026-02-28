/// AI Coach daily quota snapshot returned by backend.
library;

class AIQuota {
  const AIQuota({
    required this.accountTier,
    required this.usedToday,
    required this.limitPerDay,
    required this.remainingToday,
  });

  final String accountTier;
  final int usedToday;
  final int limitPerDay;
  final int remainingToday;

  bool get isExhausted => remainingToday <= 0;
}

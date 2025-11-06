/// Purpose for buddy matching
enum MatchingPurpose {
  workoutPartner,
  gymBuddy,
  both,
  openToEverything;

  String get displayName {
    switch (this) {
      case MatchingPurpose.workoutPartner:
        return 'Workout Partner';
      case MatchingPurpose.gymBuddy:
        return 'Gym Buddy';
      case MatchingPurpose.both:
        return 'Entrambi';
      case MatchingPurpose.openToEverything:
        return 'Aperto a tutto';
    }
  }

  String get emoji {
    switch (this) {
      case MatchingPurpose.workoutPartner:
        return '💪';
      case MatchingPurpose.gymBuddy:
        return '🤝';
      case MatchingPurpose.both:
        return '💪🤝';
      case MatchingPurpose.openToEverything:
        return '❤️';
    }
  }
}

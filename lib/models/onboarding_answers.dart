class OnboardingAnswers {
  final String eventType;
  final String? eventTypeId;
  final String? locationId;
  final int guestCount;
  final double budget;
  final List<String> selectedNeedsIds;

  const OnboardingAnswers({
    this.eventType = '',
    this.eventTypeId,
    this.locationId,
    this.guestCount = 0,
    this.budget = 0,
    this.selectedNeedsIds = const [],
  });
}

class OnboardingSession {
  static OnboardingAnswers? current;
}

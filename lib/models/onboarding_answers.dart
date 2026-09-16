/// The answers collected across the 5 onboarding questions
/// ([onboardingQuestions] in questions_model.dart), threaded from the
/// question flow (see startOnboardingFlow in question_screen.dart) through
/// to [RecommendedPlanScreen].
///
/// Only the fields needed so far (event_type, guests_count, budget, needs)
/// are here. Defaults are sensible placeholders for entry points that
/// don't go through the onboarding flow (e.g. the bottom nav bar returning
/// to the home screen from another tab).
class OnboardingAnswers {
  // The selected option's Arabic title from the first question (event_type
  // — e.g. "عزيمة"، "زفاف"، "تخرج"، "أعياد"), not its id. There's no field
  // yet for the user to name their event themselves, so this doubles as
  // the default name shown for a plan saved to favorites.
  final String eventType;
  final int guestCount;
  final double budget;
  final List<String> selectedNeedsIds;

  const OnboardingAnswers({
    this.eventType = '',
    this.guestCount = 0,
    this.budget = 0,
    this.selectedNeedsIds = const [],
  });
}

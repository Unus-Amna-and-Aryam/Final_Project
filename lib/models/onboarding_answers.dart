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
  // The event_type/location questions' option ids (question.id == 'wedding'/
  // 'indoor'/etc, not the display title) — kept alongside [eventType] only
  // so pushNeedsQuestion (question_screen.dart) can rebuild question 5's
  // category list (bride/venues are conditional on these) when the user
  // comes back to revise their needs from RecommendedPlanScreen, without
  // re-asking questions 1-2.
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

/// Holds the most recently seen real [OnboardingAnswers] app-wide, so the
/// home tab can be rebuilt with the same answers it already had instead of
/// falling back to empty `OnboardingAnswers()` defaults.
///
/// There's no state-management library in this project (see the note in
/// question_screen.dart's startOnboardingFlow), and AppBottomNavBar's 3
/// tabs (RecommendedPlanScreen/FavoritesScreen/ProfileScreen) are separate
/// top-level routes swapped in with `Navigator.pushReplacement` — neither
/// FavoritesScreen nor ProfileScreen is ever given real onboarding answers
/// directly, so without this, switching away from the home tab and back
/// destroyed RecommendedPlanScreen (along with the answers passed to its
/// constructor) and rebuilt it from scratch with placeholder defaults,
/// losing every selected need and recommendation.
///
/// [current] is set from RecommendedPlanScreen's initState every time it's
/// built (including right after onboarding finishes), and read by
/// FavoritesScreen/ProfileScreen's bottom-nav handler when it needs to
/// rebuild the home tab.
class OnboardingSession {
  static OnboardingAnswers? current;
}

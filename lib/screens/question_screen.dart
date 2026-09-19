import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/models/onboarding_answers.dart';
import 'package:final_project/models/questions_model.dart';
import 'package:final_project/screens/create_acount_screen.dart';
import 'package:final_project/screens/recommended_plan_screen.dart';

/// Pushes the onboarding question flow starting at the first question in
/// [onboardingQuestions]. Each question advances to the next on "التالي";
/// after the last one, it hands off to [RecommendedPlanScreen] with the
/// collected [OnboardingAnswers].
void startOnboardingFlow(BuildContext context) {
  _pushQuestion(context, 0, answers: const OnboardingAnswers());
}

// There's no state-management library (Provider/Riverpod/Bloc/etc.) or
// shared/persisted answer store anywhere in this flow — every QuestionScreen
// only knows its own selections, and they're discarded once "التالي" moves
// to the next screen. So earlier answers that later questions need are
// threaded through this same recursive push chain as plain parameters, just
// like [index] already is, rather than introducing a state-management
// pattern for a couple of values.
void _pushQuestion(
  BuildContext context,
  int index, {
  String? eventTypeId,
  String? locationId,
  required OnboardingAnswers answers,
}) {
  var question = onboardingQuestions[index];

  // Question 5 ("needs"): two categories are conditional on earlier
  // answers — "العروس" only for a "زفاف" (wedding) event (question 1), and
  // "قاعات واستراحات" only when the event is "خارج المنزل" (question 2,
  // id 'outdoor'), since there's no venue to book for an indoor one. Both
  // conditions are independent and compose on the same categories list.
  // Excluded categories are still the same QuestionCategory/
  // _buildExpandableList used for every other category, so whichever ones
  // remain automatically match their exact style and the accordion list
  // (not a grid) just renders however many are left — nothing to
  // recalculate.
  if (question.id == 'needs') {
    question = _needsQuestion(eventTypeId: eventTypeId, locationId: locationId);
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => QuestionScreen(
        question: question,
        onNext: (selectedIds) {
          final nextIndex = index + 1;
          // Each of these only updates from its own question; every other
          // question just passes the existing value through unchanged.
          final nextEventTypeId = question.id == 'event_type'
              ? (selectedIds.isNotEmpty ? selectedIds.first : eventTypeId)
              : eventTypeId;
          final nextLocationId = question.id == 'location'
              ? (selectedIds.isNotEmpty ? selectedIds.first : locationId)
              : locationId;
          // The option's Arabic title (not its id) — see
          // OnboardingAnswers.eventType.
          final nextEventType = question.id == 'event_type' && selectedIds.isNotEmpty
              ? question.options
                  .firstWhere((option) => option.id == selectedIds.first)
                  .title
              : answers.eventType;
          final nextAnswers = OnboardingAnswers(
            eventType: nextEventType,
            eventTypeId: nextEventTypeId,
            locationId: nextLocationId,
            guestCount: question.id == 'guests_count' && selectedIds.isNotEmpty
                ? int.parse(selectedIds.first)
                : answers.guestCount,
            budget: question.id == 'budget' && selectedIds.isNotEmpty
                ? double.parse(selectedIds.first)
                : answers.budget,
            selectedNeedsIds:
                question.id == 'needs' ? selectedIds : answers.selectedNeedsIds,
          );
          if (nextIndex < onboardingQuestions.length) {
            _pushQuestion(
              context,
              nextIndex,
              eventTypeId: nextEventTypeId,
              locationId: nextLocationId,
              answers: nextAnswers,
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    RecommendedPlanScreen(answers: nextAnswers),
              ),
            );
          }
        },
      ),
    ),
  );
}

// Question 5 ("needs") with its "العروس" and "قاعات واستراحات" categories
// filtered per [_pushQuestion]'s comment above — shared with
// [pushNeedsQuestion] so re-opening this question later applies the exact
// same exclusions as reaching it the first time through the flow.
QuestionModel _needsQuestion({String? eventTypeId, String? locationId}) {
  final question = onboardingQuestions.last; // id == 'needs'
  final excludedCategoryIds = <String>{
    if (eventTypeId != 'wedding') 'bride',
    if (locationId == 'indoor') 'venues',
  };
  if (excludedCategoryIds.isEmpty) return question;
  return QuestionModel(
    id: question.id,
    step: question.step,
    totalSteps: question.totalSteps,
    title: question.title,
    options: question.options,
    allowMultiSelect: question.allowMultiSelect,
    layout: question.layout,
    sliderSteps: question.sliderSteps,
    sliderUnitLabel: question.sliderUnitLabel,
    sliderQuickPicks: question.sliderQuickPicks,
    categories: question.categories
        ?.where((category) => !excludedCategoryIds.contains(category.id))
        .toList(),
  );
}

/// Re-opens question 5 ("needs") pre-filled with [answers]'s current
/// selections, so RecommendedPlanScreen's header back button can send the
/// user to revise their needs. A plain Navigator.pop() can't reach it: once
/// onboarding first finishes, [_pushQuestion] hands off to
/// RecommendedPlanScreen with `pushReplacement`, which drops question 5's
/// own route from the stack — there's nothing left there to pop back to.
void pushNeedsQuestion(BuildContext context, OnboardingAnswers answers) {
  _pushRevisedQuestion(context, onboardingQuestions.length - 1, answers);
}

// Re-opens onboardingQuestions[index] pre-filled with [answers]'s current
// value for that question — this is the "revise an earlier answer" detour
// off the needs page (reached via [pushNeedsQuestion]), not the original
// onboarding flow ([_pushQuestion]/[startOnboardingFlow]), which already
// gets correct back-arrow behavior for free from the Navigator stack it
// builds. Its own back arrow steps to index-1 (or opens CreatAcountScreen
// before index 0, i.e. "تسجيل الدخول"); proceeding forward pops this
// route off and swaps whatever question is beneath it (index-1's own
// pushed copy, or nothing on the very first step) for a fresh one built
// from the just-revised answer — so repeatedly stepping back and forward
// through this detour never piles up stale routes.
void _pushRevisedQuestion(
  BuildContext context,
  int index,
  OnboardingAnswers answers, {
  bool replace = false,
}) {
  final isLast = index == onboardingQuestions.length - 1;
  final question = isLast
      ? _needsQuestion(
          eventTypeId: answers.eventTypeId,
          locationId: answers.locationId,
        )
      : onboardingQuestions[index];

  final initialSelectedIds = switch (question.id) {
    'event_type' =>
      answers.eventTypeId != null ? {answers.eventTypeId!} : <String>{},
    'location' =>
      answers.locationId != null ? {answers.locationId!} : <String>{},
    'guests_count' => {answers.guestCount.toString()},
    'budget' => {answers.budget.toInt().toString()},
    'needs' => answers.selectedNeedsIds.toSet(),
    _ => <String>{},
  };

  final route = MaterialPageRoute(
    builder: (context) => QuestionScreen(
      question: question,
      initialSelectedIds: initialSelectedIds,
      onBack: index == 0
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreatAcountScreen(),
                ),
              )
          : () => _pushRevisedQuestion(context, index - 1, answers),
      onNext: (selectedIds) {
        final updatedAnswers = _applyAnswer(question, selectedIds, answers);
        if (isLast) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  RecommendedPlanScreen(answers: updatedAnswers),
            ),
          );
        } else {
          Navigator.of(context).pop();
          _pushRevisedQuestion(context, index + 1, updatedAnswers, replace: true);
        }
      },
    ),
  );
  if (replace) {
    Navigator.of(context).pushReplacement(route);
  } else {
    Navigator.of(context).push(route);
  }
}

// [question]'s selection folded into [answers] — the same per-question
// update logic [_pushQuestion] inlines for the original forward flow,
// factored out here since [_pushRevisedQuestion] needs it at every step
// rather than just once.
OnboardingAnswers _applyAnswer(
  QuestionModel question,
  List<String> selectedIds,
  OnboardingAnswers answers,
) {
  switch (question.id) {
    case 'event_type':
      final nextEventTypeId =
          selectedIds.isNotEmpty ? selectedIds.first : answers.eventTypeId;
      final nextEventType = selectedIds.isNotEmpty
          ? question.options
              .firstWhere((option) => option.id == selectedIds.first)
              .title
          : answers.eventType;
      return OnboardingAnswers(
        eventType: nextEventType,
        eventTypeId: nextEventTypeId,
        locationId: answers.locationId,
        guestCount: answers.guestCount,
        budget: answers.budget,
        selectedNeedsIds: answers.selectedNeedsIds,
      );
    case 'location':
      return OnboardingAnswers(
        eventType: answers.eventType,
        eventTypeId: answers.eventTypeId,
        locationId:
            selectedIds.isNotEmpty ? selectedIds.first : answers.locationId,
        guestCount: answers.guestCount,
        budget: answers.budget,
        selectedNeedsIds: answers.selectedNeedsIds,
      );
    case 'guests_count':
      return OnboardingAnswers(
        eventType: answers.eventType,
        eventTypeId: answers.eventTypeId,
        locationId: answers.locationId,
        guestCount: int.parse(selectedIds.first),
        budget: answers.budget,
        selectedNeedsIds: answers.selectedNeedsIds,
      );
    case 'budget':
      return OnboardingAnswers(
        eventType: answers.eventType,
        eventTypeId: answers.eventTypeId,
        locationId: answers.locationId,
        guestCount: answers.guestCount,
        budget: double.parse(selectedIds.first),
        selectedNeedsIds: answers.selectedNeedsIds,
      );
    default: // 'needs'
      return OnboardingAnswers(
        eventType: answers.eventType,
        eventTypeId: answers.eventTypeId,
        locationId: answers.locationId,
        guestCount: answers.guestCount,
        budget: answers.budget,
        selectedNeedsIds: selectedIds,
      );
  }
}

/// One onboarding question page: progress header, a grid/list/wrap of
/// selectable option cards (driven by [QuestionModel.layout]), and a
/// pinned "التالي" button. Reusable across all onboarding questions.
class QuestionScreen extends StatefulWidget {
  final QuestionModel question;
  final void Function(List<String> selectedIds) onNext;
  // Overrides the options'/categories' own isDefaultSelected flags — used by
  // pushNeedsQuestion to reopen this question with the answers it already
  // collected, instead of always starting from the question's own defaults.
  final Set<String>? initialSelectedIds;
  // Overrides the back arrow's default Navigator.maybePop() — used by the
  // needs page (see _pushNeedsQuestionScreen) to revise the budget instead
  // of just popping back to wherever this screen happened to be pushed
  // from.
  final VoidCallback? onBack;

  const QuestionScreen({
    super.key,
    required this.question,
    required this.onNext,
    this.initialSelectedIds,
    this.onBack,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late Set<String> _selectedIds;
  // Index into question.sliderSteps; only meaningful when layout is slider.
  int _sliderIndex = 0;
  // Which category ids are currently expanded; only meaningful when layout
  // is expandableMultiSelect. Purely visual — never affects _selectedIds.
  final Set<String> _expandedCategoryIds = {};

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSelectedIds;
    if (widget.question.layout == QuestionLayout.slider) {
      final steps = widget.question.sliderSteps!;
      _sliderIndex = initial != null && initial.isNotEmpty
          ? steps.indexOf(int.parse(initial.first)).clamp(0, steps.length - 1)
          : 0;
      _selectedIds = {steps[_sliderIndex].toString()};
    } else if (initial != null) {
      _selectedIds = Set.of(initial);
    } else if (widget.question.layout == QuestionLayout.expandableMultiSelect) {
      _selectedIds = widget.question.categories!
          .expand((category) => category.items)
          .where((item) => item.isDefaultSelected)
          .map((item) => item.id)
          .toSet();
    } else {
      _selectedIds = widget.question.options
          .where((option) => option.isDefaultSelected)
          .map((option) => option.id)
          .toSet();
    }
  }

  void _setSliderIndex(int index) {
    final steps = widget.question.sliderSteps!;
    setState(() {
      _sliderIndex = index;
      _selectedIds = {steps[_sliderIndex].toString()};
    });
  }

  void _toggle(String id) {
    setState(() {
      if (widget.question.allowMultiSelect) {
        if (_selectedIds.contains(id)) {
          _selectedIds.remove(id);
        } else {
          _selectedIds.add(id);
        }
      } else {
        _selectedIds = {id};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.Beige,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const BackButtonIcon(),
                            color: AppColors.Burgundy,
                            onPressed: widget.onBack ??
                                () => Navigator.of(context).maybePop(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'خطوة ${question.step} من ${question.totalSteps}',
                      style: GoogleFonts.amiri(
                        fontSize: 13,
                        color: AppColors.Burgundy_White,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(question.totalSteps, (i) {
                        final isActive = i == question.step - 1;
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(
                              left: i == question.totalSteps - 1 ? 0 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.Gold
                                  : AppColors.Burgundy.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      question.title,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.amiri(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.Burgundy,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Expanded(
                // The stretch-overscroll indicator is disabled app-wide in
                // main.dart's MaterialApp.scrollBehavior — see the note
                // there for why (this "needs" list is what surfaced it).
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildOptions(question),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _selectedIds.isEmpty
                        ? null
                        : () => widget.onNext(_selectedIds.toList()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.Burgundy,
                      disabledBackgroundColor: AppColors.Burgundy.withValues(
                        alpha: 0.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'التالي',
                          style: GoogleFonts.amiri(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: AppColors.white, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptions(QuestionModel question) {
    switch (question.layout) {
      case QuestionLayout.grid2:
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.95,
          children: question.options
              .map((option) => _OptionCard(
                    option: option,
                    isSelected: _selectedIds.contains(option.id),
                    onTap: () => _toggle(option.id),
                  ))
              .toList(),
        );
      case QuestionLayout.singleColumn:
        return Column(
          children: question.options
              .map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: SizedBox(
                    width: double.infinity,
                    child: _OptionCard(
                      option: option,
                      isSelected: _selectedIds.contains(option.id),
                      onTap: () => _toggle(option.id),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      case QuestionLayout.wrap:
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: question.options
              .map(
                (option) => SizedBox(
                  width: 150,
                  child: _OptionCard(
                    option: option,
                    isSelected: _selectedIds.contains(option.id),
                    onTap: () => _toggle(option.id),
                  ),
                ),
              )
              .toList(),
        );
      case QuestionLayout.slider:
        return _buildSlider(question);
      case QuestionLayout.expandableMultiSelect:
        return _buildExpandableList(question);
    }
  }

  Widget _buildExpandableList(QuestionModel question) {
    return Column(
      children: question.categories!.map((category) {
        final isExpanded = _expandedCategoryIds.contains(category.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              // Always Burgundy, collapsed or expanded — not conditional on
              // isExpanded, so it never changes shade or disappears.
              border: Border.all(color: AppColors.Burgundy, width: 1.2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedCategoryIds.remove(category.id);
                      } else {
                        _expandedCategoryIds.add(category.id);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 22,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.title,
                          style: GoogleFonts.amiri(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppColors.Burgundy,
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.Burgundy,
                        ),
                      ],
                    ),
                  ),
                ),
               if (isExpanded)
                  // A plain Column, not a nested scrollable ListView — this
                  // used to be capped at a 160px ConstrainedBox with its own
                  // ListView so a long category scrolled independently, but
                  // that nested vertical scrollable fought the outer
                  // SingleChildScrollView (_buildOptions's caller) over the
                  // drag gesture. On Android that showed up as a stretch/
                  // overscroll glitch right at the scroll boundary whenever
                  // the last category was expanded and long. Letting the
                  // outer scroll view handle the whole page — including
                  // every expanded category, however long — removes the
                  // conflict entirely.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                    child: Column(
                      children: category.items.map((item) {
                        final isSelected = _selectedIds.contains(item.id);
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: GestureDetector(
                            onTap: () => _toggle(item.id),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  size: 22,
                                  color: isSelected
                                      ? AppColors.Gold
                                      : Colors.grey.shade300,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  item.title,
                                  style: GoogleFonts.amiri(
                                    fontSize: 20,
                                    color: AppColors.Burgundy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlider(QuestionModel question) {
    final steps = question.sliderSteps!;
    final unit = question.sliderUnitLabel ?? '';
    final currentValue = steps[_sliderIndex];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Text(
                '$currentValue',
                style: GoogleFonts.amiri(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.Burgundy,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  unit,
                  style: GoogleFonts.amiri(
                    fontSize: 14,
                    color: AppColors.Burgundy_White,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.Gold,
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: AppColors.Gold,
                  overlayColor: AppColors.Gold.withValues(alpha: 0.2),
                  trackHeight: 4,
                ),
                child: Slider(
                  // The slider only ever operates on the step index, so it
                  // always snaps to one of [steps] and never a value
                  // in-between — divisions = steps.length - 1 makes each
                  // step its own stop regardless of the numeric gaps
                  // between them (e.g. 10→50 vs 50→100).
                  value: _sliderIndex.toDouble(),
                  min: 0,
                  max: (steps.length - 1).toDouble(),
                  divisions: steps.length - 1,
                  onChanged: (value) => _setSliderIndex(value.round()),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${steps.first}',
                    style: GoogleFonts.amiri(
                      fontSize: 12,
                      color: AppColors.Burgundy_White,
                    ),
                  ),
                  Text(
                    '${steps.last}',
                    style: GoogleFonts.amiri(
                      fontSize: 12,
                      color: AppColors.Burgundy_White,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (question.sliderQuickPicks != null) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: question.sliderQuickPicks!.map((pick) {
              final index = steps.indexOf(pick);
              final isActive = index == _sliderIndex;
              final label =
                  '$pick${unit.isNotEmpty ? ' $unit' : ''}${pick == steps.last ? '+' : ''}';
              return GestureDetector(
                onTap: index == -1 ? null : () => _setSliderIndex(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.Burgundy : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? AppColors.Burgundy
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.amiri(
                      fontSize: 13,
                      color: isActive ? AppColors.white : AppColors.Burgundy,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final QuestionOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  // No icon/iconImagePath ever shown — just centered, larger title (+
  // subtitle when the question has one), with a faint full-card logo
  // watermark that only appears once selected. Applies to every card using
  // this widget (currently questions 1 and 2).
  @override
  Widget build(BuildContext context) {
    final foreground = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            option.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.white : AppColors.Burgundy,
            ),
          ),
          if (option.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              option.subtitle!,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 16,
                color: isSelected
                    ? AppColors.white
                    : AppColors.Burgundy_White,
              ),
            ),
          ],
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.Burgundy : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: Colors.grey.shade200),
        ),
        child: isSelected
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.2,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Positioned.fill (not a bare Stack child) so this gets
                    // the exact same tight full-card constraints as the
                    // unselected path below — otherwise it shrink-wraps to
                    // the text width and Stack's default alignment anchors
                    // it to the RTL "start" (right) edge instead of center.
                    Positioned.fill(child: foreground),
                  ],
                ),
              )
            : foreground,
      ),
    );
  }
}
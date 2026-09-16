import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/models/onboarding_answers.dart';
import 'package:final_project/models/providers_model.dart';
import 'package:final_project/screens/favorites_screen.dart';
import 'package:final_project/screens/profile_screen.dart';
import 'package:final_project/screens/provider_detail_screen.dart';
import 'package:final_project/service/favorites_database_service.dart';
import 'package:final_project/service/providers_database_service.dart';
import 'package:final_project/widgets/app_bottom_nav_bar.dart';

/// Matches a needs-question sub-item id (see [QuestionSubItem] ids in
/// questions_model.dart) to the provider row(s) it corresponds to in the
/// `providers` table. [subCategory] is null for needs that cover a whole
/// provider category (e.g. the merged "venues_combined" item) — every
/// provider in [category] matches regardless of its sub-category.
///
/// Values here are the actual strings stored in the database (checked
/// directly against the `providers` table), not the question's own
/// wording — a few differ: several drop the hamza the question text uses
/// ("او" vs "أو", "ارقام" vs "أرقام"), and "hospitality_sweets" ("أصناف
/// الحلا") is stored under sub_category "الحالي", which reads like a
/// data-entry typo for "الحلا" but is what's actually there.
class _NeedProviderMatch {
  final String category;
  final String? subCategory;

  const _NeedProviderMatch(this.category, [this.subCategory]);
}

const Map<String, _NeedProviderMatch> _needIdToProviderMatch = {
  'venues_combined': _NeedProviderMatch('قاعات واستراحات'),
  'catering_kitchens': _NeedProviderMatch('مأكولات', 'مطابخ'),
  'catering_buffet': _NeedProviderMatch('مأكولات', 'بوفيه'),
  'decor_stands': _NeedProviderMatch('الديكور والتنسيق', 'ستاندات او مجسمات'),
  'decor_furniture': _NeedProviderMatch('الديكور والتنسيق', 'طاولات ومقاعد'),
  'decor_numbers': _NeedProviderMatch('الديكور والتنسيق', 'ارقام للتنسيق الخاص'),
  'decor_flowers': _NeedProviderMatch('الديكور والتنسيق', 'زهور'),
  'hospitality_cake': _NeedProviderMatch('الضيافة', 'كيكات'),
  'hospitality_sweets': _NeedProviderMatch('الضيافة', 'الحالي'),
  'hospitality_savory': _NeedProviderMatch('الضيافة', 'المالح'),
  'hospitality_favors': _NeedProviderMatch('الضيافة', 'توزيعات'),
  'photography_male': _NeedProviderMatch('التصوير', 'مصور'),
  'photography_female': _NeedProviderMatch('التصوير', 'مصورة'),
  'bride_salons': _NeedProviderMatch('العروس', 'الصالونات'),
  'bride_assistant': _NeedProviderMatch('العروس', 'الوصيفة'),
};

// Which of the needs-question's 6 categories (see [QuestionCategory] ids in
// questions_model.dart) each need sub-item id belongs to. Used to tell,
// from widget.answers.selectedNeedsIds alone, which whole categories the
// user has any need selected in — for the budget-split estimate below.
const Map<String, String> _needIdToCategoryGroup = {
  'venues_combined': 'venues',
  'catering_kitchens': 'catering',
  'catering_buffet': 'catering',
  'decor_stands': 'decor',
  'decor_furniture': 'decor',
  'decor_numbers': 'decor',
  'decor_flowers': 'decor',
  'hospitality_cake': 'hospitality',
  'hospitality_sweets': 'hospitality',
  'hospitality_savory': 'hospitality',
  'hospitality_favors': 'hospitality',
  'photography_male': 'photography',
  'photography_female': 'photography',
  'bride_salons': 'bride',
  'bride_assistant': 'bride',
};

// Default share of the budget each category is assumed to take, before
// normalizing to just the categories the user actually selected needs in.
// Used only as a fallback price for a recommendation card (see
// _RecommendedPlanScreenState._normalizedShareFraction) when the candidate
// currently shown in that card has no real price of its own.
const Map<String, double> _needCategoryDefaultShares = {
  'venues': 0.35,
  'catering': 0.20,
  'decor': 0.15,
  'hospitality': 0.10,
  'photography': 0.10,
  'bride': 0.10,
};

/// All providers matching one selected needs-category (see
/// [_needIdToCategoryGroup]), backing a single recommendation card —
/// [candidates] is never empty; the card shows [candidates].first and lets
/// "البديل" cycle through the rest. [group] is the needs-category id (a key
/// of [_needCategoryDefaultShares]) this card was built for, used to work
/// out that card's fallback price when its displayed candidate has none.
class _CategoryRecommendation {
  final String group;
  final List<Providers> candidates;

  const _CategoryRecommendation(this.group, this.candidates);
}

/// The recommended-plan / home screen shown after onboarding: a budget
/// summary card, a list of recommended services, and a favorite-plan
/// button, with the app's bottom nav bar underneath.
class RecommendedPlanScreen extends StatefulWidget {
  final OnboardingAnswers answers;

  const RecommendedPlanScreen({super.key, required this.answers});

  @override
  State<RecommendedPlanScreen> createState() => _RecommendedPlanScreenState();
}

class _RecommendedPlanScreenState extends State<RecommendedPlanScreen> {
  // The price currently shown on each recommendation card, keyed by that
  // card's index — the *only* source of "المصروف" (see [_spent] below).
  // Seeded with every card's initial displayed price
  // (_ServiceCard.onDisplayedPriceChanged, fired right after each card
  // first builds) as soon as recommendations are built from real provider
  // data, then updated only when a card's "البديل" changes which price it
  // shows. There is deliberately no other way to compute a total spend —
  // this map's values are exactly what's printed on the cards on screen.
  Map<int, num> _displayedCardPrices = {};

  // "المصروف": always exactly the sum of what's currently printed on the
  // recommendation cards below, per [_displayedCardPrices]. Zero while
  // provider data hasn't loaded yet (and so no cards are shown), matching
  // the "nothing spent because nothing recommended yet" state on screen.
  double get _spent => _displayedCardPrices.values
      .fold<double>(0, (sum, price) => sum + price);

  double get _budget => widget.answers.budget;
  int get _guestCount => widget.answers.guestCount;

  // _spent can legitimately exceed _budget (e.g. real provider prices for
  // the selected needs cost more than planned) — that's exactly what
  // [_needsExceedBudget] warns about, and "المتبقي" is left unclamped so
  // it can go negative and show the real overrun. But a progress bar can
  // only ever paint a fraction between 0 and 1 — Flutter widgets that take
  // a 0-1 value don't tolerate an out-of-range one — so the ratio actually
  // handed to the widget is clamped separately here. Also guards against
  // dividing by a zero budget (e.g. this screen's placeholder
  // OnboardingAnswers()), which would otherwise produce NaN.
  double get _spentRatio =>
      _budget > 0 ? (_spent / _budget).clamp(0.0, 1.0) : 0.0;

  // Rough minimum reasonable cost per guest (in SAR) — used only to flag an
  // unrealistic budget-to-guest-count ratio below, not as an actual
  // per-guest price estimate. Adjustable later.
  static const double _minReasonableCostPerGuest = 150;

  // True when the budget doesn't even cover _minReasonableCostPerGuest per
  // guest — i.e. too many guests for the budget chosen (or too small a
  // budget for the guest count chosen).
  bool get _guestCountMismatch =>
      (_budget / _guestCount) < _minReasonableCostPerGuest;

  // True when the actual cost shown across the recommendation cards
  // ([_spent]) overshoots the budget by 20% or more. A plain
  // "_spent > _budget" would fire on any smaller overrun too, but that's
  // the same underlying idea with a much more sensitive threshold, so
  // rather than show two overlapping "your budget is off" messages, only
  // this more specific, higher-confidence one is surfaced.
  bool get _needsExceedBudget => _spent > _budget * 1.2;

  // The plan-mismatch messages that currently apply, in display order —
  // empty when the plan looks fine. Backs the alert block in
  // [_buildBudgetCard]: one Divider is shown once above all of them, and
  // each message gets its own icon + text row.
  //
  // [_guestCountMismatch] and [_needsExceedBudget] now share one unified
  // message text, so rather than potentially list the exact same sentence
  // twice when both are true, it's shown once for either (or both).
  List<String> get _planMismatchMessages => [
        if (_guestCountMismatch || _needsExceedBudget)
          'عدد الضيوف أو الميزانية غير مناسبين',
      ];

  late final Future<List<Providers>> _providersFuture;

  @override
  void initState() {
    super.initState();
    _providersFuture = ProvidersDatabaseService().getAllProviders();
    // Record these as the app's current real onboarding answers, so
    // switching to another bottom-nav tab and back rebuilds this screen
    // with the same answers instead of empty defaults — see
    // [OnboardingSession].
    OnboardingSession.current = widget.answers;
  }

  // [group]'s share of [_needCategoryDefaultShares], normalized against
  // just [selectedGroups] (every group with a card on screen) — i.e. what
  // fraction of the budget a recommendation card for [group] should show
  // as its price when its currently displayed candidate has no real price
  // of its own. Used only to seed that one card's fallback price; never
  // summed independently of the cards (see [_spent]).
  double _normalizedShareFraction(String group, Set<String> selectedGroups) {
    final selectedSharesSum = selectedGroups.fold<double>(
      0,
      (sum, g) => sum + (_needCategoryDefaultShares[g] ?? 0),
    );
    if (selectedSharesSum <= 0) return 0;
    return (_needCategoryDefaultShares[group] ?? 0) / selectedSharesSum;
  }

  void _handleNavTap(BottomNavItem item) {
    if (item == BottomNavItem.home) return; // already here
    final screen = item == BottomNavItem.profile
        ? const ProfileScreen()
        : const FavoritesScreen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _budget - _spent;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.Beige,
        // SafeArea's top inset has been observed to briefly report 0 right
        // after popping back from a pushed screen (a known MediaQuery
        // timing quirk on some Android setups), which shifted this whole
        // page's content up under the status bar. Reading the inset
        // directly and clamping it to a sane minimum avoids that, while
        // still respecting the real inset on a normal/first load.
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              math.max(MediaQuery.paddingOf(context).top, 24) + 12,
              20,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 18),
                _buildTagline(),
                const SizedBox(height: 20),
                _buildBudgetCard(remaining),
                const SizedBox(height: 24),
                _buildServicesSection(context),
                const SizedBox(height: 8),
                _buildFavoriteButton(context),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          selected: BottomNavItem.home,
          onItemSelected: _handleNavTap,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _CircleIconButton(
              icon: Icons.arrow_forward_ios,
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          Text(
            'أُنس',
            style: GoogleFonts.amiri(
              color: AppColors.Burgundy,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _AiBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildTagline() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.Gold.withOpacity(0.6)),
        ),
        child: Text(
          'عبارة تلخص خطتك',
          style: GoogleFonts.amiri(
            color: AppColors.Burgundy,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(double remaining) {
    final labelStyle = GoogleFonts.amiri(
      color: AppColors.Beige,
      fontSize: 15,
    );
    final valueStyle = GoogleFonts.amiri(
      color: AppColors.Gold,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.Burgundy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // "الميزانية" leads (reads first, on the right in RTL) and
          // "المصروف منها" trails (left) — same order in both rows so the
          // amounts land directly under their own label.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الميزانية', style: labelStyle),
              Text('المصروف منها', style: labelStyle),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_formatAmount(_budget)} ريال', style: valueStyle),
              Text('${_formatAmount(_spent)} ريال', style: valueStyle),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _spentRatio,
              minHeight: 8,
              color: AppColors.Gold,
              backgroundColor: AppColors.Beige.withOpacity(0.22),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'المتبقي',
                  value: '${_formatAmount(remaining)} ريال',
                ),
              ),
              Expanded(
                child: _StatChip(
                  label: 'عدد الضيوف',
                  value: '$_guestCount ضيف',
                ),
              ),
            ],
          ),
          // Collapsed entirely (not just hidden) unless at least one plan
          // mismatch actually applies — see [_guestCountMismatch] and
          // [_needsExceedBudget].
          if (_planMismatchMessages.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(color: AppColors.Beige.withOpacity(0.2), height: 1),
            const SizedBox(height: 14),
            for (var i = 0; i < _planMismatchMessages.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.diamond, size: 14, color: AppColors.Gold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _planMismatchMessages[i],
                      style: GoogleFonts.amiri(
                        color: AppColors.Beige,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    return FutureBuilder<List<Providers>>(
      future: _providersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _servicesFallback('تعذّر تحميل التوصيات الآن');
        }

        final recommendations = _recommendationsByCategory(snapshot.data!);
        if (recommendations.isEmpty) {
          return _servicesFallback('لا توجد توصيات متاحة حاليًا');
        }

        // Tracks exactly what's currently shown in each card (post any
        // "البديل" swaps), for [_buildFavoriteButton] to save as the plan's
        // provider list — not what's recomputed here, which stays at index
        // 0 for every card. Only (re)seeded when the set of cards actually
        // changes (in practice: once, when real provider data first
        // arrives) so a swap made before this rebuilds isn't lost.
        //
        // [_displayedCardPrices] is reset alongside it, for the same
        // reason: a fresh set of cards means the old per-index prices no
        // longer mean anything, and each new card will re-seed its own
        // entry via onDisplayedPriceChanged right after it builds.
        if (_displayedPlanProviders == null ||
            _displayedPlanProviders!.length != recommendations.length) {
          _displayedPlanProviders = [
            for (final recommendation in recommendations)
              recommendation.candidates.first,
          ];
          _displayedCardPrices = {};
        }

        final selectedGroups =
            recommendations.map((r) => r.group).toSet();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildServicesHeader(recommendations.length),
            const SizedBox(height: 12),
            for (var i = 0; i < recommendations.length; i++)
              _ServiceCard(
                candidates: recommendations[i].candidates,
                fallbackPrice: _normalizedShareFraction(
                      recommendations[i].group,
                      selectedGroups,
                    ) *
                    _budget,
                onOpenDetail: (provider) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ProviderDetailScreen(provider: provider),
                  ),
                ),
                onDisplayedProviderChanged: (provider) =>
                    _displayedPlanProviders![i] = provider,
                onDisplayedPriceChanged: (price) =>
                    setState(() => _displayedCardPrices[i] = price),
              ),
          ],
        );
      },
    );
  }

  // See _buildServicesSection's assignment for what this holds and why.
  List<Providers>? _displayedPlanProviders;

  /// One card's worth of recommendation: every provider matching a single
  /// selected needs-category (see [_needIdToCategoryGroup]), in the order
  /// found — [candidates].first is shown initially, and "البديل" cycles
  /// through the rest.
  List<_CategoryRecommendation> _recommendationsByCategory(
    List<Providers> allProviders,
  ) {
    // Selected need ids grouped by their top-level category, preserving
    // the order each category was first selected in — so exactly one
    // card is built per selected category, not per selected need.
    final orderedGroups = <String>[];
    final needsByGroup = <String, List<String>>{};
    for (final needId in widget.answers.selectedNeedsIds) {
      final group = _needIdToCategoryGroup[needId];
      if (group == null) continue;
      if (!needsByGroup.containsKey(group)) orderedGroups.add(group);
      needsByGroup.putIfAbsent(group, () => []).add(needId);
    }

    final recommendations = <_CategoryRecommendation>[];
    for (final group in orderedGroups) {
      final seenIds = <int?>{};
      final candidates = <Providers>[];
      for (final needId in needsByGroup[group]!) {
        final match = _needIdToProviderMatch[needId];
        if (match == null) continue;
        for (final provider in allProviders) {
          final categoryMatches = provider.category == match.category &&
              (match.subCategory == null ||
                  provider.subCategory == match.subCategory);
          if (!categoryMatches || seenIds.contains(provider.id)) continue;
          seenIds.add(provider.id);
          candidates.add(provider);
        }
      }
      // A category with no matching provider at all contributes no card,
      // rather than one with an empty candidate list.
      if (candidates.isNotEmpty) {
        recommendations.add(_CategoryRecommendation(group, candidates));
      }
    }
    return recommendations;
  }

  Widget _servicesFallback(String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildServicesHeader(0),
        const SizedBox(height: 12),
        Text(
          message,
          style: GoogleFonts.amiri(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildServicesHeader(int count) {
    return Row(
      children: [
        Text(
          'التوصيات',
          style: GoogleFonts.amiri(
            color: AppColors.Burgundy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.Gold,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: GoogleFonts.amiri(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveFavoritePlan(BuildContext context) async {
    final providers = _displayedPlanProviders;
    if (providers == null || providers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى الانتظار حتى تحميل التوصيات أولاً',
            style: GoogleFonts.amiri(),
          ),
          backgroundColor: AppColors.Burgundy,
        ),
      );
      return;
    }

    String message;
    try {
      await FavoritesDatabaseService().saveFavoritePlan(
        eventType: widget.answers.eventType,
        guestCount: widget.answers.guestCount,
        budget: widget.answers.budget,
        providers: providers,
      );
      message = 'تمت الإضافة للمفضلة';
    } on NotSignedInException {
      message = 'سجّل الدخول لحفظ الخطة بالمفضلة';
    } catch (_) {
      message = 'تعذّر حفظ الخطة الآن، حاول لاحقًا';
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.amiri()),
        backgroundColor: AppColors.Burgundy,
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => _saveFavoritePlan(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.Burgundy,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.Gold,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite, color: AppColors.Burgundy, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                'اضغط للمفضلة',
                style: GoogleFonts.amiri(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatAmount(num amount) {
  final digits = amount.toInt().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.55,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400),
        ),
        alignment: Alignment.center,
        child: Text(
          'AI',
          style: GoogleFonts.amiri(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.Burgundy, size: 16),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.amiri(
            color: AppColors.Beige.withOpacity(0.75),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.amiri(
            color: AppColors.Beige,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// One recommendation card. [candidates] is every provider matching the
/// card's category (never empty) — the card shows candidates[_index]
/// (starting at the first) and "البديل" cycles to the next one, wrapping
/// around; it's disabled when there's nothing else to cycle to.
class _ServiceCard extends StatefulWidget {
  final List<Providers> candidates;
  // This card's normalized share of the budget (see
  // _RecommendedPlanScreenState._normalizedShareFraction) — shown, and
  // counted, as this card's price whenever the currently displayed
  // candidate has no real minPrice/maxPrice of its own.
  final num fallbackPrice;
  final void Function(Providers provider) onOpenDetail;
  // Fired whenever "البديل" changes which candidate is shown, so the
  // parent can track it for the full-plan favorite save — see
  // _buildServicesSection's _displayedPlanProviders.
  final void Function(Providers provider) onDisplayedProviderChanged;
  // Fired with exactly the price shown on this card (real, or
  // [fallbackPrice] when the candidate has none) — right after the card
  // first builds, and again on every "البديل" swap. The parent sums these
  // across all cards for "المصروف"; see
  // _RecommendedPlanScreenState._displayedCardPrices. This must always
  // match [_priceText] below — they read the same [_displayedPrice].
  final void Function(num displayedPrice) onDisplayedPriceChanged;

  const _ServiceCard({
    required this.candidates,
    required this.fallbackPrice,
    required this.onOpenDetail,
    required this.onDisplayedProviderChanged,
    required this.onDisplayedPriceChanged,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  int _index = 0;

  Providers get _provider => widget.candidates[_index];

  bool get _hasAlternate => widget.candidates.length > 1;

  String get _subtitle {
    final parts = [_provider.category, _provider.subCategory]
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>();
    return parts.join(' - ');
  }

  // The price actually printed on this card, real or fallback — the sole
  // basis for both [_priceText] and the onDisplayedPriceChanged reports,
  // so the two can never diverge.
  num get _displayedPrice =>
      _provider.minPrice ?? _provider.maxPrice ?? widget.fallbackPrice;

  String get _priceText => _formatAmount(_displayedPrice);

  @override
  void initState() {
    super.initState();
    // Deferred to after the first frame: reporting synchronously here
    // would call the parent's setState while it's still mid-build (this
    // card is being created as part of the parent's own build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onDisplayedPriceChanged(_displayedPrice);
    });
  }

  void _showNextAlternative() {
    setState(() => _index = (_index + 1) % widget.candidates.length);
    widget.onDisplayedProviderChanged(_provider);
    widget.onDisplayedPriceChanged(_displayedPrice);
  }

  Future<void> _addToFavorites() async {
    String message;
    try {
      await FavoritesDatabaseService().saveFavoriteProvider(_provider);
      message = 'تمت الإضافة للمفضلة';
    } on NotSignedInException {
      message = 'سجّل الدخول لحفظ المفضلة';
    } catch (_) {
      message = 'تعذّر الحفظ الآن، حاول لاحقًا';
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.amiri()),
        backgroundColor: AppColors.Burgundy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onOpenDetail(_provider),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.Beige,
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(Icons.diamond, color: AppColors.Gold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _provider.name ?? 'بدون اسم',
                          style: GoogleFonts.amiri(
                            color: AppColors.Burgundy,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _subtitle,
                            style: GoogleFonts.amiri(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _priceText,
                        style: GoogleFonts.amiri(
                          color: AppColors.Burgundy,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ريال',
                        style: GoogleFonts.amiri(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.grey.shade100, height: 1),
              const SizedBox(height: 8),
              // "البديل" on the right, "المفضلة" on the left — the first
              // child in a Row lands on the right under this screen's RTL
              // Directionality, same as every other right-led row here.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _hasAlternate ? _showNextAlternative : null,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppColors.Burgundy,
                      disabledForegroundColor: Colors.grey.shade400,
                    ),
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: Text(
                      'البديل',
                      style: GoogleFonts.amiri(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _addToFavorites,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.Gold,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: AppColors.Burgundy,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
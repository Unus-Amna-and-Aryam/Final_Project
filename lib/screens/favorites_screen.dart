import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/models/favorite_plan.dart';
import 'package:final_project/models/onboarding_answers.dart';
import 'package:final_project/models/providers_model.dart';
import 'package:final_project/screens/favorite_plan_detail_screen.dart';
import 'package:final_project/screens/profile_screen.dart';
import 'package:final_project/screens/provider_detail_screen.dart';
import 'package:final_project/screens/recommended_plan_screen.dart';
import 'package:final_project/service/favorites_database_service.dart';
import 'package:final_project/widgets/app_bottom_nav_bar.dart';
import 'package:final_project/widgets/app_header.dart';
import 'package:final_project/widgets/sign_in_required_view.dart';

/// The favorites screen, reached from the bottom nav bar: every single
/// provider saved from a _ServiceCard's "المفضلة" button, plus every full
/// plan saved from RecommendedPlanScreen's "اضغط للمفضلة" button — both
/// loaded from [FavoritesDatabaseService], scoped to the signed-in user.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _service = FavoritesDatabaseService();
  late final Future<List<FavoriteProviderEntry>> _favoriteProvidersFuture;
  late final Future<List<FavoritePlan>> _favoritePlansFuture;

  // Ids removed via the gold heart button, filtered out of the loaded
  // futures' data below instead of refetching — the delete already
  // happened in Supabase by the time an id lands here (see
  // _FavoriteHeartButton.onRemove).
  final Set<int> _removedProviderIds = {};
  final Set<int> _removedPlanIds = {};

  // Drives the "عناصري المفضلة" carousel and the dot bar underneath it —
  // the dots re-render off [_currentProviderPage], which this listener
  // keeps in sync with whatever page is actually centered as the user
  // swipes.
  final _providerPageController = PageController(viewportFraction: 0.72);
  int _currentProviderPage = 0;

  // Same idea as the pair above, for the "خططي المفضلة" carousel.
  final _planPageController = PageController(viewportFraction: 0.72);
  int _currentPlanPage = 0;

  @override
  void initState() {
    super.initState();
    _favoriteProvidersFuture = _service.getFavoriteProviders();
    _favoritePlansFuture = _service.getFavoritePlans();
    _providerPageController.addListener(() {
      final page = _providerPageController.page?.round() ?? 0;
      if (page != _currentProviderPage) {
        setState(() => _currentProviderPage = page);
      }
    });
    _planPageController.addListener(() {
      final page = _planPageController.page?.round() ?? 0;
      if (page != _currentPlanPage) {
        setState(() => _currentPlanPage = page);
      }
    });
  }

  @override
  void dispose() {
    _providerPageController.dispose();
    _planPageController.dispose();
    super.dispose();
  }

  Future<void> _removeFavoriteProvider(int id) async {
    await _service.deleteFavoriteProvider(id);
    if (!mounted) return;
    setState(() => _removedProviderIds.add(id));
  }

  Future<void> _removeFavoritePlan(int id) async {
    await _service.deleteFavoritePlan(id);
    if (!mounted) return;
    setState(() => _removedPlanIds.add(id));
  }

  void _handleNavTap(BottomNavItem item) {
    if (item == BottomNavItem.favorites) return; // already here
    // The real onboarding answers aren't available from this tab directly,
    // but RecommendedPlanScreen stashes them in OnboardingSession every
    // time it's built — reuse those instead of losing them to empty
    // defaults. Falls back to placeholder defaults only if the home tab
    // was somehow never reached yet this app run.
    final screen = item == BottomNavItem.home
        ? RecommendedPlanScreen(
            answers: OnboardingSession.current ?? const OnboardingAnswers(),
          )
        : const ProfileScreen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  bool get _isSignedIn => Supabase.instance.client.auth.currentUser != null;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.Beige,
        body: SafeArea(
          child: !_isSignedIn
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppHeader(title: 'المفضلة', fontSize: 28),
                      const Expanded(child: SignInRequiredView()),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppHeader(title: 'المفضلة', fontSize: 28),
                      const SizedBox(height: 18),
                      _buildSectionHeader('عناصري المفضلة'),
                      const SizedBox(height: 12),
                      _buildFavoriteItemsSection(context),
                      const SizedBox(height: 28),
                      _buildSectionHeader('خططي المفضلة'),
                      const SizedBox(height: 12),
                      _buildFavoritePlansSection(context),
                    ],
                  ),
                ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          selected: BottomNavItem.favorites,
          onItemSelected: _handleNavTap,
        ),
      ),
    );
  }

  // Same title + count-badge style as RecommendedPlanScreen's
  // _buildServicesHeader (that one's private to that file, so this is a
  // small local equivalent rather than a shared import).
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.amiri(
        color: AppColors.Burgundy,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFavoriteItemsSection(BuildContext context) {
    return FutureBuilder<List<FavoriteProviderEntry>>(
      future: _favoriteProvidersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(height: 150);
        }
        final entries = snapshot.data
            ?.where((e) => !_removedProviderIds.contains(e.id))
            .toList();
        if (snapshot.hasError || entries == null || entries.isEmpty) {
          return _emptyMessage('لا توجد عناصر مفضلة بعد');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
              child: PageView.builder(
                controller: _providerPageController,
                // RTL Directionality already reverses PageView's
                // scroll/paint direction for us, so the first item lands
                // on the right and swiping right-to-left reveals the
                // rest, matching the app's reading direction.
                itemCount: entries.length,
                // Keyed by the favorite row's own id so Flutter maps each
                // card's Element (and so each heart button's filled/empty
                // state) to the *same* entry across rebuilds — without
                // this, removing one card mid-list shifted every card
                // after it onto the wrong (stale) heart state, since a
                // keyless list matches old/new children by position, not
                // identity.
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _FavoriteProviderCard(
                    key: ValueKey(entries[index].id),
                    provider: entries[index].provider,
                    isActive: index ==
                        _currentProviderPage.clamp(0, entries.length - 1),
                    onRemove: () => _removeFavoriteProvider(entries[index].id),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _DotsIndicator(
              count: entries.length,
              currentIndex: _currentProviderPage.clamp(0, entries.length - 1),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFavoritePlansSection(BuildContext context) {
    return FutureBuilder<List<FavoritePlan>>(
      future: _favoritePlansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(height: 140);
        }
        final plans = snapshot.data
            ?.where((p) => p.id == null || !_removedPlanIds.contains(p.id))
            .toList();
        if (snapshot.hasError || plans == null || plans.isEmpty) {
          return _emptyMessage('لا توجد خطط مفضلة بعد');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 140,
              child: PageView.builder(
                controller: _planPageController,
                // Same RTL reasoning as the provider carousel above.
                itemCount: plans.length,
                // Keyed for the same reason as the provider cards above —
                // see that itemBuilder's comment.
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _FavoritePlanCard(
                      key: ValueKey(plan.id ?? -1 - index),
                      plan: plan,
                      isActive:
                          index == _currentPlanPage.clamp(0, plans.length - 1),
                      onRemove: plan.id == null
                          ? null
                          : () => _removeFavoritePlan(plan.id!),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            _DotsIndicator(
              count: plans.length,
              currentIndex: _currentPlanPage.clamp(0, plans.length - 1),
            ),
          ],
        );
      },
    );
  }

  Widget _emptyMessage(String message) {
    return Text(
      message,
      style: GoogleFonts.amiri(color: Colors.grey.shade600, fontSize: 13),
    );
  }
}

/// One favorited provider, as a page in the "عناصري المفضلة" carousel.
class _FavoriteProviderCard extends StatelessWidget {
  final Providers provider;
  final bool isActive;
  final Future<void> Function() onRemove;

  const _FavoriteProviderCard({
    super.key,
    required this.provider,
    required this.isActive,
    required this.onRemove,
  });

  String get _subtitle {
    final parts = [provider.category, provider.subCategory]
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>();
    return parts.join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProviderDetailScreen(provider: provider),
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isActive ? AppColors.Burgundy : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.name ?? 'بدون اسم',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.amiri(
                      color: AppColors.Burgundy,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_subtitle.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.amiri(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Positioned(top: 8, left: 8, child: _FavoriteHeartButton(onRemove: onRemove)),
      ],
    );
  }
}

/// One favorited full plan, as a page in the "خططي المفضلة" carousel.
class _FavoritePlanCard extends StatelessWidget {
  final FavoritePlan plan;
  final bool isActive;
  // Null when [plan] somehow has no row id yet (see FavoritePlan.id) — the
  // heart button is left off entirely rather than being unable to delete.
  final Future<void> Function()? onRemove;

  const _FavoritePlanCard({
    super.key,
    required this.plan,
    required this.isActive,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FavoritePlanDetailScreen(plan: plan),
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isActive ? AppColors.Burgundy : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.eventType.isNotEmpty ? plan.eventType : 'خطة بدون اسم',
                style: GoogleFonts.amiri(
                  color: AppColors.Burgundy,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'عدد الأشخاص: ${plan.guestCount}',
                style: GoogleFonts.amiri(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'الميزانية: ${_formatAmount(plan.budget)} ريال',
                style: GoogleFonts.amiri(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onRemove == null) return card;
    return Stack(
      children: [
        card,
        Positioned(top: 8, left: 8, child: _FavoriteHeartButton(onRemove: onRemove!)),
      ],
    );
  }
}

/// The gold heart button overlaid on a favorite card ([_FavoriteProviderCard]
/// / [_FavoritePlanCard]): filled by default, flips to an outline as soon as
/// it's tapped (before the delete even finishes), then the card disappears
/// from the list once [onRemove] — which does the real Supabase delete and
/// updates the parent's state — succeeds. On failure it flips back to
/// filled and the card stays.
class _FavoriteHeartButton extends StatefulWidget {
  final Future<void> Function() onRemove;

  const _FavoriteHeartButton({required this.onRemove});

  @override
  State<_FavoriteHeartButton> createState() => _FavoriteHeartButtonState();
}

class _FavoriteHeartButtonState extends State<_FavoriteHeartButton> {
  bool _filled = true;
  bool _busy = false;

  Future<void> _handleTap() async {
    if (_busy) return;
    setState(() {
      _filled = false;
      _busy = true;
    });
    try {
      await widget.onRemove();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _filled = true;
        _busy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذّر الحذف الآن، حاول لاحقًا', style: GoogleFonts.amiri()),
          backgroundColor: AppColors.Burgundy,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(
          _filled ? Icons.favorite : Icons.favorite_border,
          color: AppColors.Gold,
          size: 22,
        ),
      ),
    );
  }
}

/// The dot bar under "عناصري المفضلة": one dot per card, the current one
/// drawn as a wider pill so it reads clearly as "you are here" — updates
/// live as _FavoritesScreenState's PageController reports a new page.
class _DotsIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _DotsIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? AppColors.Burgundy
                : AppColors.Gold.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
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

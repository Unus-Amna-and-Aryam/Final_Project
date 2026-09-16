import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late final Future<List<Providers>> _favoriteProvidersFuture;
  late final Future<List<FavoritePlan>> _favoritePlansFuture;

  @override
  void initState() {
    super.initState();
    final service = FavoritesDatabaseService();
    _favoriteProvidersFuture = service.getFavoriteProviders();
    _favoritePlansFuture = service.getFavoritePlans();
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.Beige,
        appBar: AppBar(
          backgroundColor: AppColors.Burgundy,
          title: Text(
            'المفضلة',
            style: GoogleFonts.amiri(
              color: AppColors.Beige,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFavoriteItemsSection(BuildContext context) {
    return FutureBuilder<List<Providers>>(
      future: _favoriteProvidersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final providers = snapshot.data;
        if (snapshot.hasError || providers == null || providers.isEmpty) {
          return _emptyMessage('لا توجد عناصر مفضلة بعد');
        }

        return SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // RTL Directionality already reverses ListView's scroll/paint
            // direction for us, so the first item lands on the right and
            // scrolling right-to-left reveals the rest, matching the app's
            // reading direction — no extra reverse: true needed.
            itemCount: providers.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _FavoriteProviderCard(provider: providers[index]),
          ),
        );
      },
    );
  }

  Widget _buildFavoritePlansSection(BuildContext context) {
    return FutureBuilder<List<FavoritePlan>>(
      future: _favoritePlansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final plans = snapshot.data;
        if (snapshot.hasError || plans == null || plans.isEmpty) {
          return _emptyMessage('لا توجد خطط مفضلة بعد');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final plan in plans) _FavoritePlanCard(plan: plan),
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

/// One favorited provider, as a landscape card in the horizontal list.
class _FavoriteProviderCard extends StatelessWidget {
  final Providers provider;

  const _FavoriteProviderCard({required this.provider});

  String get _subtitle {
    final parts = [provider.category, provider.subCategory]
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>();
    return parts.join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProviderDetailScreen(provider: provider),
          ),
        ),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
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
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.amiri(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One favorited full plan, as a nearly full-width card in the vertical
/// list.
class _FavoritePlanCard extends StatelessWidget {
  final FavoritePlan plan;

  const _FavoritePlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FavoritePlanDetailScreen(plan: plan),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'عدد الأشخاص: ${plan.guestCount}',
                style: GoogleFonts.amiri(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'الميزانية: ${_formatAmount(plan.budget)} ريال',
                style: GoogleFonts.amiri(
                  color: Colors.grey.shade600,
                  fontSize: 13,
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

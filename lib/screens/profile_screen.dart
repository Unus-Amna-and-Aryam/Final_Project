import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/models/onboarding_answers.dart';
import 'package:final_project/screens/about_us_screen.dart';
import 'package:final_project/screens/favorites_screen.dart';
import 'package:final_project/screens/my_info_screen.dart';
import 'package:final_project/screens/recommended_plan_screen.dart';
import 'package:final_project/widgets/app_bottom_nav_bar.dart';

/// The profile screen, reached from the bottom nav bar: a profile circle
/// with the locally-saved display name (see [profileDisplayNameKey] in
/// my_info_screen.dart) under it, "معلوماتي" / "من نحن" cards that open
/// their own screens, and an "أين نحن؟" card that expands in place to show
/// 3 city cards.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _displayName;
  bool _whereExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
  }

  Future<void> _loadDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _displayName = prefs.getString(profileDisplayNameKey));
  }

  Future<void> _openMyInfo(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MyInfoScreen()),
    );
    // The name may have just been added/edited on MyInfoScreen — reload it
    // so it shows immediately under the profile circle on return.
    _loadDisplayName();
  }

  void _handleNavTap(BuildContext context, BottomNavItem item) {
    if (item == BottomNavItem.profile) return; // already here
    // The real onboarding answers aren't available from this tab directly,
    // but RecommendedPlanScreen stashes them in OnboardingSession every
    // time it's built — reuse those instead of losing them to empty
    // defaults. Falls back to placeholder defaults only if the home tab
    // was somehow never reached yet this app run.
    final screen = item == BottomNavItem.home
        ? RecommendedPlanScreen(
            answers: OnboardingSession.current ?? const OnboardingAnswers(),
          )
        : const FavoritesScreen();
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
            'أُنس',
            style: GoogleFonts.amiri(
              color: AppColors.Beige,
              fontSize: 24,
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
                const SizedBox(height: 8),
                _buildProfileCircle(),
                const SizedBox(height: 12),
                Text(
                  _displayName?.isNotEmpty == true
                      ? _displayName!
                      : 'مستخدم أُنس',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    color: AppColors.Burgundy,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 28),
                _ProfileMenuCard(
                  title: 'معلوماتي',
                  onTap: () => _openMyInfo(context),
                ),
                const SizedBox(height: 14),
                _ProfileMenuCard(
                  title: 'من نحن',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AboutUsScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                _buildWhereWeAreCard(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          selected: BottomNavItem.profile,
          onItemSelected: (item) => _handleNavTap(context, item),
        ),
      ),
    );
  }

  Widget _buildProfileCircle() {
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.Gold, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(Icons.person, size: 56, color: AppColors.Burgundy),
      ),
    );
  }

  Widget _buildWhereWeAreCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _whereExpanded = !_whereExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'أين نحن؟',
                    style: GoogleFonts.amiri(
                      color: AppColors.Burgundy,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    _whereExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.Burgundy,
                  ),
                ],
              ),
            ),
          ),
          if (_whereExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
              child: Row(
                children: [
                  Expanded(
                    child: _CityCard(
                      name: 'الرياض',
                      comingSoon: false,
                      // TODO: navigate to the Riyadh destination once it's
                      // decided what this should open.
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: _CityCard(name: 'جدة', comingSoon: true),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: _CityCard(name: 'الدمام', comingSoon: true),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// "معلوماتي" / "من نحن" style menu card: full-width, white background,
/// rounded corners, light shadow — same look as the recommendation/favorite
/// cards elsewhere in the app.
class _ProfileMenuCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.amiri(
                  color: AppColors.Burgundy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.Burgundy),
            ],
          ),
        ),
      ),
    );
  }
}

/// One city card inside the expanded "أين نحن؟" section. [comingSoon] cities
/// show a "قريبًا" badge, are dimmed, and aren't tappable ([onTap] ignored).
class _CityCard extends StatelessWidget {
  final String name;
  final bool comingSoon;
  final VoidCallback? onTap;

  const _CityCard({required this.name, required this.comingSoon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.Beige,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.Gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Placeholder for the city photo — no real image asset for
              // this yet, replace with an actual photo of the city later.
              Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.location_city, color: AppColors.Burgundy, size: 26),
              ),
              if (comingSoon)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.Gold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'قريبًا',
                      style: GoogleFonts.amiri(
                        color: AppColors.Burgundy,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: GoogleFonts.amiri(
              color: AppColors.Burgundy,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    if (comingSoon) {
      return Opacity(opacity: 0.55, child: card);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      ),
    );
  }
}

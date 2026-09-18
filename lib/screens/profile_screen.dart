import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/models/onboarding_answers.dart';
import 'package:final_project/screens/about_us_screen.dart';
import 'package:final_project/screens/create_acount_screen.dart';
import 'package:final_project/screens/favorites_screen.dart';
import 'package:final_project/screens/my_info_screen.dart';
import 'package:final_project/screens/recommended_plan_screen.dart';
import 'package:final_project/widgets/app_bottom_nav_bar.dart';
import 'package:final_project/widgets/app_header.dart';
import 'package:final_project/widgets/sign_in_required_view.dart';

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
  Uint8List? _imageBytes;
  bool _whereExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final storedImage = prefs.getString(profileImageKey);
    setState(() {
      _displayName = prefs.getString(profileDisplayNameKey);
      _imageBytes = storedImage == null ? null : base64Decode(storedImage);
    });
  }

  // Reads the picked file as raw bytes (via XFile, not dart:io/path_provider)
  // and stores it base64-encoded in SharedPreferences — the only approach
  // that works identically on every target this app builds for, including
  // a future Flutter Web build: there's no real filesystem to save a path
  // into on web, but bytes + Image.memory work everywhere.
  Future<void> _pickProfileImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        // Keeps the base64 string (and so the SharedPreferences entry)
        // reasonably sized — this is a thumbnail for a 96x96 circle, not a
        // full-resolution photo.
        maxWidth: 600,
        maxHeight: 600,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(profileImageKey, base64Encode(bytes));

      if (!mounted) return;
      setState(() => _imageBytes = bytes);
    } catch (e) {
      // Surfaced instead of left silent — a bare await failing here
      // (e.g. a plugin not yet registered after a hot reload instead of a
      // full restart) would otherwise look exactly like the circle not
      // responding to taps at all.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذّر اختيار الصورة: $e', style: GoogleFonts.amiri()),
          backgroundColor: AppColors.Burgundy,
        ),
      );
    }
  }

  Future<void> _openMyInfo(BuildContext context) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const MyInfoScreen()));
    // The name may have just been added/edited on MyInfoScreen — reload it
    // so it shows immediately under the profile circle on return.
    _loadProfile();
  }

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;
    // Clears the whole stack (this profile tab and everything under it),
    // so the user can't navigate back into signed-in screens with the back
    // button after signing out.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const CreatAcountScreen()),
      (route) => false,
    );
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
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => screen));
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
                      const AppHeader(title: 'الملف الشخصي', fontSize: 28),
                      const Expanded(child: SignInRequiredView()),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // No onBack — this tab's root is only ever reached via
                      // pushReplacement (see AppBottomNavBar), so there's never a
                      // route to pop back to.
                      const AppHeader(title: 'الملف الشخصي', fontSize: 28),
                      const SizedBox(height: 18),
                      _buildProfileCircle(),
                      const SizedBox(height: 12),
                      Text(
                        _displayName?.isNotEmpty == true
                            ? _displayName!
                            : 'مستخدم أُنس',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          color: AppColors.Burgundy,
                          fontSize: 21,
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
                          MaterialPageRoute(
                            builder: (context) => const AboutUsScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildWhereWeAreCard(),
                      const SizedBox(height: 14),
                      _ProfileMenuCard(
                        title: 'تسجيل الخروج',
                        icon: Icons.logout,
                        color: Colors.red.shade700,
                        onTap: () => _signOut(context),
                      ),
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _pickProfileImage,
        child: Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              clipBehavior: Clip.antiAlias,
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
              child: _imageBytes != null
                  ? Image.memory(
                      _imageBytes!,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.person, size: 56, color: AppColors.Burgundy),
            ),
            // Small camera badge signaling the circle is tappable to
            // add/change the picture.
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.Gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.camera_alt,
                  size: 14,
                  color: AppColors.Burgundy,
                ),
              ),
            ),
          ],
        ),
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
                      fontSize: 19,
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
              child: Column(
                children: [
                  _CityCard(
                    name: 'الرياض',
                    imagePath: 'assets/images/riyadh_d.jpg',
                    comingSoon: false,
                    // TODO: navigate to the Riyadh destination once it's
                    // decided what this should open.
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  const _CityCard(
                    name: 'جدة',
                    imagePath: 'assets/images/jeddah_d.jpg',
                    comingSoon: true,
                  ),
                  const SizedBox(height: 12),
                  const _CityCard(
                    name: 'الدمام',
                    imagePath: 'assets/images/dhahran_d.jpg',
                    comingSoon: true,
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
  // Defaults match every other menu card ("معلوماتي"/"من نحن"); overridden
  // by the sign-out card to visually set it apart as a different kind of
  // action.
  final IconData icon;
  final Color? color;

  const _ProfileMenuCard({
    required this.title,
    required this.onTap,
    this.icon = Icons.arrow_forward_ios,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? AppColors.Burgundy;
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
                  color: resolvedColor,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                icon,
                size: icon == Icons.arrow_forward_ios ? 18 : 23,
                color: resolvedColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One city card inside the expanded "أين نحن؟" section: a full-width photo
/// with the city name overlaid top-right. [comingSoon] cities are dimmed,
/// show "قريبا ..." bottom-left, and aren't tappable ([onTap] ignored).
class _CityCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final bool comingSoon;
  final VoidCallback? onTap;

  const _CityCard({
    required this.name,
    required this.imagePath,
    required this.comingSoon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      height: 130,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.Gold.withValues(alpha: 0.5)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(imagePath, fit: BoxFit.cover),
          if (comingSoon)
            Container(color: Colors.black.withValues(alpha: 0.45)),
          Positioned(
            top: 10,
            right: 14,
            child: Text(
              name,
              style: GoogleFonts.amiri(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: const [Shadow(blurRadius: 6, color: Colors.black87)],
              ),
            ),
          ),
          if (comingSoon)
            Positioned(
              bottom: 10,
              left: 14,
              child: Text(
                'قريبا ...',
                style: GoogleFonts.amiri(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(blurRadius: 6, color: Colors.black87)],
                ),
              ),
            ),
        ],
      ),
    );

    if (comingSoon) {
      return card;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      ),
    );
  }
}

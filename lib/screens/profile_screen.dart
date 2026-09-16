import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/models/onboarding_answers.dart';
import 'package:final_project/screens/favorites_screen.dart';
import 'package:final_project/screens/recommended_plan_screen.dart';
import 'package:final_project/widgets/app_bottom_nav_bar.dart';

/// Placeholder profile screen, reached from the bottom nav bar. Content to
/// be designed later.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleNavTap(BuildContext context, BottomNavItem item) {
    if (item == BottomNavItem.profile) return; // already here
    // No onboarding answers are available from this tab, so the home screen
    // is reached with placeholder defaults here — same as before this
    // screen required real answers.
    final screen = item == BottomNavItem.home
        ? const RecommendedPlanScreen(answers: OnboardingAnswers())
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
            'الملف الشخصي',
            style: GoogleFonts.amiri(
              color: AppColors.Beige,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const SizedBox.expand(),
        bottomNavigationBar: AppBottomNavBar(
          selected: BottomNavItem.profile,
          onItemSelected: (item) => _handleNavTap(context, item),
        ),
      ),
    );
  }
}

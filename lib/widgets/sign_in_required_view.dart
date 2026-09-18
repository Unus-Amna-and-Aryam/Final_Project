import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/screens/create_acount_screen.dart';

/// Shown in place of a tab's real content when there's no signed-in
/// Supabase user — used by ProfileScreen and FavoritesScreen, both
/// meaningless without an account (unlike the home tab, which the
/// "تخطي الآن" skip flow can use freely without ever authenticating).
class SignInRequiredView extends StatelessWidget {
  const SignInRequiredView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 56, color: AppColors.Burgundy),
            const SizedBox(height: 16),
            Text(
              'يجب تسجيل الدخول لعرض هذه الصفحة',
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                color: AppColors.Burgundy,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreatAcountScreen(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.Burgundy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'سجل الدخول الآن',
                  style: GoogleFonts.amiri(
                    color: AppColors.Beige,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

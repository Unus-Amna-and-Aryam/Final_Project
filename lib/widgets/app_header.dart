import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_project/constants/app_colors.dart';

/// Same header style as RecommendedPlanScreen's own header: a centered
/// bold title on the page's plain Beige background, with a circular white
/// back button (when [onBack] is given) instead of a solid-color Material
/// AppBar. Used by screens that want that same look (profile, my info,
/// about us) rather than each building it inline.
class AppHeader extends StatelessWidget {
  final String title;
  // Omit for a screen with no back action (e.g. a bottom-nav tab root).
  final VoidCallback? onBack;
  final double fontSize;

  const AppHeader({
    super.key,
    required this.title,
    this.onBack,
    this.fontSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    // A Row (button — flexible title — balancing spacer) instead of a
    // Stack centered in a fixed-height box: a long title now wraps to a
    // second line and grows the header instead of overlapping the back
    // button, which a fixed-width unconstrained Text centered on top of
    // that button used to do.
    const buttonSlotWidth = 38.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        onBack != null
            ? _CircleIconButton(icon: Icons.arrow_back, onTap: onBack!)
            : const SizedBox(width: buttonSlotWidth),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.amiri(
              color: AppColors.Burgundy,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: buttonSlotWidth),
      ],
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
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.Burgundy, size: 24),
      ),
    );
  }
}

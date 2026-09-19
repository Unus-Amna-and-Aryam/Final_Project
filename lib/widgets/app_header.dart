import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_project/constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String title;
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
              color: AppColors.burgundy,
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
        child: Icon(icon, color: AppColors.burgundy, size: 24),
      ),
    );
  }
}

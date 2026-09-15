import 'package:flutter/material.dart';
import 'package:final_project/constants/app_colors.dart';

/// The 3 destinations on [AppBottomNavBar].
enum BottomNavItem { home, profile, favorites }

const double _barHeight = 64;

/// Simple bottom nav bar shared by the home, profile and favorites screens:
/// a flat bar with 3 evenly-spaced icons, where the active destination
/// renders as a solid/filled icon and the other two render as outlined
/// icons. Only brand colors (AppColors) are used.
class AppBottomNavBar extends StatelessWidget {
  final BottomNavItem selected;
  final ValueChanged<BottomNavItem> onItemSelected;

  const AppBottomNavBar({
    super.key,
    required this.selected,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.Beige,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _barHeight,
          child: Row(
            children: [
              Expanded(
                child: _NavIcon(
                  outlinedIcon: Icons.home_outlined,
                  filledIcon: Icons.home,
                  selected: selected == BottomNavItem.home,
                  onTap: () => onItemSelected(BottomNavItem.home),
                ),
              ),
              Expanded(
                child: _NavIcon(
                  outlinedIcon: Icons.person_outline,
                  filledIcon: Icons.person,
                  selected: selected == BottomNavItem.profile,
                  onTap: () => onItemSelected(BottomNavItem.profile),
                ),
              ),
              Expanded(
                child: _NavIcon(
                  outlinedIcon: Icons.favorite_border,
                  filledIcon: Icons.favorite,
                  selected: selected == BottomNavItem.favorites,
                  onTap: () => onItemSelected(BottomNavItem.favorites),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData outlinedIcon;
  final IconData filledIcon;
  final bool selected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.outlinedIcon,
    required this.filledIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: _barHeight,
          child: Icon(
            selected ? filledIcon : outlinedIcon,
            size: 26,
            color: selected
                ? AppColors.Burgundy
                : AppColors.Burgundy.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}

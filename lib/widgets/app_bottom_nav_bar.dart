import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:final_project/constants/app_colors.dart';

enum BottomNavItem { home, profile, favorites }

class AppBottomNavBar extends StatelessWidget {
  final BottomNavItem selected;
  final ValueChanged<BottomNavItem> onItemSelected;

  const AppBottomNavBar({
    super.key,
    required this.selected,
    required this.onItemSelected,
  });

  Widget _icon(IconData icon, BottomNavItem item) {
    return Icon(
      icon,
      size: 26,
      color: selected == item
          ? AppColors.burgundy
          : AppColors.beige.withValues(alpha: 0.7),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: selected.index,
      height: 60,
      color: AppColors.burgundy,
      buttonBackgroundColor: AppColors.gold,
      backgroundColor: AppColors.beige,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      items: [
        _icon(Icons.home, BottomNavItem.home),
        _icon(Icons.person, BottomNavItem.profile),
        _icon(Icons.favorite, BottomNavItem.favorites),
      ],
      onTap: (index) => onItemSelected(BottomNavItem.values[index]),
    );
  }
}

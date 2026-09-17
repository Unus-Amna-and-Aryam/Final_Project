import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:final_project/constants/app_colors.dart';

/// The 3 destinations on [AppBottomNavBar], in the exact order they're
/// rendered — do not reorder or add/remove entries without also updating
/// every screen that constructs this bar. Also the order [items] is built
/// in below, since [CurvedNavigationBar] maps its `index` positionally.
enum BottomNavItem { home, profile, favorites }

/// Bottom nav bar shared by the home, profile and favorites screens: a
/// curved Burgundy bar (curved_navigation_bar package) whose selected item
/// rises into a floating Gold circle — the same Gold-circle-with-Burgundy-
/// icon accent used elsewhere in the app (e.g. the favorite buttons on
/// _ServiceCard/_ProfileMenuCard).
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
          ? AppColors.Burgundy
          : AppColors.Beige.withValues(alpha: 0.7),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: selected.index,
      height: 60,
      color: AppColors.Burgundy,
      buttonBackgroundColor: AppColors.Gold,
      backgroundColor: AppColors.Beige,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      // Same fixed order as [BottomNavItem]: home, profile, favorites.
      items: [
        _icon(Icons.home, BottomNavItem.home),
        _icon(Icons.person, BottomNavItem.profile),
        _icon(Icons.favorite, BottomNavItem.favorites),
      ],
      onTap: (index) => onItemSelected(BottomNavItem.values[index]),
    );
  }
}

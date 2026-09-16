import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_project/constants/app_colors.dart';

/// The 3 destinations on [AppBottomNavBar], in the exact order they're
/// rendered — do not reorder or add/remove entries without also updating
/// every screen that constructs this bar.
enum BottomNavItem { home, profile, favorites }

// Height of the solid Burgundy strip itself.
const double _barHeight = 64;
// Extra height reserved above the strip purely so the active item's bubble
// can float above it without being clipped — see [AppBottomNavBar]. Sized
// so more than half the bubble pokes above the strip (a clearly-visible
// float, not a subtle one).
const double _topOverflow = 36;
const double _totalHeight = _barHeight + _topOverflow;
const double _bubbleSize = 56;

// The active item's bubble color: AppColors.Burgundy itself blended most
// of the way to black, not a new brand color — Burgundy alone is too
// close in tone to the strip behind it (same hue, so a plain-Burgundy
// bubble barely reads as "floating"); this near-black shade gives it real
// contrast while staying visibly derived from the app's own maroon.
final Color _activeBubbleColor =
    Color.lerp(AppColors.Burgundy, Colors.black, 0.6)!;

/// Bottom nav bar shared by the home, profile and favorites screens: a
/// solid Burgundy strip with 3 evenly-spaced items in a fixed order. The
/// active item (per [selected]) renders as a near-black circular bubble
/// (see [_activeBubbleColor]) that floats above the strip's top edge, a
/// Gold icon inside it, with its label centered directly underneath in
/// white; the other two are plain icons, dimmed (Beige at partial
/// opacity), with no label.
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
    return SafeArea(
      top: false,
      child: SizedBox(
        height: _totalHeight,
        // Clip.none (the default for Stack, stated explicitly here) is
        // what lets the active bubble in _NavItem paint above the strip
        // below instead of being cut off at this box's top edge — nothing
        // in this widget (or wrapping it, on any of the 3 screens that use
        // it) may wrap it in a ClipRRect/ClipRect that would undo that.
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // The solid strip, anchored to the bottom of the reserved
            // height so the extra space above it stays empty/transparent
            // for the bubble to float into.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _barHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.Burgundy,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
              ),
            ),
            // Same fixed left-to-right order as [BottomNavItem]: home,
            // profile, favorites — never reordered to match any reference
            // image.
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.home,
                      label: 'الرئيسية',
                      selected: selected == BottomNavItem.home,
                      onTap: () => onItemSelected(BottomNavItem.home),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.person,
                      label: 'الملف الشخصي',
                      selected: selected == BottomNavItem.profile,
                      onTap: () => onItemSelected(BottomNavItem.profile),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.favorite,
                      label: 'المفضلة',
                      selected: selected == BottomNavItem.favorites,
                      onTap: () => onItemSelected(BottomNavItem.favorites),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
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
          height: _totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (selected) ...[
                // The bubble sits at the very top of the reserved height,
                // so most of it pokes out above the strip below (whose top
                // edge is at _topOverflow from here) and only its lower
                // portion sinks into the strip — a clearly-visible float,
                // matching the reference image's proportions. Each of this
                // and the label below is independently centered via its
                // own Center (rather than one shared Column), so there's
                // no ambiguity about either one drifting off-center.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: _bubbleSize,
                      height: _bubbleSize,
                      decoration: BoxDecoration(
                        color: _activeBubbleColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        color: AppColors.Gold,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                // Directly under the bubble, still within the strip, and
                // horizontally centered to the same axis as the bubble
                // above it.
                Positioned(
                  top: _bubbleSize + 6,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ] else
                // Vertically centered within just the solid strip portion
                // (the bottom _barHeight of this item's full height).
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: (_barHeight - 24) / 2,
                  child: Icon(
                    icon,
                    size: 24,
                    color: AppColors.Beige.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

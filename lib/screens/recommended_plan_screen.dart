import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/models/providers_model.dart';
import 'package:final_project/screens/favorites_screen.dart';
import 'package:final_project/screens/profile_screen.dart';
import 'package:final_project/screens/provider_detail_screen.dart';
import 'package:final_project/service/providers_database_service.dart';
import 'package:final_project/widgets/app_bottom_nav_bar.dart';

/// The recommended-plan / home screen shown after onboarding: a budget
/// summary card, a list of recommended services, and a favorite-plan
/// button, with the app's bottom nav bar underneath.
class RecommendedPlanScreen extends StatefulWidget {
  const RecommendedPlanScreen({super.key});

  @override
  State<RecommendedPlanScreen> createState() => _RecommendedPlanScreenState();
}

class _RecommendedPlanScreenState extends State<RecommendedPlanScreen> {
  // Placeholder plan numbers until this screen is wired to the real
  // onboarding answers (budget/guest-count questions).
  static const double _budget = 300000;
  static const double _spent = 76500;
  static const int _guestCount = 150;

  // The only concrete mismatch we can check with the data this screen
  // currently has is spent-over-budget. There's no venue-capacity field on
  // [Providers] yet to compare _guestCount against, so that half of "بيانات
  // غير مناسبة" isn't wired up — add an `|| _guestCount > someCapacity`
  // clause here once that data source exists.
  bool get _hasMismatch => _spent > _budget;

  late final Future<List<Providers>> _providersFuture;

  @override
  void initState() {
    super.initState();
    _providersFuture = ProvidersDatabaseService().getAllProviders();
  }

  void _handleNavTap(BottomNavItem item) {
    if (item == BottomNavItem.home) return; // already here
    final screen = item == BottomNavItem.profile
        ? const ProfileScreen()
        : const FavoritesScreen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _budget - _spent;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.Beige,
        // SafeArea's top inset has been observed to briefly report 0 right
        // after popping back from a pushed screen (a known MediaQuery
        // timing quirk on some Android setups), which shifted this whole
        // page's content up under the status bar. Reading the inset
        // directly and clamping it to a sane minimum avoids that, while
        // still respecting the real inset on a normal/first load.
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              math.max(MediaQuery.paddingOf(context).top, 24) + 12,
              20,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 18),
                _buildTagline(),
                const SizedBox(height: 20),
                _buildBudgetCard(remaining),
                const SizedBox(height: 24),
                _buildServicesSection(context),
                const SizedBox(height: 8),
                _buildFavoriteButton(context),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          selected: BottomNavItem.home,
          onItemSelected: _handleNavTap,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _CircleIconButton(
              icon: Icons.arrow_forward_ios,
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          Text(
            'أُنس',
            style: GoogleFonts.amiri(
              color: AppColors.Burgundy,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _AiBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildTagline() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.Gold.withOpacity(0.6)),
        ),
        child: Text(
          'عبارة تلخص خطتك',
          style: GoogleFonts.amiri(
            color: AppColors.Burgundy,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(double remaining) {
    final labelStyle = GoogleFonts.amiri(
      color: AppColors.Beige,
      fontSize: 15,
    );
    final valueStyle = GoogleFonts.amiri(
      color: AppColors.Gold,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.Burgundy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // "الميزانية" leads (reads first, on the right in RTL) and
          // "المصروف منها" trails (left) — same order in both rows so the
          // amounts land directly under their own label.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الميزانية', style: labelStyle),
              Text('المصروف منها', style: labelStyle),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_formatAmount(_budget)} ريال', style: valueStyle),
              Text('${_formatAmount(_spent)} ريال', style: valueStyle),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: AppColors.Gold,
              inactiveTrackColor: AppColors.Beige.withOpacity(0.25),
              thumbColor: AppColors.Gold,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: _spent / _budget,
              onChanged: null,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _spent / _budget,
              minHeight: 8,
              color: AppColors.Gold,
              backgroundColor: AppColors.Beige.withOpacity(0.22),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'المتبقي',
                  value: '${_formatAmount(remaining)} ريال',
                ),
              ),
              Expanded(
                child: _StatChip(
                  label: 'عدد الضيوف',
                  value: '$_guestCount ضيف',
                ),
              ),
            ],
          ),
          // Collapsed entirely (not just hidden) unless the plan actually
          // has a mismatch — see [_hasMismatch].
          if (_hasMismatch) ...[
            const SizedBox(height: 16),
            Divider(color: AppColors.Beige.withOpacity(0.2), height: 1),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.diamond, size: 14, color: AppColors.Gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'في حال كانت الميزانية أو عدد الأشخاص غير مناسب، عدّلهما من هنا',
                    style: GoogleFonts.amiri(
                      color: AppColors.Beige,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    return FutureBuilder<List<Providers>>(
      future: _providersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _servicesFallback('تعذّر تحميل التوصيات الآن');
        }

        final providers = snapshot.data!.take(3).toList();
        if (providers.isEmpty) {
          return _servicesFallback('لا توجد توصيات متاحة حاليًا');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildServicesHeader(providers.length),
            const SizedBox(height: 12),
            for (final provider in providers)
              _ServiceCard(
                provider: provider,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ProviderDetailScreen(provider: provider),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _servicesFallback(String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildServicesHeader(0),
        const SizedBox(height: 12),
        Text(
          message,
          style: GoogleFonts.amiri(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildServicesHeader(int count) {
    return Row(
      children: [
        Text(
          'التوصيات',
          style: GoogleFonts.amiri(
            color: AppColors.Burgundy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.Gold,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: GoogleFonts.amiri(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تمت الإضافة للمفضلة',
                style: GoogleFonts.amiri(),
              ),
              backgroundColor: AppColors.Burgundy,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.Burgundy,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.Gold,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite, color: AppColors.Burgundy, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                'اضغط للمفضلة',
                style: GoogleFonts.amiri(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatAmount(num amount) {
  final digits = amount.toInt().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.55,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400),
        ),
        alignment: Alignment.center,
        child: Text(
          'AI',
          style: GoogleFonts.amiri(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.Burgundy, size: 16),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.amiri(
            color: AppColors.Beige.withOpacity(0.75),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.amiri(
            color: AppColors.Beige,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Providers provider;
  final VoidCallback onTap;

  const _ServiceCard({required this.provider, required this.onTap});

  String get _subtitle {
    final parts = [provider.category, provider.subCategory]
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>();
    return parts.join(' - ');
  }

  String get _priceText {
    final price = provider.minPrice ?? provider.maxPrice;
    return price != null ? _formatAmount(price) : '-';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.Beige,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.diamond, color: AppColors.Gold, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name ?? 'بدون اسم',
                      style: GoogleFonts.amiri(
                        color: AppColors.Burgundy,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _subtitle,
                        style: GoogleFonts.amiri(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _priceText,
                    style: GoogleFonts.amiri(
                      color: AppColors.Burgundy,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ريال',
                    style: GoogleFonts.amiri(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

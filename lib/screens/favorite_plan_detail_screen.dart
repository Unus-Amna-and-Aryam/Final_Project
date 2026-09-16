import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/models/favorite_plan.dart';
import 'package:final_project/models/providers_model.dart';

/// Full details for one saved favorite plan (see [FavoritesScreen] and
/// [FavoritePlan]) — the event name, guest count, budget, and every
/// provider that was recommended at save time. A static snapshot, not a
/// live recommendation: no "البديل"/"المفضلة" actions here.
class FavoritePlanDetailScreen extends StatelessWidget {
  final FavoritePlan plan;

  const FavoritePlanDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.Beige,
        appBar: AppBar(
          backgroundColor: AppColors.Burgundy,
          title: Text(
            plan.eventType.isNotEmpty ? plan.eventType : 'تفاصيل الخطة',
            style: GoogleFonts.amiri(
              color: AppColors.Beige,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 24),
            Text(
              'المزودون المحفوظون',
              style: GoogleFonts.amiri(
                color: AppColors.Burgundy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (plan.providers.isEmpty)
              Text(
                'لا يوجد مزودون محفوظون بهذه الخطة',
                style:
                    GoogleFonts.amiri(color: Colors.grey.shade600, fontSize: 13),
              )
            else
              for (final provider in plan.providers)
                _PlanProviderCard(provider: provider),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
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
      child: Row(
        children: [
          Expanded(
            child: _SummaryStat(
              label: 'عدد الضيوف',
              value: '${plan.guestCount} ضيف',
            ),
          ),
          Expanded(
            child: _SummaryStat(
              label: 'الميزانية',
              value: '${_formatAmount(plan.budget)} ريال',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({required this.label, required this.value});

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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PlanProviderCard extends StatelessWidget {
  final Providers provider;

  const _PlanProviderCard({required this.provider});

  String get _subtitle {
    final parts = [provider.category, provider.subCategory]
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>();
    return parts.join(' - ');
  }

  String get _priceText {
    final price = provider.minPrice ?? provider.maxPrice;
    return price != null ? '${_formatAmount(price)} ريال' : '-';
  }

  @override
  Widget build(BuildContext context) {
    final contactRows = <MapEntry<String, String>>[
      if (provider.phoneNumber != null && provider.phoneNumber!.isNotEmpty)
        MapEntry('رقم الجوال', provider.phoneNumber!),
      if (provider.socialAccount != null && provider.socialAccount!.isNotEmpty)
        MapEntry('الحساب الاجتماعي', provider.socialAccount!),
      if (provider.locationLink != null && provider.locationLink!.isNotEmpty)
        MapEntry('الموقع', provider.locationLink!),
    ];

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
              Text(
                _priceText,
                style: GoogleFonts.amiri(
                  color: AppColors.Burgundy,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (contactRows.isNotEmpty) ...[
            const SizedBox(height: 10),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 8),
            for (final row in contactRows)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      '${row.key}: ',
                      style: GoogleFonts.amiri(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.value,
                        style: GoogleFonts.amiri(
                          color: AppColors.Burgundy,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/models/favorite_plan.dart';
import 'package:final_project/models/providers_model.dart';
import 'package:final_project/widgets/app_header.dart';

class FavoritePlanDetailScreen extends StatelessWidget {
  final FavoritePlan plan;

  const FavoritePlanDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.beige,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AppHeader(
                title: plan.eventType.isNotEmpty
                    ? plan.eventType
                    : 'تفاصيل الخطة',
                onBack: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 18),
              _buildSummaryCard(),
              const SizedBox(height: 24),
              Text(
                'المزودون المحفوظون',
                style: GoogleFonts.amiri(
                  color: AppColors.burgundy,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (plan.providers.isEmpty)
                Text(
                  'لا يوجد مزودون محفوظون بهذه الخطة',
                  style: GoogleFonts.amiri(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                )
              else
                for (final provider in plan.providers)
                  _PlanProviderCard(provider: provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.burgundy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
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
            color: AppColors.beige.withValues(alpha: 0.75),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.amiri(
            color: AppColors.beige,
            fontSize: 19,
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
    final parts = [
      provider.category,
      provider.subCategory,
    ].where((s) => s != null && s.isNotEmpty).cast<String>();
    return parts.join(' - ');
  }

  String get _priceText {
    final price = provider.minPrice ?? provider.maxPrice;
    return price != null ? '${_formatAmount(price)} ريال' : '-';
  }

  @override
  Widget build(BuildContext context) {
    final contactRows = <_ContactRow>[
      if (provider.phoneNumber != null && provider.phoneNumber!.isNotEmpty)
        _ContactRow('رقم الجوال', provider.phoneNumber!),
      if (provider.socialAccount != null && provider.socialAccount!.isNotEmpty)
        _ContactRow('الحساب الاجتماعي', provider.socialAccount!, isLink: true),
      if (provider.locationLink != null && provider.locationLink!.isNotEmpty)
        _ContactRow('الموقع', provider.locationLink!, isLink: true),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                width: 52,
                height: 52,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.beige,
                  shape: BoxShape.circle,
                ),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name ?? 'بدون اسم',
                      style: GoogleFonts.amiri(
                        color: AppColors.burgundy,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _subtitle,
                        style: GoogleFonts.amiri(
                          color: Colors.grey.shade600,
                          fontSize: 14,
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
                  color: AppColors.burgundy,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (contactRows.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 10),
            for (final row in contactRows) _ContactRowTile(row: row),
          ],
        ],
      ),
    );
  }
}

class _ContactRow {
  final String label;
  final String value;
  final bool isLink;

  const _ContactRow(this.label, this.value, {this.isLink = false});
}

class _ContactRowTile extends StatelessWidget {
  final _ContactRow row;

  const _ContactRowTile({required this.row});

  Future<void> _openLink(BuildContext context) async {
    final uri = Uri.tryParse(row.value);
    final opened =
        uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذّر فتح الرابط', style: GoogleFonts.amiri()),
          backgroundColor: AppColors.burgundy,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '${row.label}: ',
            style: GoogleFonts.amiri(color: Colors.grey.shade600, fontSize: 15),
          ),
          Expanded(
            child: Text(
              row.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.amiri(
                color: row.isLink ? AppColors.gold : AppColors.burgundy,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                decoration: row.isLink ? TextDecoration.underline : null,
              ),
            ),
          ),
          if (row.isLink) ...[
            const SizedBox(width: 6),
            Icon(Icons.open_in_new, size: 16, color: AppColors.burgundy),
          ],
        ],
      ),
    );

    if (!row.isLink) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: () => _openLink(context), child: content),
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

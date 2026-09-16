import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/models/providers_model.dart';

/// Full details for one service provider, as stored in the `providers`
/// table (see [ProvidersDatabaseService]). Reached by tapping a service
/// card on the recommended-plan screen. Only shows the fields that are
/// actually present on the record.
class ProviderDetailScreen extends StatelessWidget {
  final Providers provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      if (provider.category != null && provider.category!.isNotEmpty)
        MapEntry('الفئة', provider.category!),
      if (provider.subCategory != null && provider.subCategory!.isNotEmpty)
        MapEntry('الفئة الفرعية', provider.subCategory!),
      if (provider.minPrice != null || provider.maxPrice != null)
        MapEntry('السعر', _priceRangeText(provider)),
      if (provider.phoneNumber != null && provider.phoneNumber!.isNotEmpty)
        MapEntry('رقم الجوال', provider.phoneNumber!),
      if (provider.socialAccount != null && provider.socialAccount!.isNotEmpty)
        MapEntry('الحساب الاجتماعي', provider.socialAccount!),
      if (provider.locationLink != null && provider.locationLink!.isNotEmpty)
        MapEntry('الموقع', provider.locationLink!),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.Beige,
        appBar: AppBar(
          backgroundColor: AppColors.Burgundy,
          title: Text(
            provider.name ?? 'تفاصيل الخدمة',
            style: GoogleFonts.amiri(
              color: AppColors.Beige,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: rows.isEmpty
            ? Center(
                child: Text(
                  'لا تتوفر تفاصيل إضافية لهذه الخدمة',
                  style: GoogleFonts.amiri(color: Colors.grey.shade600),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: rows.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _DetailRow(
                  label: rows[index].key,
                  value: rows[index].value,
                ),
              ),
      ),
    );
  }

  static String _priceRangeText(Providers provider) {
    final min = provider.minPrice;
    final max = provider.maxPrice;
    if (min != null && max != null && min != max) {
      return '${min.toStringAsFixed(0)} - ${max.toStringAsFixed(0)} ريال';
    }
    return '${(min ?? max)!.toStringAsFixed(0)} ريال';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.amiri(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.amiri(
              color: AppColors.Burgundy,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

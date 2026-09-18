import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/models/providers_model.dart';

/// Full details for one service provider, as stored in the `providers`
/// table (see [ProvidersDatabaseService]). Reached by tapping a service
/// card on the recommended-plan screen. Only shows the fields that are
/// actually present on the record. "الحساب الاجتماعي" and "الموقع" are
/// stored as full URLs (checked directly against the live `providers`
/// table — e.g. a tiktok.com link and a maps.app.goo.gl link
/// respectively), so those two rows open in the browser/maps app when
/// tapped; every other row is plain, non-interactive text.
class ProviderDetailScreen extends StatelessWidget {
  final Providers provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final rows = <_DetailRowData>[
      if (provider.category != null && provider.category!.isNotEmpty)
        _DetailRowData('الفئة', provider.category!),
      if (provider.subCategory != null && provider.subCategory!.isNotEmpty)
        _DetailRowData('الفئة الفرعية', provider.subCategory!),
      if (provider.minPrice != null || provider.maxPrice != null)
        _DetailRowData('السعر', _priceRangeText(provider)),
      if (provider.phoneNumber != null && provider.phoneNumber!.isNotEmpty)
        _DetailRowData('رقم الجوال', provider.phoneNumber!),
      if (provider.socialAccount != null && provider.socialAccount!.isNotEmpty)
        _DetailRowData('الحساب الاجتماعي', provider.socialAccount!, isLink: true),
      if (provider.locationLink != null && provider.locationLink!.isNotEmpty)
        _DetailRowData('الموقع', provider.locationLink!, isLink: true),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.Beige,
        appBar: AppBar(
          backgroundColor: AppColors.Burgundy,
          iconTheme: IconThemeData(color: AppColors.Beige),
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
                itemBuilder: (context, index) => _DetailRow(data: rows[index]),
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

class _DetailRowData {
  final String label;
  final String value;
  final bool isLink;

  const _DetailRowData(this.label, this.value, {this.isLink = false});
}

class _DetailRow extends StatelessWidget {
  final _DetailRowData data;

  const _DetailRow({required this.data});

  Future<void> _openLink(BuildContext context) async {
    final uri = Uri.tryParse(data.value);
    final opened = uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذّر فتح الرابط', style: GoogleFonts.amiri()),
          backgroundColor: AppColors.Burgundy,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: GoogleFonts.amiri(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  maxLines: data.isLink ? 1 : null,
                  overflow: data.isLink ? TextOverflow.ellipsis : null,
                  style: GoogleFonts.amiri(
                    color: data.isLink ? AppColors.Gold : AppColors.Burgundy,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    decoration:
                        data.isLink ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
          if (data.isLink) ...[
            const SizedBox(width: 8),
            Icon(Icons.open_in_new, size: 18, color: AppColors.Burgundy),
          ],
        ],
      ),
    );

    if (!data.isLink) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openLink(context),
        borderRadius: BorderRadius.circular(14),
        child: content,
      ),
    );
  }
}

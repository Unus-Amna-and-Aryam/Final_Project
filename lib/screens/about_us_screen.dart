import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/widgets/app_header.dart';

/// "من نحن": static intro text about the app, reached from ProfileScreen's
/// "About us" card. Placeholder copy — replace with the real text later.
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.Beige,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppHeader(
                  title: 'من نحن',
                  onBack: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 18),
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.Gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'أُنس',
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: AppColors.Burgundy,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            // Placeholder copy — not final wording.
            'أُنس تطبيق يساعدك على تخطيط مناسبتك بسهولة، من خلال '
            'اقتراح خطة متكاملة تناسب ميزانيتك وعدد ضيوفك، وربطك '
            'بأفضل مزودي الخدمات في القاعات والمأكولات والديكور '
            'والضيافة والتصوير وخدمات العروس، كل ذلك في مكان واحد '
            'لتوفير وقتك وجهدك.',
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: Colors.grey.shade700,
              fontSize: 18,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

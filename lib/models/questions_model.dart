import 'package:flutter/material.dart';

class QuestionOption {
  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? iconImagePath;
  final bool isDefaultSelected;

  const QuestionOption({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon = Icons.diamond,
    this.iconImagePath,
    this.isDefaultSelected = false,
  });
}

enum QuestionLayout {
  grid2,
  singleColumn,
  wrap,
  slider,
  expandableMultiSelect,
}

class QuestionSubItem {
  final String id;
  final String title;
  final bool isDefaultSelected;

  const QuestionSubItem({
    required this.id,
    required this.title,
    this.isDefaultSelected = false,
  });
}

class QuestionCategory {
  final String id;
  final String title;
  final List<QuestionSubItem> items;

  const QuestionCategory({
    required this.id,
    required this.title,
    required this.items,
  });
}

class QuestionModel {
  final String id;
  final int step;
  final int totalSteps;
  final String title;
  final List<QuestionOption> options;
  final bool allowMultiSelect;
  final QuestionLayout layout;
  final List<int>? sliderSteps;
  final String? sliderUnitLabel;
  final List<int>? sliderQuickPicks;
  final List<QuestionCategory>? categories;

  const QuestionModel({
    required this.id,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.options,
    this.allowMultiSelect = false,
    this.layout = QuestionLayout.grid2,
    this.sliderSteps,
    this.sliderUnitLabel,
    this.sliderQuickPicks,
    this.categories,
  });
}

const List<QuestionModel> onboardingQuestions = [
  QuestionModel(
    id: 'event_type',
    step: 1,
    totalSteps: 5,
    title: 'اختر مناسبتك مع أُنس',
    layout: QuestionLayout.grid2,
    options: [
      QuestionOption(
        id: 'invitation',
        title: 'عزيمة',
        subtitle: 'جمعة عائلية أو لمة أصدقاء',
        iconImagePath: 'assets/images/logo.png',
      ),
      QuestionOption(
        id: 'wedding',
        title: 'زفاف',
        subtitle: 'ليلة العمر وتفاصيل الفرح',
        icon: Icons.favorite,
      ),
      QuestionOption(
        id: 'graduation',
        title: 'تخرج',
        subtitle: 'مسك الختام وبداية المشوار',
        icon: Icons.school,
        isDefaultSelected: true,
      ),
      QuestionOption(
        id: 'holidays',
        title: 'أعياد',
        subtitle: 'تجهيزات العيد ولمة الأهل',
        icon: Icons.celebration,
      ),
    ],
  ),
  QuestionModel(
    id: 'location',
    step: 2,
    totalSteps: 5,
    title: 'أين ستقام مناسبتك؟',
    layout: QuestionLayout.grid2,
    options: [
      QuestionOption(id: 'indoor', title: 'داخل المنزل', icon: Icons.home),
      QuestionOption(id: 'outdoor', title: 'خارج المنزل', icon: Icons.park),
    ],
  ),
  QuestionModel(
    id: 'guests_count',
    step: 3,
    totalSteps: 5,
    title: 'كم عدد ضيوفك؟',
    layout: QuestionLayout.slider,
    options: [],
    sliderSteps: [10, 50, 100, 150, 200, 250, 300, 350, 400, 450, 500],
    sliderUnitLabel: 'شخص',
    sliderQuickPicks: [50, 100, 500],
  ),
  QuestionModel(
    id: 'budget',
    step: 4,
    totalSteps: 5,
    title: 'ميزانيتك تقريبًا؟',
    layout: QuestionLayout.slider,
    options: [],
    sliderSteps: [
      500,
      1500,
      2500,
      3500,
      4500,
      5500,
      6500,
      7500,
      8500,
      9500,
      10500,
      11500,
      12500,
      13500,
      14500,
      15500,
      16500,
      17500,
      18500,
      19500,
      20000,
    ],
    sliderUnitLabel: 'ريال',
    sliderQuickPicks: [4500, 9500, 20000],
  ),
  QuestionModel(
    id: 'needs',
    step: 5,
    totalSteps: 5,
    title: 'وش احتياجاتك؟',
    layout: QuestionLayout.expandableMultiSelect,
    allowMultiSelect: true,
    options: [],
    categories: [
      QuestionCategory(
        id: 'venues',
        title: 'قاعات واستراحات',
        items: [
          QuestionSubItem(id: 'venues_combined', title: 'قاعات واستراحات'),
        ],
      ),
      QuestionCategory(
        id: 'catering',
        title: 'مأكولات',
        items: [
          QuestionSubItem(id: 'catering_kitchens', title: 'مطابخ'),
          QuestionSubItem(id: 'catering_buffet', title: 'بوفيه'),
        ],
      ),
      QuestionCategory(
        id: 'decor',
        title: 'الديكور والتنسيق',
        items: [
          QuestionSubItem(id: 'decor_stands', title: 'ستاندات أو مجسمات'),
          QuestionSubItem(id: 'decor_furniture', title: 'طاولات ومقاعد'),
          QuestionSubItem(id: 'decor_numbers', title: 'أرقام للتنسيق الخاص'),
          QuestionSubItem(id: 'decor_flowers', title: 'زهور'),
        ],
      ),
      QuestionCategory(
        id: 'hospitality',
        title: 'ضيافة',
        items: [
          QuestionSubItem(id: 'hospitality_cake', title: 'كيك'),
          QuestionSubItem(id: 'hospitality_sweets', title: 'أصناف الحلا'),
          QuestionSubItem(id: 'hospitality_savory', title: 'أصناف المالح'),
          QuestionSubItem(id: 'hospitality_favors', title: 'توزيعات'),
        ],
      ),
      QuestionCategory(
        id: 'photography',
        title: 'التصوير',
        items: [
          QuestionSubItem(id: 'photography_male', title: 'مصور'),
          QuestionSubItem(id: 'photography_female', title: 'مصورة'),
        ],
      ),
      QuestionCategory(
        id: 'bride',
        title: 'العروس',
        items: [
          QuestionSubItem(id: 'bride_salons', title: 'الصالونات'),
          QuestionSubItem(id: 'bride_assistant', title: 'الوصيفة'),
        ],
      ),
    ],
  ),
];

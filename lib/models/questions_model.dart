import 'package:flutter/material.dart';

/// A single selectable card on a question page.
class QuestionOption {
  final String id;
  final String title;
  // Small line under the title. Omit it to show just the title.
  final String? subtitle;
  final IconData icon;
  // Optional asset image (e.g. the logo) shown small in place of [icon].
  // When set, this takes priority over [icon].
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

/// How a question's option cards should be arranged. Pick whichever best
/// fits the number/length of options for that question.
enum QuestionLayout {
  grid2, // two columns, e.g. 4 short options
  singleColumn, // one full-width card per row
  wrap, // cards wrap freely, sized to their own content
  slider, // a single discrete-step slider instead of option cards
  expandableMultiSelect, // collapsible categories of checkable sub-items
}

/// A checkable sub-item inside a [QuestionCategory]. Used only by
/// QuestionLayout.expandableMultiSelect.
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

/// A collapsible category header with its list of checkable sub-items.
/// Used only by QuestionLayout.expandableMultiSelect. Expanding/collapsing
/// a category is purely visual and never affects which sub-items (in this
/// or any other category) are selected.
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

/// Generic data for one onboarding question page. The same [QuestionScreen]
/// widget renders any of these. There's no subtitle field for the question
/// itself — only the title is shown under the progress bar.
class QuestionModel {
  final String id;
  final int step;
  final int totalSteps;
  final String title;
  final List<QuestionOption> options;
  final bool allowMultiSelect;
  final QuestionLayout layout;

  // Only used when layout is QuestionLayout.slider. [sliderSteps] are the
  // only values the slider can land on (snaps to the nearest one), e.g.
  // [10, 50, 100, ..., 500]. [sliderUnitLabel] is shown under the big
  // number (e.g. "شخص"). [sliderQuickPicks] are shortcut chips for a few
  // of those values; the chip for the last (max) step gets a "+" suffix.
  final List<int>? sliderSteps;
  final String? sliderUnitLabel;
  final List<int>? sliderQuickPicks;

  // Only used when layout is QuestionLayout.expandableMultiSelect.
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

/// The 5 onboarding question pages shown after "تخطي الآن" / "متابعة".
///
/// Only the first question's content is real. Questions 2-5 are
/// placeholders — replace their title and options with the real content
/// whenever it's ready; the screen and navigation code don't need to
/// change when you do.
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
      500, 1500, 2500, 3500, 4500, 5500, 6500, 7500, 8500, 9500, 10500,
      11500, 12500, 13500, 14500, 15500, 16500, 17500, 18500, 19500, 20000,
    ],
    sliderUnitLabel: 'ريال',
    // 5000/10000 aren't in sliderSteps above (every step is 500 mod 1000,
    // except the final 20000), so the nearest actual steps are used here
    // instead — otherwise these chips would be unresponsive.
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
          // Was two separate sub-items (قاعات / استراحات); merged into one
          // that shares the category's own title.
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

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/screens/guests_screen.dart';
import 'package:final_project/widgets/app_header.dart';

/// Lets the user customize a themed invitation card (title, description,
/// a sample guest name for the live preview) before moving on to
/// [GuestsScreen] to add real guests and send it to them. The card's
/// gradient/accent/icon are picked from [eventTypeId] — one of the
/// event_type question's option ids (see questions_model.dart), not a
/// free-form string — so it matches whichever event the user's onboarding
/// answers said this plan is for.
class InvitationCardScreen extends StatefulWidget {
  final String eventTypeId;

  const InvitationCardScreen({super.key, required this.eventTypeId});

  @override
  State<InvitationCardScreen> createState() => _InvitationCardScreenState();
}

class _InvitationCardScreenState extends State<InvitationCardScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _guestNameController = TextEditingController();
  // Wraps whichever card preview is showing (see build()) so it can be
  // rasterized into an actual image for GuestsScreen to share — WhatsApp's
  // wa.me link can pre-fill text and open a specific contact, but it can't
  // also attach an image, so sending the real card design has to go
  // through the OS share sheet with a real image file instead.
  final _cardBoundaryKey = GlobalKey();

  // Keyed by the event_type question's actual option ids (questions_model.dart)
  // — not the English placeholders ('wedding'/'graduation'/'eid'/'special')
  // this screen started from, which don't exist anywhere in this app's data.
  //
  // Every theme is a real photo background now (see _buildImageCard) —
  // 'bgGradient'/_buildGradientCard stay only as a fallback for an event
  // type that doesn't have a photo yet.
  Map<String, dynamic> _cardTheme() {
    switch (widget.eventTypeId) {
      case 'wedding': // زفاف
        return {
          'bgImage': 'assets/images/wedding.jpg',
          'defaultTitle': 'حفل زفاف',
          'accentColor': AppColors.Burgundy,
          'icon': Icons.favorite,
        };
      case 'graduation': // تخرج
        return {
          'bgImage': 'assets/images/graduation.jpg',
          'defaultTitle': 'حفل تخرج',
          'accentColor': AppColors.Burgundy,
          'icon': Icons.school,
        };
      case 'holidays': // أعياد
        return {
          'bgImage': 'assets/images/eid.jpg',
          'defaultTitle': 'عيد مبارك',
          'accentColor': AppColors.Burgundy,
          'icon': Icons.celebration,
        };
      case 'invitation': // عزيمة
      default:
        return {
          'bgImage': 'assets/images/other.jpg',
          'defaultTitle': 'دعوة خاصة',
          'accentColor': AppColors.Burgundy,
          'icon': Icons.card_giftcard,
        };
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController.text = _cardTheme()['defaultTitle'] as String;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _guestNameController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.amiri(color: Colors.grey.shade600),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.Burgundy, width: 1.5),
      ),
    );
  }

  // Rasterizes the card preview exactly as currently shown (whichever
  // fields/theme are filled in) into a PNG — this is the actual file
  // GuestsScreen shares, not just the invitation text.
  Future<Uint8List?> _captureCardImage() async {
    final boundary = _cardBoundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;
    // 3x: the on-screen card is a small preview; a low-res capture would
    // look blurry once shared full-size in a chat.
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  bool _capturing = false;

  Future<void> _goToGuests(Map<String, dynamic> theme) async {
    setState(() => _capturing = true);
    final imageBytes = await _captureCardImage();
    if (!mounted) return;
    setState(() => _capturing = false);

    if (imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذّر إنشاء صورة البطاقة', style: GoogleFonts.amiri()),
          backgroundColor: AppColors.Burgundy,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GuestsScreen(
          cardTitle: _titleController.text.isEmpty
              ? theme['defaultTitle'] as String
              : _titleController.text,
          cardDescription: _descController.text,
          cardImageBytes: imageBytes,
        ),
      ),
    );
  }

  // Every non-image theme: a plain gradient card with the icon/title/desc/
  // guest-name stacked and centered — see InvitationCardScreen's own doc
  // comment.
  Widget _buildGradientCard(Map<String, dynamic> theme) {
    return Container(
      height: 230,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: (theme['bgGradient'] as List<Color>),
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(theme['icon'] as IconData, color: theme['accentColor'] as Color, size: 28),
          const SizedBox(height: 8),
          Text(
            _titleController.text.isEmpty ? 'اسم المناسبة' : _titleController.text,
            style: GoogleFonts.amiri(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme['accentColor'] as Color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            _descController.text.isEmpty
                ? 'وصف الدعوة يظهر هنا...'
                : _descController.text,
            style: GoogleFonts.amiri(fontSize: 13, color: Colors.white70),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            _guestNameController.text.isEmpty
                ? 'إلى المكرم'
                : 'من المكرم: ${_guestNameController.text}',
            style: GoogleFonts.amiri(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.Beige,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // The 'graduation' theme: a real photo background (two graduation caps
  // hanging at the top-left, the rest of the frame plain/empty) instead of
  // a gradient — text is positioned in that empty space below the caps
  // rather than centered over them, and colored dark (Burgundy) since the
  // photo's background is light, unlike every gradient card's light text
  // on a dark background.
  Widget _buildImageCard(Map<String, dynamic> theme) {
    return Container(
      height: 420,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            theme['bgImage'] as String,
            fit: BoxFit.cover,
            // Keeps the hanging caps (near the image's top) in frame even
            // though this card's aspect ratio differs from the source
            // photo's — a centered cover crop would cut into them.
            alignment: Alignment.topCenter,
          ),
          Positioned(
            top: 190,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Text(
                  _titleController.text.isEmpty
                      ? 'اسم المناسبة'
                      : _titleController.text,
                  style: GoogleFonts.amiri(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme['accentColor'] as Color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _descController.text.isEmpty
                      ? 'وصف الدعوة يظهر هنا...'
                      : _descController.text,
                  style: GoogleFonts.amiri(
                    fontSize: 14,
                    color: AppColors.Burgundy.withValues(alpha: 0.75),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 28,
            left: 24,
            right: 24,
            child: Text(
              _guestNameController.text.isEmpty
                  ? 'من المكرم'
                  : _guestNameController.text,
              style: GoogleFonts.amiri(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.Burgundy,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _cardTheme();

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
                  title: 'تخصيص بطاقة الدعوة',
                  onBack: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 20),
                // Live preview — updates as the fields below change.
                // Wrapped in RepaintBoundary (see _captureCardImage) so the
                // exact same design shown here is what gets shared.
                RepaintBoundary(
                  key: _cardBoundaryKey,
                  child: theme.containsKey('bgImage')
                      ? _buildImageCard(theme)
                      : _buildGradientCard(theme),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.amiri(color: AppColors.Burgundy),
                  decoration: _fieldDecoration('اسم المناسبة أو نوعها'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  onChanged: (_) => setState(() {}),
                  maxLines: 2,
                  style: GoogleFonts.amiri(color: AppColors.Burgundy),
                  decoration:
                      _fieldDecoration('وصف الدعوة (مثل: يسعدنا حضوركم...)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _guestNameController,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.amiri(color: AppColors.Burgundy),
                  decoration: _fieldDecoration('اسم المدعو'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.Burgundy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed:
                        _capturing ? null : () => _goToGuests(theme),
                    child: _capturing
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.Beige,
                            ),
                          )
                        : Text(
                            'التالي: إضافة قائمة المدعوين وإرسال الدعوات',
                            style: GoogleFonts.amiri(
                              color: AppColors.Beige,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

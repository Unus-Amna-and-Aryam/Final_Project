import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/widgets/app_header.dart';

const String profileDisplayNameKey = 'profile_display_name';
const String profileImageKey = 'profile_image_base64';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  final _nameController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? get _currentEmail => Supabase.instance.client.auth.currentUser?.email;

  @override
  void initState() {
    super.initState();
    _loadSavedName();
  }

  Future<void> _loadSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nameController.text = prefs.getString(profileDisplayNameKey) ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      await prefs.remove(profileDisplayNameKey);
    } else {
      await prefs.setString(profileDisplayNameKey, name);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ الاسم', style: GoogleFonts.amiri()),
        backgroundColor: AppColors.burgundy,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.beige,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppHeader(
                        title: 'معلوماتي',
                        fontSize: 28,
                        onBack: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 18),
                      _buildFieldLabel('البريد الإلكتروني'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          _currentEmail ?? 'غير مسجّل الدخول',
                          style: GoogleFonts.amiri(
                            color: _currentEmail != null
                                ? AppColors.burgundy
                                : Colors.grey.shade500,
                            fontSize: 21,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildFieldLabel('الاسم'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          color: AppColors.burgundy,
                          fontSize: 21,
                        ),
                        decoration: InputDecoration(
                          hintText: 'أدخل اسمك',
                          hintStyle: GoogleFonts.amiri(
                            color: Colors.grey.shade400,
                            fontSize: 21,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: AppColors.burgundy,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.burgundy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: _saving
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.beige,
                                  ),
                                )
                              : Text(
                                  'حفظ',
                                  style: GoogleFonts.amiri(
                                    color: AppColors.beige,
                                    fontSize: 22,
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.amiri(
        color: AppColors.burgundy,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

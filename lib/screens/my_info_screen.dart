import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_project/constants/app_colors.dart';

/// SharedPreferences key the display name is saved under — read back by
/// ProfileScreen to show under the profile circle. There is currently no
/// `users`/`profiles` table in the Supabase schema (see
/// supabase/favorites_schema.sql) to attach a display name to the signed-in
/// account, so this is stored locally on the device only, as a stand-in
/// until such a table exists. This also means the name does not follow the
/// user to another device or survive a reinstall/skip-login flow.
const String profileDisplayNameKey = 'profile_display_name';

/// "معلوماتي": shows the current signed-in Supabase user's email
/// (read-only) and lets the user set/edit the local display name shown on
/// [ProfileScreen] (see [profileDisplayNameKey]).
class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  final _nameController = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  // Supabase Auth is the app's only sign-in mechanism (create_acount_screen.dart);
  // its current session's email is the one real source of "current user's
  // email" in the project. Null for anyone who reached onboarding via
  // "تخطي الآن", which never authenticates.
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
        backgroundColor: AppColors.Burgundy,
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
        backgroundColor: AppColors.Beige,
        appBar: AppBar(
          backgroundColor: AppColors.Burgundy,
          title: Text(
            'معلوماتي',
            style: GoogleFonts.amiri(
              color: AppColors.Beige,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFieldLabel('البريد الإلكتروني'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
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
                                ? AppColors.Burgundy
                                : Colors.grey.shade500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildFieldLabel('الاسم'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.amiri(
                          color: AppColors.Burgundy,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'أدخل اسمك',
                          hintStyle: GoogleFonts.amiri(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                BorderSide(color: AppColors.Burgundy, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.Burgundy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: _saving
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.Beige,
                                  ),
                                )
                              : Text(
                                  'حفظ',
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.amiri(
        color: AppColors.Burgundy,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

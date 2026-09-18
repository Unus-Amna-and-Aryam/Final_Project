import 'package:final_project/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:final_project/screens/question_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatAcountScreen extends StatefulWidget {
  const CreatAcountScreen({super.key});

  @override
  State<CreatAcountScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<CreatAcountScreen> {
  int isSignUp = 0;

  final Color backgroundColor = AppColors.Beige;
  final Color topBubbleColor = AppColors.Burgundy;

  final Color toggleContainerBg = AppColors.white;             
  final Color toggleActiveColor = AppColors.Burgundy_White; 
  final Color toggleInactiveColor = const Color.fromARGB(0, 134, 78, 78);      
  final Color toggleActiveTextColor = AppColors.white;         
  final Color toggleInactiveTextColor = Colors.grey;       

  final Color mainButtonColor = AppColors.Burgundy_White;
  final Color mainButtonTextColor = AppColors.white;

  // "unus" image, top-right of the upper bubble. Adjust these to freely
  // resize/reposition it within the bubble.
  final double unusWidth = 240;
  final double unusHeight = 240;
  final double unusTop = 40;
  final double unusRight = 0;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _skipToOnboarding() async {
    // "تخطي الآن" only skips the sign-in form — it doesn't clear an
    // existing Supabase session. Without this, a device that was ever
    // really signed in (even in an earlier test) stays signed in through
    // "skip", so screens gated on being signed in (SignInRequiredView)
    // never actually show for the guest flow this button is meant for.
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    startOnboardingFlow(context);
  }
// 1. ضعي الدالة هنا 👇 داخل الـ State
  Future<void> _handleAuthAction() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('الرجاء إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    if (isSignUp == 1 && password != confirmPassword) {
      _showSnackBar('كلمة المرور غير متطابقة مع تأكيد كلمة المرور');
      return;
    }

    try {
      final supabase = Supabase.instance.client;

      if (isSignUp == 1) {
        await supabase.auth.signUp(
          email: email,
          password: password,
        );
        _showSnackBar('تم إنشاء الحساب بنجاح!');
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        _showSnackBar('تم تسجيل الدخول بنجاح!');
      }

      if (!mounted) return;
      startOnboardingFlow(context);
} on AuthException catch (e) {
      // استبدال رسائل الأخطاء الإنجليزية برسائل عربية واضحة
      String arabicMessage = _translateAuthError(e.message);
      _showSnackBar(arabicMessage);
    } catch (e) {
      _showSnackBar('حدث خطأ غير متوقع: $e');
    }
  }

  // 2. وضعي دالة الـ SnackBar بجانبها هنا 👇
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.amiri(fontSize: 16)),
        backgroundColor: AppColors.Burgundy,
      ),
    );
  }
  // دالة لترجمة أخطاء Supabase الشهيرة إلى العربية
  String _translateAuthError(String englishMessage) {
    if (englishMessage.contains('Invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    } else if (englishMessage.contains('Password should be at least')) {
      return 'كلمة المرور يجب أن تكون 6 أحرف أو أرقام على الأقل';
    } else if (englishMessage.contains('User already registered')) {
      return 'هذا البريد الإلكتروني مسجل مسبقاً، حاول تسجيل الدخول';
    } else if (englishMessage.contains('Email not confirmed')) {
      return 'يرجى تأكيد البريد الإلكتروني أولاً';
    } else if (englishMessage.contains('Invalid email')) {
      return 'البريد الإلكتروني غير صالح';
    }
    // إذا كان خطأ آخر لم نكتبه، نرجع رسالة عامة أو الرسالة نفسها
    return 'حدث خطأ أثناء المصادقة، يجدر المحاولة مرة أخرى';
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        // Keep the bottom "skip" bubble fixed in place instead of being
        // pushed up when the keyboard appears; fields still scroll into
        // view via the SingleChildScrollView below.
        resizeToAvoidBottomInset: false,
        // Scaffold.body gives its child loose constraints, so a bare Stack
        // shrinks to fit its tallest non-positioned child (the scroll
        // view's content) instead of filling the screen. That left
        // Positioned(bottom: 0) anchored short of the real screen edge.
        // Forcing the Stack to the full screen size fixes it.
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
          children: [

            ClipPath(
              clipper: ConcaveBubbleClipper(),
              child: SizedBox(
                width: size.width,
                // Derived from width (not height) so the bubble keeps the
                // same proportions/curve on any screen aspect ratio instead
                // of stretching or shrinking abnormally.
                height: size.width * 0.93,
                child: Stack(
                  children: [
                    // Zoomed in a bit past a plain BoxFit.cover (which would
                    // show the background at its normal, more tightly
                    // tiled scale) so the pattern reads bigger/bolder
                    // within the bubble instead of busy and small.
                    Positioned.fill(
                      child: Transform.scale(
                        scale: 1.3,
                        child: Image.asset(
                          'assets/images/hello_background.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 28.0, top: 20.0, left: 28.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),

                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: unusTop,
                      right: unusRight,
                      // Tinted to match "تخطي الان"'s color below, instead
                      // of the golden shade baked into the source image.
                      child: Image.asset(
                        'assets/images/unus.png',
                        width: unusWidth,
                        height: unusHeight,
                        fit: BoxFit.contain,
                        color: AppColors.Beige,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.35),

                    Container(
                      height: 52,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: toggleContainerBg,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignUp = 0;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSignUp == 0 ? toggleActiveColor : toggleInactiveColor,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "تسجيل دخول",
                                  style: 
                                  GoogleFonts.amiri(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isSignUp == 0 ? toggleActiveTextColor : toggleInactiveTextColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignUp = 1;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSignUp == 1 ? toggleActiveColor : toggleInactiveColor,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "مستخدم جديد",
                                  style: GoogleFonts.amiri(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isSignUp == 1 ? toggleActiveTextColor : toggleInactiveTextColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    if (isSignUp == 0) ...[
                      _buildCustomTextField(
                        labelText: "البريد الإلكتروني" ,
                        hintText: "أدخل البريد الإلكتروني",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),
                      _buildCustomTextField(

                        labelText: "كلمة المرور",
                        hintText: "أدخل كلمة المرور",
                        controller: _passwordController,
                        isObscure: true,
                      ),
                    ] else ...[
                      _buildCustomTextField(
                        labelText: "البريد الإلكتروني",
                        hintText: "أدخل البريد الإلكتروني",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),
                      _buildCustomTextField(
                        labelText: "كلمة المرور",
                        hintText: "أدخل كلمة المرور",
                        controller: _passwordController,
                        isObscure: true,
                      ),
                      const SizedBox(height: 18),
                      _buildCustomTextField(
                        labelText: "تأكيد كلمة المرور",
                        hintText: "أعد كتابة كلمة المرور",
                        controller: _confirmPasswordController,
                        isObscure: true,
                      ),
                    ],

                    const SizedBox(height: 28),

                    SizedBox(
                      width: 170,
                      height: 42,
                      child: ElevatedButton(
                        onPressed:_handleAuthAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainButtonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          "متابعة",
                          style: GoogleFonts.amiri(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: mainButtonTextColor,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              child: GestureDetector(
                onTap: _skipToOnboarding,
                child: ClipPath(
                  clipper: BottomBubbleClipper(),
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      children: [
                        // Same zoomed-in scale as the top bubble's
                        // background, so the pattern reads at a matching
                        // size in both places.
                        Positioned.fill(
                          child: Transform.scale(
                            scale: 3,
                            child: Image.asset(
                              'assets/images/hello_background.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment(-0.4, 0.4),
                          child: Text(
                            "تخطي الان",
                            style: GoogleFonts.amiri(
                              color: AppColors.Beige,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    String? labelText,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        alignLabelWithHint: true,
        
        labelStyle: GoogleFonts.amiri(
          color: Colors.grey.shade600,
          fontSize: 16,
        ),
        floatingLabelStyle: GoogleFonts.amiri(
          color: topBubbleColor,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        hintStyle: GoogleFonts.amiri(
          color: Colors.grey.shade400,
          fontSize: 15,
        ),

        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: topBubbleColor, width: 1.5),
        ),
      ),
    );
  }
}

class ConcaveBubbleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.70);

    var controlPoint = Offset(size.width * 0.5, size.height * 0.95);
    var endPoint = Offset(size.width, size.height * 0.50);

    path.quadraticBezierTo(
      controlPoint.dx, controlPoint.dy,
      endPoint.dx, endPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomBubbleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(
      size.width * 0.85, size.height * 0.15,
      size.width, size.height,
    );
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
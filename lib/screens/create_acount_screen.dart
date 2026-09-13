import 'package:flutter/material.dart';

class CreatAcountScreen extends StatefulWidget {
  const CreatAcountScreen({super.key});

  @override
  State<CreatAcountScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<CreatAcountScreen> {
  int isSignUp = 0;

  final Color backgroundColor = const Color.fromARGB(255, 244, 238, 228);   
  final Color topBubbleColor = const Color(0xFF4A1620); 

  final Color toggleContainerBg = Colors.white;             
  final Color toggleActiveColor = const Color.fromARGB(255, 104, 62, 70);    
  final Color toggleInactiveColor = const Color.fromARGB(0, 134, 78, 78);      
  final Color toggleActiveTextColor = Colors.white;         
  final Color toggleInactiveTextColor = Colors.grey;       

  final Color mainButtonColor =const Color.fromARGB(255, 104, 62, 70);    
  final Color mainButtonTextColor = Colors.white;           

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl, 
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
       
            ClipPath(
              clipper: ConcaveBubbleClipper(),
              child: Container(
                width: size.width,
                height: size.height * 0.42,
                color: topBubbleColor,
                child: SafeArea(
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
                            color: Colors.black.withOpacity(0.06),
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
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
                        onPressed: () {
                          // إضافة التوجيه للشاشة التالية هنا عند التنفيذ
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainButtonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          "متابعة",
                          style: TextStyle(
                            fontSize: 18,
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
                onTap: () {
                  // إضافة التوجيه للشاشة التالية عند الضغط على تخطي
                },
                child: CustomPaint(
                  size: const Size(140, 140),
                  painter: BottomBubblePainter(color: topBubbleColor),
                  child: const SizedBox(
                    width: 140,
                    height: 140,
                    child: Align(
                      alignment: Alignment(-0.4, 0.4),
                      child: Text(
                        "تخطي الان",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
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
        
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
        floatingLabelStyle: TextStyle(
          color: topBubbleColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),

        filled: true,
        fillColor: Colors.white,
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

class BottomBubblePainter extends CustomPainter {
  final Color color;
  BottomBubblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(
      size.width * 0.85, size.height * 0.15, 
      size.width, size.height,
    );
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
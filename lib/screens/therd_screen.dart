import 'package:flutter/material.dart';
import 'package:final_project/constants/app_colors.dart';

class TherdScreen extends StatelessWidget {
  const TherdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Burgundy,
      body: Center(
        child: Text(
          'الصفحة الرئيسية',
          style: TextStyle(color: AppColors.Gold, fontSize: 24),
        ),
      ),
    );
  }
}

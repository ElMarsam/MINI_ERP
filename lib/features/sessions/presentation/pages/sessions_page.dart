import 'package:flutter/material.dart';
import 'package:erp_mini/core/constants/app_colors.dart';

class SessionsPage extends StatelessWidget {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_outlined, size: 64, color: AppColors.secondary),
            const SizedBox(height: 16),
            const Text(
              'إدارة السيشنات ومساحات العمل',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

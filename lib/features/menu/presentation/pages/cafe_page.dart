import 'package:flutter/material.dart';
import 'package:erp_mini/core/constants/app_colors.dart';

class CafePage extends StatelessWidget {
  const CafePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.coffee_outlined, size: 64, color: AppColors.secondary),
            const SizedBox(height: 16),
            const Text(
              'البوفيه والمنيو',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

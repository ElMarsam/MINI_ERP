import 'package:coworking_erp/core/constants/app_colors.dart';
import 'package:coworking_erp/core/constants/app_text_style.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ==============================================================================
// ويدجت ترويسة الداشبورد (DashboardHeader)
// يحتوي على العنوان وأيقونة الساعة المتحركة (Lottie Animation) مع التراجع عند الخطأ
// ==============================================================================
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  padding: const EdgeInsets.all(2),
                  child: Lottie.asset(
                    'assets/lotties/clock.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        LucideIcons.timer,
                        size: 18,
                        color: AppColors.secondary,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text('السيشنات النشطة حالياً', style: AppTextStyles.headlineLg),
              ],
            ),
            const SizedBox(height: 2),
          ],
        ),
      ],
    );
  }
}

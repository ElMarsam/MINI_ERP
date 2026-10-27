import 'package:erp_mini/core/constants/app_colors.dart';
import 'package:erp_mini/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';

// ==============================================================================
// ويدجت الشريط الجانبي لتذكير أعياد الميلاد (DashboardBirthdaysSidebar)
// يعرض بطاقة ملخص المناسبات القادمة مع شارة العدد أو رسالة التفرغ
// ==============================================================================
class DashboardBirthdaysSidebar extends StatelessWidget {
  final List<BirthdayBooking> upcomingBirthdays;

  const DashboardBirthdaysSidebar({super.key, required this.upcomingBirthdays});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  LucideIcons.cake,
                  size: 13,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'أعياد الميلاد',
                  style: AppTextStyles.labelLg.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: AppColors.statusPendingBorder),
                ),
                child: Text(
                  '${upcomingBirthdays.length}',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onStatusPending,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (upcomingBirthdays.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(
                    LucideIcons.calendarCheck,
                    size: 28,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'لا توجد مناسبات قادمة',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcomingBirthdays.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                return BirthdayReminderCard(booking: upcomingBirthdays[i]);
              },
            ),
        ],
      ),
    );
  }
}

import 'package:erp_mini/core/constants/app_colors.dart';
import 'package:erp_mini/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';

// ==============================================================================
// ويدجت شبكة الجلسات النشطة في الداشبورد (DashboardActiveSessionsGrid)
// يعرض حالة فارغة أنيقة أو شبكة متجاوبة من البطاقات النشطة
// ==============================================================================
class DashboardActiveSessionsGrid extends StatelessWidget {
  final List<Session> activeSessions;
  final Future<void> Function(String sessionId) onPause;
  final Future<void> Function(String sessionId) onResume;
  final void Function(Session session) onEnd;

  const DashboardActiveSessionsGrid({
    super.key,
    required this.activeSessions,
    required this.onPause,
    required this.onResume,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeSessions.isEmpty)
          // عرض شاشة فارغة في حالة عدم وجود جلسات مفتوحة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.armchair,
                    size: 28,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'لا توجد سيشنات نشطة في الوقت الحالي',
                  style: AppTextStyles.headlineSm,
                ),
                const SizedBox(height: 4),
                Text(
                  'يمكنك بدء جلسة جديدة من الزر أعلى الصفحة في أي وقت',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          )
        else
          // شبكة عرض الكروت بشكل متجاوب بحسب أبعاد الشاشة
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 3;
              if (constraints.maxWidth < 620) {
                crossAxisCount = 1;
              } else if (constraints.maxWidth < 1050) {
                crossAxisCount = 2;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 260,
                ),
                itemCount: activeSessions.length,
                itemBuilder: (context, index) {
                  final session = activeSessions[index];

                  return ActiveSessionCard(
                    key: ValueKey('dash_sess_${session.id}'),
                    session: session,
                    onPause: () => onPause(session.id),
                    onResume: () => onResume(session.id),
                    onEnd: () => onEnd(session),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

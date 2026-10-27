import 'package:coworking_erp/features/sessions/domain/entities/session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/utils/app_clock.dart';
import '../../../widgets/common/status_badge.dart';

// ==============================================================================
// ويدجت جدول سجل الجلسات المنتهية (SessionsClosedHistoryTable)
// يعرض أرشيف الجلسات المغلقة لليوم مع الحسابات وطرق الدفع والوقت المستغرق
// ==============================================================================
class SessionsClosedHistoryTable extends StatelessWidget {
  final List<Session> sessions;

  const SessionsClosedHistoryTable({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.receiptText,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد جلسات منتهية مسجلة اليوم حتى الآن',
              style: AppTextStyles.headlineSm,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListView.separated(
        itemCount: sessions.length + 1,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.tableRowDivider),
        itemBuilder: (context, index) {
          // صف عناوين الأعمدة
          if (index == 0) {
            return Container(
              height: 40,
              color: AppColors.tableHeaderBg,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('العميل', style: AppTextStyles.labelMd),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'المكتب / القاعة',
                      style: AppTextStyles.labelMd,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'وقت البداية والنهاية',
                      style: AppTextStyles.labelMd,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'المدة المستغرقة',
                      style: AppTextStyles.labelMd,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'الإجمالي المحسوب',
                      style: AppTextStyles.labelMd,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('المبلغ المدفوع', style: AppTextStyles.labelMd),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('طريقة الدفع', style: AppTextStyles.labelMd),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('الحالة', style: AppTextStyles.labelMd),
                  ),
                ],
              ),
            );
          }

          // صف بيانات الجلسة المنتهية
          final session = sessions[index - 1];
          String startStr;
          String endStr;
          final cairoStart = AppClock.toCairo(session.startTime);
          final cairoEnd = session.endTime != null
              ? AppClock.toCairo(session.endTime!)
              : null;
          try {
            startStr = DateFormat('hh:mm a', 'ar').format(cairoStart);
            endStr = cairoEnd != null
                ? DateFormat('hh:mm a', 'ar').format(cairoEnd)
                : '-';
          } catch (_) {
            startStr =
                '${cairoStart.hour.toString().padLeft(2, '0')}:${cairoStart.minute.toString().padLeft(2, '0')}';
            endStr = cairoEnd != null
                ? '${cairoEnd.hour.toString().padLeft(2, '0')}:${cairoEnd.minute.toString().padLeft(2, '0')}'
                : '-';
          }

          final duration = session.elapsedDuration;
          final durationStr =
              '${duration.inHours}س ${duration.inMinutes.remainder(60)}د';

          final paymentMethodLabel = switch (session.paymentMethod) {
            'cash' => 'كاش (نقدي)',
            'instapay' => 'إنستاباي',
            'vodafone_cash' => 'فودافون كاش',
            _ => session.paymentMethod ?? '-',
          };

          return Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    session.customerName,
                    style: AppTextStyles.labelLg,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    session.deskLabel ?? 'مكتب فردي',
                    style: AppTextStyles.bodySm,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '$startStr - $endStr',
                    style: AppTextStyles.bodySm,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(durationStr, style: AppTextStyles.numericTabular),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${session.totalAmount.toStringAsFixed(1)} ج.م',
                    style: AppTextStyles.numericTabular.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${session.paidAmount.toStringAsFixed(1)} ج.م',
                    style: AppTextStyles.numericTabular.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(paymentMethodLabel, style: AppTextStyles.bodySm),
                ),
                Expanded(
                  flex: 2,
                  child: const StatusBadge(
                    label: 'منتهي',
                    status: BadgeStatus.neutral,
                    showDot: false,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

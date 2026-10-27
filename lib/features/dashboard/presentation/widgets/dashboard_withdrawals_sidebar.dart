import 'package:flutter/material.dart';
import 'package:coworking_erp/core/constants/app_colors.dart';
import 'package:coworking_erp/core/constants/app_text_style.dart';
import 'package:coworking_erp/features/dashboard/data/models/cash_withdrawal_model.dart';

// ==============================================================================
// ويدجت الشريط الجانبي لمسحوبات الخزينة (DashboardWithdrawalsSidebar)
// يعرض بطاقة النقدية المسحوبة من الدرج مع زر تسجيل سحب نقدية جديد
// ==============================================================================
class DashboardWithdrawalsSidebar extends StatelessWidget {
  final List<CashWithdrawalModel> withdrawals;
  final VoidCallback onWithdrawPressed;

  const DashboardWithdrawalsSidebar({
    super.key,
    required this.withdrawals,
    required this.onWithdrawPressed,
  });

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
          // الترويسة: أيقونة الخزينة + العنوان
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 13,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'مسحوبات الخزنة',
                  style: AppTextStyles.labelLg.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // زر تسجيل سحب جديد
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onWithdrawPressed,
              icon: const Icon(
                Icons.remove_circle_outline,
                size: 13,
                color: AppColors.error,
              ),
              label: Text(
                'تسجيل سحب نقدية',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.error,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

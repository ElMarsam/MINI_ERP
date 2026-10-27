import 'package:coworking_erp/core/constants/app_colors.dart';
import 'package:coworking_erp/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ==============================================================================
// ويدجت نافذة سحب نقدية من الخزينة (CashWithdrawalDialog)
// تتيح لموظفي الاستقبال والإدارة تسجيل خروج مبالغ كاش من درج الخزينة
// تشمل: اسم المستلم/المسؤول، المبلغ المسحوب، سبب الصرف، وعرض التاريخ والوقت
// ==============================================================================
class CashWithdrawalDialog extends StatefulWidget {
  // دالة تأكيد السحب التي تستقبل البيانات وترسلها لقاعدة البيانات
  final Future<void> Function({
    required String staffName,
    required double amount,
    required String reason,
    DateTime? createdAt,
  })
  onConfirm;

  const CashWithdrawalDialog({super.key, required this.onConfirm});

  // ميثود استاتيكية مساعدة لفتح النافذة كـ Dialog بنمط منبثق
  static Future<void> show(
    BuildContext context, {
    required Future<void> Function({
      required String staffName,
      required double amount,
      required String reason,
      DateTime? createdAt,
    })
    onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible:
          false, // منع الإغلاق بالنقر خارج النافذة لضمان التركيز
      builder: (_) => CashWithdrawalDialog(onConfirm: onConfirm),
    );
  }

  @override
  State<CashWithdrawalDialog> createState() => _CashWithdrawalDialogState();
}

class _CashWithdrawalDialogState extends State<CashWithdrawalDialog> {
  // وحدات التحكم بحقول الإدخال
  final TextEditingController _staffNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  // تاريخ وتوقيت العملية الحالي
  final DateTime _selectedDate = DateTime.now();

  // مؤشر التحميل أثناء إرسال البيانات للسيرفر
  bool _isSubmitting = false;

  // التخلص من وحدات التحكم لتحرير الذاكرة
  @override
  void dispose() {
    _staffNameController.dispose();
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  // التحقق من صحة المدخلات وإرسال العملية
  Future<void> _submit() async {
    // 1. التحقق من إدخال اسم المسؤول
    final staffName = _staffNameController.text.trim();
    if (staffName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى كتابة اسم الشخص الساحب من الريسبشن'),
        ),
      );
      return;
    }

    // 2. التحقق من كتابة مبلغ صالح وموجب
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')));
      return;
    }

    // 3. التحقق من إدخال سبب السحب
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى تحديد سبب السحب')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // استدعاء دالة التأكيد الممررة
      await widget.onConfirm(
        staffName: staffName,
        amount: amount,
        reason: reason,
        createdAt: _selectedDate,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تسجيل سحب $amount ج.م بنجاح'),
            backgroundColor: AppColors.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // تنسيق التاريخ والوقت لعرضه في شريط المعاينة
    String formattedDate;
    try {
      formattedDate = DateFormat(
        'yyyy/MM/dd - hh:mm a',
        'ar',
      ).format(_selectedDate);
    } catch (_) {
      formattedDate =
          '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── ترويسة النافذة: أيقونة الخزينة + العنوان وزر الإغلاق ───
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.banknote,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تسجيل سحب نقدية من الخزنة',
                      style: AppTextStyles.headlineSm,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'سحب مبلغ من خزنة الكاش لحساب مصاريف ونثريات',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    LucideIcons.x,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ─── حقل اسم الساحب ───
            Text('اسم الساحب / المسؤول *', style: AppTextStyles.labelLg),
            const SizedBox(height: 6),
            TextField(
              controller: _staffNameController,
              decoration: const InputDecoration(
                hintText: 'مثال: عمر (الريسبشن) أو أحمد المدير',
                prefixIcon: Icon(LucideIcons.userCheck, size: 18),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // ─── حقل المبلغ المسحوب ───
            Text('المبلغ المسحوب *', style: AppTextStyles.labelLg),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: AppTextStyles.headlineSm.copyWith(color: AppColors.error),
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixIcon: Icon(
                  LucideIcons.coins,
                  size: 18,
                  color: AppColors.error,
                ),
                suffixText: 'ج.م',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // ─── حقل سبب السحب أو البند ───
            Text('سبب السحب / البند *', style: AppTextStyles.labelLg),
            const SizedBox(height: 6),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'اكتب سبب السحب بالتفصيل...',
                prefixIcon: Icon(LucideIcons.fileText, size: 18),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // ─── بطاقة معاينة تاريخ ووقت العملية ───
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.calendar,
                    size: 15,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text('تاريخ ووقت السحب:', style: AppTextStyles.labelSm),
                  const Spacer(),
                  Text(
                    formattedDate,
                    style: AppTextStyles.labelSm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── أزرار الإجراءات (إلغاء + تأكيد السحب) ───
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('إلغاء'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          LucideIcons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                  label: Text(
                    'تأكيد السحب',
                    style: AppTextStyles.labelLg.copyWith(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

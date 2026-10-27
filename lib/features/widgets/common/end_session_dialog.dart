import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:coworking_erp/core/constants/app_constants.dart';
import 'package:coworking_erp/core/theme/app_colors.dart';
import 'package:coworking_erp/core/theme/app_text_styles.dart';
import 'package:coworking_erp/core/utils/app_clock.dart';
import 'package:coworking_erp/domain/entities/session.dart';
import 'package:coworking_erp/domain/entities/cafe.dart';
import 'select_cafe_dialog.dart';

// ==============================================================================
// ويدجت نافذة إنهاء الجلسة وحساب الفاتورة (EndSessionDialog)
// تتيح للموظف مراجعة التكلفة المحسوبة للوقت، وإضافة مصروفات كافيه، رسوم إضافية،
// أو خصومات، وتحديد طريقة الدفع (كاش، إنستاباي، فودافون كاش) وسداد الفاتورة بالكامل
// ==============================================================================
class EndSessionDialog extends StatefulWidget {
  // كائن الجلسة المراد إنهاؤها
  final Session session;

  // دالة تأكيد إنهاء الجلسة وحفظ التحصيل المالي في السيرفر
  final Future<void> Function({
    required String sessionId,
    required double totalAmount,
    required double paidAmount,
    required String paymentMethod,
  }) onConfirmEnd;

  const EndSessionDialog({
    super.key,
    required this.session,
    required this.onConfirmEnd,
  });

  // ميثود استاتيكية مساعدة لفتح النافذة كـ Dialog
  static Future<void> show(
    BuildContext context, {
    required Session session,
    required Future<void> Function({
      required String sessionId,
      required double totalAmount,
      required double paidAmount,
      required String paymentMethod,
    }) onConfirmEnd,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EndSessionDialog(
        session: session,
        onConfirmEnd: onConfirmEnd,
      ),
    );
  }

  @override
  State<EndSessionDialog> createState() => _EndSessionDialogState();
}

class _EndSessionDialogState extends State<EndSessionDialog> {
  // تكلفة وقت الجلسة الأساسية
  late double _sessionCost;

  // طلبات الكافيه والمشروبات
  double _extraCharges = 0.0;

  // قائمة عناصر وبنود البوفيه المختارة
  Map<String, CafeOrderItem> _selectedCafeItems = {};

  // رسوم إضافية
  double _fees = 0.0;

  // الخصم أو التخفيض الممنوح
  double _discount = 0.0;

  // إجمالي الفاتورة النهائي
  late double _totalAmount;

  // وسيلة الدفع المختارة (افتراضياً كاش)
  String _selectedPaymentMethod = AppConstants.paymentCash;

  // مؤشر حفظ البيانات
  bool _isSubmitting = false;

  // وحدات التحكم بالحقول الإضافية
  final TextEditingController _feesController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  // تهيئة الحسابات المبدئية عند فتح النافذة
  @override
  void initState() {
    super.initState();
    _sessionCost = widget.session.calculateCurrentAmount();
    _totalAmount = _sessionCost;
  }

  // إعادة احتساب إجمالي الفاتورة ديناميكياً مع أي تعديل
  void _recalculate() {
    setState(() {
      _totalAmount = (_sessionCost + _extraCharges + _fees - _discount).clamp(0.0, double.infinity);
    });
  }

  // فتح نافذة اختيار طلبات البوفيه والمنيو
  Future<void> _openCafeMenuSelector() async {
    final result = await SelectCafeDialog.show(
      context,
      initialSelectedItems: _selectedCafeItems,
    );
    if (result != null) {
      setState(() {
        _selectedCafeItems = result;
        _extraCharges = result.values.fold(0.0, (sum, i) => sum + i.total);
        _recalculate();
      });
    }
  }

  // التخلص من وحدات التحكم
  @override
  void dispose() {
    _feesController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  // تأكيد إنهاء الجلسة وتسجيل السداد بالكامل
  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await widget.onConfirmEnd(
      sessionId: widget.session.id,
      totalAmount: _totalAmount,
      paidAmount: _totalAmount,
      paymentMethod: _selectedPaymentMethod,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final duration = session.elapsedDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    // تنسيق مدة الجلسة بالعربية
    final timeFormatted = hours > 0
        ? '$hours ساعة و $minutes دقيقة'
        : '$minutes دقيقة (${duration.inSeconds.remainder(60)} ثانية)';

    // تنسيق أوقات البدء والانتهاء بتوقيت القاهرة
    String timeStart;
    String timeEnd;
    final cairoStartTime = AppClock.toCairo(session.startTime);
    final cairoNow = AppClock.nowCairo();
    try {
      timeStart = DateFormat('hh:mm a', 'ar').format(cairoStartTime);
      timeEnd = DateFormat('hh:mm a', 'ar').format(cairoNow);
    } catch (_) {
      timeStart = '${cairoStartTime.hour.toString().padLeft(2, '0')}:${cairoStartTime.minute.toString().padLeft(2, '0')}';
      timeEnd = '${cairoNow.hour.toString().padLeft(2, '0')}:${cairoNow.minute.toString().padLeft(2, '0')}';
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.surface,
        child: Container(
          width: 540,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── ترويسة النافذة: أيقونة الفاتورة + العنوان ───
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.receiptText, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('إنهاء الجلسة وحساب الفاتورة', style: AppTextStyles.headlineMd),
                        Text(
                          'مراجعة التكلفة الإجمالية وطريقة التحصيل المالي',
                          style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textMuted),
                  ),
                ],
              ),
              const Divider(height: 20, color: AppColors.divider),

              // ─── صندوق ملخص تفاصيل الجلسة والوقت ───
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    // اسم العميل ونوع الحجز
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.user, size: 15, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Text(session.customerName, style: AppTextStyles.headlineSm.copyWith(fontSize: 15)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Text(
                            session.deskLabel ?? 'مكتب فردي',
                            style: AppTextStyles.labelMd.copyWith(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: AppColors.outlineVariant),
                    const SizedBox(height: 10),
                    // فترة الجلسة (من - إلى)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('فترة الجلسة:', style: AppTextStyles.labelMd),
                        Text('من $timeStart إلى $timeEnd', style: AppTextStyles.bodySm),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // صافي الوقت المستغرق
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('صافي الوقت المستغرق:', style: AppTextStyles.labelMd),
                        Text(
                          timeFormatted,
                          style: AppTextStyles.headlineSm.copyWith(
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // تكلفة وقت العمل
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('تكلفة الوقت المحسوبة:', style: AppTextStyles.labelMd),
                        Text(
                          '${_sessionCost.toStringAsFixed(1)} ج.م',
                          style: AppTextStyles.headlineSm.copyWith(
                            fontSize: 14,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    // ─── تفاصيل طلبات البوفيه في ريسيت السيشن ───
                    if (_selectedCafeItems.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.dividerInteractive),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(LucideIcons.coffee, size: 13, color: AppColors.secondary),
                                    const SizedBox(width: 5),
                                    Text(
                                      'طلبات البوفيه المضافة (${_selectedCafeItems.values.fold(0, (sum, i) => sum + i.quantity)} صنف):',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '+${_extraCharges.toStringAsFixed(1)} ج.م',
                                  style: AppTextStyles.labelMd.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Divider(height: 1, color: AppColors.divider),
                            const SizedBox(height: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 110),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: _selectedCafeItems.values.map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '• ${item.productName} × ${item.quantity}',
                                            style: AppTextStyles.bodySm.copyWith(
                                              color: AppColors.textPrimary,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            '${item.total.toStringAsFixed(1)} ج.م',
                                            style: AppTextStyles.bodySm.copyWith(
                                              color: AppColors.textMuted,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_extraCharges > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('طلبات كافيه / إضافات:', style: AppTextStyles.labelMd),
                          Text(
                            '+${_extraCharges.toStringAsFixed(1)} ج.م',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_fees > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('رسوم إضافية:', style: AppTextStyles.labelMd),
                          Text(
                            '+${_fees.toStringAsFixed(1)} ج.م',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_discount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('خصم / تخفيض:', style: AppTextStyles.labelMd),
                          Text(
                            '-${_discount.toStringAsFixed(1)} ج.م',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ─── حقول التعديل المالي: زر البوفيه والمنيو، رسوم إضافية، وخصومات ───
              Row(
                children: [
                  // زر اختيار طلبات البوفيه والمنيو
                  Expanded(
                    flex: 4,
                    child: InkWell(
                      onTap: _openCafeMenuSelector,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedCafeItems.isNotEmpty
                              ? AppColors.secondary.withValues(alpha: 0.08)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _selectedCafeItems.isNotEmpty
                                ? AppColors.secondary
                                : AppColors.dividerInteractive,
                            width: _selectedCafeItems.isNotEmpty ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _selectedCafeItems.isNotEmpty
                                    ? AppColors.secondary
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                LucideIcons.coffee,
                                size: 16,
                                color: _selectedCafeItems.isNotEmpty
                                    ? Colors.white
                                    : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedCafeItems.isNotEmpty
                                        ? 'طلبات البوفيه (${_selectedCafeItems.values.fold(0, (sum, i) => sum + i.quantity)})'
                                        : 'البوفيه والمنيو',
                                    style: AppTextStyles.labelSm.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: _selectedCafeItems.isNotEmpty
                                          ? AppColors.secondary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    _selectedCafeItems.isNotEmpty
                                        ? '+${_extraCharges.toStringAsFixed(1)} ج.م (تعديل)'
                                        : 'إضافة مشروبات / سناكس',
                                    style: AppTextStyles.bodySm.copyWith(
                                      fontSize: 10,
                                      color: _selectedCafeItems.isNotEmpty
                                          ? AppColors.secondary
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _selectedCafeItems.isNotEmpty
                                  ? LucideIcons.pencil
                                  : LucideIcons.plus,
                              size: 14,
                              color: _selectedCafeItems.isNotEmpty
                                  ? AppColors.secondary
                                  : AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _feesController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'رسوم إضافية (ج.م)',
                        hintText: '0',
                        prefixIcon: Icon(LucideIcons.plusCircle, size: 16),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (val) {
                        _fees = double.tryParse(val.trim()) ?? 0.0;
                        _recalculate();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _discountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'خصم / تخفيض (ج.م)',
                        hintText: '0',
                        prefixIcon: Icon(LucideIcons.tag, size: 16),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (val) {
                        _discount = double.tryParse(val.trim()) ?? 0.0;
                        _recalculate();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ─── خيارات وسيلة الدفع (كاش، إنستاباي، فودافون كاش) ───
              Text('طريقة الدفع والتحصيل:', style: AppTextStyles.labelLg),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentOption(
                      label: 'كاش (نقدي)',
                      icon: LucideIcons.banknote,
                      value: AppConstants.paymentCash,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPaymentOption(
                      label: 'إنستاباي (InstaPay)',
                      icon: LucideIcons.smartphone,
                      value: AppConstants.paymentInstaPay,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPaymentOption(
                      label: 'فودافون كاش',
                      icon: LucideIcons.phoneCall,
                      value: AppConstants.paymentVodafoneCash,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ─── شريط الإجمالي المطلوب والمبلغ المسدد ───
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.dividerInteractive),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('إجمالي الفاتورة المطلوب سدادها', style: AppTextStyles.labelMd),
                        const SizedBox(height: 4),
                        Text(
                          '${_totalAmount.toStringAsFixed(1)} ج.م',
                          style: AppTextStyles.headlineLg.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.statusActiveBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.statusActiveBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.checkCheck, size: 16, color: AppColors.statusActive),
                          const SizedBox(width: 8),
                          Text(
                            'سداد كامل الفاتورة',
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.statusActive,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── أزرار الإجراءات (إلغاء + تأكيد الدفع وإنهاء السيشن) ───
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: Text('إلغاء', style: AppTextStyles.labelLg.copyWith(color: AppColors.textMuted)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(LucideIcons.checkCheck, size: 16, color: Colors.white),
                    label: Text(
                      _isSubmitting ? 'جاري الحفظ...' : 'تأكيد الدفع وإنهاء السيشن',
                      style: AppTextStyles.labelLg.copyWith(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بناء زر اختيار وسيلة الدفع بشكل تفاعلي
  Widget _buildPaymentOption({
    required String label,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryContainer : AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AppColors.secondary : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: isSelected ? AppColors.onSecondaryContainer : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

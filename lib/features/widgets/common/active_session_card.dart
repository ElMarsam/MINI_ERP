import 'dart:async';
import 'package:coworking_erp/core/constants/app_colors.dart';
import 'package:coworking_erp/core/constants/app_text_style.dart';
import 'package:coworking_erp/features/sessions/domain/entities/session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:coworking_erp/core/utils/app_clock.dart';

// ==============================================================================
// إعدادات مظهر شارة نوع الحجز (_BookingTypeConfig)
// تحدد الألوان والأيقونة المناسبة لكل نوع حجز (عيد ميلاد، كورس، اجتماع، مكتب، إلخ)
// ==============================================================================
class _BookingTypeConfig {
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final IconData icon;

  const _BookingTypeConfig({
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.icon,
  });
}

// دالة مساعدة لتحديد الأيقونة والألوان تلقائياً بحسب النص المكتوب في نوع الجلسة أو المكتب
_BookingTypeConfig _getBookingTypeConfig(String type) {
  const bgColor = Color(0xFFF8FAFC);
  const borderColor = Color(0xFFE2E8F0);
  const textColor = Color(0xFF475569);

  IconData icon = LucideIcons.building2;
  if (type.contains('عيد ميلاد')) {
    icon = LucideIcons.cake;
  } else if (type.contains('كورس')) {
    icon = LucideIcons.graduationCap;
  } else if (type.contains('ورشة') || type.contains('ورشه')) {
    icon = LucideIcons.wrench;
  } else if (type.contains('جاردن') ||
      type.contains('حديقة') ||
      type.contains('جولة')) {
    icon = LucideIcons.trees;
  } else if (type.contains('ميتنج') || type.contains('اجتماع')) {
    icon = LucideIcons.users;
  } else if (type.contains('ورك') ||
      type.contains('روك') ||
      type.contains('سبيس') ||
      type.contains('سبيت')) {
    icon = LucideIcons.building2;
  }

  return _BookingTypeConfig(
    bgColor: bgColor,
    borderColor: borderColor,
    textColor: textColor,
    icon: icon,
  );
}

// ==============================================================================
// ويدجت بطاقة الجلسة النشطة (ActiveSessionCard)
// تعرض بيانات الجلسة المفتوحة لايف:
// - اسم العميل ووقت البدء
// - نوع الحجز
// - عداد زمني لايف يتحدث كل ثانية
// - حساب التكلفة الحالية لحظياً
// - زر إيقاف مؤقت / استئناف
// - زر إنهاء وحساب الفاتورة
// ==============================================================================
class ActiveSessionCard extends StatefulWidget {
  // كائن الجلسة المحملة
  final Session session;

  // دالة الإيقاف المؤقت
  final FutureOr<void> Function() onPause;

  // دالة الاستئناف
  final FutureOr<void> Function() onResume;

  // دالة استدعاء حوار إنهاء الجلسة وتسوية الفاتورة
  final VoidCallback onEnd;

  const ActiveSessionCard({
    super.key,
    required this.session,
    required this.onPause,
    required this.onResume,
    required this.onEnd,
  });

  @override
  State<ActiveSessionCard> createState() => _ActiveSessionCardState();
}

class _ActiveSessionCardState extends State<ActiveSessionCard> {
  // تايمر محلي لتحديث واجهة البطاقة كل ثانية لتشغيل العداد والفوترة اللحظية
  Timer? _ticker;

  // مؤشر لمعرفة ما إذا كان طلب الإيقاف/الاستئناف قيد التنفيذ لمنع الضغطات المكررة
  bool _isToggling = false;

  // معالجة الضغط على زر الإيقاف المؤقت / الاستئناف
  Future<void> _handleToggle() async {
    if (_isToggling) return;
    setState(() => _isToggling = true);
    try {
      if (widget.session.status == SessionStatus.paused) {
        await widget.onResume();
      } else {
        await widget.onPause();
      }
    } finally {
      if (mounted) {
        setState(() => _isToggling = false);
      }
    }
  }

  // بدء التايمر المحلي عند تركيب الويدجت
  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.session.status == SessionStatus.active) {
        setState(() {});
      }
    });
  }

  // إلغاء التايمر عند إزالة الكارت من الشجرة لمنع تسريب الذاكرة
  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final isPaused = session.status == SessionStatus.paused;

    // حساب المدة المنقضية (ساعات، دقائق، ثواني)
    final duration = session.elapsedDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    // تنسيق نص التايمر الرقمي
    final timeString = hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // حساب التكلفة الحالية بالجنيه
    final currentCost = session.calculateCurrentAmount();
    final pausedMinutes = session.totalPausedDuration.inMinutes;

    // تحديد نوع الحجز وأيقونته
    final bookingType =
        (session.deskLabel != null && session.deskLabel!.trim().isNotEmpty)
        ? session.deskLabel!.trim()
        : 'الورك سبيس';
    final typeConfig = _getBookingTypeConfig(bookingType);

    // تنسيق وقت بدء الجلسة بصيغة 12 ساعة بتوقيت القاهرة مستقلاً عن ضبط الجهاز
    String startTimeFormatted;
    final cairoStartTime = AppClock.toCairo(session.startTime);
    try {
      startTimeFormatted = DateFormat('hh:mm a', 'ar').format(cairoStartTime);
    } catch (_) {
      final h = cairoStartTime.hour > 12
          ? cairoStartTime.hour - 12
          : cairoStartTime.hour;
      final amPm = cairoStartTime.hour >= 12 ? 'م' : 'ص';
      startTimeFormatted =
          '${h.toString().padLeft(2, '0')}:${cairoStartTime.minute.toString().padLeft(2, '0')} $amPm';
    }

    // تعطيل التفاعل وتخفيف الشفافية أثناء تنفيذ عمليات التبديل (Pause / Resume)
    return IgnorePointer(
      ignoring: _isToggling,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isToggling ? 0.8 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPaused
                  ? AppColors.statusPendingBorder
                  : AppColors.dividerInteractive,
              width: isPaused ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isPaused
                    ? AppColors.tertiary.withValues(alpha: 0.06)
                    : const Color(0x060F172A),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── ترويسة البطاقة: اسم العميل، وقت البدء، ونوع الحجز ───
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    // صورة / أيقونة العميل الرمزية
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPaused
                            ? AppColors.statusPendingBg
                            : AppColors.secondaryContainer,
                        border: Border.all(
                          color: isPaused
                              ? AppColors.statusPendingBorder
                              : AppColors.statusActiveBorder,
                        ),
                      ),
                      child: Icon(
                        LucideIcons.user,
                        size: 20,
                        color: isPaused
                            ? AppColors.tertiary
                            : AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // اسم العميل + توقيت البدء + شارة التوقف إن وُجدت
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.customerName,
                            style: AppTextStyles.headlineSm.copyWith(
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.clock,
                                size: 12,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'بدأت: $startTimeFormatted',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              if (pausedMinutes > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusPendingBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'توقف: $pausedMinutes د',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.onStatusPending,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // شارة نوع الحجز (مكتب / قاعة / كورس)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: typeConfig.bgColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: typeConfig.borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            typeConfig.icon,
                            size: 12,
                            color: typeConfig.textColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            bookingType,
                            style: AppTextStyles.labelSm.copyWith(
                              color: typeConfig.textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: AppColors.divider),
              const Spacer(),

              // ─── صندوق العداد اللحظي وحساب الفاتورة الحالية ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isPaused
                        ? AppColors.statusPendingBg
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPaused
                          ? AppColors.statusPendingBorder
                          : AppColors.outlineVariant,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // عداد الوقت المستغرق
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isPaused
                                    ? LucideIcons.pauseCircle
                                    : LucideIcons.timer,
                                size: 13,
                                color: isPaused
                                    ? AppColors.onStatusPending
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPaused
                                    ? 'الوقت (متوقف مؤقتاً)'
                                    : 'الوقت المستغرق',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: isPaused
                                      ? AppColors.onStatusPending
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            timeString,
                            style: AppTextStyles.headlineLg.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: isPaused
                                  ? AppColors.onStatusPending
                                  : AppColors.textPrimary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // الحساب المالي التراكمي اللحظي
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.coins,
                                size: 13,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'الحساب الحالي',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${currentCost.toStringAsFixed(1)} ج.م',
                            style: AppTextStyles.headlineLg.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ─── شريط الأزرار التفاعلية (إيقاف/استئناف + إنهاء الجلسة) ───
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Row(
                  children: [
                    // زر الإيقاف المؤقت أو الاستئناف
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: _isToggling ? null : _handleToggle,
                        icon: _isToggling
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isPaused
                                        ? AppColors.secondary
                                        : AppColors.tertiary,
                                  ),
                                ),
                              )
                            : Icon(
                                isPaused ? LucideIcons.play : LucideIcons.pause,
                                size: 15,
                                color: isPaused
                                    ? AppColors.secondary
                                    : AppColors.tertiary,
                              ),
                        label: Text(
                          _isToggling
                              ? (isPaused
                                    ? 'جاري الاستئناف...'
                                    : 'جاري الإيقاف...')
                              : (isPaused ? 'استئناف' : 'إيقاف مؤقت'),
                          style: AppTextStyles.labelLg.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPaused
                                ? AppColors.secondary
                                : AppColors.tertiary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          disabledForegroundColor: isPaused
                              ? AppColors.secondary
                              : AppColors.tertiary,
                          disabledIconColor: isPaused
                              ? AppColors.secondary
                              : AppColors.tertiary,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: BorderSide(
                            color: isPaused
                                ? AppColors.secondary.withValues(alpha: 0.7)
                                : AppColors.tertiary.withValues(alpha: 0.7),
                            width: _isToggling ? 1.5 : 1.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // زر إنهاء الجلسة وتسوية الفاتورة
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: _isToggling ? null : widget.onEnd,
                        icon: const Icon(
                          LucideIcons.receiptText,
                          size: 15,
                          color: Colors.white,
                        ),
                        label: Text(
                          'إنهاء وحساب الفاتورة',
                          style: AppTextStyles.labelLg.copyWith(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isToggling
                              ? AppColors.primary.withValues(alpha: 0.5)
                              : AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

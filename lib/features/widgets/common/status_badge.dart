import 'package:coworking_erp/core/constants/app_colors.dart';
import 'package:coworking_erp/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';

// ==============================================================================
// أنواع حالات الشارة (Badge Status)
// تحدد النسق اللوني لشارة الحالة (نشط، معلق، خطأ، معلومات، محايد)
// ==============================================================================
enum BadgeStatus {
  active, // أخضر - نشط
  pending, // عنبري - معلق / مؤقت
  error, // أحمر - خطأ / ملغي
  info, // أزرق - معلوماتي
  neutral, // رمادي - محايد / منتهي
}

// ==============================================================================
// ويدجت شارة الحالة (StatusBadge)
// تعرض كبسولة صغيرة ملونة تعبر عن حالة عنصر ما، مع نقطة نابضة للجلسات النشطة
// ==============================================================================
class StatusBadge extends StatelessWidget {
  // النص المكتوب داخل الشارة
  final String label;

  // نوع الحالة لتحديد الألوان المناسبة
  final BadgeStatus status;

  // هل تظهر نقطة خضراء نابضة في بداية الشارة أم لا
  final bool showDot;

  // الـ Constructor الأساسي للشارة
  const StatusBadge({
    super.key,
    required this.label,
    required this.status,
    this.showDot = true,
  });

  // Factory Constructor: يحول نص حالة الجلسة (active / paused / closed) إلى شارة مترجمة ومناسبة
  factory StatusBadge.fromSessionStatus(String status) {
    return StatusBadge(
      // ترجمة نص الحالة إلى العربية
      label: switch (status) {
        'active' => 'نشط',
        'paused' => 'متوقف',
        'closed' => 'منتهي',
        _ => status,
      },
      // تعيين نوع الـ BadgeStatus المقابل
      status: switch (status) {
        'active' => BadgeStatus.active,
        'paused' => BadgeStatus.pending,
        'closed' => BadgeStatus.neutral,
        _ => BadgeStatus.neutral,
      },
    );
  }

  // لون الخلفية المتغير حسب الحالة
  Color get _bgColor => switch (status) {
    BadgeStatus.active => AppColors.statusActiveBg,
    BadgeStatus.pending => AppColors.statusPendingBg,
    BadgeStatus.error => AppColors.statusErrorBg,
    BadgeStatus.info => AppColors.statusInfoBg,
    BadgeStatus.neutral => AppColors.surfaceVariant,
  };

  // لون الإطار (Border) المتغير حسب الحالة
  Color get _borderColor => switch (status) {
    BadgeStatus.active => AppColors.statusActiveBorder,
    BadgeStatus.pending => AppColors.statusPendingBorder,
    BadgeStatus.error => AppColors.statusErrorBorder,
    BadgeStatus.info => AppColors.statusInfoBorder,
    BadgeStatus.neutral => AppColors.dividerInteractive,
  };

  // لون النص المتغير حسب الحالة لضمان التباين العالي وسهولة القراءة
  Color get _textColor => switch (status) {
    BadgeStatus.active => AppColors.onStatusActive,
    BadgeStatus.pending => AppColors.onStatusPending,
    BadgeStatus.error => AppColors.onStatusError,
    BadgeStatus.info => AppColors.statusInfo,
    BadgeStatus.neutral => AppColors.textMuted,
  };

  @override
  Widget build(BuildContext context) {
    // حاوية بيضاوية دائرية الحواف (Capsule/Pill)
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // إظهار النقطة النابضة فقط للحالة النشطة
          if (showDot && status == BadgeStatus.active) ...[
            _PulsingDot(color: _textColor),
            const SizedBox(width: 4),
          ],
          // نص الحالة
          Text(label, style: AppTextStyles.labelMd.copyWith(color: _textColor)),
        ],
      ),
    );
  }
}

// ==============================================================================
// ويدجت النقطة النابضة (_PulsingDot)
// تصنع أنيميشن نبض مستمر (Pulsing Animation) لبيان أن الجلسة قيد التشغيل حالياً
// ==============================================================================
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // تهيئة الأنيميشن ليتكرر دورياً بين الشفافية الكاملة ونصف الشفافية
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  // التخلص من الـ AnimationController عند إزالة الويدجت
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // إعادة بناء النقطة مع تغير قيمة الشفافية
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, _) => Opacity(
        opacity: _animation.value,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

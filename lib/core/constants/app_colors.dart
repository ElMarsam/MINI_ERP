import 'package:flutter/material.dart';

// كلاس يحتوي على كل الألوان المستخدمة في التطبيق
// الفكرة: بدل ما تكتب Color(0xFF...) في كل Widget، بتستخدم AppColors.primary مثلاً
// وبكده لو احتجت تغيير لون معين بتغيره من مكان واحد بس
class AppColors {
  AppColors._(); // private constructor: يمنع إنشاء instances

  // ─── اللون الأساسي (Primary) ─────────────────────────────────────────────────
  // Navy غامق - بيُستخدم في الأزرار الرئيسية والخلفيات الداكنة
  static const Color primary = Color(0xFF0F172A);
  static const Color primaryVariant = Color(
    0xFF1E293B,
  ); // نسخة أفتح من الـ primary
  static const Color primaryContainer = Color(
    0xFF1E293B,
  ); // خلفية العناصر الـ primary
  static const Color onPrimary = Color(
    0xFFFFFFFF,
  ); // لون النص فوق الـ primary (أبيض)
  static const Color onPrimaryContainer = Color(
    0xFF94A3B8,
  ); // لون النص فوق الـ container

  // ─── اللون الثانوي (Secondary) ─────────────────────────────────────────────
  // أخضر زمردي - لون النشاط والتأكيد (Active sessions, success, ...)
  static const Color secondary = Color(0xFF059669);
  static const Color secondaryLight = Color(0xFF10B981); // نسخة أفتح
  static const Color secondaryContainer = Color(
    0xFFECFDF5,
  ); // خلفية فاتحة خضراء
  static const Color onSecondary = Color(
    0xFFFFFFFF,
  ); // نص فوق الـ secondary (أبيض)
  static const Color onSecondaryContainer = Color(
    0xFF065F46,
  ); // نص داكن فوق الخلفية الخضراء

  // ─── اللون الثالث (Tertiary) ────────────────────────────────────────────────
  // عنبري ذهبي - بيُستخدم للتحذيرات والـ "paused" state
  static const Color tertiary = Color(0xFFD97706);
  static const Color tertiaryContainer = Color(0xFFFFFBEB); // خلفية صفراء فاتحة
  static const Color onTertiary = Color(0xFFFFFFFF); // نص فوقه أبيض
  static const Color onTertiaryContainer = Color(
    0xFFB45309,
  ); // نص داكن فوق الخلفية

  // ─── خلفيات الـ Surface ──────────────────────────────────────────────────────
  // الخلفيات الرئيسية للتطبيق والكروت
  static const Color background = Color(
    0xFFF8FAFC,
  ); // خلفية الصفحة الرئيسية (رمادي فاتح جداً)
  static const Color surface = Color(
    0xFFFFFFFF,
  ); // خلفية الكروت والـ Dialogs (أبيض)
  static const Color surfaceVariant = Color(
    0xFFF1F5F9,
  ); // خلفية بديلة أكثر تدريجاً
  static const Color surfaceContainerHighest = Color(
    0xFFE2E8F0,
  ); // أعمق نسخة من الـ surface
  static const Color onBackground = Color(0xFF0F172A); // لون النص على الخلفية
  static const Color onSurface = Color(0xFF0F172A); // لون النص على الـ surface
  static const Color onSurfaceVariant = Color(
    0xFF64748B,
  ); // لون النص الثانوي على الـ surface

  // ─── ألوان حالة "نشط" (Active) ──────────────────────────────────────────────
  // بتُستخدم على كروت السيشنات النشطة
  static const Color statusActive = Color(0xFF059669); // اللون الأخضر الأساسي
  static const Color statusActiveBg = Color(
    0xFFECFDF5,
  ); // خلفية خضراء فاتحة جداً
  static const Color statusActiveBorder = Color(0xFFA7F3D0); // بوردر أخضر فاتح
  static const Color onStatusActive = Color(
    0xFF047857,
  ); // نص داكن فوق الخلفية الخضراء

  // ─── ألوان حالة "في الانتظار" (Pending/Paused) ──────────────────────────────
  // بتُستخدم على السيشنات المتوقفة مؤقتاً والحجوزات المعلقة
  static const Color statusPending = Color(0xFFD97706); // برتقالي/عنبري
  static const Color statusPendingBg = Color(0xFFFFFBEB); // خلفية صفراء فاتحة
  static const Color statusPendingBorder = Color(0xFFFDE68A); // بوردر أصفر فاتح
  static const Color onStatusPending = Color(0xFFB45309); // نص داكن فوق الخلفية

  // ─── ألوان حالة "خطأ" (Error) ────────────────────────────────────────────────
  // بتُستخدم في رسائل الخطأ والإجراءات الحذرة
  static const Color statusError = Color(0xFFE11D48); // أحمر وردي
  static const Color statusErrorBg = Color(0xFFFFF1F2); // خلفية وردية فاتحة
  static const Color statusErrorBorder = Color(0xFFFECDD3); // بوردر وردي
  static const Color onStatusError = Color(0xFFBE123C); // نص داكن فوق الخلفية

  // ─── ألوان حالة "معلومة" (Info) ─────────────────────────────────────────────
  static const Color statusInfo = Color(0xFF0284C7); // أزرق سماوي
  static const Color statusInfoBg = Color(0xFFF0F9FF); // خلفية زرقاء فاتحة
  static const Color statusInfoBorder = Color(0xFFBAE6FD); // بوردر أزرق فاتح

  // ─── ألوان الـ Error الرئيسية ────────────────────────────────────────────────
  static const Color error = Color(0xFFE11D48);
  static const Color errorContainer = Color(0xFFFFF1F2);
  static const Color onError = Color(0xFFFFFFFF);

  // ─── الحدود والفواصل (Borders & Dividers) ────────────────────────────────────
  static const Color outline = Color(0xFF94A3B8); // حدود العناصر التفاعلية
  static const Color outlineVariant = Color(0xFFE2E8F0); // حدود الكروت الخفيفة
  static const Color divider = Color(0xFFE2E8F0); // خط الفصل بين العناصر
  static const Color dividerInteractive = Color(
    0xFFCBD5E1,
  ); // حدود الـ Inputs والـ Buttons

  // ─── ألوان النصوص ───────────────────────────────────────────────────────────
  static const Color textPrimary = Color(
    0xFF0F172A,
  ); // النص الرئيسي (أسود تقريباً)
  static const Color textSecondary = Color(
    0xFF475569,
  ); // النص الثانوي (رمادي داكن)
  static const Color textMuted = Color(0xFF64748B); // النص الخافت (رمادي متوسط)
  static const Color textDisabled = Color(0xFF94A3B8); // نص العناصر المعطلة

  // ─── ألوان شريط التنقل الجانبي (Navigation Rail / Sidebar) ──────────────────
  static const Color navRailBg = Color(0xFF000000); // خلفية الـ Sidebar (أسود)
  static const Color navRailActive = Color(
    0xFF063E2F,
  ); // خلفية العنصر المختار (أخضر غامق)
  static const Color navRailActiveBorder = Color(
    0xFF10B981,
  ); // بوردر العنصر المختار (أخضر مضيء)
  static const Color navRailText = Color(0xFF9CA3AF); // لون النص العادي (رمادي)
  static const Color navRailActiveText = Color(
    0xFFFFFFFF,
  ); // لون النص المختار (أبيض)
  static const Color navRailActiveIndicator = Color(
    0xFF10B981,
  ); // مؤشر التحديد الجانبي

  // ─── ألوان الجداول (Tables) ─────────────────────────────────────────────────
  static const Color tableHeaderBg = Color(0xFFF8FAFC); // خلفية صف العناوين
  static const Color tableRowHover = Color(
    0xFFF8FAFC,
  ); // خلفية الصف عند Hover الماوس
  static const Color tableRowSelected = Color(0xFFF0FDF4); // خلفية الصف المختار
  static const Color tableRowSelectedBorder = Color(
    0xFF059669,
  ); // بوردر الصف المختار
  static const Color tableRowDivider = Color(0xFFE2E8F0); // خط الفصل بين الصفوف

  // ─── ألوان خريطة الـ Desks (Floor Map) ──────────────────────────────────────
  static const Color deskOccupiedBg = Color(
    0xFFF0FDF4,
  ); // خلفية المكتب المشغول (أخضر فاتح)
  static const Color deskOccupiedBorder = Color(
    0xFF10B981,
  ); // بوردر المكتب المشغول (أخضر)
  static const Color deskAvailableBg = Color(
    0xFFFFFFFF,
  ); // خلفية المكتب المتاح (أبيض)
  static const Color deskAvailableBorder = Color(
    0xFFCBD5E1,
  ); // بوردر المكتب المتاح (رمادي)
  static const Color deskReservedBg = Color(
    0xFFFFFBEB,
  ); // خلفية المكتب المحجوز (أصفر فاتح)
  static const Color deskReservedBorder = Color(
    0xFFF59E0B,
  ); // بوردر المكتب المحجوز (ذهبي)
}

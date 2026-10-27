import 'package:coworking_erp/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

// كلاس يحتوي على كل أنماط النصوص المستخدمة في التطبيق
// الفكرة: بدل ما تعرّف TextStyle في كل Widget، بتستخدم AppTextStyles.headlineLg مثلاً
// وبكده الـ Typography بتبقى موحدة في التطبيق كله
class AppTextStyles {
  AppTextStyles._(); // private constructor: يمنع إنشاء instances

  // ─── الخطوط المستخدمة ───────────────────────────────────────────────────────
  static const String _fontBody =
      'IBMPlexSansArabic'; // خط النصوص العادية (واضح وقابل للقراءة)
  static const String _fontHeadline = 'Cairo'; // خط العناوين (هندسي ومميز)

  // ─── أنماط العناوين (Headline Styles) ───────────────────────────────────────
  // بتستخدم خط Cairo - مناسب للعناوين الكبيرة والبطاقات والإحصائيات

  // عنوان كبير جداً - بيُستخدم مثلاً لأرقام KPI في الداشبورد
  static const TextStyle headlineXl = TextStyle(
    fontFamily: _fontHeadline,
    fontSize: 28,
    fontWeight: FontWeight.w700, // Bold
    height: 1.3, // تباعد الأسطر
    color: AppColors.textPrimary,
    fontFeatures: [
      FontFeature.tabularFigures(),
    ], // الأرقام بتاخد عرض ثابت (مهم للجداول)
  );

  // عنوان كبير - بيُستخدم لعناوين الصفحات
  static const TextStyle headlineLg = TextStyle(
    fontFamily: _fontHeadline,
    fontSize: 22,
    fontWeight: FontWeight.w600, // Semi-bold
    height: 1.35,
    color: AppColors.textPrimary,
  );

  // عنوان متوسط - بيُستخدم لعناوين الكروت والـ Sections
  static const TextStyle headlineMd = TextStyle(
    fontFamily: _fontHeadline,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // عنوان صغير - بيُستخدم لعناوين الأقسام الفرعية
  static const TextStyle headlineSm = TextStyle(
    fontFamily: _fontHeadline,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  // ─── أنماط النص العادي (Body Styles) ────────────────────────────────────────
  // بتستخدم خط IBM Plex Sans Arabic - مريح للقراءة في النصوص الطويلة والجداول

  // نص كبير - للمعلومات التفصيلية الأساسية
  static const TextStyle bodyLg = TextStyle(
    fontFamily: _fontBody,
    fontSize: 15,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5,
    color: AppColors.textPrimary,
  );

  // نص متوسط - الأكثر استخداماً في التطبيق (قوائم، بيانات جداول، ...)
  static const TextStyle bodyMd = TextStyle(
    fontFamily: _fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  // نص صغير - للتفاصيل الثانوية والـ placeholders
  static const TextStyle bodySm = TextStyle(
    fontFamily: _fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary, // لون أفتح قليلاً
  );

  // ─── أنماط التسميات (Label Styles) ──────────────────────────────────────────
  // بتُستخدم في أزرار، Chips، عناوين أعمدة الجداول

  // تسمية كبيرة - مناسبة لنص الأزرار الرئيسية
  static const TextStyle labelLg = TextStyle(
    fontFamily: _fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w600, // Semi-bold
    height: 1.25,
    color: AppColors.textPrimary,
  );

  // تسمية متوسطة - مناسبة للـ Chips وعناوين الأعمدة
  static const TextStyle labelMd = TextStyle(
    fontFamily: _fontBody,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.textMuted, // لون رمادي خافت
  );

  // تسمية صغيرة - مناسبة للـ badges والتسميات الثانوية
  static const TextStyle labelSm = TextStyle(
    fontFamily: _fontBody,
    fontSize: 10,
    fontWeight: FontWeight.w500, // Medium
    height: 1.2,
    color: AppColors.textMuted,
  );

  // ─── نمط الأرقام الكبيرة (KPI Metric) ──────────────────────────────────────
  // بيُستخدم تحديداً لإظهار الأرقام الكبيرة في بطاقات الإحصائيات في الداشبورد
  static const TextStyle numericMetric = TextStyle(
    fontFamily: _fontHeadline, // Cairo عشان الأرقام تبقى مميزة
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()], // أرقام بعرض ثابت
  );

  // ─── نمط أرقام الجداول (Tabular Numeric) ────────────────────────────────────
  // بيُستخدم في خلايا الجداول اللي فيها أرقام (مبالغ، ساعات، ...)
  static const TextStyle numericTabular = TextStyle(
    fontFamily: _fontBody, // IBM Plex أفضل للأرقام الصغيرة في الجداول
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: AppColors.textPrimary,
    fontFeatures: [
      FontFeature.tabularFigures(),
    ], // أرقام بعرض ثابت (مهم للمحاذاة)
  );
}

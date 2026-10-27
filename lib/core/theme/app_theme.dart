import 'package:erp_mini/core/constants/app_colors.dart';
import 'package:erp_mini/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';

// كلاس يحتوي على الثيم الكامل للتطبيق
// الثيم بيعرّف شكل كل Widget بصورة مركزية بدل ما تعرّفه في كل حتة
class AppTheme {
  AppTheme._(); // private constructor

  // الثيم الفاتح للتطبيق - الثيم الوحيد المستخدم حالياً
  static ThemeData get lightTheme {
    return ThemeData(
      // استخدام Material 3 (أحدث نسخة من نظام التصميم من Google)
      useMaterial3: true,

      // ─── نظام الألوان (Color Scheme) ──────────────────────────────────────────
      // بيحدد الألوان الرئيسية اللي Flutter بيستخدمها تلقائياً في كل الـ Widgets
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: Color(0xFF93000A),
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: Color(0xFF2D3133),
        onInverseSurface: Color(0xFFEFF1F3),
        inversePrimary: AppColors.onPrimaryContainer,
        surfaceTint: Color(0xFF565E74),
      ),

      // ─── الخلفيات الرئيسية ─────────────────────────────────────────────────
      scaffoldBackgroundColor: AppColors.background, // لون خلفية كل الصفحات
      // ─── الفواصل (Dividers) ────────────────────────────────────────────────
      dividerColor: AppColors.divider,
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1, // سماكة الخط
        space: 0, // المسافة حول الخط
      ),

      // ─── أنماط النصوص (Text Theme) ────────────────────────────────────────
      // ربط أنماط النص بـ Material TextTheme حتى يمكن استخدامهم عبر Theme.of(context).textTheme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.headlineXl,
        displayMedium: AppTextStyles.headlineLg,
        displaySmall: AppTextStyles.headlineMd,
        headlineLarge: AppTextStyles.headlineLg,
        headlineMedium: AppTextStyles.headlineMd,
        headlineSmall: AppTextStyles.headlineSm,
        titleLarge: AppTextStyles.headlineSm,
        titleMedium: AppTextStyles.labelLg,
        titleSmall: AppTextStyles.labelMd,
        bodyLarge: AppTextStyles.bodyLg,
        bodyMedium: AppTextStyles.bodyMd,
        bodySmall: AppTextStyles.bodySm,
        labelLarge: AppTextStyles.labelLg,
        labelMedium: AppTextStyles.labelMd,
        labelSmall: AppTextStyles.labelSm,
      ),

      // ─── الـ Text Fields والـ Inputs ────────────────────────────────────────
      // شكل أي TextField أو TextFormField في التطبيق
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface, // خلفية بيضاء
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        // حدود الـ Input في الحالة العادية
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: AppColors.dividerInteractive,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: AppColors.dividerInteractive,
            width: 1,
          ),
        ),
        // حدود الـ Input لما يكون مُركّز عليه (focused)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        // حدود الـ Input لما يكون فيه خطأ
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: AppTextStyles.bodyMd.copyWith(
          color: AppColors.textDisabled,
        ), // نمط الـ placeholder
        labelStyle: AppTextStyles.labelMd,
        isDense: true, // يجعل الـ Input أصغر ارتفاعاً
      ),

      // ─── الأزرار المرفوعة (ElevatedButton) ─────────────────────────────────
      // شكل أي ElevatedButton في التطبيق
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, // خلفية navy داكنة
              foregroundColor: AppColors.onPrimary, // نص أبيض
              elevation: 0, // بدون ظل
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              minimumSize: const Size(0, 36), // أقل ارتفاع 36px
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              textStyle: AppTextStyles.labelLg,
            ).copyWith(
              // إخفاء مؤشر Windows عند الـ Hover (لأننا نستخدم Lottie cursor)
              mouseCursor: const WidgetStatePropertyAll(
                SystemMouseCursors.none,
              ),
            ),
      ),

      // ─── الأزرار المخططة (OutlinedButton) ─────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(
                color: AppColors.dividerInteractive,
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              textStyle: AppTextStyles.labelLg,
            ).copyWith(
              mouseCursor: const WidgetStatePropertyAll(
                SystemMouseCursors.none,
              ),
            ),
      ),

      // ─── أزرار النص (TextButton) ───────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom().copyWith(
          mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.none),
        ),
      ),

      // ─── أزرار الأيقونات (IconButton) ─────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom().copyWith(
          mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.none),
        ),
      ),

      // ─── الكروت (Card) ───────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface, // خلفية بيضاء
        elevation: 0, // بدون ظل (مسطح)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(
            color: AppColors.divider,
            width: 1,
          ), // بوردر خفيف
        ),
        shadowColor: const Color(0x0A0F172A), // ظل شفاف جداً
        margin: EdgeInsets.zero,
      ),

      // ─── الـ Chips ────────────────────────────────────────────────────────────
      // مثل بادجات الحالة (Active, Paused, ...)
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ), // دائري تماماً
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        labelStyle: AppTextStyles.labelMd,
      ),

      // ─── الـ Checkboxes ──────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ), // زوايا مدورة قليلاً
        side: const BorderSide(color: AppColors.outline, width: 1.5),
        // اللون يتغير حسب الحالة (مختار أم لا)
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary; // محدد → navy
          }
          return Colors.transparent; // غير محدد → شفاف
        }),
      ),

      // ─── شريط التنقل الجانبي (NavigationRail) ───────────────────────────────
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.navRailBg, // خلفية سوداء
        selectedIconTheme: IconThemeData(
          color: AppColors.navRailActiveText,
        ), // أيقونة مختارة بيضاء
        unselectedIconTheme: IconThemeData(
          color: AppColors.navRailText,
        ), // أيقونة عادية رمادية
        selectedLabelTextStyle: TextStyle(
          color: AppColors.navRailActiveText,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: AppColors.navRailText,
          fontSize: 11,
        ),
        indicatorColor:
            AppColors.navRailActive, // خلفية الـ indicator (أخضر غامق)
        elevation: 0,
        minWidth: 64, // عرض الـ Sidebar المقفول
        minExtendedWidth: 240, // عرض الـ Sidebar المفتوح
      ),

      // ─── التلميحات (Tooltips) ─────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.primaryVariant, // خلفية navy
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: AppTextStyles.bodySm.copyWith(
          color: AppColors.onPrimary,
        ), // نص أبيض
      ),

      // ─── التبويبات (TabBar) ──────────────────────────────────────────────────
      tabBarTheme: const TabBarThemeData(
        indicatorColor: AppColors.secondary, // الـ indicator أخضر
        labelColor: AppColors.secondary, // لون التبويب المختار أخضر
        unselectedLabelColor:
            AppColors.textMuted, // لون التبويبات العادية رمادي
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:coworking_erp/core/theme/app_colors.dart';
import 'package:coworking_erp/core/theme/app_text_styles.dart';
import 'package:coworking_erp/core/routes/app_router.dart';

// ==============================================================================
// ويدجت الهيكل العام للتطبيق (AppShell)
// الإطار الثابت الذي يحيط بجميع صفحات البرنامج:
// - شريط التنقل الجانبي الأسود (Navigation Rail / Sidebar)
// - الخط الفاصل الرأسي
// - مساحة عرض الصفحة النشطة الحالية (child)
// ==============================================================================
class AppShell extends StatefulWidget {
  // الصفحة التي يتم عرضها داخل الهيكل
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // قائمة عناصر القائمة الجانبية مع الأيقونات والمسارات (Routes)
  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: LucideIcons.layoutGrid,
      activeIcon: LucideIcons.layoutGrid,
      label: 'الرئيسية',
      route: AppRoutes.dashboard,
    ),
    _NavItem(
      icon: LucideIcons.timer,
      activeIcon: LucideIcons.timer,
      label: 'السيشنات',
      route: AppRoutes.sessions,
    ),
    _NavItem(
      icon: LucideIcons.coffee,
      activeIcon: LucideIcons.coffee,
      label: 'البوفيه والمنيو',
      route: AppRoutes.cafe,
    ),
    _NavItem(
      icon: LucideIcons.cake,
      activeIcon: LucideIcons.cake,
      label: 'أعياد الميلاد',
      route: AppRoutes.birthdays,
    ),
    _NavItem(
      icon: LucideIcons.chartColumn,
      activeIcon: LucideIcons.chartColumn,
      label: 'التقارير المالية',
      route: AppRoutes.reports,
    ),
    _NavItem(
      icon: LucideIcons.settings,
      activeIcon: LucideIcons.settings,
      label: 'الإعدادات',
      route: AppRoutes.settings,
    ),
  ];

  // تحديد العنصر النشط بناءً على مسار الـ URL الحالي
  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _navItems.length; i++) {
      if (location == _navItems[i].route) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // 1. شريط التنقل الجانبي (Sidebar)
          _buildNavRail(context, selectedIndex),

          // 2. خط فاصل عمودي داكن يفصل الشريط عن محتوى الصفحة
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: Color(0xFF161B22),
          ),

          // 3. مساحة عرض الصفحة المختارة
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }

  // بناء حاوية القائمة الجانبية السوداء
  Widget _buildNavRail(BuildContext context, int selectedIndex) {
    return Container(
      width: 210.0,
      color: AppColors.navRailBg,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        itemCount: _navItems.length,
        itemBuilder: (context, i) {
          final item = _navItems[i];
          final isSelected = i == selectedIndex;
          return _NavButton(
            item: item,
            isSelected: isSelected,
            onTap: () => context.go(item.route),
          );
        },
      ),
    );
  }
}

// ==============================================================================
// ويدجت زر عنصر القائمة الجانبية (_NavButton)
// تدعم تأثيرات الـ Hover وتوهج النيون الأخضر للعنصر النشط (Glow Effect)
// ==============================================================================
class _NavButton extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  // حالة تحويم الماوس فوق الزر
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final isHighlighted = isSelected || _isHovered;

    // تحديد ألوان الخلفية والإطار حسب حالة التحديد أو التحويم
    Color backgroundColor;
    Color borderColor;

    if (isSelected) {
      backgroundColor = const Color(0xFF071410);
      borderColor = const Color(0xFF0D5E44);
    } else if (_isHovered) {
      backgroundColor = AppColors.navRailActive;
      borderColor = AppColors.navRailActiveBorder;
    } else {
      backgroundColor = Colors.transparent;
      borderColor = Colors.transparent;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: MouseRegion(
        cursor: SystemMouseCursors.none,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          mouseCursor: SystemMouseCursors.none,
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: Colors.transparent,
          splashColor: AppColors.navRailActiveBorder.withValues(alpha: 0.15),
          highlightColor: Colors.transparent,
          child: Stack(
            children: [
              // الحاوية الأساسية للزر مع الأيقونة والنص
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: borderColor,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isHighlighted ? widget.item.activeIcon : widget.item.icon,
                      color: isHighlighted
                          ? AppColors.navRailActiveText
                          : AppColors.navRailText,
                      size: 19,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.item.label,
                        style: AppTextStyles.labelLg.copyWith(
                          color: isHighlighted
                              ? AppColors.navRailActiveText
                              : const Color(0xFFD1D5DB),
                          fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // خط النيون الأخضر المتوهج في الجانب الأيمن للعنصر النشط
              if (isSelected)
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 3.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FFA3),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FFA3).withValues(alpha: 0.9),
                          blurRadius: 7,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.5),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// كائن عنصر التنقل (_NavItem)
// يحمل أيقونة ومسار واسم كل صفحة في القائمة الجانبية
// ==============================================================================
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

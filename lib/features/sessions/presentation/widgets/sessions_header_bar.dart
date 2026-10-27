import 'package:coworking_erp/core/constants/app_colors.dart';
import 'package:coworking_erp/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ==============================================================================
// ويدجت الشريط العلوي لإدارة السيشنات (SessionsHeaderBar)
// يجمع بين عنوان الشاشة، حقل البحث الفوري بالاسم أو المكتب، وزر تسجيل الدخول
// ==============================================================================
class SessionsHeaderBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onStartSessionPressed;

  const SessionsHeaderBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onStartSessionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // عنوان الشاشة ووصفها
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إدارة السيشنات', style: AppTextStyles.headlineLg),
            Text(
              'تسجيل الدخول، ومتابعة الوقت الفعلي، وإنهاء الجلسات وطرق الدفع',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
        const Spacer(),
        // حقل البحث السريع بالاسم أو رقم المكتب
        SizedBox(
          width: 260,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'بحث باسم العميل أو المكتب...',
              prefixIcon: const Icon(LucideIcons.search, size: 16),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 14),
                      onPressed: onClearSearch,
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(width: 12),
        // زر فتح نافذة بدء سيشن جديدة
        ElevatedButton.icon(
          onPressed: onStartSessionPressed,
          icon: const Icon(LucideIcons.plus, size: 16, color: Colors.white),
          label: Text(
            'بدء سيشن جديدة',
            style: AppTextStyles.labelLg.copyWith(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}

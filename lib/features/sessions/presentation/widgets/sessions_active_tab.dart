import 'package:coworking_erp/core/constants/app_colors.dart';
import 'package:coworking_erp/core/constants/app_text_style.dart';
import 'package:coworking_erp/features/sessions/domain/entities/session.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../widgets/common/active_session_card.dart';

// ==============================================================================
// ويدجت تبويب الجلسات النشطة (SessionsActiveTab)
// يعرض شبكة الكروت التفاعلية للجلسات الحالية مع استجابة للأحجام وحالة فارغة
// ==============================================================================
class SessionsActiveTab extends StatelessWidget {
  final List<Session> sessions;
  final bool isSearching;
  final VoidCallback onStartSession;
  final Future<void> Function(String sessionId) onPauseSession;
  final Future<void> Function(String sessionId) onResumeSession;
  final void Function(Session session) onEndSession;

  const SessionsActiveTab({
    super.key,
    required this.sessions,
    required this.isSearching,
    required this.onStartSession,
    required this.onPauseSession,
    required this.onResumeSession,
    required this.onEndSession,
  });

  @override
  Widget build(BuildContext context) {
    // حالة عدم وجود سيشنات نشطة أو عدم مطابقة نتائج البحث
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.armchair,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              isSearching
                  ? 'لم يتم العثور على نتائج للبحث'
                  : 'لا توجد سيشنات نشطة حالياً',
              style: AppTextStyles.headlineSm,
            ),
            const SizedBox(height: 16),
            if (!isSearching)
              ElevatedButton.icon(
                onPressed: onStartSession,
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('تسجيل دخول عميل جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      );
    }

    // شبكة متجاوبة لعرض بطاقات الجلسات المفتوحة بحسب حجم الشاشة
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 900) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1300) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 260,
          ),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];

            return ActiveSessionCard(
              key: ValueKey('sess_${session.id}'),
              session: session,
              onPause: () => onPauseSession(session.id),
              onResume: () => onResumeSession(session.id),
              onEnd: () => onEndSession(session),
            );
          },
        );
      },
    );
  }
}

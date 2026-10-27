import 'package:coworking_erp/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:coworking_erp/features/widgets/layout/app_sidebar.dart';
import 'package:go_router/go_router.dart';

// كلاس بيحتوي على اسم كل Route في التطبيق كـ constants
// الهدف: تتجنب كتابة الـ paths يدوياً في كل حتة وتنقلها من مكان واحد
class AppRoutes {
  static const String dashboard = '/'; // الصفحة الرئيسية
  static const String sessions = '/sessions'; // صفحة السيشنات
  static const String cafe = '/cafe'; // صفحة الكافيه
  static const String birthdays = '/birthdays'; // صفحة حجوزات الأعياد
  static const String reports = '/reports'; // صفحة التقارير
  static const String settings = '/settings'; // صفحة الإعدادات
}

// تعريف الـ Router الرئيسي للتطبيق باستخدام go_router
final GoRouter appRouter = GoRouter(
  // الصفحة اللي بتبدأ بيها لما التطبيق يفتح
  initialLocation: AppRoutes.dashboard,
  routes: [
    // ShellRoute: بيغلف كل الصفحات بـ AppShell (الـ Sidebar والـ Layout العام)
    // يعني AppShell بيظهر دايماً وبس المحتوى اللي جوه بيتغير
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        // كل GoRoute بيعرّف صفحة ومساربها (path)
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (_, _) => const DashboardPage(),
        ),
        GoRoute(
          path: AppRoutes.sessions,
          builder: (_, _) => const SessionsPage(),
        ),
        GoRoute(path: AppRoutes.cafe, builder: (_, _) => const CafePage()),
        GoRoute(
          path: AppRoutes.birthdays,
          builder: (_, _) => const BirthdaysPage(),
        ),
        GoRoute(
          path: AppRoutes.reports,
          builder: (_, _) => const ReportsPage(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (_, _) => const SettingsPage(),
        ),
      ],
    ),
  ],
);

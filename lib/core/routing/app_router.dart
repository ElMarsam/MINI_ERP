import 'package:erp_mini/features/widgets.dart';
import 'package:erp_mini/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:erp_mini/features/sessions/presentation/pages/sessions_page.dart';
import 'package:erp_mini/features/menu/presentation/pages/cafe_page.dart';
import 'package:erp_mini/features/birthday_events/presentation/pages/birthdays_page.dart';
import 'package:erp_mini/features/reports/presentation/pages/reports_page.dart';
import 'package:erp_mini/features/settings/presentation/pages/settings_page.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String sessions = '/sessions';
  static const String cafe = '/cafe';
  static const String birthdays = '/birthdays';
  static const String reports = '/reports';
  static const String settings = '/settings';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (_, _) => const DashboardPage(),
        ),
        GoRoute(
          path: AppRoutes.sessions,
          builder: (_, _) => const SessionsPage(),
        ),
        GoRoute(
          path: AppRoutes.cafe,
          builder: (_, _) => const CafePage(),
        ),
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

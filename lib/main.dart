import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coworking_erp/core/theme/app_theme.dart';
import 'package:coworking_erp/core/di/injection_container.dart';
import 'package:coworking_erp/core/network/supabase_client.dart';
import 'package:coworking_erp/core/routing/app_router.dart';
import 'package:coworking_erp/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:coworking_erp/features/sessions/presentation/cubit/sessions_cubit.dart';

// ==============================================================================
// نقطة البداية لتشغيل تطبيق إي آر بي مساحة العمل (Coworking Space ERP)
// ==============================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة الاتصال بـ Supabase
  await AppSupabaseConfig.initialize();

  // 2. تهيئة حاوية الاعتمادات (Dependency Injection)
  await initDependencies();

  runApp(const CoworkingErpApp());
}

class CoworkingErpApp extends StatelessWidget {
  const CoworkingErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardCubit>(
          create: (_) => sl<DashboardCubit>(),
        ),
        BlocProvider<SessionsCubit>(
          create: (_) => sl<SessionsCubit>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Coworking Space ERP',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coworking_erp/core/network/supabase_client.dart';
import 'package:coworking_erp/features/dashboard/data/datasources/supabase_remote_data_source.dart';
import 'package:coworking_erp/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:coworking_erp/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:coworking_erp/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:coworking_erp/features/sessions/data/repositories/session_repository_impl.dart';
import 'package:coworking_erp/features/sessions/domain/repositories/session_repository.dart';
import 'package:coworking_erp/features/sessions/presentation/cubit/sessions_cubit.dart';

// ==============================================================================
// حاوية حقن الاعتمادات (Service Locator - GetIt)
// ==============================================================================
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── 1. عميل سوبابيز الأساسي (Supabase Client) ───
  sl.registerLazySingleton<SupabaseClient>(() => AppSupabaseConfig.client);

  // ─── 2. مصادر البيانات البعيدة (Remote Data Sources) ───
  sl.registerLazySingleton<SupabaseRemoteDataSource>(
    () => SupabaseRemoteDataSource(sl<SupabaseClient>()),
  );

  // ─── 3. المستودعات (Repositories) ───
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl<SupabaseRemoteDataSource>()),
  );
  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(sl<SupabaseRemoteDataSource>()),
  );

  // ─── 4. مدراء الحالة (Cubits) ───
  sl.registerFactory<DashboardCubit>(
    () => DashboardCubit(dashboardRepository: sl<DashboardRepository>()),
  );
  sl.registerFactory<SessionsCubit>(
    () => SessionsCubit(sessionRepository: sl<SessionRepository>()),
  );
}

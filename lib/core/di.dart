import 'package:get_it/get_it.dart';
final sl = GetIt.instance;
/*
Future<void> init() async {
  // ─── Data Sources ──────────────────────────────────────────────
  sl.registerLazySingleton<DashboardRemoteDataSource>(
        () => MockDashboardRemoteDataSource(),
  );
  sl.registerLazySingleton<SessionRemoteDataSource>(
        () => MockSessionRemoteDataSource(),
  );
  sl.registerLazySingleton<MenuRemoteDataSource>(
        () => MockMenuRemoteDataSource(),
  );

  // ─── Repositories ──────────────────────────────────────────────
  sl.registerLazySingleton<DashboardRepository>(
        () => DashboardRepositoryImpl(sl<DashboardRemoteDataSource>()),
  );
  sl.registerLazySingleton<SessionRepository>(
        () => SessionRepositoryImpl(sl<SessionRemoteDataSource>()),
  );
  sl.registerLazySingleton<MenuRepository>(
        () => MenuRepositoryImpl(sl<MenuRemoteDataSource>()),
  );

  // ─── Cubits / Blocs ───────────────────────────────────────────
  sl.registerFactory<DashboardCubit>(
        () => DashboardCubit(dashboardRepository: sl<DashboardRepository>()),
  );
  sl.registerFactory<SessionsCubit>(
        () => SessionsCubit(sessionRepository: sl<SessionRepository>()),
  );
  sl.registerFactory<MenuCubit>(
        () => MenuCubit(menuRepository: sl<MenuRepository>()),
  );
}*/
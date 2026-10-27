import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coworking_erp/core/di/injection_container.dart';
import 'package:coworking_erp/features/sessions/domain/entities/session.dart';
import 'package:coworking_erp/features/dashboard/data/datasources/supabase_remote_data_source.dart';
import 'package:coworking_erp/features/dashboard/data/models/cash_withdrawal_model.dart';
import 'package:coworking_erp/features/dashboard/domain/entities/birthday_booking.dart';
import 'package:coworking_erp/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:coworking_erp/features/dashboard/domain/repositories/dashboard_repository.dart';

part 'dashboard_state.dart';

// ==============================================================================
// كلاس مدير حالة لوحة التحكم (DashboardCubit)
// يطبق مبدأ Dependency Inversion بالاعتماد على DashboardRepository
// ==============================================================================
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;
  Timer? _refreshTimer;

  DashboardCubit({
    DashboardRepository? dashboardRepository,
    SupabaseRemoteDataSource? dataSource,
  }) : _dashboardRepository =
           dashboardRepository ??
           (dataSource != null
               ? sl<DashboardRepository>()
               : sl<DashboardRepository>()),
       super(const DashboardInitial());

  // تحميل بيانات الداشبورد
  Future<void> loadDashboard({bool forceLoading = false}) async {
    if (state is! DashboardLoaded || forceLoading) {
      emit(const DashboardLoading());
    }
    await _fetchData();
    _startAutoRefresh();
  }

  // تحديث فوري
  Future<void> refresh() async {
    await _fetchData();
  }

  // جلب البيانات عبر الـ Repository بالتوازي لتسريع الاستجابة
  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        _dashboardRepository.getDashboardStats(),
        _dashboardRepository.getActiveSessions(),
        _dashboardRepository.getUpcomingBirthdays(),
        _dashboardRepository.getCashWithdrawalsToday(),
      ]);

      emit(
        DashboardLoaded(
          stats: results[0] as DashboardStats,
          activeSessions: results[1] as List<Session>,
          upcomingBirthdays: results[2] as List<BirthdayBooking>,
          cashWithdrawals: results[3] as List<CashWithdrawalModel>,
          lastRefreshed: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  // تسجيل سحب نقدي جديد من الخزينة
  Future<void> addCashWithdrawal({
    required String staffName,
    required double amount,
    required String reason,
    DateTime? createdAt,
  }) async {
    try {
      await _dashboardRepository.createCashWithdrawal(
        staffName: staffName,
        amount: amount,
        reason: reason,
        createdAt: createdAt,
      );
      await _fetchData();
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  // للتوافق مع أي شاشات فرعية
  DashboardRepository get repository => _dashboardRepository;
  SupabaseRemoteDataSource get dataSource => sl<SupabaseRemoteDataSource>();

  // تايمر التحديث الدوري في الخلفية كل دقيقتين دون تعطيل الواجهة
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      if (state is DashboardLoaded) _fetchData();
    });
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}

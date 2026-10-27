import 'package:coworking_erp/features/dashboard/data/datasources/supabase_remote_data_source.dart';
import 'package:coworking_erp/features/dashboard/data/models/cash_withdrawal_model.dart';
import 'package:coworking_erp/features/dashboard/domain/entities/birthday_booking.dart';
import 'package:coworking_erp/features/sessions/domain/entities/session.dart';

import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';

// ==============================================================================
// تطبيق مستودع لوحة التحكم (DashboardRepositoryImpl)
// ==============================================================================
class DashboardRepositoryImpl implements DashboardRepository {
  final SupabaseRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<DashboardStats> getDashboardStats() async {
    final statsData = await _remoteDataSource.getDashboardStats();

    return DashboardStats(
      activeSessionsCount: statsData['active_sessions_count'] as int,
      totalDesks: 30,
      occupiedDesks: statsData['active_sessions_count'] as int,
      todayRevenue: statsData['today_revenue'] as double,
      todayCafeRevenue: 0.0,
      todaySessionRevenue: statsData['today_revenue'] as double,
      cashCollected: statsData['cash_collected'] as double,
      instaPayCollected: statsData['instapay_collected'] as double,
      vodafoneCashCollected: statsData['vodafone_cash_collected'] as double,
      newCustomersToday: 0,
      outstandingBalances: 0.0,
      upcomingBirthdays: (statsData['upcoming_birthdays_count'] as int?) ?? 0,
    );
  }

  @override
  Future<List<Session>> getActiveSessions() async {
    return _remoteDataSource.getActiveSessions();
  }

  @override
  Future<List<BirthdayBooking>> getUpcomingBirthdays() async {
    return _remoteDataSource.getUpcomingBirthdays();
  }

  @override
  Future<List<CashWithdrawalModel>> getCashWithdrawalsToday() async {
    return _remoteDataSource.getCashWithdrawalsToday();
  }

  @override
  Future<CashWithdrawalModel> createCashWithdrawal({
    required String staffName,
    required double amount,
    required String reason,
    DateTime? createdAt,
  }) async {
    return _remoteDataSource.createCashWithdrawal(
      staffName: staffName,
      amount: amount,
      reason: reason,
      createdAt: createdAt,
    );
  }
}

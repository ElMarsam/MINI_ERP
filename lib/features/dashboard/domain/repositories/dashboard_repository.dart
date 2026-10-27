import '../entities/dashboard_stats.dart';
import '../entities/session.dart';
import '../entities/birthday_booking.dart';
import '../../data/models/cash_withdrawal_model.dart';

// ==============================================================================
// عقد مستودع لوحة التحكم (DashboardRepository Interface)
// يجمع إحصائيات الداشبورد، الجلسات النشطة، مناسبات أعياد الميلاد، وحركات السحب
// ==============================================================================
abstract class DashboardRepository {
  // جلب إحصائيات الـ KPIs
  Future<DashboardStats> getDashboardStats();

  // جلب الجلسات النشطة
  Future<List<Session>> getActiveSessions();

  // جلب أعياد الميلاد القادمة
  Future<List<BirthdayBooking>> getUpcomingBirthdays();

  // جلب مسحوبات الخزينة اليومية
  Future<List<CashWithdrawalModel>> getCashWithdrawalsToday();

  // تسجيل سحب نقدي جديد من الخزينة
  Future<CashWithdrawalModel> createCashWithdrawal({
    required String staffName,
    required double amount,
    required String reason,
    DateTime? createdAt,
  });
}

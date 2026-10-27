import 'package:equatable/equatable.dart';

// Domain Entity لإحصائيات الداشبورد
// بيُستخدم لعرض الملخص في الصفحة الرئيسية
class DashboardStats extends Equatable {
  final int activeSessionsCount;      // عدد السيشنات النشطة حالياً
  final int totalDesks;               // إجمالي عدد المكاتب المتاحة
  final int occupiedDesks;            // عدد المكاتب المشغولة
  final double todayRevenue;          // إجمالي الإيراد اليوم
  final double todayCafeRevenue;      // إيراد الكافيه اليوم
  final double todaySessionRevenue;   // إيراد السيشنات اليوم
  final double cashCollected;         // إجمالي ما تم تحصيله نقداً اليوم
  final double instaPayCollected;     // إجمالي ما تم تحصيله عبر InstaPay
  final double vodafoneCashCollected; // إجمالي ما تم تحصيله عبر فودافون كاش
  final int newCustomersToday;        // عدد العملاء الجدد اليوم
  final double outstandingBalances;   // إجمالي الأرصدة المستحقة (الديون)
  final int upcomingBirthdays;        // عدد حجوزات الأعياد القادمة

  const DashboardStats({
    required this.activeSessionsCount,
    required this.totalDesks,
    required this.occupiedDesks,
    required this.todayRevenue,
    required this.todayCafeRevenue,
    required this.todaySessionRevenue,
    required this.cashCollected,
    required this.instaPayCollected,
    required this.vodafoneCashCollected,
    required this.newCustomersToday,
    required this.outstandingBalances,
    required this.upcomingBirthdays,
  });

  // حساب نسبة الإشغال (مكاتب مشغولة / إجمالي مكاتب)
  // لو totalDesks = 0 يرجع 0.0 عشان يتجنب القسمة على صفر
  double get occupancyRate => totalDesks > 0 ? occupiedDesks / totalDesks : 0.0;

  // الخصائص اللي Equatable بيستخدمها للمقارنة
  @override
  List<Object?> get props => [
    activeSessionsCount, totalDesks, occupiedDesks, todayRevenue,
    cashCollected, instaPayCollected, vodafoneCashCollected,
  ];
}

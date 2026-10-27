part of 'dashboard_cubit.dart';

// ==============================================================================
// كلاس حالات لوحة التحكم (DashboardState)
// يعبر عن الحالة اللحظية لشاشة الداشبورد في نمط BLoC/Cubit
// ==============================================================================
abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

// الحالة المبدئية: عند فتح التطبيق لأول مرة وقبل بدء جلب أي بيانات
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

// حالة التحميل: تظهر أثناء انتظار استجابة السيرفر لجلب الإحصائيات والبيانات
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

// حالة اكتمال التحميل بنجاح: تحتوي على كافة البيانات المطلوبة لعرض واجهة الداشبورد
class DashboardLoaded extends DashboardState {
  // كائن إحصائيات الـ KPIs (الإيرادات، عدد الجلسات، كاش، إنستاباي، فودافون كاش)
  final DashboardStats stats;

  // قائمة الجلسات النشطة المفتوحة حالياً في المكان
  final List<Session> activeSessions;

  // قائمة مناسبات أعياد الميلاد القادمة
  final List<BirthdayBooking> upcomingBirthdays;

  // قائمة مسحوبات النقدية من الخزينة لليوم الحالي
  final List<CashWithdrawalModel> cashWithdrawals;

  // توقيت آخر تحديث ناجح للبيانات
  final DateTime lastRefreshed;

  // Constructor يستقبل كافة البيانات المحملة
  const DashboardLoaded({
    required this.stats,
    required this.activeSessions,
    required this.upcomingBirthdays,
    this.cashWithdrawals = const [],
    required this.lastRefreshed,
  });

  // خصائص مقارنة الحالة لتحديد متى يجب إعادة بناء الـ UI
  @override
  List<Object?> get props => [stats, activeSessions, upcomingBirthdays, cashWithdrawals, lastRefreshed];
}

// حالة حدوث خطأ: عند فشل الاتصال بقاعدة البيانات أو انقطاع الإنترنت
class DashboardError extends DashboardState {
  // رسالة الخطأ التوضيحية لعرضها للمستخدم في SnackBar أو شاشة تنبيه
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}

part of 'sessions_cubit.dart';

// ==============================================================================
// كلاس حالات إدارة الجلسات (SessionsState)
// يعبر عن الحالة اللحظية لصفحة إدارة جلسات العمل (Sessions)
// ==============================================================================
abstract class SessionsState extends Equatable {
  const SessionsState();
  @override
  List<Object?> get props => [];
}

// الحالة المبدئية: قبل بدء تحميل بيانات الجلسات
class SessionsInitial extends SessionsState {
  const SessionsInitial();
}

// حالة جاري التحميل: تظهر أثناء قراءة الجلسات من السيرفر
class SessionsLoading extends SessionsState {
  const SessionsLoading();
}

// حالة اكتمال تحميل الجلسات بنجاح
class SessionsLoaded extends SessionsState {
  // قائمة الجلسات المفتوحة والنشطة حالياً
  final List<Session> activeSessions;

  // قائمة جميع جلسات اليوم (المفتوحة والمنتهية)
  final List<Session> todaySessions;

  // عداد ثواني / نبضات (Tick) لتحديث الوقت المنقضي كل ثانية على بطاقات الجلسات
  final int? tick;

  const SessionsLoaded({
    required this.activeSessions,
    required this.todaySessions,
    this.tick,
  });

  @override
  List<Object?> get props => [activeSessions, todaySessions, tick];
}

// حالة تنفيذ إجراء على جلسة محددة (مثل: جاري الإيقاف، جاري الإنهاء، جاري البدء)
class SessionsActionLoading extends SessionsState {
  // معرف الجلسة الجاري تنفيذ الإجراء عليها
  final String sessionId;

  // اسم الإجراء (pause / resume / end)
  final String action;

  const SessionsActionLoading({required this.sessionId, required this.action});

  @override
  List<Object?> get props => [sessionId, action];
}

// حالة حدوث خطأ أثناء جلب أو تعديل الجلسات
class SessionsError extends SessionsState {
  // رسالة الخطأ
  final String message;

  const SessionsError({required this.message});

  @override
  List<Object?> get props => [message];
}

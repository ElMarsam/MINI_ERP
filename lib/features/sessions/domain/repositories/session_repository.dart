import '../entities/session.dart';

// ==============================================================================
// عقد مستودع الجلسات (SessionRepository Interface)
// تطبيق لمبدأ Dependency Inversion Principle (DIP) من مبادئ SOLID
// يفصل طبقة الدومين وإدارة الحالة عن تفاصيل سوبابيز وقاعدة البيانات
// ==============================================================================
abstract class SessionRepository {
  // جلب كافة الجلسات النشطة المفتوحة حالياً
  Future<List<Session>> getActiveSessions();

  // جلب سجل جلسات اليوم (المفتوحة والمنتهية)
  Future<List<Session>> getSessionsToday();

  // فتح جلسة جديدة
  Future<Session> createSession({
    required String customerId,
    required String customerName,
    String? deskId,
    String? deskLabel,
    double? ratePerMinute,
  });

  // تحديث حالة الجلسة (إيقاف مؤقت / استئناف)
  Future<Session> updateSessionStatus(
    String id,
    String status, {
    DateTime? currentPauseTime,
    Duration? currentPausedDuration,
  });

  // إنهاء الجلسة وتسوية الفاتورة والمدفوعات
  Future<Session> endSession({
    required String id,
    required double totalAmount,
    required double paidAmount,
    required String paymentMethod,
  });
}

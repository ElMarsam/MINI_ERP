import 'package:coworking_erp/features/sessions/domain/entities/session.dart';

// ==============================================================================
// كلاس موديل الجلسة (SessionModel)
// يربط بين كيان الدومين (Session Entity) وقاعدة بيانات Supabase (JSON)
// مسؤول عن تحويل البيانات القادمة من وإلى السيرفر (Serialization / Deserialization)
// ==============================================================================
class SessionModel extends Session {
  // الـ Constructor يمرر كل البيانات للـ Super Class (Session)
  const SessionModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.startTime,
    super.endTime,
    super.pauseTime,
    super.totalPausedDuration,
    super.deskId,
    super.deskLabel,
    super.ratePerMinute,
    required super.totalAmount,
    required super.paidAmount,
    super.paymentMethod,
    super.status,
    super.isActive,
    super.notes,
  });

  // Factory Constructor: يحول خريطة JSON القادمة من قاعدة البيانات إلى كائن SessionModel
  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      // استخراج المعرف الفريد للجلسة
      id: json['id'] as String,
      // استخراج معرف العميل
      customerId: json['customer_id'] as String,
      // استخراج اسم العميل، وإعطاء قيمة افتراضية نص فارغ لو كان null
      customerName: json['customer_name'] as String? ?? '',
      // تحويل وقت البدء من نص ISO8601 إلى DateTime
      startTime: DateTime.parse(
        (json['check_in_at'] ?? json['start_time'] ?? DateTime.now().toIso8601String()) as String,
      ),
      // تحويل وقت الانتهاء إذا كان متوفراً
      endTime: json['check_out_at'] != null
          ? DateTime.parse(json['check_out_at'] as String)
          : (json['end_time'] != null
                ? DateTime.parse(json['end_time'] as String)
                : null),
      // تحويل وقت الإيقاف المؤقت إذا كان متوفراً
      pauseTime: json['pause_time'] != null
          ? DateTime.parse(json['pause_time'] as String)
          : null,
      // تحويل إجمالي ثواني الإيقاف إلى كائن Duration مع ضمان عدم كونه سالباً
      totalPausedDuration: Duration(
        seconds: ((json['total_paused_seconds'] as num?)?.toInt() ?? 0).clamp(
          0,
          999999999,
        ),
      ),
      // استخراج بيانات المكتب المخصص
      deskId: (json['space_id'] ?? json['desk_id']) as String?,
      deskLabel: (json['space_label'] ?? json['desk_label'] ?? json['notes']) as String?,
      // استخراج تسعيرة الدقيقة كرقم عشري
      ratePerMinute: (json['rate_per_minute'] as num?)?.toDouble(),
      // استخراج المبالغ المالية مع ضمان عدم إرجاع null
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      // طريقة الدفع
      paymentMethod: json['payment_method'] as String?,
      // مطابقة نص الحالة بقيم الـ Enum مع دعم completed من الداتابيز
      status: () {
        final st = json['status']?.toString();
        if (st == 'completed' || st == 'closed') return SessionStatus.closed;
        if (st == 'paused') return SessionStatus.paused;
        return SessionStatus.active;
      }(),
      // الملاحظات
      notes: json['notes'] as String?,
    );
  }

  // ميثود لتحويل كائن SessionModel إلى خريطة JSON لإرسالها وتخزينها في Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      // تحويل أوقات DateTime إلى صيغة ISO8601 القياسية
      'check_in_at': startTime.toIso8601String(),
      'check_out_at': endTime?.toIso8601String(),
      if (deskId != null) 'space_id': deskId,
      'rate_per_minute': ratePerMinute,
      'total_amount': totalAmount,
      // تخزين اسم حالة الـ Enum كنص متوافق مع session_status في Supabase
      'status': status == SessionStatus.closed ? 'completed' : 'active',
      'notes': notes,
    };
  }
}

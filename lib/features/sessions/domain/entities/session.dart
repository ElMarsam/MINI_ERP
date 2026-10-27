import 'package:equatable/equatable.dart';
import 'package:coworking_erp/core/utils/app_clock.dart';

// Enum يعرّف الحالات الممكنة للسيشن (Session Status)
enum SessionStatus {
  active, // السيشن شغّاله والوقت بيحسب
  paused, // السيشن متوقفة مؤقتاً والوقت واقف
  closed, // السيشن اتقفلت وتم التحصيل
}

// Domain Entity للسيشن - يمثل جلسة عمل واحدة
// Equatable: يسمح بالمقارنة بين sessions بالـ props بدل مقارنة الـ reference
class Session extends Equatable {
  final String id; // معرّف فريد للسيشن (UUID)
  final String customerId; // معرّف العميل المرتبط بالسيشن
  final String customerName; // اسم العميل (محتفظ به للعرض بدون استدعاء إضافي)
  final DateTime startTime; // وقت بداية السيشن
  final DateTime? endTime; // وقت نهاية السيشن (null لو مفتوحة)
  final DateTime? pauseTime; // الوقت اللي حصل فيه الـ Pause الأخير
  final Duration
  totalPausedDuration; // إجمالي وقت الـ Pause (يُطرح من الوقت الفعلي)
  final String? deskId; // معرّف المكتب المستخدم
  final String? deskLabel; // اسم/رقم المكتب (للعرض)
  final double? ratePerMinute; // سعر الدقيقة (لو null بيُستخدم default rate)
  final double totalAmount; // المبلغ الكلي المحسوب
  final double paidAmount; // المبلغ اللي اتدفع فعلاً
  final String? paymentMethod; // طريقة الدفع (cash/instapay/vodafone_cash)
  final SessionStatus status; // الحالة الحالية للسيشن
  final String? notes; // ملاحظات إضافية

  // خاصية مساعدة لمعرفة هل الجلسة نشطة أم لا
  bool get isActive => status == SessionStatus.active;

  const Session({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.startTime,
    this.endTime,
    this.pauseTime,
    this.totalPausedDuration = Duration.zero, // افتراضياً صفر
    this.deskId,
    this.deskLabel,
    this.ratePerMinute,
    required this.totalAmount,
    required this.paidAmount,
    this.paymentMethod,
    SessionStatus? status,
    bool? isActive,
    this.notes,
  }) : status = status ?? (isActive == false ? SessionStatus.closed : SessionStatus.active);

  // حساب الرصيد المتبقي (ما لم يُدفع بعد)
  double get balance => totalAmount - paidAmount;

  // حساب المدة الفعلية للسيشن (بدون أوقات الـ Pause)
  Duration get elapsedDuration {
    // التأكد من أن إجمالي مدة التوقف ليست سالبة
    final safePaused = totalPausedDuration.isNegative
        ? Duration.zero
        : totalPausedDuration;
    // لو السيشن متوقفة: احسب من البداية لوقت الـ Pause واطرح وقت الـ Pause السابق
    if (status == SessionStatus.paused && pauseTime != null) {
      final diff =
          pauseTime!.toUtc().difference(startTime.toUtc()) - safePaused;
      return diff.isNegative ? Duration.zero : diff;
    }
    // لو السيشن نشطة أو منتهية: احسب من البداية لـ (وقت النهاية أو الآن)
    final end = (endTime ?? AppClock.nowUtc()).toUtc();
    final diff = end.difference(startTime.toUtc()) - safePaused;
    return diff.isNegative ? Duration.zero : diff;
  }

  // حساب المبلغ الحالي بناءً على الوقت الفعلي المنقضي
  double calculateCurrentAmount({double defaultRatePerMinute = 0.50}) {
    // لو السيشن منتهية، رجّع المبلغ المحدد مسبقاً
    if (status == SessionStatus.closed) {
      return totalAmount;
    }
    final rate = ratePerMinute ?? defaultRatePerMinute; // السعر بالدقيقة
    final minutes = elapsedDuration.inMinutes;
    // لو أقل من دقيقة بس أكثر من 15 ثانية: احسب دقيقة واحدة على الأقل
    final effectiveMinutes = minutes == 0 && elapsedDuration.inSeconds > 15
        ? 1
        : minutes;
    return (effectiveMinutes * rate);
  }

  // تحويل المدة لصيغة نص "HH:MM:SS" أو "MM:SS" لو أقل من ساعة
  String get formattedDuration {
    final duration = elapsedDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      // لو في ساعات: اعرض بصيغة 01:30:45
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    // لو أقل من ساعة: اعرض بصيغة 30:45
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // نسخ كائن الجلسة مع تعديل بعض الخصائص (Immutability Pattern)
  Session copyWith({
    String? id,
    String? customerId,
    String? customerName,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? pauseTime,
    Duration? totalPausedDuration,
    String? deskId,
    String? deskLabel,
    double? ratePerMinute,
    double? totalAmount,
    double? paidAmount,
    String? paymentMethod,
    SessionStatus? status,
    bool? isActive,
    String? notes,
  }) {
    final resolvedStatus = status ??
        (isActive != null
            ? (isActive ? SessionStatus.active : SessionStatus.closed)
            : this.status);
    return Session(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      pauseTime: pauseTime ?? this.pauseTime,
      totalPausedDuration: totalPausedDuration ?? this.totalPausedDuration,
      deskId: deskId ?? this.deskId,
      deskLabel: deskLabel ?? this.deskLabel,
      ratePerMinute: ratePerMinute ?? this.ratePerMinute,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: resolvedStatus,
      notes: notes ?? this.notes,
    );
  }

  // الخصائص اللي Equatable بيستخدمها للمقارنة بين Sessions
  @override
  List<Object?> get props => [
    id,
    customerId,
    startTime,
    endTime,
    status,
    totalAmount,
    paidAmount,
  ];
}

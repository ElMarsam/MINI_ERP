import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coworking_erp/core/utils/logger.dart';
import 'package:coworking_erp/features/dashboard/data/models/customer_model.dart';
import 'package:coworking_erp/features/sessions/data/models/session_model.dart';
import 'package:coworking_erp/features/dashboard/domain/entities/birthday_booking.dart';
import 'package:coworking_erp/features/dashboard/data/models/cash_withdrawal_model.dart';
import 'package:coworking_erp/features/dashboard/domain/entities/cafe.dart';

// ==============================================================================
// مصدر البيانات البعيد عبر سوبابيز (SupabaseRemoteDataSource)
// المسؤول الأول عن تنفيذ كل استعلامات قواعد البيانات (CRUD Queries)
// يتعامل مباشرة مع جداول Supabase: customers, sessions, birthday_bookings, financial_transactions
// ==============================================================================
class SupabaseRemoteDataSource {
  // عميل سوبابيز المستخدم لتنفيذ استعلامات الشبكة
  final SupabaseClient _client;

  // Constructor يستقبل كائن SupabaseClient المجهز مسبقاً
  SupabaseRemoteDataSource(this._client);

  // ════════════════════════════════════════════════════════════════════════════
  // ─── قسم العملاء (CUSTOMERS) ────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  // جلب قائمة العملاء مع إمكانية البحث بالاسم وترتيبهم أبجدياً
  Future<List<CustomerModel>> getCustomers({String? search}) async {
    var query = _client.from('customers').select();
    // إذا تم تمرير نص بحث، يتم عمل فلترة Case-insensitive على حقل name
    if (search != null && search.isNotEmpty) {
      query = query.ilike('name', '%$search%');
    }
    // تنفيذ الاستعلام وترتيب النتائج تصاعدياً بالاسم
    final data = await query.order('full_name');
    return (data as List).map((e) => CustomerModel.fromJson(e)).toList();
  }

  // جلب بيانات عميل محدد عن طريق معرفه الفريد (ID)
  Future<CustomerModel> getCustomerById(String id) async {
    final data = await _client.from('customers').select().eq('id', id).single();
    return CustomerModel.fromJson(data);
  }

  // إضافة عميل جديد إلى قاعدة البيانات
  Future<CustomerModel> createCustomer(Map<String, dynamic> json) async {
    final data = await _client.from('customers').insert(json).select().single();
    return CustomerModel.fromJson(data);
  }

  // تحديث بيانات عميل حالي (مثل رقم التليفون، الملاحظات، أو الرصيد)
  Future<CustomerModel> updateCustomer(
    String id,
    Map<String, dynamic> json,
  ) async {
    final data = await _client
        .from('customers')
        .update(json)
        .eq('id', id)
        .select()
        .single();
    return CustomerModel.fromJson(data);
  }

  // حذف منطقي (Soft Delete) للعميل بتغيير حالته إلى غير نشط دون مسح بياناته من الداتابيز
  Future<void> deleteCustomer(String id) async {
    await _client.from('customers').update({'is_active': false}).eq('id', id);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ─── قسم الجلسات (SESSIONS) ────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  // جلب جميع الجلسات المفتوحة حالياً (النشطة أو المتوقفة مؤقتاً) مع ربط اسم العميل
  Future<List<SessionModel>> getActiveSessions() async {
    // نحدد كل الجلسات التي حالتها ليست closed، ونعمل join مع جدول customers لجلب اسم العميل
    final data = await _client
        .from('sessions')
        .select('*, customers(full_name)')
        .neq('status', 'completed')
        .order('check_in_at');
    return (data as List).map((e) {
      final map = Map<String, dynamic>.from(e);
      // تسطيح اسم العميل ليصبح حقلاً مباشراً customer_name
      if (map['customers'] != null) {
        map['customer_name'] = map['customers']['full_name'];
      }
      return SessionModel.fromJson(map);
    }).toList();
  }

  // جلب كافة جلسات اليوم (المفتوحة والمنتهية) لعرض السجل اليومي
  Future<List<SessionModel>> getSessionsToday() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final data = await _client
        .from('sessions')
        .select('*, customers(full_name)')
        .gte('check_in_at', startOfDay.toIso8601String())
        .order('check_in_at', ascending: false);
    return (data as List).map((e) {
      final map = Map<String, dynamic>.from(e);
      if (map['customers'] != null) {
        map['customer_name'] = map['customers']['full_name'];
      }
      return SessionModel.fromJson(map);
    }).toList();
  }

  // فتح جلسة عمل جديدة لعميل وتسجيل وقت البدء
  Future<SessionModel> createSession(Map<String, dynamic> json) async {
    final data = await _client
        .from('sessions')
        .insert(json)
        .select('*, customers(full_name)')
        .single();
    final map = Map<String, dynamic>.from(data);
    if (map['customers'] != null) {
      map['customer_name'] = map['customers']['full_name'];
    }
    return SessionModel.fromJson(map);
  }

  // تحديث حالة الجلسة (إيقاف مؤقت Pause أو استئناف Resume) وحساب فترات التوقف بدقة
  Future<SessionModel> updateSessionStatus(
    String id,
    String status, {
    DateTime? currentPauseTime,
    Duration? currentPausedDuration,
  }) async {
    final nowUtc = DateTime.now().toUtc();
    final isPausing = status == 'paused';
    final Map<String, dynamic> updatePayload = {
      'status': status,
      'updated_at': nowUtc.toIso8601String(),
    };

    Duration newPausedDuration = currentPausedDuration ?? Duration.zero;
    if (status == 'active' && currentPauseTime != null) {
      final diffSecs = nowUtc.difference(currentPauseTime.toUtc()).inSeconds;
      if (diffSecs > 0) {
        newPausedDuration += Duration(seconds: diffSecs);
      }
    }

    // إرسال التحديث لسوبابيز واسترجاع الجلسة المحدثة
    final data = await _client
        .from('sessions')
        .update(updatePayload)
        .eq('id', id)
        .select('*, customers(full_name)')
        .single();
    final map = Map<String, dynamic>.from(data);
    if (map['customers'] != null) {
      map['customer_name'] = map['customers']['full_name'];
    }
    final model = SessionModel.fromJson(map);
    return SessionModel(
      id: model.id,
      customerId: model.customerId,
      customerName: model.customerName,
      startTime: model.startTime,
      endTime: model.endTime,
      pauseTime: isPausing ? nowUtc : null,
      totalPausedDuration: newPausedDuration,
      deskId: model.deskId,
      deskLabel: model.deskLabel,
      ratePerMinute: model.ratePerMinute,
      totalAmount: model.totalAmount,
      paidAmount: model.paidAmount,
      paymentMethod: model.paymentMethod,
      status: model.status,
      notes: model.notes,
    );
  }

  // إغلاق الجلسة (اسم بديل لـ endSession للتوافق)
  Future<SessionModel> closeSession(
    String id, {
    required double totalAmount,
    required double paidAmount,
    required String paymentMethod,
  }) async {
    return endSession(
      id: id,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      paymentMethod: paymentMethod,
    );
  }

  // إنهاء الجلسة، تسجيل الحساب، تحديث رصيد العميل إذا وُجد متبقي، وقيد المعاملة المالية في الخزينة
  Future<SessionModel> endSession({
    required String id,
    required double totalAmount,
    required double paidAmount,
    required String paymentMethod,
  }) async {
    // 1. تحديث حالة الجلسة إلى closed وحفظ المبالغ وطريقة الدفع (السيشن تسدد بالكامل دائماً ولا يوجد مديونية)
    final nowUtc = DateTime.now().toUtc().toIso8601String();
    final data = await _client
        .from('sessions')
        .update({
          'status': 'completed',
          'check_out_at': nowUtc,
          'total_amount': totalAmount,
          'updated_at': nowUtc,
        })
        .eq('id', id)
        .select('*, customers(full_name)')
        .single();

    // 2. تسجيل معاملة إيراد في جدول transactions بكامل المبلغ المسدد
    if (totalAmount > 0) {
      try {
        await _client.from('transactions').insert({
          'session_id': id,
          'direction': 'in',
          'purpose': 'session',
          'amount': totalAmount,
          'method': paymentMethod,
          'note': 'تحصيل جلسة عمل',
          'created_at': nowUtc,
        });
      } catch (e) {
        AppLogger.error('Error recording session financial transaction', e);
      }
    }

    // تجهيز الكائن النهائي وإرجاعه
    final map = Map<String, dynamic>.from(data);
    if (map['customers'] != null) {
      map['customer_name'] = map['customers']['full_name'];
    }
    return SessionModel.fromJson(map);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ─── قسم حجوزات أعياد الميلاد (BIRTHDAY BOOKINGS) ──────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  // جلب جميع حجوزات أعياد الميلاد مرتبة بتواريخ الفعاليات
  Future<List<BirthdayBooking>> getBirthdayBookings() async {
    final data = await _client
        .from('event_bookings')
        .select()
        .order('start_at', ascending: true);
    return (data as List).map((e) => BirthdayBooking.fromJson(e)).toList();
  }

  // جلب حجوزات أعياد الميلاد القادمة (ابتداءً من اليوم فصاعداً)
  Future<List<BirthdayBooking>> getUpcomingBirthdays() async {
    final today = DateTime.now();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();
    final data = await _client
        .from('event_bookings')
        .select()
        .gte('start_at', startOfDay)
        .order('start_at', ascending: true);
    return (data as List).map((e) => BirthdayBooking.fromJson(e)).toList();
  }

  // إنشاء حجز عيد ميلاد جديد
  Future<BirthdayBooking> createBirthdayBooking(
    Map<String, dynamic> json,
  ) async {
    final data = await _client
        .from('event_bookings')
        .insert(json)
        .select()
        .single();
    return BirthdayBooking.fromJson(data);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ─── إحصائيات الداشبورد (DASHBOARD STATS) ──────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  // تجميع وحساب أرقام الـ KPIs اليومية: عدد الجلسات، إجمالي الإيراد، وتفصيله حسب وسيلة الدفع
  Future<Map<String, dynamic>> getDashboardStats() async {
    final today = DateTime.now();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();

    // تنفيذ استعلامات الداشبورد بالتوازي (Concurrent Parallel Queries) لتسريع التحميل
    final results = await Future.wait([
      _client.from('sessions').select('id').neq('status', 'completed'),
      _client
          .from('transactions')
          .select('amount, method, direction')
          .gte('created_at', startOfDay),
      _client.from('event_bookings').select('id').gte('start_at', startOfDay),
    ]);

    final activeSessionsResponse = results[0] as List;
    final todayTransactions = results[1] as List;
    final upcomingBirthdaysResponse = results[2] as List;
    final activeSessionsCount = activeSessionsResponse.length;

    double totalRevenue = 0;
    double cashCollected = 0;
    double instaPayCollected = 0;
    double vodafoneCashCollected = 0;

    // تجميع الإيرادات واستثناء حركات السحب النقدي
    for (final t in todayTransactions) {
      final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
      final direction = t['direction']?.toString();
      if (direction != 'out') {
        totalRevenue += amount;
        final method = (t['method'] ?? t['payment_method'])?.toString();
        switch (method) {
          case 'cash':
            cashCollected += amount;
            break;
          case 'instapay':
            instaPayCollected += amount;
            break;
          case 'vodafone_cash':
            vodafoneCashCollected += amount;
            break;
        }
      }
    }

    final upcomingBirthdaysCount = upcomingBirthdaysResponse.length;

    return {
      'active_sessions_count': activeSessionsCount,
      'today_revenue': totalRevenue,
      'cash_collected': cashCollected,
      'instapay_collected': instaPayCollected,
      'vodafone_cash_collected': vodafoneCashCollected,
      'upcoming_birthdays_count': upcomingBirthdaysCount,
    };
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ─── سحب النقدية من الخزينة (CASH WITHDRAWALS) ─────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  // جلب جميع حركات سحب الكاش المنفذة اليوم من الخزينة
  Future<List<CashWithdrawalModel>> getCashWithdrawalsToday() async {
    final today = DateTime.now();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();
    final data = await _client
        .from('expenses')
        .select()
        .gte('created_at', startOfDay)
        .order('created_at', ascending: false);
    return (data as List).map((e) => CashWithdrawalModel.fromJson(e)).toList();
  }

  // تسجيل حركة سحب نقدية جديدة من الخزينة مع توثيق اسم المستلم والسبب
  Future<CashWithdrawalModel> createCashWithdrawal({
    required String staffName,
    required double amount,
    required String reason,
    DateTime? createdAt,
  }) async {
    final now = createdAt ?? DateTime.now();
    final timestamp = now.toIso8601String();
    final spentAtDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final data = await _client
        .from('expenses')
        .insert({
          'category': staffName,
          'description': reason,
          'amount': amount,
          'method': 'cash',
          'spent_at': spentAtDate,
          'created_at': timestamp,
        })
        .select()
        .single();
    return CashWithdrawalModel.fromJson(data);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ─── منتجات البوفيه والمنيو (CAFE PRODUCTS) ────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  // جلب قائمة منتجات ومشروبات الكافيه من جدول cafe_products مع Fallback
  Future<List<CafeProduct>> getCafeProducts() async {
    try {
      final data = await _client
          .from('products')
          .select()
          .order('category')
          .order('name');
      return (data as List).map((e) {
        return CafeProduct(
          id: e['id'] as String,
          name: e['name'] as String,
          price: (e['price'] as num?)?.toDouble() ?? 0.0,
          category: (e['category'] as String?) ?? 'أخرى',
          isAvailable: (e['is_available'] as bool?) ?? true,
          imageUrl: e['image_url'] as String?,
        );
      }).toList();
    } catch (e) {
      AppLogger.warning('Supabase getCafeProducts fallback to default menu', e);
      return const [
        CafeProduct(
          id: 'prod-1',
          name: 'قهوة عربية / تركي',
          price: 20.0,
          category: 'مشروبات',
        ),
        CafeProduct(
          id: 'prod-2',
          name: 'شاي أحمر / أخضر',
          price: 15.0,
          category: 'مشروبات',
        ),
        CafeProduct(
          id: 'prod-3',
          name: 'كابتشينو',
          price: 35.0,
          category: 'مشروبات',
        ),
        CafeProduct(
          id: 'prod-4',
          name: 'لاتيه',
          price: 40.0,
          category: 'مشروبات',
        ),
        CafeProduct(
          id: 'prod-5',
          name: 'عصير برتقال فريش',
          price: 25.0,
          category: 'مشروبات',
        ),
        CafeProduct(
          id: 'prod-6',
          name: 'مياه معدنية',
          price: 10.0,
          category: 'مشروبات',
        ),
        CafeProduct(
          id: 'prod-7',
          name: 'ساندويتش جبنة',
          price: 30.0,
          category: 'مأكولات',
        ),
        CafeProduct(
          id: 'prod-8',
          name: 'كيك شوكولاتة',
          price: 25.0,
          category: 'مأكولات',
        ),
      ];
    }
  }
}

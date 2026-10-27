import 'dart:async';
import 'dart:collection';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coworking_erp/domain/entities/session.dart';
import 'package:coworking_erp/domain/repositories/session_repository.dart';
import 'package:coworking_erp/domain/repositories/customer_repository.dart';
import 'package:coworking_erp/data/datasources/remote/supabase_remote_data_source.dart';
import 'package:coworking_erp/core/di/injection_container.dart';
import 'package:coworking_erp/core/utils/logger.dart';

part 'sessions_state.dart';

// ==============================================================================
// كلاس مدير جلسات العمل (SessionsCubit)
// يطبق مبادئ الـ OOP وهياكل البيانات المتقدمة:
// - LinkedHashMap لتسريع العمليات بزمن O(1) مع الحفاظ على ترتيب العناصر
// - Dependency Inversion بالاعتماد على SessionRepository و CustomerRepository
// ==============================================================================
class SessionsCubit extends Cubit<SessionsState> {
  final SessionRepository _sessionRepository;
  final CustomerRepository _customerRepository;
  Timer? _tickTimer;

  // هيكل بيانات LinkedHashMap لحفظ الجلسات بزمن وصول O(1) مع الحفاظ على الترتيب
  final LinkedHashMap<String, Session> _activeSessionsMap =
      LinkedHashMap<String, Session>();
  final LinkedHashMap<String, Session> _todaySessionsMap =
      LinkedHashMap<String, Session>();

  SessionsCubit({
    SessionRepository? sessionRepository,
    CustomerRepository? customerRepository,
    SupabaseRemoteDataSource? dataSource,
  }) : _sessionRepository = sessionRepository ?? sl<SessionRepository>(),
       _customerRepository = customerRepository ?? sl<CustomerRepository>(),
       super(const SessionsInitial());

  // تحميل قائمة الجلسات
  Future<void> loadSessions({bool forceLoading = false}) async {
    if (state is! SessionsLoaded || forceLoading) {
      emit(const SessionsLoading());
    }
    await _fetchSessions();
    _startTick();
  }

  // جلب الجلسات عبر الـ Repository بالتوازي وملء خريطة البيانات O(1)
  Future<void> _fetchSessions() async {
    try {
      final results = await Future.wait([
        _sessionRepository.getActiveSessions(),
        _sessionRepository.getSessionsToday(),
      ]);

      final activeList = results[0];
      final todayList = results[1];

      _activeSessionsMap.clear();
      for (final s in activeList) {
        _activeSessionsMap[s.id] = s;
      }

      _todaySessionsMap.clear();
      for (final s in todayList) {
        _todaySessionsMap[s.id] = s;
      }

      _emitLoaded();
    } catch (e) {
      AppLogger.error('Sessions fetch error', e);
      emit(SessionsError(message: e.toString()));
    }
  }

  // بطاقات الجلسات النشطة (ActiveSessionCard) تمتلك تايمر محلي مستقل لتحديث الثواني والتكلفة،
  // لذا لا حاجة لإعادة بناء الصفحة بالكامل كل ثانية منعاً لتهنيج واجهة المستخدم.
  void _startTick() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  // إيقاف الجلسة مؤقتاً
  Future<void> pauseSession(String sessionId) async {
    try {
      final updated = await _sessionRepository.updateSessionStatus(
        sessionId,
        'paused',
      );
      _replaceSession(updated);
    } catch (e) {
      AppLogger.error('Pause session error', e);
      if (state is! SessionsLoaded) {
        emit(SessionsError(message: e.toString()));
      }
    }
  }

  // استئناف الجلسة
  Future<void> resumeSession(String sessionId) async {
    try {
      final existing = _activeSessionsMap[sessionId];
      final updated = await _sessionRepository.updateSessionStatus(
        sessionId,
        'active',
        currentPauseTime: existing?.pauseTime,
        currentPausedDuration: existing?.totalPausedDuration,
      );
      _replaceSession(updated);
    } catch (e) {
      AppLogger.error('Resume session error', e);
      if (state is! SessionsLoaded) {
        emit(SessionsError(message: e.toString()));
      }
    }
  }

  // بدء جلسة جديدة
  Future<void> startSession({
    required String customerId,
    required String customerName,
    String? deskId,
    String? deskLabel,
    double? ratePerMinute,
    String? notes,
  }) async {
    try {
      final newSession = await _sessionRepository.createSession(
        customerId: customerId,
        customerName: customerName,
        deskId: deskId,
        deskLabel: deskLabel,
        ratePerMinute: ratePerMinute,
      );
      _replaceSession(newSession);
    } catch (e) {
      AppLogger.error('Start session error', e);
      if (state is! SessionsLoaded) {
        emit(SessionsError(message: e.toString()));
      }
    }
  }

  // إنهاء الجلسة وتسوية الفاتورة
  Future<void> closeSession(
    String sessionId, {
    required double totalAmount,
    required double paidAmount,
    required String paymentMethod,
  }) async {
    emit(SessionsActionLoading(sessionId: sessionId, action: 'close'));
    try {
      final closedSession = await _sessionRepository.endSession(
        id: sessionId,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        paymentMethod: paymentMethod,
      );
      _replaceSession(closedSession);
    } catch (e) {
      AppLogger.error('Close session error', e);
      _emitLoaded();
    }
  }

  // تحديث الجلسة في هياكل البيانات بزمن O(1)
  void _replaceSession(Session updated) {
    if (updated.status == SessionStatus.closed) {
      _activeSessionsMap.remove(updated.id); // O(1) Removal
    } else {
      _activeSessionsMap[updated.id] = updated; // O(1) Insertion/Update
    }

    _todaySessionsMap[updated.id] = updated; // O(1)
    _emitLoaded();
  }

  void _emitLoaded() {
    emit(
      SessionsLoaded(
        activeSessions: _activeSessionsMap.values.toList(),
        todaySessions: _todaySessionsMap.values.toList(),
      ),
    );
  }

  // Getters للوصول للمستودعات ومصدر البيانات
  SessionRepository get sessionRepository => _sessionRepository;
  CustomerRepository get customerRepository => _customerRepository;
  SupabaseRemoteDataSource get dataSource => sl<SupabaseRemoteDataSource>();

  @override
  Future<void> close() {
    _tickTimer?.cancel();
    return super.close();
  }
}

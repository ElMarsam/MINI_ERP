import 'package:coworking_erp/features/dashboard/data/datasources/supabase_remote_data_source.dart';

import '../../domain/entities/session.dart';
import '../../domain/repositories/session_repository.dart';

// ==============================================================================
// تطبيق مستودع الجلسات (SessionRepositoryImpl)
// يربط بين عقد الـ Repository ومصدر البيانات SupabaseRemoteDataSource
// ==============================================================================
class SessionRepositoryImpl implements SessionRepository {
  final SupabaseRemoteDataSource _remoteDataSource;

  SessionRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Session>> getActiveSessions() async {
    return _remoteDataSource.getActiveSessions();
  }

  @override
  Future<List<Session>> getSessionsToday() async {
    return _remoteDataSource.getSessionsToday();
  }

  @override
  Future<Session> createSession({
    required String customerId,
    required String customerName,
    String? deskId,
    String? deskLabel,
    double? ratePerMinute,
  }) async {
    final sessionData = {
      'customer_id': customerId,
      'start_time': DateTime.now().toUtc().toIso8601String(),
      'status': 'active',
      'total_amount': 0.0,
      'paid_amount': 0.0,
      'desk_id': deskId,
      'desk_label': deskLabel,
      'rate_per_minute': ratePerMinute ?? 0.50,
    };
    final session = await _remoteDataSource.createSession(sessionData);
    if (session.customerName.isEmpty && customerName.isNotEmpty) {
      return session.copyWith(customerName: customerName);
    }
    return session;
  }

  @override
  Future<Session> updateSessionStatus(
    String id,
    String status, {
    DateTime? currentPauseTime,
    Duration? currentPausedDuration,
  }) async {
    return _remoteDataSource.updateSessionStatus(
      id,
      status,
      currentPauseTime: currentPauseTime,
      currentPausedDuration: currentPausedDuration,
    );
  }

  @override
  Future<Session> endSession({
    required String id,
    required double totalAmount,
    required double paidAmount,
    required String paymentMethod,
  }) async {
    return _remoteDataSource.endSession(
      id: id,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      paymentMethod: paymentMethod,
    );
  }
}

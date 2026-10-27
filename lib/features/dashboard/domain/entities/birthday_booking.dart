import 'package:equatable/equatable.dart';

// ==============================================================================
// كيان حجز عيد الميلاد (BirthdayBooking)
// يمثل بيانات حجز مناسبة أو عيد ميلاد قادم
// ==============================================================================
class BirthdayBooking extends Equatable {
  final String id;
  final String clientName;
  final DateTime eventDate;
  final String? packageType;
  final int guestsCount;
  final double? totalPrice;
  final double? depositPaid;
  final String? status;
  final String? phone;

  const BirthdayBooking({
    required this.id,
    required this.clientName,
    required this.eventDate,
    this.packageType,
    required this.guestsCount,
    this.totalPrice,
    this.depositPaid,
    this.status,
    this.phone,
  });

  String get customerName => clientName;

  factory BirthdayBooking.fromJson(Map<String, dynamic> json) {
    final rawDate = json['start_at'] ?? json['event_date'];
    return BirthdayBooking(
      id: json['id']?.toString() ?? '',
      clientName:
          json['title']?.toString() ??
          json['child_name']?.toString() ??
          json['client_name']?.toString() ??
          json['customer_name']?.toString() ??
          'عميل',
      eventDate: rawDate != null
          ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
          : DateTime.now(),
      packageType: (json['package_type'] ?? json['event_type']) as String?,
      guestsCount: (json['guests_count'] as num?)?.toInt() ?? 1,
      totalPrice: ((json['total_amount'] ?? json['package_price'] ?? json['total_price']) as num?)?.toDouble(),
      depositPaid: ((json['deposit_amount'] ?? json['deposit_paid']) as num?)?.toDouble(),
      status: json['status'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': clientName,
      'client_name': clientName,
      'start_at': eventDate.toIso8601String(),
      'event_date': eventDate.toIso8601String(),
      'package_type': packageType,
      'guests_count': guestsCount,
      'total_amount': totalPrice,
      'total_price': totalPrice,
      'deposit_paid': depositPaid,
      'status': status,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [
    id,
    clientName,
    eventDate,
    packageType,
    guestsCount,
    totalPrice,
    depositPaid,
    status,
    phone,
  ];
}

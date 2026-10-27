import 'package:equatable/equatable.dart';

// ==============================================================================
// نموذج حركة سحب نقدية من الخزينة (CashWithdrawalModel)
// ==============================================================================
class CashWithdrawalModel extends Equatable {
  final String id;
  final String staffName;
  final double amount;
  final String reason;
  final DateTime createdAt;

  const CashWithdrawalModel({
    required this.id,
    required this.staffName,
    required this.amount,
    required this.reason,
    required this.createdAt,
  });

  factory CashWithdrawalModel.fromJson(Map<String, dynamic> json) {
    return CashWithdrawalModel(
      id: json['id']?.toString() ?? '',
      staffName:
          json['category']?.toString() ??
          json['created_by']?.toString() ??
          json['staff_name']?.toString() ??
          '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      reason:
          json['description']?.toString() ?? json['reason']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : (json['spent_at'] != null
              ? DateTime.tryParse(json['spent_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_by': staffName,
      'amount': amount,
      'description': reason,
      'payment_method': 'cash',
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, staffName, amount, reason, createdAt];
}

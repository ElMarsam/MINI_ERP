import 'package:equatable/equatable.dart';

// ==============================================================================
// نموذج بيانات العميل (CustomerModel)
// ==============================================================================
class CustomerModel extends Equatable {
  final String id;
  final String name;
  final String? phone;
  final String? notes;
  final double? balance;
  final DateTime? createdAt;
  final bool isActive;

  const CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    this.balance,
    this.createdAt,
    this.isActive = true,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone'] as String?,
      notes: json['notes'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'notes': notes,
      'balance': balance,
      'created_at': createdAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? notes,
    double? balance,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    notes,
    balance,
    createdAt,
    isActive,
  ];
}

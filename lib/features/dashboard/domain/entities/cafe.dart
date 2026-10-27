import 'package:equatable/equatable.dart';

// ==============================================================================
// كيان منتجات الكافيه والبوفيه (CafeProduct)
// ==============================================================================
class CafeProduct extends Equatable {
  final String id;
  final String name;
  final double price;
  final String category;
  final bool isAvailable;
  final String? imageUrl;

  const CafeProduct({
    required this.id,
    required this.name,
    required this.price,
    this.category = 'أخرى',
    this.isAvailable = true,
    this.imageUrl,
  });

  factory CafeProduct.fromJson(Map<String, dynamic> json) {
    return CafeProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category']?.toString() ?? 'أخرى',
      isAvailable: (json['is_available'] as bool?) ?? true,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'is_available': isAvailable,
      'image_url': imageUrl,
    };
  }

  @override
  List<Object?> get props => [id, name, price, category, isAvailable, imageUrl];
}

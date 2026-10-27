import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:coworking_erp/core/constants/app_colors.dart';
import 'package:coworking_erp/core/constants/app_text_style.dart';

// ==============================================================================
// كائن عنصر طلب البوفيه (CafeOrderItem)
// ==============================================================================
class CafeOrderItem {
  final String productId;
  final String productName;
  final double price;
  int quantity;

  CafeOrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

// ==============================================================================
// نافذة اختيار طلبات الكافيه والبوفيه (SelectCafeDialog)
// تطابق تماماً التصميم المعتمد في التطبيق (Image 4)
// ==============================================================================
class SelectCafeDialog extends StatefulWidget {
  final Map<String, CafeOrderItem> initialSelectedItems;

  const SelectCafeDialog({super.key, required this.initialSelectedItems});

  static Future<Map<String, CafeOrderItem>?> show(
    BuildContext context, {
    Map<String, CafeOrderItem> initialSelectedItems = const {},
  }) {
    return showDialog<Map<String, CafeOrderItem>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SelectCafeDialog(initialSelectedItems: initialSelectedItems),
    );
  }

  @override
  State<SelectCafeDialog> createState() => _SelectCafeDialogState();
}

class _SelectCafeDialogState extends State<SelectCafeDialog> {
  late Map<String, CafeOrderItem> _items;
  String _selectedCategory = 'الكل';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<String> _categories = [
    'الكل',
    'مشروبات ساخنة',
    'مشروبات باردة',
    'مأكولات وسناكس',
    'حلويات',
  ];

  static const List<Map<String, dynamic>> _menuProducts = [
    {
      'id': 'prod-1',
      'name': 'قهوة تركي مظبوط / سادة',
      'price': 20.0,
      'category': 'مشروبات ساخنة',
      'icon': LucideIcons.coffee,
    },
    {
      'id': 'prod-2',
      'name': 'إسبريسو سينجل / دبل',
      'price': 25.0,
      'category': 'مشروبات ساخنة',
      'icon': LucideIcons.coffee,
    },
    {
      'id': 'prod-3',
      'name': 'كابتشينو إيطالي',
      'price': 35.0,
      'category': 'مشروبات ساخنة',
      'icon': LucideIcons.coffee,
    },
    {
      'id': 'prod-4',
      'name': 'كافيه لاتيه',
      'price': 40.0,
      'category': 'مشروبات ساخنة',
      'icon': LucideIcons.coffee,
    },
    {
      'id': 'prod-5',
      'name': 'فلات وايت',
      'price': 42.0,
      'category': 'مشروبات ساخنة',
      'icon': LucideIcons.coffee,
    },
    {
      'id': 'prod-6',
      'name': 'شاي أحمر / أخضر بالنعناع',
      'price': 15.0,
      'category': 'مشروبات ساخنة',
      'icon': LucideIcons.coffee,
    },
    {
      'id': 'prod-7',
      'name': 'عصير برتقال فريش',
      'price': 30.0,
      'category': 'مشروبات باردة',
      'icon': LucideIcons.cupSoda,
    },
    {
      'id': 'prod-8',
      'name': 'مياه معدنية',
      'price': 10.0,
      'category': 'مشروبات باردة',
      'icon': LucideIcons.cupSoda,
    },
    {
      'id': 'prod-9',
      'name': 'كرواسون جبنة / شيكولاتة',
      'price': 35.0,
      'category': 'مأكولات وسناكس',
      'icon': LucideIcons.croissant,
    },
    {
      'id': 'prod-10',
      'name': 'كوكيز شوكولاتة',
      'price': 25.0,
      'category': 'حلويات',
      'icon': LucideIcons.cookie,
    },
  ];

  @override
  void initState() {
    super.initState();
    _items = Map<String, CafeOrderItem>.from(
      widget.initialSelectedItems.map(
        (key, value) => MapEntry(
          key,
          CafeOrderItem(
            productId: value.productId,
            productName: value.productName,
            price: value.price,
            quantity: value.quantity,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    return _items.values.fold(0.0, (sum, i) => sum + i.total);
  }

  int get _totalCount {
    return _items.values.fold(0, (sum, i) => sum + i.quantity);
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return _menuProducts.where((p) {
      final name = p['name'] as String;
      final category = p['category'] as String;

      final matchesCategory = _selectedCategory == 'الكل' || category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || name.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.surface,
        child: Container(
          width: 580,
          constraints: const BoxConstraints(maxHeight: 700),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── ترويسة النافذة ───
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.coffee,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'بوفيه المأكولات والمشروبات',
                          style: AppTextStyles.headlineMd.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'اختر الطلبات والمشروبات لحساب الجلسة',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      LucideIcons.x,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── حقل البحث السريع ───
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن مشروب أو صنف في المنيو...',
                  prefixIcon: const Icon(LucideIcons.search, size: 16),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, size: 14),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.dividerInteractive),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              ),
              const SizedBox(height: 12),

              // ─── تصنيفات المنيو (Horizontal Filter Tabs) ───
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedCategory = cat),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.secondary : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.secondary : AppColors.divider,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: AppTextStyles.labelMd.copyWith(
                              color: isSelected ? Colors.white : AppColors.textMuted,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // ─── قائمة الأصناف ───
              Expanded(
                child: _filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد أصناف تطابق البحث',
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          final id = product['id'] as String;
                          final name = product['name'] as String;
                          final price = (product['price'] as num).toDouble();
                          final icon = (product['icon'] as IconData?) ?? LucideIcons.coffee;
                          final currentItem = _items[id];
                          final qty = currentItem?.quantity ?? 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: qty > 0 ? AppColors.secondaryContainer.withValues(alpha: 0.3) : AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: qty > 0 ? AppColors.secondary.withValues(alpha: 0.6) : AppColors.divider,
                              ),
                            ),
                            child: Row(
                              children: [
                                // زر الإضافة أو أزرار التحكم بالكمية في اليسار
                                if (qty == 0)
                                  IconButton(
                                    icon: const Icon(
                                      LucideIcons.circlePlus,
                                      color: AppColors.secondary,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _items[id] = CafeOrderItem(
                                          productId: id,
                                          productName: name,
                                          price: price,
                                          quantity: 1,
                                        );
                                      });
                                    },
                                  )
                                else
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                        icon: const Icon(LucideIcons.minusCircle, color: AppColors.error, size: 18),
                                        onPressed: () {
                                          setState(() {
                                            if (qty > 1) {
                                              currentItem!.quantity--;
                                            } else {
                                              _items.remove(id);
                                            }
                                          });
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Text(
                                          '$qty',
                                          style: AppTextStyles.labelLg.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                        icon: const Icon(LucideIcons.plusCircle, color: AppColors.secondary, size: 18),
                                        onPressed: () {
                                          setState(() {
                                            currentItem!.quantity++;
                                          });
                                        },
                                      ),
                                    ],
                                  ),

                                const Spacer(),

                                // اسم وسعر الصنف في اليمين
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      name,
                                      style: AppTextStyles.labelLg.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${price.toStringAsFixed(1)} ج.م',
                                      style: AppTextStyles.bodySm.copyWith(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),

                                // أيقونة الصنف
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(icon, size: 16, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),

              // ─── الفوتر: الإجمالي وزر التأكيد والإلغاء ───
              Row(
                children: [
                  // الإجمالي في اليمين
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي طلبات البوفيه:',
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_totalAmount.toStringAsFixed(1)} ج.م ($_totalCount صنف)',
                        style: AppTextStyles.labelLg.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // أزرار الإلغاء والتأكيد في اليسار
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'إلغاء',
                      style: AppTextStyles.labelMd.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_items),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      _totalCount == 0 ? 'تأكيد (بدون طلبات)' : 'تأكيد الطلبات ($_totalCount)',
                      style: AppTextStyles.labelMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

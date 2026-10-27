import 'package:coworking_erp/core/constants/app_colors.dart';
import 'package:coworking_erp/core/constants/app_text_style.dart';
import 'package:coworking_erp/features/dashboard/data/datasources/supabase_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ==============================================================================
// ويدجت نافذة بدء سيشن جديدة (StartSessionDialog)
// تتيح فتح جلسة عمل لعميل حالي أو جديد، مع تحديد نوع الجلسة (عادي، عيد ميلاد، كورس، ...)
// وحساب سعر الدقيقة تلقائياً بناءً على سعر الساعة المدخل
// ==============================================================================
class StartSessionDialog extends StatefulWidget {
  // مرجع مصدر البيانات للتحقق من العميل أو إضافته
  final SupabaseRemoteDataSource dataSource;

  // دالة بدء الجلسة عند تأكيد النموذج
  final Future<void> Function({
    required String customerId,
    required String customerName,
    String? deskId,
    String? deskLabel,
    double? ratePerMinute,
  })
  onStartSession;

  const StartSessionDialog({
    super.key,
    required this.dataSource,
    required this.onStartSession,
  });

  // ميثود استاتيكية مساعدة لفتح النافذة
  static Future<void> show(
    BuildContext context, {
    required SupabaseRemoteDataSource dataSource,
    required Future<void> Function({
      required String customerId,
      required String customerName,
      String? deskId,
      String? deskLabel,
      double? ratePerMinute,
    })
    onStartSession,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StartSessionDialog(
        dataSource: dataSource,
        onStartSession: onStartSession,
      ),
    );
  }

  @override
  State<StartSessionDialog> createState() => _StartSessionDialogState();
}

class _StartSessionDialogState extends State<StartSessionDialog> {
  // وحدات التحكم بحقول الإدخال
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController(
    text: '30',
  ); // افتراضياً 30 ج.م/ساعة

  // نوع الحجز المختار في القائمة المنسدلة (افتراضياً الورك سبيس)
  String _selectedSessionType = 'الورك سبيس';

  // قائمة الأنواع المتاحة للحجوزات
  static const List<String> _sessionTypes = [
    'الورك سبيس',
    'ورشة',
    'جاردن',
    'عيد ميلاد',
    'كورس',
    'ميتنج روم',
  ];

  // دالة مساعدة لتحديد أيقونة كل نوع حجز
  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'ورشة':
        return LucideIcons.wrench;
      case 'جاردن':
        return LucideIcons.trees;
      case 'عيد ميلاد':
        return LucideIcons.cake;
      case 'كورس':
        return LucideIcons.graduationCap;
      case 'الورك سبيس':
      case 'ورك سبيس':
      case 'روك سبيس':
      case 'ورك سبيت':
        return LucideIcons.building2;
      case 'ميتنج روم':
        return LucideIcons.users;
      default:
        return LucideIcons.building2;
    }
  }

  // مؤشر التحميل أثناء الإنشاء
  bool _isSubmitting = false;

  // التخلص من وحدات التحكم
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  // التحقق من المدخلات، إنشاء حساب العميل إذا كان جديداً، وبدء الجلسة
  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى إدخال اسم العميل')));
      return;
    }

    // حساب تسعيرة الدقيقة (سعر الساعة ÷ 60)
    final hourlyRate =
        double.tryParse(_hourlyRateController.text.trim()) ?? 30.0;
    final ratePerMinute = hourlyRate > 0 ? (hourlyRate / 60.0) : 0.50;

    setState(() => _isSubmitting = true);
    try {
      // محاولة إضافة العميل في قاعدة البيانات أولاً
      final cust = await widget.dataSource.createCustomer({
        'name': name,
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'balance': 0.0,
      });

      // بدء الجلسة بالمعرف المرجع من قاعدة البيانات
      await widget.onStartSession(
        customerId: cust.id,
        customerName: cust.name,
        deskId: null,
        deskLabel: _selectedSessionType,
        ratePerMinute: ratePerMinute,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      // في حالة وجود قيود شبكة أو خطأ، يتم بدء الجلسة كـ Fallback بمعرف محلي فريد
      await widget.onStartSession(
        customerId: 'cust-${DateTime.now().millisecondsSinceEpoch}',
        customerName: name,
        deskId: null,
        deskLabel: _selectedSessionType,
        ratePerMinute: ratePerMinute,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.surface,
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── ترويسة النافذة: أيقونة التشغيل + العنوان ───
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.play,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('بدء سيشن جديدة', style: AppTextStyles.headlineMd),
                        Text(
                          'أدخل اسم العميل وسعر الساعة لبدء حساب الوقت الفعلي',
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
              const Divider(height: 24, color: AppColors.divider),

              // ─── حقل اسم العميل ───
              TextField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'اسم العميل *',
                  hintText: 'اكتب اسم العميل...',
                  prefixIcon: Icon(LucideIcons.user, size: 18),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),

              // ─── القائمة المنسدلة لاختيار نوع السيشن ───
              DropdownButtonFormField<String>(
                initialValue: _selectedSessionType,
                decoration: const InputDecoration(
                  labelText: 'نوع السيشن / الحجز *',
                  prefixIcon: Icon(LucideIcons.layers, size: 18),
                  border: OutlineInputBorder(),
                ),
                dropdownColor: AppColors.surface,
                icon: const Icon(
                  LucideIcons.chevronDown,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                borderRadius: BorderRadius.circular(8),
                items: _sessionTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTypeIcon(type),
                          size: 16,
                          color: type == _selectedSessionType
                              ? AppColors.secondary
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: type == _selectedSessionType
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedSessionType = val);
                  }
                },
              ),
              const SizedBox(height: 14),

              // ─── صف رقم الهاتف وسعر الساعة ───
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف / الواتساب (اختياري)',
                        hintText: '01xxxxxxxxx',
                        prefixIcon: Icon(LucideIcons.phone, size: 18),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _hourlyRateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'سعر الساعة *',
                        suffixText: 'ج.م',
                        prefixIcon: Icon(LucideIcons.coins, size: 18),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ─── أزرار الإجراءات (إلغاء + بدء السيشن الآن) ───
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(
                      'إلغاء',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            LucideIcons.play,
                            size: 16,
                            color: Colors.white,
                          ),
                    label: Text(
                      _isSubmitting ? 'جاري البدء...' : 'بدء السيشن الآن',
                      style: AppTextStyles.labelLg.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
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

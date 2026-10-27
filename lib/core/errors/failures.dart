import 'package:equatable/equatable.dart';

// ==============================================================================
// كلاس الفشل الأساسي (Base Failure)
// يرث من Equatable للمقارنة بالقيمة وليس بالمرجع في الذاكرة
// كل أنواع الأخطاء في طبقة الـ Domain والـ Core ترث من هذا الكلاس
// ==============================================================================
abstract class Failure extends Equatable {
  // رسالة الخطأ التي توضح سبب الفشل وتظهر للمستخدم أو تُسجل في الـ Logger
  final String message;

  // Constructor يستقبل رسالة الخطأ المطلوبة
  const Failure({required this.message});

  // خصائص الكائن المستخدمة في المقارنة (تحديد التساوي بين كائنين)
  @override
  List<Object> get props => [message];
}

// خطأ السيرفر: يحدث عند وجود مشكلة في الخادم أو استجابة غير متوقعة من Supabase/API
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

// خطأ الشبكة: يحدث عند انقطاع الإنترنت أو عدم القدرة على الوصول للسيرفر
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

// خطأ التخزين المؤقت / الكاش: يحدث عند الفشل في قراءة أو حفظ البيانات محلياً
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

// خطأ التحقق من صحة البيانات: يحدث عند إدخال بيانات غير صحيحة (مثل رقم هاتف غير صالح)
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

// خطأ عدم العثور على العنصر: يحدث عند البحث عن مورد غير موجود في قاعدة البيانات
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

// خطأ الصلاحيات والتوثيق: يحدث عند محاولة تنفيذ عملية تتطلب تسجيل دخول أو إذن خاص
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message});
}

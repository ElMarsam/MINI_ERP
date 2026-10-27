import 'package:logger/logger.dart';

// كلاس مسؤول عن طباعة رسائل الـ Log في التطبيق بشكل منظم وملوّن
// بدل ما تكتب print() في كل مكان، تستخدم AppLogger عشان الرسائل تبقى واضحة وقابلة للفلترة
class AppLogger {
  // إنشاء instance واحد من الـ Logger مع إعدادات الطباعة
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,         // عدد أسطر الـ Stack Trace اللي بتظهر في رسائل عادية
      errorMethodCount: 8,    // عدد أسطر الـ Stack Trace في رسائل الـ Error
      lineLength: 120,        // أقصى طول للسطر الواحد
      colors: true,           // تلوين الرسائل (أخضر للـ info، أحمر للـ error، ...)
      printEmojis: true,      // إضافة إيموجي قبل كل رسالة (💡 info, ⚠️ warning, 🚨 error)
    ),
  );

  // طباعة رسالة معلومة (info) - للأحداث الطبيعية
  static void info(String message, [dynamic data]) => _logger.i('$message ${data ?? ""}');

  // طباعة رسالة تنقيح (debug) - للتطوير والاختبار فقط
  static void debug(String message, [dynamic data]) => _logger.d('$message ${data ?? ""}');

  // طباعة تحذير (warning) - لحاجة مش خطأ بس تستاهل انتباه
  static void warning(String message, [dynamic data]) => _logger.w('$message ${data ?? ""}');

  // طباعة خطأ (error) - مع إمكانية تمرير الـ Exception والـ StackTrace
  static void error(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}

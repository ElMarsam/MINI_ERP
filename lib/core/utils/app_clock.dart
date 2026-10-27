// ==============================================================================
// كلاس توقيت التطبيق الموحد (AppClock)
// يضمن استقلال التطبيق التام عن إعدادات التوقيت المحلي لجهاز العميل (No Device Dependency)
// ويوحد كل الحسابات على توقيت القاهرة وسيرفر Supabase (UTC / Cairo Time)
// ==============================================================================
class AppClock {
  AppClock._();

  // الفارق الزمني لتوقيت القاهرة الحالي (UTC+3)
  static const Duration cairoOffset = Duration(hours: 3);

  // إرجاع التوقيت الحالي بصيغة UTC العالمية الموحدة مع السيرفر
  static DateTime nowUtc() => DateTime.now().toUtc();

  // إرجاع التوقيت الحالي بتوقيت القاهرة بغض النظر عن ضبط منطقة جهاز المستخدم
  static DateTime nowCairo() => DateTime.now().toUtc().add(cairoOffset);

  // تحويل أي كائن DateTime لتوقيت القاهرة بدقة واستقلالية تامة
  static DateTime toCairo(DateTime dateTime) {
    return dateTime.toUtc().add(cairoOffset);
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

// ==============================================================================
// إعدادات وتكوين عميل سوبابيز (Supabase Client Configuration)
// ==============================================================================
class AppSupabaseConfig {
  static const String supabaseUrl = 'https://bjudgttzzlcmsqxrojpl.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJqdWRndHR6emxjbXNxeHJvanBsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI4MzU3ODQsImV4cCI6MjEwODQxMTc4NH0.gOdONl_rqVEMj36Fqzep83qLNWTUYFTC5nMnKkMeKR8';

  // تهيئة اتصال Supabase عند بدء تشغيل التطبيق
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: supabaseAnonKey,
    );
  }

  // الحصول على كائن الـ Client الأساسي
  static SupabaseClient get client => Supabase.instance.client;
}

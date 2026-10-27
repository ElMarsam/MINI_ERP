import 'package:flutter/material.dart';
import 'package:erp_mini/core/routing/app_router.dart';
import 'package:erp_mini/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bjudgttzzlcmsqxrojpl.supabase.co',
    publishableKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJqdWRndHR6emxjbXNxeHJvanBsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI4MzU3ODQsImV4cCI6MjEwODQxMTc4NH0.gOdONl_rqVEMj36Fqzep83qLNWTUYFTC5nMnKkMeKR8',
  );

  // اختبار الاتصال بـ Supabase وطباعة النتيجة في الـ Debug Console
  try {
    final res = await Supabase.instance.client.from('transactions').select().limit(1);
    debugPrint('🟢 Supabase Connected Successfully! Response: $res');
  } catch (e) {
    debugPrint('🟡 Supabase Connection Note: $e');
  }

  runApp(const ErpApp());
}

class ErpApp extends StatelessWidget {
  const ErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NileHub ERP',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.secondary,
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
    );
  }
}

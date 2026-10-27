import 'package:flutter/material.dart';
import 'package:erp_mini/core/routing/app_router.dart';
import 'package:erp_mini/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

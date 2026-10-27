import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// ==============================================================================
// ويدجت مؤشر الماوس المخصص بأنيميشن Lottie (CustomLottieCursor)
// تلغي مؤشر الماوس الافتراضي للنظام وترسم مكانه أيقونة أو أنيميشن Lottie متحرك
// يتبع إحداثيات الماوس لحظياً ويتفاعل مع الضغطات بالانكماش الخفيف (Click Animation)
// ==============================================================================
class CustomLottieCursor extends StatefulWidget {
  // الويدجت الابن التي يتم تغليفها بمؤشر الماوس المخصص (مثل شاشة التطبيق بأكملها)
  final Widget child;

  // مسار ملف أنيميشن اللوتي في مجلد الأصول (Assets)
  final String assetPath;

  // حجم أبعاد المؤشر (العرض والارتفاع) بالبكسل
  final double size;

  // نقطة الارتكاز (Hotspot): الإزاحة بين رأس السهم وموضع النقر الفعلي
  final Offset hotspot;

  const CustomLottieCursor({
    super.key,
    required this.child,
    this.assetPath = 'assets/lotties/mouse.json',
    this.size = 34.0,
    this.hotspot = const Offset(4.0, 4.0),
  });

  @override
  State<CustomLottieCursor> createState() => _CustomLottieCursorState();
}

class _CustomLottieCursorState extends State<CustomLottieCursor> {
  // المتغير المراقب لموقع الماوس اللحظي (X, Y)
  final ValueNotifier<Offset?> _cursorPosition = ValueNotifier<Offset?>(null);

  // المتغير المراقب لحالة ضغط زر الماوس (مضغوط أم مفلوت) لتنفيذ تأثير النقر
  final ValueNotifier<bool> _isPointerDown = ValueNotifier<bool>(false);

  // التخلص من المراقبين عند تدمير الويدجت لمنع تسريب الذاكرة
  @override
  void dispose() {
    _cursorPosition.dispose();
    _isPointerDown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. MouseRegion: إخفاء مؤشر النظام وتتبع الدخول والخروج والتحويم
    return MouseRegion(
      cursor: SystemMouseCursors.none,
      onHover: (event) {
        _cursorPosition.value = event.position;
      },
      onEnter: (event) {
        _cursorPosition.value = event.position;
      },
      onExit: (_) {
        // إخفاء المؤشر عندما يغادر الماوس نافذة التطبيق
        _cursorPosition.value = null;
      },
      // 2. Listener: اعتراض أحداث المؤشر واللمس لتحديث الإحداثيات عند النقر والتحريك
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerMove: (event) => _cursorPosition.value = event.position,
        onPointerHover: (event) => _cursorPosition.value = event.position,
        onPointerDown: (event) {
          _cursorPosition.value = event.position;
          _isPointerDown.value = true; // تفعيل حالة الضغط لتصغير الحجم
        },
        onPointerUp: (_) => _isPointerDown.value = false,
        onPointerCancel: (_) => _isPointerDown.value = false,
        // 3. Stack: وضع شاشة التطبيق في الأسفل ومؤشر الـ Lottie فوقها
        child: Stack(
          fit: StackFit.expand,
          children: [
            // محتوى التطبيق الأساسي
            widget.child,

            // طبقة رسم مؤشر الـ Lottie المتحرك
            ValueListenableBuilder<Offset?>(
              valueListenable: _cursorPosition,
              builder: (context, pos, _) {
                // إذا كان الماوس خارج النافذة لا نرسم شيئاً
                if (pos == null) return const SizedBox.shrink();

                return Positioned(
                  left: pos.dx - widget.hotspot.dx,
                  top: pos.dy - widget.hotspot.dy,
                  // IgnorePointer: يضمن عدم اعتراض المؤشر للنقرات وتمريرها للعناصر تحته
                  child: IgnorePointer(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isPointerDown,
                      builder: (context, isDown, _) {
                        // أنيميشن تغيير الحجم عند الضغط
                        return AnimatedScale(
                          scale: isDown ? 0.85 : 1.0,
                          duration: const Duration(milliseconds: 90),
                          curve: Curves.easeOutQuad,
                          child: SizedBox(
                            width: widget.size,
                            height: widget.size,
                            // تشغيل ملف الـ Lottie بشكل متكرر
                            child: Lottie.asset(
                              widget.assetPath,
                              fit: BoxFit.contain,
                              repeat: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

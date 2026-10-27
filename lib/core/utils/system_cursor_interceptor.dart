import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ════════════════════════════════════════════════════════════════════════════════
// الهدف: إخفاء مؤشر الماوس الافتراضي (Windows cursor) في كل التطبيق
// حتى لا يظهر مع مؤشر الـ Lottie المتحرك المخصص
//
// المشكلة: فلاتر لما بيمر الماوس على زرار أو TextField، بيبعت أمر لـ Windows
// يغير شكل الماوس (مثلاً "cursor: click" أو "cursor: text")، فيظهر مؤشر Windows
// بجانب مؤشر الـ Lottie.
//
// الحل: اعتراض القناة 'flutter/mousecursor' وإجبار كل رسائلها تبعت 'kind: none'
// بدل أي شكل تاني، فيختفي مؤشر Windows تماماً.
// ════════════════════════════════════════════════════════════════════════════════

// الكلاس ده بيعمل Wrap على الـ BinaryMessenger الأصلي
// ويعترض أي رسالة بتروح لقناة الماوس قبل ما تصل لـ Windows
class _HideSystemCursorBinaryMessenger extends BinaryMessenger {
  final BinaryMessenger _delegate; // الـ Messenger الأصلي اللي بنغلفه

  _HideSystemCursorBinaryMessenger(this._delegate);

  // تمرير الرسائل القادمة من الـ Platform للـ Flutter بدون تعديل
  @override
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? data,
    PlatformMessageResponseCallback? callback,
  ) {
    // ignore: deprecated_member_use
    return _delegate.handlePlatformMessage(channel, data, callback);
  }

  // اعتراض الرسائل الخارجة من Flutter لـ Windows
  @override
  Future<ByteData?>? send(String channel, ByteData? message) {
    // نراقب قناة الماوس فقط، باقي القنوات تعدي عادي
    if (channel == 'flutter/mousecursor') {
      try {
        // محاولة فك تشفير الرسالة بـ StandardMethodCodec (الكودك الافتراضي)
        MethodCodec codec = const StandardMethodCodec();
        MethodCall? methodCall;
        try {
          methodCall = codec.decodeMethodCall(message);
        } catch (_) {
          // لو فشل، نجرب JSONMethodCodec كـ fallback
          codec = const JSONMethodCodec();
          methodCall = codec.decodeMethodCall(message);
        }

        // لو الأمر هو تفعيل مؤشر نظام معين
        if (methodCall.method == 'activateSystemCursor') {
          final args = Map<String, dynamic>.from(methodCall.arguments as Map);
          // نغير الـ kind لـ 'none' فيختفي مؤشر Windows
          args['kind'] = 'none';
          final newMessage = codec.encodeMethodCall(MethodCall('activateSystemCursor', args));
          return _delegate.send(channel, newMessage);
        }
      } catch (_) {
        // لو فشل كل حاجة، نمرر الرسالة الأصلية
      }
    }
    // أي قناة تانية تعدي بدون تعديل
    return _delegate.send(channel, message);
  }

  // تمرير تسجيل الـ Handlers بدون تعديل
  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    _delegate.setMessageHandler(channel, handler);
  }
}

// Custom Binding بديل عن WidgetsFlutterBinding العادي
// بيستخدم الـ Messenger المخصص اللي بيخفي مؤشر Windows
class HideSystemCursorBinding extends WidgetsFlutterBinding {
  // Singleton Pattern: لو التطبيق اتشغل خد نفس الـ instance
  static WidgetsBinding ensureInitialized() {
    return _instance ?? HideSystemCursorBinding();
  }

  static HideSystemCursorBinding? _instance;

  // Constructor: بيخزن نفسه في الـ static instance
  HideSystemCursorBinding() {
    _instance = this;
  }

  // Override الـ createBinaryMessenger عشان نستخدم الـ Messenger المخصص
  @override
  BinaryMessenger createBinaryMessenger() {
    return _HideSystemCursorBinaryMessenger(super.createBinaryMessenger());
  }
}

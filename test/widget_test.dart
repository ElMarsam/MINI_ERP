import 'package:flutter_test/flutter_test.dart';

import 'package:erp_mini/main.dart';

void main() {
  testWidgets('NileHub ERP smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ErpApp());

    // Verify app renders dashboard or main elements.
    expect(find.text('الرئيسية - لوحة التحكم'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ai_ar_advertisement/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ArAdVisionApp());
    expect(find.byType(ArAdVisionApp), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kids_app_grad/my_application/my_application.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApplication());
  });
}

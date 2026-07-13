import 'package:flutter_test/flutter_test.dart';

import 'package:ma/main.dart';

void main() {
  testWidgets('App launches and shows Login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const POSApp());

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
  });
}

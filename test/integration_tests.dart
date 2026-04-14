import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reliq_app/main.dart';
import 'package:reliq_app/screens/auth_screens/splash_screen.dart';

void main() {
  testWidgets('App initializes with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ReliqApp(initialTheme: 'white'));

    // Verify splash screen appears
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('RELIQ'), findsOneWidget);
    expect(find.byIcon(Icons.church_rounded), findsOneWidget);
  });

  testWidgets('App waits before navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const ReliqApp(initialTheme: 'white'));

    // After initial build, splash should still show
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('RELIQ'), findsOneWidget);
  });
}

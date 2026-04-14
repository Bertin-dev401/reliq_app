// Widget tests for Reliq App
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:reliq_app/main.dart';
import 'package:reliq_app/providers/auth_provider.dart';
import 'package:reliq_app/utils/validation_utils.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ReliqApp(initialTheme: 'white'));

    // Verify splash screen appears
    expect(find.text('RELIQ'), findsOneWidget);
    expect(find.byIcon(Icons.church_rounded), findsOneWidget);
  });

  testWidgets('Email validation works correctly', (WidgetTester tester) async {
    // Valid emails
    expect(ValidationUtils.validateEmail('user@example.com'), isNull);
    expect(ValidationUtils.validateEmail('test.email+tag@domain.co.uk'), isNull);

    // Invalid emails
    expect(ValidationUtils.validateEmail(''), isNotNull);
    expect(ValidationUtils.validateEmail('invalidemail'), isNotNull);
    expect(ValidationUtils.validateEmail('user@'), isNotNull);
  });

  testWidgets('Password validation requires strong password', (WidgetTester tester) async {
    // Invalid passwords
    expect(ValidationUtils.validatePassword('weak'), isNotNull); // Too short
    expect(ValidationUtils.validatePassword('noupppercase1'), isNotNull);
    expect(ValidationUtils.validatePassword('NOLOWERCASE1'), isNotNull);
    expect(ValidationUtils.validatePassword('NoNumbers'), isNotNull);

    // Valid password
    expect(ValidationUtils.validatePassword('ValidPass1'), isNull);
  });

  testWidgets('Name validation works correctly', (WidgetTester tester) async {
    // Valid names
    expect(ValidationUtils.validateName('John Doe'), isNull);
    expect(ValidationUtils.validateName('AB'), isNull);

    // Invalid names
    expect(ValidationUtils.validateName(''), isNotNull);
    expect(ValidationUtils.validateName('A'), isNotNull);
    expect(
      ValidationUtils.validateName('A' * 101), // Over 100 chars
      isNotNull,
    );
  });

  testWidgets('Denomination validation works correctly', (WidgetTester tester) async {
    // Valid denomination
    expect(ValidationUtils.validateDenomination('Catholic'), isNull);

    // Invalid denomination
    expect(ValidationUtils.validateDenomination(''), isNotNull);
    expect(ValidationUtils.validateDenomination(null), isNotNull);
    expect(ValidationUtils.validateDenomination('All'), isNotNull);
  });

  testWidgets('Password confirmation validation works', (WidgetTester tester) async {
    const password = 'ValidPass1';

    // Matching passwords
    expect(ValidationUtils.validateConfirmPassword(password, password), isNull);

    // Non-matching passwords
    expect(
      ValidationUtils.validateConfirmPassword('DifferentPass1', password),
      isNotNull,
    );
  });

  testWidgets('Required field validation works', (WidgetTester tester) async {
    // Empty/null values
    expect(ValidationUtils.validateRequired('', 'Username'), isNotNull);
    expect(ValidationUtils.validateRequired(null, 'Email'), isNotNull);
    expect(ValidationUtils.validateRequired('   ', 'Password'), isNotNull);

    // Valid value
    expect(ValidationUtils.validateRequired('valid_value', 'Field'), isNull);
  });
}

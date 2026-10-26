import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signup_app/main.dart';

void main() {
  testWidgets('Empty fields display errors and do not show success', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Create Your Account'), findsOneWidget);
    expect(find.text('Join Us Today for the Cash Money!'), findsOneWidget);

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your full name'), findsOneWidget);
    expect(find.text('Please enter your email address'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Invalid input is rejected and valid input shows green success', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '   ');
    await tester.enterText(fields.at(1), 'student.example.com');
    await tester.enterText(fields.at(2), '12345');
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your full name'), findsOneWidget);
    expect(find.text('Please enter a valid email address'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    await tester.enterText(fields.at(0), 'Student Name');
    await tester.enterText(fields.at(1), 'student@example.com');
    await tester.enterText(fields.at(2), '123456');
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Sign up successful!'), findsOneWidget);
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
      Colors.green,
    );
    expect(find.text('Please enter your full name'), findsNothing);
    expect(find.text('Please enter a valid email address'), findsNothing);
    expect(find.text('Password must be at least 6 characters'), findsNothing);
  });
}

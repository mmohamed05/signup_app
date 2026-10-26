import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signup_app/local_signup_tips.dart';
import 'package:signup_app/main.dart';
import 'package:signup_app/signup_coach.dart';

Future<void> showCoach(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: SignupCoach())),
  );
}

Future<void> requestTip(WidgetTester tester) async {
  final button = find.text('Get a signup tip');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
}

void main() {
  test(
    'Preset tips have fixed category and are plain text within 240 characters',
    () {
      expect(LocalSignupTips.category, 'password_help');
      for (final tip in LocalSignupTips.tips) {
        expect(tip, isNotEmpty);
        expect(tip.length, lessThanOrEqualTo(240));
        expect(tip, isNot(matches(r'[<>\n\r]')));
      }
    },
  );

  testWidgets('Loading indicator appears and prevents duplicate requests', (
    tester,
  ) async {
    await showCoach(tester);
    await requestTip(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    expect(find.text(LocalSignupTips.tips.first), findsNothing);
    await tester.pump(LocalSignupTips.delay);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Success shows labeled deterministic tips and cycles in order', (
    tester,
  ) async {
    await showCoach(tester);
    expect(find.text('Preset demo tip — not live AI'), findsOneWidget);
    expect(find.text('Category: password_help'), findsOneWidget);
    for (var i = 0; i <= LocalSignupTips.tips.length; i++) {
      await requestTip(tester);
      await tester.pump(LocalSignupTips.delay);
      await tester.pumpAndSettle();
      expect(
        find.text(LocalSignupTips.tips[i % LocalSignupTips.tips.length]),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsNothing);
    }
  });

  testWidgets('Simulated error shows an error and Retry without a tip', (
    tester,
  ) async {
    await showCoach(tester);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await requestTip(tester);
    await tester.pump(LocalSignupTips.delay);
    await tester.pumpAndSettle();
    expect(
      find.text('Demo error: could not load a preset tip. Please retry.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text(LocalSignupTips.tips.first), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Retry loads successfully after the simulated error', (
    tester,
  ) async {
    await showCoach(tester);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await requestTip(tester);
    await tester.pump(LocalSignupTips.delay);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(LocalSignupTips.delay);
    await tester.pumpAndSettle();
    expect(find.text(LocalSignupTips.tips.first), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(
      find.text('Demo error: could not load a preset tip. Please retry.'),
      findsNothing,
    );
  });

  testWidgets(
    'Coach preserves personal data and does not trigger or bypass validation',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      final fields = find.byType(TextFormField);
      const privateValues = ['Private Student', 'private-invalid-email', 'abc'];
      for (var i = 0; i < privateValues.length; i++) {
        await tester.enterText(fields.at(i), privateValues[i]);
      }
      await requestTip(tester);
      await tester.pump(LocalSignupTips.delay);
      await tester.pumpAndSettle();
      expect(find.text(LocalSignupTips.tips.first), findsOneWidget);
      expect(find.text('Please enter a valid email address'), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      final coachText = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(SignupCoach),
              matching: find.byType(Text),
            ),
          )
          .map((text) => text.data ?? '')
          .join(' ');
      for (var i = 0; i < privateValues.length; i++) {
        expect(
          tester.widget<TextFormField>(fields.at(i)).controller!.text,
          privateValues[i],
        );
        expect(coachText, isNot(contains(privateValues[i])));
      }
      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsNothing);
    },
  );

  testWidgets('Pending local request safely finishes after coach is disposed', (
    tester,
  ) async {
    await showCoach(tester);
    await requestTip(tester);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(LocalSignupTips.delay);
    expect(tester.takeException(), isNull);
  });
}

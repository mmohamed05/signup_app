# signup_app — MAD 4360 Activity 10

Flutter signup form with Undergraduate Task A: Local AI Signup Coach Simulation.
The implementation follows the requirements supplied by the supervising assistant;
the professor's PDF was not available.

## Run

Verified with Flutter 3.47.2 and Dart 3.13.2.

```sh
flutter pub get
flutter run -d emulator-5554
flutter analyze
flutter test --reporter expanded
flutter build apk --release
```

## Signup form

The original `MyApp → MaterialApp → SignupPage → Scaffold → Form → Column`
structure, purple theme, three controllers, and `GlobalKey<FormState>` are retained.
A scroll view accommodates the keyboard and smaller screens.

- Heading: **Create Your Account**
- AppBar: **Join Us Today for the Cash Money!**
- Full Name: rejects empty or whitespace-only input.
- Email Address: rejects empty input or input without `@`.
- Password: obscured; requires at least 6 characters.
- Sign Up: validates the form before showing the green success SnackBar.

This is a UI demonstration; it does not create or persist an account.

## Task A

**Get a signup tip** uses only the fixed `password_help` category. Three preset,
plain-text tips cycle deterministically, each at most 240 characters. A 600 ms
local delay demonstrates loading. Requests are disabled while loading. Results
are labeled **Preset demo tip — not live AI**.

Select **Simulate next error**, then request a tip to demonstrate the error state.
The switch resets for that request; **Retry** loads the next preset successfully.
A failed request does not advance the tip sequence.

## Privacy design

`SignupCoach` owns its service and UI state. Its constructor receives no form
values, controllers, callbacks, or form key. `LocalSignupTips.getTip` accepts only
a Boolean error simulation flag. The coach never reads personal form data, logs
it, stores it, sends it elsewhere, or submits the form. It cannot bypass signup
validation. No HTTP client, external AI service, API key, or networking is used.
The verified release APK has no Internet permission. Flutter's generated debug
and profile manifests retain their development tooling permissions.

## Final verification — October 26, 2026

- `flutter analyze`: **No issues found!** (1.0 s).
- `flutter test --reporter expanded`: **9 passed, 0 failed** (`+9: All tests passed!`).
- `flutter build apk --release`: succeeded; reported APK size **48.2 MB**.
- Release APK installed successfully and launched on existing **Pixel_7**, device
  `emulator-5554` (1080 × 2400).
- Android `apksigner verify --verbose`: **Verifies**, APK Signature Scheme v2 valid.
- Package: `com.example.signup_app`, version `1.0.0` (code 1), minimum SDK 24,
  target SDK 36; ARM64, ARMv7, and x86_64 native libraries.

### Automated test coverage

| Test | Result |
| --- | --- |
| Empty fields display errors and do not show success | PASS |
| Invalid input is rejected and valid input shows green success | PASS |
| Preset tips have fixed category and are plain text within 240 characters | PASS |
| Loading indicator appears and prevents duplicate requests | PASS |
| Success shows labeled deterministic tips and cycles in order | PASS |
| Simulated error shows an error and Retry without a tip | PASS |
| Retry loads successfully after the simulated error | PASS |
| Coach preserves personal data and does not trigger or bypass validation | PASS |
| Pending local request safely finishes after coach is disposed | PASS |

### Actual Pixel 7 release-app checks and screenshots

Screenshots are unedited PNG captures from `adb exec-out screencap -p`, not mockups.
Only synthetic signup inputs were used. Android UI hierarchy checks confirmed the
validation, success, error, and retry result text; loading was captured during the
actual local delay.

| Check | Result | Screenshot |
| --- | --- | --- |
| Original form and coach label | PASS | [Initial](evidence/screenshots/01-initial.png) |
| Empty form shows all three validation errors | PASS | [Empty validation](evidence/screenshots/02-empty-validation.png) |
| `Demo Student`, `invalid-email`, `12345` rejected | PASS | [Invalid input](evidence/screenshots/03-invalid-input.png) |
| `Demo Student`, `demo@example.com`, `demo123` shows green success | PASS | [Signup success](evidence/screenshots/04-signup-success.png) |
| Tip request displays loading | PASS | [Loading](evidence/screenshots/05-tip-loading.png) |
| First preset appears | PASS | [Tip success](evidence/screenshots/06-tip-success.png) |
| Simulated error shows Retry | PASS | [Error](evidence/screenshots/07-tip-error.png) |
| Retry displays loading | PASS | [Retry loading](evidence/screenshots/08-retry-loading.png) |
| Retry returns the next preset | PASS | [Retry success](evidence/screenshots/09-retry-success.png) |

## Release APK

Local build output: `build/app/outputs/flutter-apk/app-release.apk`.
Build output is ignored by Git. The source repository contains the screenshot evidence.

SHA-256:

```text
d1e468028ece155a143b16f9deb06c7cdd341d960c468077030e5604ffa2c94c
```

The release build retains Flutter's starter **debug signing key** configuration.
It is installable for this classroom demonstration; a production store release
would require a dedicated release signing configuration.

## Undergraduate reflection questions

The professor's exact questions are reproduced below, with draft answers for review.

1. **Trace the local tip feature from button tap to displayed text. Which widget/state changes during the simulated loading state, and how does the user recover from the local error case?**

   **Draft answer:** Tapping **Get a signup tip** calls `_getTip()` in
   `_SignupCoachState`, which uses `setState` to clear the previous tip and set
   `_state` to `_TipState.loading`; `SignupCoach` then shows a
   `CircularProgressIndicator` and loading text while disabling the request
   button and error checkbox.
   After the 600 ms local delay, `LocalSignupTips.getTip()` returns a preset and
   another `setState` stores it in `_tip` and selects `_TipState.success`, causing
   `Text(_tip!)` to display it.
   If **Simulate next error** was selected, the request instead enters
   `_TipState.error` and shows **Retry**, which calls `_getTip()` again with the
   one-shot error flag already reset; the loading, error, and retry tests verify
   the indicator, disabled button, error message, and successful recovery.

2. **Why must the app keep form validation local even when it can ask an AI for a tip? Give one example of a bad decision if AI were allowed to approve signup.**

   **Draft answer:** Local validation enforces the required name, email, and
   password rules consistently, while advice from an AI could be incorrect and
   must never determine signup approval; this implementation uses only preset
   local tips and gives the coach no access to form values or the form key.
   A bad decision would be approving signup with the three-character password
   `abc` because an AI called it acceptable, despite the six-character minimum.
   The privacy-separation test confirms that requesting a tip preserves the
   entered values and does not submit the form, and that subsequently pressing
   **Sign Up** still rejects the invalid email and short password without
   showing the success SnackBar.

## Source layout

- `lib/main.dart`: original signup form plus the separate coach widget.
- `lib/signup_coach.dart`: coach presentation and request states.
- `lib/local_signup_tips.dart`: fixed category, preset tips, local simulation.
- `test/widget_test.dart`: original form validation checks.
- `test/signup_coach_test.dart`: coach states, privacy separation, and lifecycle checks.
- `evidence/screenshots/`: genuine Pixel 7 release-app screenshots.

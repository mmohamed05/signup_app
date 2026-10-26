/// Local preset data only. This API accepts no personal form data.
class LocalSignupTips {
  static const category = 'password_help';
  static const delay = Duration(milliseconds: 600);
  static const tips = <String>[
    'Use a long, unique password for each account. A passphrase made of unrelated words can be easier to remember.',
    'Avoid names, birthdays, and common phrases in passwords. Never share your password with anyone.',
    'A password manager can help you create and store unique passwords. Enable two-step verification when available.',
  ];

  int _nextTip = 0;

  Future<String> getTip({bool simulateError = false}) async {
    await Future<void>.delayed(delay);
    if (simulateError) {
      throw StateError('Simulated local tip error');
    }
    final tip = tips[_nextTip];
    _nextTip = (_nextTip + 1) % tips.length;
    return tip;
  }
}

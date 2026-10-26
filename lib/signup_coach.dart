import 'package:flutter/material.dart';

import 'local_signup_tips.dart';

/// Separate from signup: no form values, controllers, or form key are received.
class SignupCoach extends StatefulWidget {
  const SignupCoach({super.key});

  @override
  State<SignupCoach> createState() => _SignupCoachState();
}

enum _TipState { idle, loading, success, error }

class _SignupCoachState extends State<SignupCoach> {
  final LocalSignupTips _tips = LocalSignupTips();
  _TipState _state = _TipState.idle;
  bool _simulateNextError = false;
  String? _tip;

  Future<void> _getTip() async {
    if (_state == _TipState.loading) return;
    final simulateError = _simulateNextError;
    setState(() {
      _state = _TipState.loading;
      _tip = null;
      _simulateNextError = false;
    });
    try {
      final tip = await _tips.getTip(simulateError: simulateError);
      if (!mounted) return;
      setState(() {
        _tip = tip;
        _state = _TipState.success;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _TipState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = _state == _TipState.loading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Local AI Signup Coach Simulation'),
        const Text('Preset demo tip — not live AI'),
        const Text('Category: ${LocalSignupTips.category}'),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Simulate next error'),
          value: _simulateNextError,
          onChanged: loading
              ? null
              : (value) => setState(() => _simulateNextError = value ?? false),
        ),
        ElevatedButton(
          onPressed: loading ? null : _getTip,
          child: const Text('Get a signup tip'),
        ),
        if (loading) ...[
          const Center(child: CircularProgressIndicator()),
          const Text('Loading preset tip...'),
        ],
        if (_state == _TipState.success)
          Semantics(liveRegion: true, child: Text(_tip!)),
        if (_state == _TipState.error) ...[
          const Text('Demo error: could not load a preset tip. Please retry.'),
          TextButton(onPressed: _getTip, child: const Text('Retry')),
        ],
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_result.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_primary_button.dart';
import '../data/auth_providers.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/otp_boxes.dart';

/// Page 08 — OTP Verification. `POST /auth/otp/verify`, six digits.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.mobile});

  final String mobile;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _resendSeconds = 30;

  String _code = '';
  String _status = '';
  bool _busy = false;
  int _seconds = _resendSeconds;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _ticker?.cancel();
    setState(() => _seconds = _resendSeconds);
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _seconds--);
      if (_seconds <= 0) timer.cancel();
    });
  }

  Future<void> _resend() async {
    setState(() => _status = '');
    final result = await ref
        .read(authControllerProvider.notifier)
        .sendOtp(widget.mobile);
    if (!mounted) return;
    _startTimer();
    if (result case ApiFailure(:final message)) {
      setState(() => _status = message);
    }
  }

  Future<void> _verify() async {
    if (_code.length != 6) {
      setState(() => _status = 'Enter all six digits');
      return;
    }

    setState(() {
      _busy = true;
      _status = '';
    });
    final result = await ref
        .read(authControllerProvider.notifier)
        .verifyOtp(mobile: widget.mobile, code: _code);
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case ApiSuccess(:final data):
        // A first OTP login only ever creates a CUSTOMER, so a trainer who
        // has not applied yet goes to the wizard, not the shell.
        context.go(data.needsApplication ? '/onboarding/profile' : '/');
      case ApiFailure(:final message):
        setState(() => _status = message);
    }
  }

  String get _masked {
    final m = widget.mobile;
    return m.length == 10 ? '+91 ••••••${m.substring(6)}' : '+91 $m';
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      step: 2,
      icon: Icons.mail_outline_rounded,
      eyebrow: 'ONE MORE STEP',
      headline: 'VERIFY YOUR',
      headlineAccent: 'NUMBER.',
      sub: 'Enter the 6-digit verification code we sent to your mobile number.',
      onBack: context.canPop() ? context.pop : null,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: HFColors.soft,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text.rich(
            TextSpan(
              text: 'OTP sent to ',
              children: [
                TextSpan(
                  text: _masked,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: HFColors.ink,
                  ),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 11, color: Color(0xFF75695E)),
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'Enter Verification Code *',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        OtpBoxes(
          onChanged: (value) => setState(() => _code = value),
          onCompleted: (_) => _verify(),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Didn't receive the code?",
              style: TextStyle(fontSize: 10, color: Color(0xFF75695E)),
            ),
            GestureDetector(
              onTap: _seconds > 0 ? null : _resend,
              child: Text(
                _seconds > 0 ? 'Resend in ${_seconds}s' : 'Resend OTP',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _seconds > 0
                      ? const Color(0xFFB7A99C)
                      : HFColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 27),
        HFPrimaryButton(
          label: 'VERIFY & CONTINUE',
          busy: _busy,
          onPressed: _verify,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 18,
          child: Center(
            child: Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: HFColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

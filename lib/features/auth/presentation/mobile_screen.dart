import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_result.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_primary_button.dart';
import '../data/auth_providers.dart';
import 'widgets/auth_scaffold.dart';

/// Page 07 — Mobile Number Verification. `POST /auth/otp/send`.
class MobileScreen extends ConsumerStatefulWidget {
  const MobileScreen({super.key});

  @override
  ConsumerState<MobileScreen> createState() => _MobileScreenState();
}

class _MobileScreenState extends ConsumerState<MobileScreen> {
  final _controller = TextEditingController();
  String? _fieldError;
  String _status = '';
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Client-side rule, matching `MOBILE_PATTERN` in `auth.dto.ts`.
  String? _validate(String value) {
    if (value.isEmpty) return 'Enter your mobile number';
    if (value.length != 10) return 'Mobile number must be 10 digits';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Enter a valid Indian mobile number';
    }
    return null;
  }

  Future<void> _send() async {
    final mobile = _controller.text.trim();
    final error = _validate(mobile);
    setState(() {
      _fieldError = error;
      _status = '';
    });
    if (error != null) return;

    setState(() => _busy = true);
    final result = await ref
        .read(authControllerProvider.notifier)
        .sendOtp(mobile);
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case ApiSuccess(:final data):
        // The API returns the code itself only when it runs in development.
        if (data.devCode != null) {
          setState(() => _status = 'Dev code: ${data.devCode}');
        }
        context.push('/login/otp', extra: mobile);
      case ApiFailure(:final message):
        setState(() => _status = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      step: 1,
      icon: Icons.search_rounded,
      eyebrow: 'VERIFY YOUR NUMBER',
      headline: 'YOUR PHONE.',
      headlineAccent: 'YOUR ACCOUNT.',
      sub:
          'Enter your mobile number. We’ll send you a one-time password to '
          'verify it’s really you.',
      onBack: context.canPop() ? context.pop : null,
      children: [
        const Text(
          'Mobile Number *',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 9),
        _MobileField(
          controller: _controller,
          hasError: _fieldError != null,
          onSubmitted: (_) => _send(),
          onChanged: (_) {
            if (_fieldError != null) setState(() => _fieldError = null);
          },
        ),
        if (_fieldError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 2),
            child: Text(
              _fieldError!,
              style: const TextStyle(fontSize: 10, color: HFColors.primary),
            ),
          ),
        const SizedBox(height: 27),
        HFPrimaryButton(label: 'SEND OTP', busy: _busy, onPressed: _send),
        const SizedBox(height: 12),
        SizedBox(
          height: 18,
          child: Center(
            child: Text(
              _status,
              style: const TextStyle(fontSize: 10, color: Color(0xFF75695E)),
            ),
          ),
        ),
      ],
    );
  }
}

/// `.phone-field` — fixed +91 prefix beside a 10-digit input.
class _MobileField extends StatelessWidget {
  const _MobileField({
    required this.controller,
    required this.hasError,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: HFColors.white,
        border: Border.all(
          color: hasError ? HFColors.primary : const Color(0xFFE8DCCF),
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFFE8DCCF))),
            ),
            child: const Center(
              child: Text(
                '🇮🇳  +91',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: .5,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 13),
                hintText: 'Enter 10-digit mobile number',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF9A8C7E)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

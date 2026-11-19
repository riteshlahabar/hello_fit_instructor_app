import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_result.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_primary_button.dart';
import '../../profile/data/profile_providers.dart';
import 'widgets/wizard_scaffold.dart';

/// Page 21 — Submit Profile for Verification.
///
/// `POST /app/instructor/code-of-conduct` then `POST /app/instructor/submit`.
/// The API refuses with reasons when the application is short, and those
/// reasons are what this screen shows — no checklist is computed here.
class SubmitScreen extends ConsumerStatefulWidget {
  const SubmitScreen({super.key});

  @override
  ConsumerState<SubmitScreen> createState() => _State();
}

class _State extends ConsumerState<SubmitScreen> {
  bool _accepted = false;
  bool _busy = false;
  String _status = '';

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _status = '';
    });
    final controller = ref.read(profileControllerProvider.notifier);

    if (!_acceptedAlready) {
      final accept = await controller.acceptCodeOfConduct();
      if (accept case ApiFailure(:final message)) {
        if (!mounted) return;
        return setState(() {
          _busy = false;
          _status = message;
        });
      }
    }

    final result = await controller.submitForReview();
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case ApiSuccess():
        context.go('/onboarding/status');
      case ApiFailure(:final message):
        setState(() => _status = message);
    }
  }

  bool get _acceptedAlready =>
      ref.read(profileControllerProvider).value?.onboarding
          .codeOfConductAccepted ??
      false;

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(profileControllerProvider).value?.onboarding;
    final blockers = onboarding?.blockersToShow ?? const <String>[];
    final canSubmit = onboarding?.readyApartFromCodeOfConduct ?? false;

    return WizardScaffold(
      stepLabel: 'FINAL ONBOARDING STEP',
      progress: 1,
      title: 'Submit Profile\nFor Verification',
      sub:
          'Send your profile to the HelloFit team. We will review it and let '
          'you know as soon as it is approved.',
      onBack: context.canPop() ? context.pop : null,
      children: [
        const WizardSectionLabel('WHAT HAPPENS NEXT'),
        for (final step in const [
          ('Ready to submit', Icons.check_circle_outline_rounded),
          ('Pending review', Icons.hourglass_empty_rounded),
          ('Team approval', Icons.verified_outlined),
        ])
          _Step(label: step.$1, icon: step.$2),
        if (blockers.isNotEmpty) ...[
          const SizedBox(height: 10),
          const WizardSectionLabel('STILL NEEDED'),
          for (final reason in blockers)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 15,
                    color: HFColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(fontSize: 11, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 12),
        InkWell(
          onTap: () => setState(() => _accepted = !_accepted),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _accepted,
                activeColor: HFColors.primary,
                visualDensity: VisualDensity.compact,
                onChanged: (v) => setState(() => _accepted = v ?? false),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 11),
                  child: Text(
                    'I accept the HelloFit code of conduct, terms and privacy '
                    'policy.',
                    style: TextStyle(fontSize: 11, height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        HFPrimaryButton(
          label: 'SUBMIT FOR VERIFICATION',
          busy: _busy,
          onPressed: _accepted && canSubmit ? _submit : null,
        ),
        SizedBox(
          height: 30,
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

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, size: 18, color: HFColors.primary),
          const SizedBox(width: 11),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

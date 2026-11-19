import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_primary_button.dart';
import '../../profile/data/profile_providers.dart';
import 'widgets/wizard_scaffold.dart';

/// Page 22 — Verification Status. Reads `onboarding.stage` and its progress
/// straight off the API; the stages are the `OnboardingStage` enum.
class VerificationStatusScreen extends ConsumerWidget {
  const VerificationStatusScreen({super.key});

  static const _stages = [
    ('APPLIED', 'Applied'),
    ('DOCUMENTS_SUBMITTED', 'Documents submitted'),
    ('SCREENING_CALL', 'Screening call'),
    ('DEMO_SESSION', 'Demo session'),
    ('APPROVED', 'Approved'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(profileControllerProvider).value?.onboarding;
    final current = onboarding?.stage ?? 'APPLIED';
    final reached = _stages.indexWhere((s) => s.$1 == current);

    return WizardScaffold(
      stepLabel: 'VERIFICATION',
      progress: (onboarding?.progressPercent ?? 0) / 100,
      title: onboarding?.isRejected ?? false
          ? 'Profile\nNeeds Changes'
          : 'Profile Under\nVerification',
      sub: onboarding?.isApproved ?? false
          ? 'You are approved. You can start accepting booking requests.'
          : 'Our team is reviewing your profile. You will be notified as soon '
                'as the review is done.',
      onBack: context.canPop() ? context.pop : null,
      children: [
        const WizardSectionLabel('PROGRESS'),
        for (var i = 0; i < _stages.length; i++)
          _StageRow(
            label: _stages[i].$2,
            done: reached >= 0 && i <= reached,
            active: i == reached,
          ),
        const SizedBox(height: 20),
        HFPrimaryButton(
          label: 'REFRESH STATUS',
          trailingArrow: false,
          onPressed: () =>
              ref.read(profileControllerProvider.notifier).refresh(),
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: () => context.go('/'),
            child: const Text(
              'Go to dashboard',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: HFColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.label,
    required this.done,
    required this.active,
  });

  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? HFColors.primary : Colors.transparent,
              border: Border.all(
                color: done ? HFColors.primary : const Color(0xFFD9CABC),
              ),
            ),
            child: done
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: done ? HFColors.ink : const Color(0xFF75695E),
            ),
          ),
        ],
      ),
    );
  }
}

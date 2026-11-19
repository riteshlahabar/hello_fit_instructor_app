import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../domain/dashboard_summary.dart';

/// `.status` — the approval-gate strip under the greeting.
class VerificationBanner extends StatelessWidget {
  const VerificationBanner({super.key, required this.state});

  final VerificationState state;

  @override
  Widget build(BuildContext context) {
    final (title, body, tag) = switch (state) {
      VerificationState.pending => (
        'Profile verification in progress',
        "We'll notify you when your profile is approved.",
        'PENDING',
      ),
      VerificationState.approved => (
        'Profile verified',
        'You can receive booking requests.',
        'APPROVED',
      ),
      VerificationState.rejected => (
        'Profile needs changes',
        'Open your profile to see what to fix.',
        'REJECTED',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: HFColors.statusBg,
        border: Border.all(color: HFColors.statusBorder),
        borderRadius: BorderRadius.circular(HFRadius.status),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: HFColors.statusTitle,
                  ),
                ),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 11,
                    color: HFColors.statusBody,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: HFColors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: HFColors.statusTag,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/hf_pieces.dart';
import '../../domain/earnings_models.dart';

/// `.total` — the big number at the top of page 57.
///
/// The comparison line is absent when `changePercent` is null, which is what
/// the API sends where there is no earlier period to compare against:
/// "↑ 0%" would claim a flat month that never happened.
class EarningsHeadline extends StatelessWidget {
  const EarningsHeadline({
    super.key,
    required this.summary,
    required this.period,
  });

  final EarningsSummary summary;
  final EarningsPeriod period;

  @override
  Widget build(BuildContext context) {
    final change = summary.changePercent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      decoration: BoxDecoration(
        color: HFColors.ink,
        borderRadius: BorderRadius.circular(HFRadius.metric),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'TOTAL EARNINGS · ${period.label.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 8,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC9BCAE),
                  ),
                ),
              ),
              const Icon(
                Icons.trending_up_rounded,
                size: 15,
                color: HFColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            rupees(summary.total),
            style: AppTheme.display(31, color: Colors.white),
          ),
          if (change != null) ...[
            const SizedBox(height: 5),
            Text(
              change >= 0
                  ? '↑ ${change.abs()}% compared to the period before'
                  : '↓ ${change.abs()}% compared to the period before',
              style: TextStyle(
                fontSize: 9,
                color: change >= 0
                    ? const Color(0xFF8FC9A8)
                    : const Color(0xFFE9A496),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

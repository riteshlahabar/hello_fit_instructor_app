import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_card.dart';
import '../../../core/widgets/hf_list_pieces.dart';
import '../../../core/widgets/hf_refresh.dart';
import '../../../core/widgets/hf_pieces.dart';
import '../data/earnings_providers.dart';
import '../domain/earnings_models.dart';
import 'widgets/earnings_chart.dart';
import 'widgets/earnings_headline.dart';
import 'widgets/transaction_row.dart';

/// Page 57 — Earnings Dashboard. The shell's fourth tab.
///
/// **No "Request Payout" button and no "Transactions" link**, though the
/// design has both: pages 58, 59 and 60 are not built, and a trainer cannot
/// start a payout — admin runs payout cycles (§6.7). The next-payout card
/// stays, because that figure is real.
class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(earningsSummaryProvider);
    final period = ref.watch(earningsPeriodProvider);

    return HFRefreshList(
      onRefresh: () => ref.refresh(earningsSummaryProvider.future),
      children: [
        const _Heading(),
        HFFilterChips<EarningsPeriod>(
          values: EarningsPeriod.values,
          labelOf: (value) => value.label,
          selected: period,
          onSelect: (value) =>
              ref.read(earningsPeriodProvider.notifier).set(value),
        ),
        const SizedBox(height: 13),
        ...switch (summary) {
          AsyncValue(:final value?) => _body(value, period),
          AsyncError(:final error) => [
            HFEmptyPanel(message: '$error'.replaceFirst('Exception: ', '')),
          ],
          _ => const [
            Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: CircularProgressIndicator(color: HFColors.primary),
              ),
            ),
          ],
        },
      ],
    );
  }

  List<Widget> _body(EarningsSummary summary, EarningsPeriod period) {
    return [
      EarningsHeadline(summary: summary, period: period),
      const HFSectionHead(title: 'Earnings summary'),
      HFCountTiles(
        tiles: [
          (rupees(summary.availableBalance), 'Available'),
          (rupees(summary.pendingAmount), 'Pending'),
          (rupees(summary.paidToDate), 'Paid out'),
        ],
      ),
      const SizedBox(height: 7),
      HFCountTiles(
        tiles: [
          ('${summary.completedSessions}', 'Sessions'),
          (rupees(summary.averagePerSession), 'Average'),
          (rupees(summary.withheldAmount), 'Withheld'),
        ],
      ),
      const HFSectionHead(title: 'Monthly earnings'),
      HFCard(child: EarningsChart(bars: summary.chart)),
      if (summary.nextPayout case final payout?) ...[
        const HFSectionHead(title: 'Next payout'),
        _NextPayout(payout: payout),
      ],
      const HFSectionHead(title: 'Recent transactions'),
      if (summary.transactions.isEmpty)
        const HFEmptyPanel(message: 'No earnings or payouts yet.')
      else
        for (final transaction in summary.transactions) ...[
          TransactionRow(transaction: transaction),
          const SizedBox(height: 8),
        ],
    ];
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'FINANCE · TRAINER ACCOUNT',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              color: HFColors.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text('EARNINGS.', style: AppTheme.display(29)),
          const SizedBox(height: 4),
          const Text(
            'Keep track of your income, payouts and performance.',
            style: TextStyle(fontSize: 11, height: 1.5, color: HFColors.muted),
          ),
        ],
      ),
    );
  }
}

/// `.payout` — the scheduled-payout strip. No "Request Payout" action: admin
/// runs the cycles, so there is nothing for the trainer to press.
class _NextPayout extends StatelessWidget {
  const _NextPayout({required this.payout});

  final NextPayout payout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HFColors.statusBg,
        border: Border.all(color: HFColors.statusBorder),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rupees(payout.amount),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: HFColors.statusTitle,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Expected on ${payout.expectedOn}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: HFColors.statusBody,
                  ),
                ),
              ],
            ),
          ),
          Text(
            payout.status,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: .4,
              color: HFColors.statusTag,
            ),
          ),
        ],
      ),
    );
  }
}

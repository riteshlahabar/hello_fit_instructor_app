import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_card.dart';
import '../../../core/widgets/hf_list_pieces.dart';
import '../../../core/widgets/hf_refresh.dart';
import '../../shell/presentation/shell_controller.dart';
import '../data/dashboard_providers.dart';
import '../domain/dashboard_summary.dart';
import 'widgets/metric_grid.dart';
import 'widgets/quick_actions.dart';
import 'widgets/request_card.dart';
import 'widgets/schedule_card.dart';
import 'widgets/verification_banner.dart';

/// Page 24 — Trainer Dashboard.
///
/// Pull down to re-read `/app/instructor/dashboard`. The loading and error
/// states are rows of the same refreshable list rather than a `Center` that
/// replaces it, so a trainer whose first read failed can pull to try again
/// instead of restarting the app.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _metricIcons = <IconData>[
    Icons.event_available_rounded,
    Icons.north_east_rounded,
    Icons.people_alt_rounded,
    Icons.currency_rupee_rounded,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);

    return HFRefreshList(
      padding: const EdgeInsets.fromLTRB(20, 7, 20, 16),
      onRefresh: () => ref.refresh(dashboardSummaryProvider.future),
      children: switch (summary) {
        AsyncValue(:final value?) => _body(ref, value),
        AsyncError(:final error) => [
          HFEmptyPanel(message: '$error'.replaceFirst('Exception: ', '')),
        ],
        _ => const [HFLoadingRow()],
      },
    );
  }

  List<Widget> _body(WidgetRef ref, DashboardSummary data) {
    void open(TrainerTab tab) =>
        ref.read(shellControllerProvider.notifier).select(tab);

    return [
      _Greeting(greeting: data.greeting, name: data.trainerName),
      VerificationBanner(state: data.verification),
      HFSectionHead(
        title: 'Your overview',
        actionLabel: 'VIEW ALL',
        onAction: () => open(TrainerTab.earnings),
      ),
      MetricGrid(metrics: data.metrics, icons: _metricIcons),
      HFSectionHead(
        title: "Today's schedule",
        actionLabel: 'SEE SCHEDULE',
        onAction: () => open(TrainerTab.bookings),
      ),
      ScheduleCard(entries: data.schedule),
      HFSectionHead(
        title: 'New booking requests',
        actionLabel: 'VIEW ALL',
        onAction: () => open(TrainerTab.bookings),
      ),
      for (final request in data.requests) ...[
        RequestCard(
          request: request,
          onReview: () => open(TrainerTab.bookings),
        ),
        const SizedBox(height: 10),
      ],
      const HFSectionHead(title: 'Quick actions'),
      QuickActions(
        actions: [
          QuickAction(
            Icons.calendar_month_rounded,
            'Bookings',
            () => open(TrainerTab.bookings),
          ),
          QuickAction(
            Icons.people_alt_rounded,
            'My Clients',
            () => open(TrainerTab.clients),
          ),
          QuickAction(
            Icons.currency_rupee_rounded,
            'Earnings',
            () => open(TrainerTab.earnings),
          ),
        ],
      ),
    ];
  }
}

/// `.hello` + `.name` — the orange half of the heading is the trainer's name.
class _Greeting extends StatelessWidget {
  const _Greeting({required this.greeting, required this.name});

  final String greeting;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            greeting,
            style: const TextStyle(fontSize: 13, color: HFColors.muted),
          ),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              text: 'WELCOME BACK, ',
              children: [
                TextSpan(
                  text: name,
                  style: AppTheme.display(29, color: HFColors.primary),
                ),
              ],
            ),
            style: AppTheme.display(29),
          ),
        ],
      ),
    );
  }
}

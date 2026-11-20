import 'package:flutter/foundation.dart';

/// The four chips across the top of page 57.
enum EarningsPeriod { week, month, quarter, year }

extension EarningsPeriodLabel on EarningsPeriod {
  String get label => switch (this) {
    EarningsPeriod.week => 'This week',
    EarningsPeriod.month => 'This month',
    EarningsPeriod.quarter => '3 months',
    EarningsPeriod.year => 'This year',
  };
}

/// One bar of the monthly chart.
@immutable
class EarningsBar {
  const EarningsBar({required this.label, required this.amount});

  factory EarningsBar.fromJson(Map<String, dynamic> json) => EarningsBar(
    label: json['label'] as String? ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
  );

  final String label;
  final double amount;
}

/// One line of the transaction list — an earning in, or a payout out.
@immutable
class EarningsTransaction {
  const EarningsTransaction({
    required this.id,
    required this.kind,
    required this.incoming,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.amount,
    required this.on,
  });

  factory EarningsTransaction.fromJson(Map<String, dynamic> json) =>
      EarningsTransaction(
        id: json['id'] as String? ?? '',
        kind: json['kind'] as String? ?? 'EARNING',
        incoming: json['direction'] == 'IN',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        status: json['status'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        on: json['on'] as String? ?? '',
      );

  final String id;
  final String kind;
  final bool incoming;
  final String title;
  final String subtitle;
  final String status;
  final double amount;
  final String on;
}

/// The payout the trainer is waiting on, when there is one.
@immutable
class NextPayout {
  const NextPayout({
    required this.amount,
    required this.status,
    required this.expectedOn,
  });

  factory NextPayout.fromJson(Map<String, dynamic> json) => NextPayout(
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    status: json['status'] as String? ?? '',
    expectedOn: json['expectedOn'] as String? ?? '',
  );

  final double amount;
  final String status;
  final String expectedOn;
}

/// Everything page 57 renders, in one value.
@immutable
class EarningsSummary {
  const EarningsSummary({
    required this.period,
    required this.total,
    required this.changePercent,
    required this.availableBalance,
    required this.pendingAmount,
    required this.withheldAmount,
    required this.paidToDate,
    required this.completedSessions,
    required this.averagePerSession,
    required this.chart,
    required this.transactions,
    required this.nextPayout,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) =>
      EarningsSummary(
        period: json['period'] as String? ?? 'month',
        total: (json['total'] as num?)?.toDouble() ?? 0,
        // Null, not zero, when there is no previous period to compare to —
        // "↑ 0%" would claim a flat month that never happened.
        changePercent: (json['changePercent'] as num?)?.toDouble(),
        availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0,
        pendingAmount: (json['pendingAmount'] as num?)?.toDouble() ?? 0,
        withheldAmount: (json['withheldAmount'] as num?)?.toDouble() ?? 0,
        paidToDate: (json['paidToDate'] as num?)?.toDouble() ?? 0,
        completedSessions: (json['completedSessions'] as num?)?.toInt() ?? 0,
        averagePerSession: (json['averagePerSession'] as num?)?.toDouble() ?? 0,
        chart: switch (json['chart']) {
          final List<dynamic> list =>
            list
                .map((e) => EarningsBar.fromJson(e as Map<String, dynamic>))
                .toList(),
          _ => const [],
        },
        transactions: switch (json['transactions']) {
          final List<dynamic> list =>
            list
                .map(
                  (e) =>
                      EarningsTransaction.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          _ => const [],
        },
        nextPayout: switch (json['nextPayout']) {
          final Map<String, dynamic> row => NextPayout.fromJson(row),
          _ => null,
        },
      );

  final String period;
  final double total;
  final double? changePercent;
  final double availableBalance;
  final double pendingAmount;
  final double withheldAmount;
  final double paidToDate;
  final int completedSessions;
  final double averagePerSession;
  final List<EarningsBar> chart;
  final List<EarningsTransaction> transactions;
  final NextPayout? nextPayout;
}

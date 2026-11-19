import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../domain/dashboard_summary.dart';

/// `.metrics` — two columns, 9px gutter, 91px minimum tile height.
class MetricGrid extends StatelessWidget {
  const MetricGrid({super.key, required this.metrics, required this.icons});

  final List<OverviewMetric> metrics;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < metrics.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 9));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _MetricTile(metrics[i], icons[i])),
              const SizedBox(width: 9),
              if (i + 1 < metrics.length)
                Expanded(child: _MetricTile(metrics[i + 1], icons[i + 1]))
              else
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
      );
    }

    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile(this.metric, this.icon);

  final OverviewMetric metric;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
      decoration: BoxDecoration(
        color: HFColors.white,
        border: Border.all(color: HFColors.line),
        borderRadius: BorderRadius.circular(HFRadius.metric),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  metric.title,
                  style: const TextStyle(fontSize: 12, color: HFColors.muted),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: HFColors.soft,
                  borderRadius: BorderRadius.circular(HFRadius.symbol),
                ),
                child: Icon(icon, size: 15, color: HFColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            metric.value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.1,
              color: HFColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            metric.caption,
            style: const TextStyle(
              fontSize: 10,
              color: HFColors.metricCaption,
            ),
          ),
        ],
      ),
    );
  }
}

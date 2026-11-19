import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/hf_card.dart';
import '../../domain/dashboard_summary.dart';

/// `.card > .schedule` — today's sessions, hairline between rows.
class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key, required this.entries});

  final List<ScheduleEntry> entries;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      if (i > 0) {
        rows.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 11),
            child: Divider(height: 1, thickness: 1, color: HFColors.line),
          ),
        );
      }
      rows.add(_ScheduleRow(entries[i]));
    }

    return HFCard(
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow(this.entry);

  final ScheduleEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 54),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          decoration: BoxDecoration(
            color: HFColors.soft,
            borderRadius: BorderRadius.circular(HFRadius.time),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.time,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: HFColors.ink,
                ),
              ),
              Text(
                entry.meridiem,
                style: const TextStyle(fontSize: 10, color: HFColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.service,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: HFColors.ink,
                ),
              ),
              Text(
                entry.clientLine,
                style: const TextStyle(fontSize: 11, color: HFColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _StatusPill(entry.status),
      ],
    );
  }
}

/// `.pill`
class _StatusPill extends StatelessWidget {
  const _StatusPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: HFColors.statusBg,
        borderRadius: BorderRadius.circular(HFRadius.pill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: HFColors.statusTag,
        ),
      ),
    );
  }
}

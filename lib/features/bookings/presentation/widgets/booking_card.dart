import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/hf_pieces.dart';
import '../../domain/booking_models.dart';

/// `.booking` — one card on pages 30 and 37.
class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.row, this.onTap});

  final BookingRow row;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: HFColors.white,
          border: Border.all(color: HFColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                HFAvatar(initials: row.client.initials, size: 36),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        row.client.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: HFColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${row.service} · ${row.slot.durationMin} min',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: HFColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                HFStatusPill(label: row.statusLabel, bucket: row.bucket),
              ],
            ),
            const SizedBox(height: 9),
            const Divider(height: 1, thickness: 1, color: HFColors.line),
            const SizedBox(height: 8),
            // `.info` — the date and time on the left, the money on the right.
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _Meta(label: row.slot.date, value: row.slot.time),
                ),
                Expanded(
                  child: _Meta(
                    label: row.area.isEmpty ? 'Client location' : row.area,
                    value: rupees(row.amount),
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, color: HFColors.muted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: HFColors.ink,
          ),
        ),
      ],
    );
  }
}

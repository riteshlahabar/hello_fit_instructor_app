import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../domain/booking_request.dart';

/// `.state` — the strip at the head of page 32: what this booking is waiting
/// for, when it was requested, and the status word on the right.
///
/// The design only draws the "Waiting for your response" case, because that is
/// the state it was mocked in. The other three are the same strip with the
/// wording that the status it is actually in calls for — a booking already
/// accepted must not read as still owing an answer.
class BookingStateStrip extends StatelessWidget {
  const BookingStateStrip({super.key, required this.detail});

  final BookingDetail detail;

  @override
  Widget build(BuildContext context) {
    final (title, sub) = _copy();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: HFColors.statusBg,
        border: Border.all(color: HFColors.statusBorder),
        borderRadius: BorderRadius.circular(HFRadius.status),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: HFColors.statusTitle,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 9,
                    height: 1.5,
                    color: HFColors.statusBody,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            detail.row.statusLabel,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: .4,
              color: HFColors.statusTag,
            ),
          ),
        ],
      ),
    );
  }

  (String, String) _copy() {
    if (detail.awaitsAnswer) {
      return (
        'Waiting for your response',
        'Requested for ${detail.row.slot.date} · ${detail.row.slot.time}',
      );
    }

    return switch (detail.requestResponse) {
      'ACCEPTED' => (
        'You accepted this booking',
        'Scheduled for ${detail.row.slot.date} · ${detail.row.slot.time}',
      ),
      'REJECTED' => (
        'You declined this request',
        'Our team arranges a replacement with the client.',
      ),
      _ => (
        'Booking ${detail.row.statusLabel.toLowerCase()}',
        '${detail.row.slot.date} · ${detail.row.slot.time}',
      ),
    };
  }
}

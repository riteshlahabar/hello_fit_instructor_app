import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/hf_field_grid.dart';
import '../../../../core/widgets/hf_pieces.dart';
import '../../domain/booking_request.dart';

/// `.request` — one card on page 31.
///
/// The design's fourth field is "Training location". Session location was
/// removed on 20-11-2026 (home-service only), so the field keeps its slot and
/// shows the service area the session is actually in.
class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.request,
    required this.onDetails,
    required this.onRespond,
  });

  final BookingRequest request;
  final VoidCallback onDetails;
  final VoidCallback onRespond;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HFColors.white,
        border: Border.all(color: HFColors.line),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Head(request: request),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: HFFieldGrid(
              fields: [
                ('Requested service', request.service),
                (
                  'Preferred slot',
                  '${request.slot.date} · ${request.slot.time}',
                ),
                ('Session duration', '${request.slot.durationMin} minutes'),
                (
                  'Client location',
                  request.area.isEmpty ? 'Client address' : request.area,
                ),
              ],
            ),
          ),
          if (request.goal case final goal? when goal.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '“${goal.trim()}”',
                style: const TextStyle(
                  fontSize: 9,
                  height: 1.55,
                  color: Color(0xFF71675D),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _Action(
                  label: 'View Details',
                  onTap: onDetails,
                  background: HFColors.soft,
                  ink: HFColors.ink,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Action(
                  label: 'Respond',
                  onTap: onRespond,
                  background: HFColors.primary,
                  ink: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Head extends StatelessWidget {
  const _Head({required this.request});

  final BookingRequest request;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HFAvatar(initials: request.client.initials, size: 39),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                request.client.name,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: HFColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Received ${request.receivedAt}',
                style: const TextStyle(fontSize: 8, color: HFColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        // `.new` — "DIRECT" where the customer chose this trainer by name
        // (§3.6), because a rejection there goes back to ops rather than on to
        // the next trainer, and the person answering should know which it is.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          decoration: BoxDecoration(
            color: HFColors.statusBg,
            borderRadius: BorderRadius.circular(HFRadius.pill),
          ),
          child: Text(
            request.isDirect ? 'CHOSE YOU' : 'NEW',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: HFColors.statusTag,
            ),
          ),
        ),
      ],
    );
  }
}

/// `.btn` — the card's own small action, half the height of a page CTA.
class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.onTap,
    required this.background,
    required this.ink,
  });

  final String label;
  final VoidCallback onTap;
  final Color background;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 36,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

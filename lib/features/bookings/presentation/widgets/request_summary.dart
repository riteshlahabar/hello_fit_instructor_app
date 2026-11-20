import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/hf_field_grid.dart';
import '../../../../core/widgets/hf_pieces.dart';
import '../../domain/booking_request.dart';

/// The client strip pages 33 and 34 both head their summary with.
class RequestClientCard extends StatelessWidget {
  const RequestClientCard({super.key, required this.request, this.subtitle});

  final BookingRequest request;

  /// Page 33 reads `Client · <service>`; page 34 adds `· New request`.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HFAvatar(initials: request.client.initials, size: 42, radius: 13),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                request.client.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: HFColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle ?? 'Client · ${request.service}',
                style: const TextStyle(fontSize: 9, color: HFColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: HFColors.statusBg,
            borderRadius: BorderRadius.circular(HFRadius.pill),
          ),
          child: Text(
            request.isDirect ? 'CHOSE YOU' : 'NEW REQUEST',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: .3,
              color: HFColors.statusTag,
            ),
          ),
        ),
      ],
    );
  }
}

/// `Session details` — the four-cell grid on pages 33 and 34, plus the
/// location and amount rows under it.
class RequestSessionFields extends StatelessWidget {
  const RequestSessionFields({super.key, required this.request});

  final BookingRequest request;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        HFFieldGrid(
          fields: [
            ('Training type', request.service),
            ('Duration', '${request.slot.durationMin} minutes'),
            ('Date', request.slot.date),
            ('Time', request.slot.range),
          ],
        ),
        const SizedBox(height: 9),
        _Row(
          icon: Icons.place_outlined,
          label: "Client's preferred location",
          value: request.area.isEmpty ? 'Client address' : request.area,
        ),
        const SizedBox(height: 7),
        _Row(
          icon: Icons.currency_rupee_rounded,
          label: request.sessionCount > 1
              ? 'Session amount · ${request.sessionCount} sessions'
              : 'Session amount',
          value: rupees(request.amount),
        ),
        if (request.persons > 1) ...[
          const SizedBox(height: 7),
          _Row(
            icon: Icons.people_alt_outlined,
            label: 'Participants',
            value: '${request.persons} people',
          ),
        ],
      ],
    );
  }
}

/// `.loc` / `.amount` — an icon, a label, and the value at the right.
class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: HFColors.soft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: HFColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 9, color: HFColors.muted),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: HFColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

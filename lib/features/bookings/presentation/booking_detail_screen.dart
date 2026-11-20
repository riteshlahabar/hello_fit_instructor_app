import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_refresh.dart';
import '../../../core/widgets/hf_action_pair.dart';
import '../../../core/widgets/hf_card.dart';
import '../../../core/widgets/hf_field_grid.dart';
import '../../../core/widgets/hf_list_pieces.dart';
import '../../../core/widgets/hf_note_field.dart';
import '../../../core/widgets/hf_pieces.dart';
import '../../../core/widgets/hf_pushed_page.dart';
import '../data/bookings_providers.dart';
import '../domain/booking_request.dart';
import 'widgets/booking_state_strip.dart';

/// Page 32 — Booking Details. Reached from a card on page 30, 31 or 37.
///
/// The accept/decline bar at the foot appears only while an answer is still
/// owed ([BookingDetail.awaitsAnswer]); for a booking already answered the
/// screen is read-only, which is what pages 30 and 37 push into.
class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(bookingDetailProvider(sessionId));
    Future<void> refresh() =>
        ref.refresh(bookingDetailProvider(sessionId).future);

    return switch (detail) {
      AsyncValue(:final value?) => _Body(detail: value, onRefresh: refresh),
      AsyncError(:final error) => _Frame(
        onRefresh: refresh,
        children: [
          HFEmptyPanel(message: '$error'.replaceFirst('Exception: ', '')),
        ],
      ),
      _ => _Frame(onRefresh: refresh, children: const [HFLoadingRow()]),
    };
  }
}

/// The page's chrome, shared by its loading, error and loaded states so the
/// heading does not appear only once the request has answered.
class _Frame extends StatelessWidget {
  const _Frame({required this.children, this.footer, this.onRefresh});

  final List<Widget> children;
  final Widget? footer;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return HFPushedPage(
      backLabel: 'Bookings',
      eyebrow: 'Review before you decide',
      title: 'BOOKING\nDETAILS.',
      sub: "Check the client's requirements and preferred session schedule.",
      footer: footer,
      onRefresh: onRefresh,
      children: children,
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.detail, required this.onRefresh});

  final BookingDetail detail;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final row = detail.row;

    return _Frame(
      onRefresh: onRefresh,
      footer: detail.awaitsAnswer && detail.requestId != null
          ? HFActionPair(
              secondaryLabel: 'Decline',
              primaryLabel: 'Accept Booking',
              onSecondary: () => context.pushNamed(
                'request-reject',
                pathParameters: {'id': detail.requestId!},
              ),
              onPrimary: () => context.pushNamed(
                'request-accept',
                pathParameters: {'id': detail.requestId!},
              ),
            )
          : null,
      children: [
        BookingStateStrip(detail: detail),
        const SizedBox(height: 12),
        HFCard(
          child: Row(
            children: [
              HFAvatar(initials: row.client.initials, size: 42, radius: 13),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      row.client.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: HFColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Booking ${row.bookingCode}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: HFColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              HFStatusPill(label: row.statusLabel, bucket: row.bucket),
            ],
          ),
        ),
        const HFSectionHead(title: 'Session information'),
        HFFieldGrid(
          fields: [
            ('Training type', row.service),
            ('Session duration', '${row.slot.durationMin} minutes'),
            ('Preferred date', row.slot.date),
            ('Preferred time', row.slot.range),
            (
              'Sessions booked',
              detail.sessionCount > 1 ? '${detail.sessionCount}' : '1',
            ),
            ('Participants', '${row.persons}'),
            ('Client location', row.area.isEmpty ? 'Client address' : row.area),
            ('Session amount', rupees(row.amount)),
          ],
        ),
        if (detail.goal case final goal? when goal.trim().isNotEmpty) ...[
          const HFSectionHead(title: 'Fitness goal'),
          HFFinePrint(icon: Icons.flag_outlined, text: goal.trim()),
        ],
        if (detail.healthNotes case final notes?
            when notes.trim().isNotEmpty) ...[
          const HFSectionHead(title: 'Client notes'),
          HFFinePrint(
            icon: Icons.medical_information_outlined,
            text: notes.trim(),
          ),
        ],
        const HFSectionHead(title: 'Your note on this booking'),
        // Read-only on purpose: the note is written on page 33, and a second
        // place to save it would be a second endpoint nobody has asked for.
        HFFinePrint(
          icon: Icons.sticky_note_2_outlined,
          text: detail.notes?.trim().isNotEmpty == true
              ? detail.notes!.trim()
              : 'Not yet submitted. Add one when you accept the request.',
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

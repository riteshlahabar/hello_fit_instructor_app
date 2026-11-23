import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_refresh.dart';
import '../../../core/widgets/hf_card.dart';
import '../../../core/widgets/hf_field_grid.dart';
import '../../../core/widgets/hf_list_pieces.dart';
import '../../../core/widgets/hf_note_field.dart';
import '../../../core/widgets/hf_pieces.dart';
import '../../shell/presentation/widgets/trainer_page.dart';
import '../data/bookings_providers.dart';
import '../domain/booking_request.dart';
import 'widgets/booking_close_actions.dart';
import 'widgets/booking_state_strip.dart';

/// Page 32 — Booking Details. Reached from the home screen's "Review"
/// and from a card on page 30 or 37.
///
/// **No Accept and no Decline here** (client, 23-11-2026). The answer to an
/// offer is given on page 33 or 34; page 31's requests inbox, which used to
/// open them, was deleted on 23-11-2026 at the client's word, so those two
/// screens currently have no entry point — ask before adding one.
/// [BookingDetail.awaitsAnswer] still drives the state strip at the top,
/// which says an answer is owed.
///
/// What this screen *does* answer is how the booking ends: [BookingCloseActions]
/// closes it as Completed or Cancelled (client, 23-11-2026), in place of the
/// note block that used to sit at the bottom.
class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(bookingDetailProvider(sessionId));
    Future<void> refresh() =>
        ref.refresh(bookingDetailProvider(sessionId).future);

    return switch (detail) {
      AsyncValue(:final value?) => _Body(
        sessionId: sessionId,
        detail: value,
        onRefresh: refresh,
      ),
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
  const _Frame({required this.children, this.onRefresh});

  final List<Widget> children;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return TrainerPage(
      heading: 'Booking Details',
      sub: "Check the client's requirements and preferred session schedule.",
      onRefresh: onRefresh,
      children: children,
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.sessionId,
    required this.detail,
    required this.onRefresh,
  });

  final String sessionId;
  final BookingDetail detail;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final row = detail.row;

    return _Frame(
      onRefresh: onRefresh,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: HFColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Booking ${row.bookingCode}',
                      style: const TextStyle(
                        fontSize: 10,
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
        // The note block that used to close this screen was deleted on
        // 23-11-2026 at the client's word — the trainer's own note is written
        // on page 33 and nobody needed it read back here. These are the two
        // buttons that took its place.
        if (detail.canClose)
          BookingCloseActions(sessionId: sessionId, detail: detail),
        const SizedBox(height: 14),
      ],
    );
  }
}

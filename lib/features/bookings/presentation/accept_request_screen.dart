import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_result.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_action_pair.dart';
import '../../../core/widgets/hf_card.dart';
import '../../../core/widgets/hf_list_pieces.dart';
import '../../../core/widgets/hf_note_field.dart';
import '../../shell/presentation/widgets/trainer_page.dart';
import '../data/bookings_providers.dart';
import '../data/request_lookup.dart';
import '../domain/booking_request.dart';
import 'widgets/request_summary.dart';

/// Page 33 — Accept Booking.
///
/// Holds its own copy of the request: accepting invalidates the inbox, so a
/// screen reading straight off the provider would blank out underneath the
/// person mid-pop.
class AcceptRequestScreen extends ConsumerStatefulWidget {
  const AcceptRequestScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<AcceptRequestScreen> createState() => _State();
}

class _State extends ConsumerState<AcceptRequestScreen> {
  final _note = TextEditingController();
  BookingRequest? _request;
  String _status = '';
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final request = _request;
    if (request == null || _busy) return;

    setState(() {
      _busy = true;
      _status = '';
    });

    final result = await ref
        .read(requestControllerProvider.notifier)
        .accept(request.id, note: _note.text);

    if (!mounted) return;

    switch (result) {
      case ApiSuccess():
        // Back to page 31, which has already re-read itself without this row.
        context.pop(true);
      case ApiFailure(:final code, :final message, :final details):
        setState(() {
          _busy = false;
          _status = envelopeMessage(code, message, details);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Latch the request the first time it arrives and never look again.
    _request ??= ref.watch(requestByIdProvider(widget.requestId));
    final request = _request;

    if (request == null) {
      return const TrainerPage(
        heading: 'Accept Booking',
        sub: 'Review the session details before confirming.',
        children: [
          HFEmptyPanel(
            message: 'This request is no longer waiting on your answer.',
          ),
        ],
      );
    }

    return TrainerPage(
      heading: 'Accept Booking',
      sub:
          'Review the session details before confirming. The client will be '
          'notified once you accept.',
      footer: HFActionPair(
        secondaryLabel: 'Decline',
        primaryLabel: 'Confirm Booking  ✓',
        busy: _busy,
        onSecondary: () => context.pushReplacementNamed(
          'request-reject',
          pathParameters: {'id': request.id},
        ),
        onPrimary: _confirm,
      ),
      children: [
        HFCard(child: RequestClientCard(request: request)),
        const HFSectionHead(title: 'Session details'),
        RequestSessionFields(request: request),
        if (request.healthNotes case final notes? when notes.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 9),
            child: HFFinePrint(
              icon: Icons.medical_information_outlined,
              text: 'Client notes · ${notes.trim()}',
            ),
          ),
        const SizedBox(height: 15),
        HFNoteField(
          label: 'Message to client (optional)',
          hint: 'Add a short confirmation note',
          controller: _note,
          enabled: !_busy,
        ),
        const SizedBox(height: 13),
        const HFFinePrint(
          text:
              'By confirming, this request moves to your confirmed bookings '
              'and the client is notified. Please make sure the date, time '
              'and location work for you.',
        ),
        SizedBox(
          height: 26,
          child: Center(
            child: Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: HFColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

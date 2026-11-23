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
import 'widgets/reason_list.dart';
import 'widgets/request_summary.dart';

/// Page 34 — Reject Booking.
///
/// The seventh reason is "Other", which makes the message box the reason and
/// therefore required; the other six leave it optional.
///
/// A `DIRECT` request is the one the customer chose this trainer for, so the
/// closing note says what actually happens: ops reassign it by hand, nobody
/// is quietly substituted. → `state/domain-rules.md`.
class RejectRequestScreen extends ConsumerStatefulWidget {
  const RejectRequestScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<RejectRequestScreen> createState() => _State();
}

class _State extends ConsumerState<RejectRequestScreen> {
  final _message = TextEditingController();
  BookingRequest? _request;
  String? _reason;
  String _status = '';
  bool _busy = false;

  bool get _isOther => _reason == rejectionReasons.last;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _decline() async {
    final request = _request;
    if (request == null || _busy) return;

    if (_reason == null) {
      setState(() => _status = 'Select a reason before declining.');
      return;
    }
    if (_isOther && _message.text.trim().isEmpty) {
      setState(() => _status = 'Describe your reason in the message box.');
      return;
    }

    setState(() {
      _busy = true;
      _status = '';
    });

    final result = await ref
        .read(requestControllerProvider.notifier)
        .reject(request.id, reason: _reason!, message: _message.text);

    if (!mounted) return;

    switch (result) {
      case ApiSuccess():
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
    _request ??= ref.watch(requestByIdProvider(widget.requestId));
    final request = _request;

    if (request == null) {
      return const TrainerPage(
        heading: 'Decline Booking',
        sub: 'Choose a reason and send a clear update to the client.',
        children: [
          HFEmptyPanel(
            message: 'This request is no longer waiting on your answer.',
          ),
        ],
      );
    }

    return TrainerPage(
      heading: 'Decline Booking',
      sub:
          "If you can't take this session, choose a reason and send a clear "
          'update to the client.',
      footer: HFActionPair(
        secondaryLabel: 'Go Back',
        primaryLabel: 'Decline Request',
        danger: true,
        busy: _busy,
        onSecondary: () => context.pop(),
        onPrimary: _decline,
      ),
      children: [
        const HFSectionHead(title: 'Booking summary'),
        HFCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RequestClientCard(
                request: request,
                subtitle: '${request.service} · New request',
              ),
              const SizedBox(height: 11),
              RequestSessionFields(request: request),
            ],
          ),
        ),
        const HFSectionHead(title: 'Reason for declining *'),
        ReasonList(
          reasons: rejectionReasons,
          selected: _reason,
          onSelect: (value) => setState(() {
            _reason = value;
            _status = '';
          }),
        ),
        const SizedBox(height: 14),
        HFNoteField(
          label: _isOther
              ? 'Message to client (required)'
              : 'Message to client (optional)',
          hint: _isOther
              ? 'Share your reason for the client'
              : 'Add anything the client should know',
          controller: _message,
          enabled: !_busy,
        ),
        const SizedBox(height: 13),
        HFFinePrint(
          icon: Icons.info_outline_rounded,
          text: request.isDirect
              ? 'This client chose you by name, so declining does not pass '
                    'the session to another trainer — our team will arrange a '
                    'replacement with the client directly.'
              : 'Declining notifies the client, removes this request from your '
                    'pending bookings and offers the session to the next '
                    'available trainer.',
        ),
        SizedBox(
          height: 30,
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

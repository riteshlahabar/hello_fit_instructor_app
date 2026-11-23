import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/widgets/hf_card.dart';
import '../../data/bookings_providers.dart';
import '../../domain/booking_request.dart';
import 'booking_close_steps.dart';

/// Page 32's close-out card — **Completed** and **Cancel** (client,
/// 23-11-2026), in place of the read-only note block that used to sit here.
///
/// Both answers are given on this screen rather than a new one: nothing in
/// the PDF or the HTML pack describes a completion screen, and an invented
/// page is exactly what rule 2 forbids. So each button opens its own step in
/// place — the code boxes for a completion, the reason list for a
/// cancellation — and the card returns to the two buttons if the trainer
/// backs out. The steps themselves are in `booking_close_steps.dart`.
enum _Step { choose, completing, cancelling }

class BookingCloseActions extends ConsumerStatefulWidget {
  const BookingCloseActions({
    super.key,
    required this.sessionId,
    required this.detail,
  });

  final String sessionId;
  final BookingDetail detail;

  @override
  ConsumerState<BookingCloseActions> createState() => _State();
}

class _State extends ConsumerState<BookingCloseActions> {
  final _note = TextEditingController();
  _Step _step = _Step.choose;
  String _code = '';
  String? _reason;
  String _status = '';
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _to(_Step step) => setState(() {
    _step = step;
    _status = '';
  });

  Future<void> _complete() async {
    if (_busy) return;

    if (_code.length != 4) {
      setState(() => _status = 'Enter the four-digit code from the client.');
      return;
    }

    await _send(
      () => ref
          .read(sessionCloseControllerProvider.notifier)
          .complete(widget.sessionId, otp: _code),
    );
  }

  Future<void> _cancel() async {
    if (_busy) return;

    final reason = _reason;
    if (reason == null) {
      setState(() => _status = 'Choose a reason before cancelling.');
      return;
    }

    final other = reason == cancellationReasons.last;
    if (other && _note.text.trim().isEmpty) {
      setState(() => _status = 'Describe the reason in the box below.');
      return;
    }

    await _send(
      () => ref.read(sessionCloseControllerProvider.notifier).cancel(
        widget.sessionId,
        reason: other ? _note.text.trim() : reason,
        clientAbsent: isClientAbsent(reason),
      ),
    );
  }

  /// A success needs no navigation: the controller invalidates the detail
  /// provider, the screen rebuilds on the new status, and this card goes with
  /// it because the server stops offering either button.
  Future<void> _send(Future<ApiResult<void>> Function() call) async {
    setState(() {
      _busy = true;
      _status = '';
    });

    final result = await call();
    if (!mounted) return;

    switch (result) {
      case ApiSuccess():
        setState(() => _busy = false);
      case ApiFailure(:final code, :final message, :final details):
        setState(() {
          _busy = false;
          _status = envelopeMessage(code, message, details);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        HFSectionHead(
          title: switch (_step) {
            _Step.choose => 'Close this booking',
            _Step.completing => 'Confirm the session happened',
            _Step.cancelling => 'Why was this session not delivered?',
          },
        ),
        switch (_step) {
          _Step.choose => CloseChoices(
            canComplete: widget.detail.canComplete,
            canCancel: widget.detail.canCancel,
            onComplete: () => _to(_Step.completing),
            onCancel: () => _to(_Step.cancelling),
          ),
          _Step.completing => CompleteStep(
            busy: _busy,
            onCode: (value) => setState(() {
              _code = value;
              _status = '';
            }),
            onBack: () => _to(_Step.choose),
            onConfirm: _complete,
          ),
          _Step.cancelling => CancelStep(
            busy: _busy,
            reason: _reason,
            note: _note,
            onReason: (value) => setState(() {
              _reason = value;
              _status = '';
            }),
            onBack: () => _to(_Step.choose),
            onConfirm: _cancel,
          ),
        },
        CloseStatusLine(text: _status),
      ],
    );
  }
}

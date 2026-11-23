import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/hf_action_pair.dart';
import '../../../../core/widgets/hf_note_field.dart';
import '../../../../core/widgets/hf_otp_boxes.dart';
import '../../domain/booking_request.dart';
import 'reason_list.dart';

/// The three states of page 32's close-out card, split out of
/// `booking_close_actions.dart` to keep both files inside the 200-line rule.
/// Everything here is stateless — the card owns the state and passes it down.

/// The pair of buttons the card opens on. Either may be absent: the server
/// says which of the two the booking's status still allows.
class CloseChoices extends StatelessWidget {
  const CloseChoices({
    super.key,
    required this.canComplete,
    required this.canCancel,
    required this.onComplete,
    required this.onCancel,
  });

  final bool canComplete;
  final bool canCancel;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HFActionPair(
          secondaryLabel: 'Cancel',
          primaryLabel: 'Completed',
          onSecondary: canCancel ? onCancel : null,
          onPrimary: canComplete ? onComplete : null,
        ),
        const SizedBox(height: 12),
        const HFFinePrint(
          icon: Icons.verified_outlined,
          text:
              'Mark the session Completed once it is over — the client reads '
              'you their four-digit session code and your earning for it is '
              'raised. Cancel only if the session did not happen.',
        ),
      ],
    );
  }
}

/// The completion step: page 8's own OTP boxes, four wide. The code is the
/// client's, so typing it is what proves the session happened.
class CompleteStep extends StatelessWidget {
  const CompleteStep({
    super.key,
    required this.busy,
    required this.onCode,
    required this.onBack,
    required this.onConfirm,
  });

  final bool busy;
  final ValueChanged<String> onCode;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Session code from the client',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: HFColors.ink,
          ),
        ),
        const SizedBox(height: 9),
        OtpBoxes(length: 4, onChanged: onCode, onCompleted: (_) => onConfirm()),
        const SizedBox(height: 13),
        HFActionPair(
          secondaryLabel: 'Back',
          primaryLabel: 'Mark Completed',
          busy: busy,
          onSecondary: onBack,
          onPrimary: onConfirm,
        ),
      ],
    );
  }
}

/// The cancellation step. The chosen reason decides the status the backend
/// writes — [isClientAbsent] is the branch that matters.
class CancelStep extends StatelessWidget {
  const CancelStep({
    super.key,
    required this.busy,
    required this.reason,
    required this.note,
    required this.onReason,
    required this.onBack,
    required this.onConfirm,
  });

  final bool busy;
  final String? reason;
  final TextEditingController note;
  final ValueChanged<String> onReason;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  bool get _isOther => reason == cancellationReasons.last;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ReasonList(
          reasons: cancellationReasons,
          selected: reason,
          onSelect: onReason,
        ),
        const SizedBox(height: 13),
        HFNoteField(
          label: _isOther
              ? 'Reason (required)'
              : 'Anything the client should know (optional)',
          hint: 'Add a short note for the client and our team',
          controller: note,
          enabled: !busy,
          lines: 2,
        ),
        const SizedBox(height: 13),
        HFActionPair(
          secondaryLabel: 'Back',
          primaryLabel: 'Cancel Booking',
          danger: true,
          busy: busy,
          onSecondary: onBack,
          onPrimary: onConfirm,
        ),
      ],
    );
  }
}

/// The one line a failed attempt reports in. Fixed height, so the card does
/// not jump when a message appears.
class CloseStatusLine extends StatelessWidget {
  const CloseStatusLine({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: HFColors.primary),
        ),
      ),
    );
  }
}

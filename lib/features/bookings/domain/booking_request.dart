import 'package:flutter/foundation.dart';

import 'booking_models.dart';

/// One row of `GET /app/instructor/requests` — page 31, and the subject of
/// pages 32, 33 and 34.
///
/// `mode` matters: `DIRECT` means the customer chose this trainer (§3.6) and
/// a rejection goes back to ops rather than to the next-best trainer, so the
/// reject screen's wording is not the same in both cases.
@immutable
class BookingRequest {
  const BookingRequest({
    required this.id,
    required this.sessionId,
    required this.bookingCode,
    required this.mode,
    required this.receivedAt,
    required this.expiresAt,
    required this.client,
    required this.service,
    required this.slot,
    required this.persons,
    required this.sessionCount,
    required this.amount,
    required this.area,
    required this.goal,
    required this.healthNotes,
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) => BookingRequest(
    id: json['id'] as String? ?? '',
    sessionId: json['sessionId'] as String? ?? '',
    bookingCode: json['bookingCode'] as String? ?? '',
    mode: json['mode'] as String? ?? 'AUTO',
    receivedAt: json['receivedAt'] as String? ?? '',
    expiresAt: json['expiresAt'] as String?,
    client: ClientRef.fromJson(
      (json['client'] as Map<String, dynamic>?) ?? const {},
    ),
    service: json['service'] as String? ?? '',
    slot: SessionSlot.fromJson(
      (json['slot'] as Map<String, dynamic>?) ?? const {},
    ),
    persons: (json['persons'] as num?)?.toInt() ?? 1,
    sessionCount: (json['sessionCount'] as num?)?.toInt() ?? 1,
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    area: json['area'] as String? ?? '',
    goal: json['goal'] as String?,
    healthNotes: json['healthNotes'] as String?,
  );

  final String id;
  final String sessionId;
  final String bookingCode;
  final String mode;
  final String receivedAt;
  final String? expiresAt;
  final ClientRef client;
  final String service;
  final SessionSlot slot;
  final int persons;
  final int sessionCount;
  final double amount;
  final String area;

  /// `CustomerProfile.goal` — the line page 31 quotes under the fields.
  final String? goal;

  /// `CustomerProfile.healthNotes` — conditions and injuries the trainer must
  /// read before arriving, which is exactly why they are shown pre-acceptance.
  final String? healthNotes;

  /// True when the customer picked this trainer by name.
  bool get isDirect => mode == 'DIRECT';
}

/// Page 34's radio list, transcribed from the client's own HTML. The seventh
/// is "Other", which turns the message box into the reason.
const rejectionReasons = <String>[
  'Not available at the requested time',
  'Schedule conflict or prior commitment',
  'Location is outside my service area',
  'Unable to travel to the requested location',
  'Session type does not match my services',
  'Not currently offering this training type',
  'Other reason',
];

/// Page 32's cancel list (client, 23-11-2026). The first entry is the one the
/// backend treats differently — it books a `NO_SHOW_CUSTOMER` instead of a
/// trainer cancellation, so the client is charged and the trainer is not at
/// fault. See [isClientAbsent].
const cancellationReasons = <String>[
  'Client was not available',
  'Client asked to cancel',
  'I am unwell or had an emergency',
  'Travel or weather made it impossible',
  'Wrong address or could not reach the client',
  'Other reason',
];

/// Which of [cancellationReasons] means the client never turned up.
bool isClientAbsent(String reason) => reason == cancellationReasons.first;

/// Page 32's extra fields on top of a [BookingRow].
@immutable
class BookingDetail {
  const BookingDetail({
    required this.row,
    required this.sessionCount,
    required this.goal,
    required this.healthNotes,
    required this.requestId,
    required this.requestResponse,
    required this.requestMode,
    required this.canComplete,
    required this.canCancel,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    final request = json['request'] as Map<String, dynamic>?;

    return BookingDetail(
      row: BookingRow.fromJson(json),
      sessionCount: (json['sessionCount'] as num?)?.toInt() ?? 1,
      goal: json['goal'] as String?,
      healthNotes: json['healthNotes'] as String?,
      requestId: request?['id'] as String?,
      requestResponse: request?['response'] as String?,
      requestMode: request?['mode'] as String?,
      canComplete: json['canComplete'] as bool? ?? false,
      canCancel: json['canCancel'] as bool? ?? false,
    );
  }

  final BookingRow row;
  final int sessionCount;
  final String? goal;
  final String? healthNotes;
  final String? requestId;
  final String? requestResponse;
  final String? requestMode;

  /// Both come from the server, which owns the status rules — the screen
  /// never decides for itself whether a booking can still be closed.
  final bool canComplete;
  final bool canCancel;

  /// The accept/decline bar only shows while an answer is still owed.
  bool get awaitsAnswer => requestId != null && requestResponse == 'PENDING';

  /// Whether page 32 shows the close-out card at all.
  bool get canClose => canComplete || canCancel;
}

import 'package:flutter/foundation.dart';

/// The slot shape every trainer screen reuses, as `/app/instructor/*` sends it.
/// `date` is already `dd-mm-yyyy` and the clock already 12-hour — the backend
/// formats both (hard rule 4), so nothing here reformats a date.
@immutable
class SessionSlot {
  const SessionSlot({
    required this.date,
    required this.time,
    required this.clock,
    required this.meridiem,
    required this.range,
    required this.durationMin,
  });

  factory SessionSlot.fromJson(Map<String, dynamic> json) => SessionSlot(
    date: json['date'] as String? ?? '',
    time: json['time'] as String? ?? '',
    clock: json['clock'] as String? ?? '',
    meridiem: json['meridiem'] as String? ?? '',
    range: json['range'] as String? ?? '',
    durationMin: (json['durationMin'] as num?)?.toInt() ?? 0,
  );

  final String date;
  final String time;
  final String clock;
  final String meridiem;
  final String range;
  final int durationMin;
}

/// The customer, as much of them as the trainer is allowed to see before the
/// session starts: a short name and initials, never a phone number.
@immutable
class ClientRef {
  const ClientRef({
    required this.id,
    required this.name,
    required this.initials,
  });

  factory ClientRef.fromJson(Map<String, dynamic> json) => ClientRef(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? 'Client',
    initials: json['initials'] as String? ?? '?',
  );

  final String id;
  final String name;
  final String initials;
}

/// The five chips on page 30. `all` is not a bucket, it is the absence of one.
enum BookingFilter { all, pending, confirmed, completed, cancelled }

extension BookingFilterLabel on BookingFilter {
  String get label => switch (this) {
    BookingFilter.all => 'All',
    BookingFilter.pending => 'Pending',
    BookingFilter.confirmed => 'Confirmed',
    BookingFilter.completed => 'Completed',
    BookingFilter.cancelled => 'Cancelled',
  };
}

/// One row on pages 30 and 37.
@immutable
class BookingRow {
  const BookingRow({
    required this.sessionId,
    required this.bookingCode,
    required this.status,
    required this.bucket,
    required this.statusLabel,
    required this.client,
    required this.service,
    required this.slot,
    required this.persons,
    required this.amount,
    required this.area,
  });

  factory BookingRow.fromJson(Map<String, dynamic> json) => BookingRow(
    sessionId: json['sessionId'] as String? ?? '',
    bookingCode: json['bookingCode'] as String? ?? '',
    status: json['status'] as String? ?? '',
    bucket: json['bucket'] as String? ?? 'pending',
    statusLabel: json['statusLabel'] as String? ?? '',
    client: ClientRef.fromJson(
      (json['client'] as Map<String, dynamic>?) ?? const {},
    ),
    service: json['service'] as String? ?? '',
    slot: SessionSlot.fromJson(
      (json['slot'] as Map<String, dynamic>?) ?? const {},
    ),
    persons: (json['persons'] as num?)?.toInt() ?? 1,
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    area: json['area'] as String? ?? '',
  );

  final String sessionId;
  final String bookingCode;
  final String status;
  final String bucket;
  final String statusLabel;
  final ClientRef client;
  final String service;
  final SessionSlot slot;
  final int persons;
  final double amount;
  final String area;
}

/// `meta.summary` — the tiles above the list, which the filter never moves.
@immutable
class BookingSummary {
  const BookingSummary({
    required this.total,
    required this.pending,
    required this.upcoming,
    required this.completed,
    required this.cancelled,
  });

  factory BookingSummary.fromJson(Map<String, dynamic>? json) => BookingSummary(
    total: (json?['total'] as num?)?.toInt() ?? 0,
    pending: (json?['pending'] as num?)?.toInt() ?? 0,
    upcoming: (json?['upcoming'] as num?)?.toInt() ?? 0,
    completed: (json?['completed'] as num?)?.toInt() ?? 0,
    cancelled: (json?['cancelled'] as num?)?.toInt() ?? 0,
  );

  static const empty = BookingSummary(
    total: 0,
    pending: 0,
    upcoming: 0,
    completed: 0,
    cancelled: 0,
  );

  final int total;
  final int pending;
  final int upcoming;
  final int completed;
  final int cancelled;
}

/// Page 30's whole payload: the rows and the tiles above them.
@immutable
class BookingPage {
  const BookingPage({required this.rows, required this.summary});

  final List<BookingRow> rows;
  final BookingSummary summary;
}

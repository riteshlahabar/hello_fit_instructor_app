import 'package:flutter/foundation.dart';

/// One row on page 38.
///
/// A "client" is not a table — it is a customer this trainer has sessions
/// with, folded out of `BookingSession` by the API. So the trainer cannot add
/// one (page 44 is deliberately not built) and there is no fitness profile to
/// read (pages 40–42 have no columns behind them).
@immutable
class TrainerClient {
  const TrainerClient({
    required this.id,
    required this.name,
    required this.initials,
    required this.service,
    required this.sessions,
    required this.completed,
    required this.upcoming,
    required this.value,
    required this.joinedAt,
    required this.firstSessionOn,
    required this.lastSessionOn,
    required this.active,
  });

  factory TrainerClient.fromJson(Map<String, dynamic> json) => TrainerClient(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? 'Client',
    initials: json['initials'] as String? ?? '?',
    service: json['service'] as String? ?? '',
    sessions: (json['sessions'] as num?)?.toInt() ?? 0,
    completed: (json['completed'] as num?)?.toInt() ?? 0,
    upcoming: (json['upcoming'] as num?)?.toInt() ?? 0,
    value: (json['value'] as num?)?.toDouble() ?? 0,
    joinedAt: json['joinedAt'] as String? ?? '',
    firstSessionOn: json['firstSessionOn'] as String? ?? '',
    lastSessionOn: json['lastSessionOn'] as String? ?? '',
    active: json['active'] as bool? ?? false,
  );

  final String id;
  final String name;
  final String initials;
  final String service;
  final int sessions;
  final int completed;
  final int upcoming;
  final double value;
  final String joinedAt;
  final String firstSessionOn;
  final String lastSessionOn;
  final bool active;
}

/// The three chips and three tiles on page 38.
enum ClientFilter { all, active, inactive }

extension ClientFilterLabel on ClientFilter {
  String get label => switch (this) {
    ClientFilter.all => 'All Clients',
    ClientFilter.active => 'Active',
    ClientFilter.inactive => 'Inactive',
  };
}

@immutable
class ClientSummary {
  const ClientSummary({
    required this.all,
    required this.active,
    required this.inactive,
  });

  factory ClientSummary.fromJson(Map<String, dynamic>? json) => ClientSummary(
    all: (json?['all'] as num?)?.toInt() ?? 0,
    active: (json?['active'] as num?)?.toInt() ?? 0,
    inactive: (json?['inactive'] as num?)?.toInt() ?? 0,
  );

  static const empty = ClientSummary(all: 0, active: 0, inactive: 0);

  final int all;
  final int active;
  final int inactive;
}

@immutable
class ClientPage {
  const ClientPage({required this.rows, required this.summary});

  final List<TrainerClient> rows;
  final ClientSummary summary;
}

/// One line of page 39's session history.
@immutable
class ClientSession {
  const ClientSession({
    required this.sessionId,
    required this.service,
    required this.statusLabel,
    required this.date,
    required this.time,
    required this.durationMin,
    required this.amount,
  });

  factory ClientSession.fromJson(Map<String, dynamic> json) => ClientSession(
    sessionId: json['sessionId'] as String? ?? '',
    service: json['service'] as String? ?? '',
    statusLabel: json['statusLabel'] as String? ?? '',
    date: json['date'] as String? ?? '',
    time: json['time'] as String? ?? '',
    durationMin: (json['durationMin'] as num?)?.toInt() ?? 0,
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
  );

  final String sessionId;
  final String service;
  final String statusLabel;
  final String date;
  final String time;
  final int durationMin;
  final double amount;
}

/// Page 39 — the client, plus the sessions that make them one.
@immutable
class ClientProfile {
  const ClientProfile({required this.client, required this.recent});

  factory ClientProfile.fromJson(Map<String, dynamic> json) => ClientProfile(
    client: TrainerClient.fromJson(json),
    recent: switch (json['recent']) {
      final List<dynamic> list => list
          .map((e) => ClientSession.fromJson(e as Map<String, dynamic>))
          .toList(),
      _ => const [],
    },
  );

  final TrainerClient client;
  final List<ClientSession> recent;
}

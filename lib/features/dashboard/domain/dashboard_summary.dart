import 'package:flutter/foundation.dart';

/// Where the trainer's profile stands in the approval gate
/// (`InstructorService.approvedAt`, spec 6.5).
enum VerificationState { pending, approved, rejected }

/// One tile in the "Your overview" grid.
@immutable
class OverviewMetric {
  const OverviewMetric({
    required this.title,
    required this.value,
    required this.caption,
  });

  final String title;
  final String value;
  final String caption;
}

/// A session on today's timeline.
@immutable
class ScheduleEntry {
  const ScheduleEntry({
    required this.time,
    required this.meridiem,
    required this.service,
    required this.clientLine,
    required this.status,
  });

  final String time;
  final String meridiem;
  final String service;
  final String clientLine;
  final String status;
}

/// A booking request waiting on the trainer (spec 4.7).
@immutable
class BookingRequestPreview {
  const BookingRequestPreview({
    required this.initials,
    required this.title,
    required this.subtitle,
  });

  final String initials;
  final String title;
  final String subtitle;
}

/// Everything the dashboard renders, in one immutable value.
@immutable
class DashboardSummary {
  const DashboardSummary({
    required this.greeting,
    required this.trainerName,
    required this.verification,
    required this.metrics,
    required this.schedule,
    required this.requests,
  });

  final String greeting;
  final String trainerName;
  final VerificationState verification;
  final List<OverviewMetric> metrics;
  final List<ScheduleEntry> schedule;
  final List<BookingRequestPreview> requests;
}

import '../domain/dashboard_repository.dart';
import '../domain/dashboard_summary.dart';

/// The content the client's own page-24 HTML shows, nothing added.
///
/// This is the design-time source only. When `GET /app/instructor/today` and
/// `/app/instructor/earnings` are wired, add an `ApiDashboardRepository` beside
/// this file and override the provider — no screen changes.
class DesignDashboardRepository implements DashboardRepository {
  const DesignDashboardRepository();

  @override
  Future<DashboardSummary> load() async {
    return const DashboardSummary(
      greeting: 'Good morning,',
      trainerName: 'TRAINER!',
      verification: VerificationState.pending,
      metrics: [
        OverviewMetric(
          title: "Today's sessions",
          value: '04',
          caption: '2 completed · 2 upcoming',
        ),
        OverviewMetric(
          title: 'Booking requests',
          value: '03',
          caption: 'Waiting for your response',
        ),
        OverviewMetric(
          title: 'Active clients',
          value: '12',
          caption: 'Your current client list',
        ),
        OverviewMetric(
          title: "This month's earnings",
          value: '₹8,400',
          caption: 'Illustrative dashboard amount',
        ),
      ],
      schedule: [
        ScheduleEntry(
          time: '09:00',
          meridiem: 'AM',
          service: 'Personal Training',
          clientLine: 'Client: Priya S. · 45 min',
          status: 'DONE',
        ),
        ScheduleEntry(
          time: '11:30',
          meridiem: 'AM',
          service: 'Strength Training',
          clientLine: 'Client: Rahul M. · 60 min',
          status: 'UP NEXT',
        ),
      ],
      requests: [
        BookingRequestPreview(
          initials: 'AK',
          title: 'New client request',
          subtitle: 'From Aditi K. · Personal training',
        ),
      ],
    );
  }
}

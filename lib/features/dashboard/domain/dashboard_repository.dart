import 'dashboard_summary.dart';

/// What the dashboard needs, stated without saying where it comes from.
///
/// The screen depends on this, never on an HTTP client — so swapping the
/// design-time source for `GET /app/instructor/today` + `/earnings` is a one
/// line change in the provider override (DIP).
abstract interface class DashboardRepository {
  Future<DashboardSummary> load();
}

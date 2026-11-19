import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/dashboard_repository.dart';
import '../domain/dashboard_summary.dart';
import 'design_dashboard_repository.dart';

/// The one seam between the screen and its source. Override this in tests, or
/// when the API repository lands.
final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => const DesignDashboardRepository(),
);

/// What the dashboard watches.
final dashboardSummaryProvider = FutureProvider<DashboardSummary>(
  (ref) => ref.watch(dashboardRepositoryProvider).load(),
);

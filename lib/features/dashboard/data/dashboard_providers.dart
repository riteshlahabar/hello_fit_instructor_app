import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_providers.dart';
import '../domain/dashboard_repository.dart';
import '../domain/dashboard_summary.dart';
import 'api_dashboard_repository.dart';

/// The one seam between the screen and its source.
///
/// Live since 20-11-2026. `DesignDashboardRepository` is kept beside it and is
/// what the widget tests override this with — a test that needs a dashboard
/// should not need a server.
final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => ApiDashboardRepository(ref.watch(apiClientProvider)),
);

/// What the dashboard watches.
final dashboardSummaryProvider = FutureProvider<DashboardSummary>(
  (ref) => ref.watch(dashboardRepositoryProvider).load(),
);

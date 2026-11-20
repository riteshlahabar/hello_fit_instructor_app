import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 exports `Override` from `misc.dart`, not the main library.
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_app/core/network/api_result.dart';
import 'package:trainer_app/core/theme/app_theme.dart';
import 'package:trainer_app/features/bookings/domain/booking_models.dart';
import 'package:trainer_app/features/clients/domain/client_models.dart';
import 'package:trainer_app/features/dashboard/data/design_dashboard_repository.dart';
import 'package:trainer_app/features/dashboard/domain/dashboard_repository.dart';
import 'package:trainer_app/features/dashboard/domain/dashboard_summary.dart';
import 'package:trainer_app/features/earnings/domain/earnings_models.dart';
import 'package:trainer_app/features/profile/domain/instructor_profile.dart';

import 'fake_profile_repository.dart';
import 'fake_tab_repositories.dart';

/// The pull-to-refresh harness: the boilerplate every refresh test would
/// otherwise copy, so a suite is its assertions and nothing else — the same
/// rule the backend's `test/smoke-harness.mjs` follows.
///
/// It owns the pump, the drag, and a counting repository per surface. What it
/// deliberately does **not** own is the fixtures: the counters wrap
/// `fake_tab_repositories.dart`, whose payloads are all empty — which is the
/// point. A `RefreshIndicator` only fires when its child *accepts* an
/// over-scroll drag, and a scrollable whose content fits the viewport refuses
/// one, so an empty payload is the short page a bare indicator silently does
/// nothing on. Every assertion here is therefore a test of
/// `HFRefresh.physics` as much as of the callback.

/// Pumps one screen under a `ProviderScope`, settled and ready to drag.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  required List<Override> overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: screen),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Drags the body down far enough to trip the indicator, then lets the
/// re-fetch and the spinner's exit animation finish.
Future<void> pullDown(WidgetTester tester) async {
  await tester.fling(find.byType(Scaffold).last, const Offset(0, 320), 1200);
  await tester.pumpAndSettle();
}

/// What every assertion in the suite says: read once on open, twice after a
/// pull. [calls] is the counter off the matching `Counting*` repository.
void expectRefetched(int calls, String surface) {
  expect(calls, 2, reason: '$surface did not re-read on pull-to-refresh');
}

class CountingDashboard implements DashboardRepository {
  int calls = 0;

  @override
  Future<DashboardSummary> load() {
    calls++;
    return const DesignDashboardRepository().load();
  }
}

class CountingBookings extends FakeBookingsRepository {
  CountingBookings();

  int calls = 0;

  @override
  Future<ApiResult<BookingPage>> list({
    BookingFilter filter = BookingFilter.all,
    String? query,
  }) {
    calls++;
    return super.list(filter: filter, query: query);
  }
}

class CountingClients extends FakeClientsRepository {
  CountingClients();

  int calls = 0;

  @override
  Future<ApiResult<ClientPage>> list({
    ClientFilter filter = ClientFilter.all,
    String? query,
  }) {
    calls++;
    return super.list(filter: filter, query: query);
  }
}

class CountingEarnings extends FakeEarningsRepository {
  CountingEarnings();

  int calls = 0;

  @override
  Future<ApiResult<EarningsSummary>> summary(EarningsPeriod period) {
    calls++;
    return super.summary(period);
  }
}

class CountingProfile extends FakeProfileRepository {
  int calls = 0;

  @override
  Future<ApiResult<InstructorProfile>> load() {
    calls++;
    return super.load();
  }
}

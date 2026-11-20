import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_app/features/bookings/data/bookings_providers.dart';
import 'package:trainer_app/features/bookings/presentation/bookings_screen.dart';
import 'package:trainer_app/features/clients/data/clients_providers.dart';
import 'package:trainer_app/features/clients/presentation/clients_screen.dart';
import 'package:trainer_app/features/dashboard/data/dashboard_providers.dart';
import 'package:trainer_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:trainer_app/features/earnings/data/earnings_providers.dart';
import 'package:trainer_app/features/earnings/presentation/earnings_screen.dart';
import 'package:trainer_app/features/profile/data/profile_providers.dart';
import 'package:trainer_app/features/profile/presentation/profile_screen.dart';

import 'support/fake_profile_repository.dart';
import 'support/refresh_harness.dart';

/// Every tab fetches again when the screen is pulled down.
/// Plumbing, fakes and the drag live in `support/refresh_harness.dart`.
void main() {
  testWidgets('Home re-reads the dashboard', (tester) async {
    final repo = CountingDashboard();
    await pumpScreen(
      tester,
      const DashboardScreen(),
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(repo),
        profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
      ],
    );
    expect(repo.calls, 1);

    await pullDown(tester);
    expectRefetched(repo.calls, 'Home');
  });

  testWidgets('Bookings re-reads its list, empty though it is', (tester) async {
    final repo = CountingBookings();
    await pumpScreen(
      tester,
      const BookingsScreen(),
      overrides: [bookingsRepositoryProvider.overrideWithValue(repo)],
    );
    expect(repo.calls, 1);

    await pullDown(tester);
    expectRefetched(repo.calls, 'Bookings');
  });

  testWidgets('Clients re-reads its list, empty though it is', (tester) async {
    final repo = CountingClients();
    await pumpScreen(
      tester,
      const ClientsScreen(),
      overrides: [clientsRepositoryProvider.overrideWithValue(repo)],
    );
    expect(repo.calls, 1);

    await pullDown(tester);
    expectRefetched(repo.calls, 'Clients');
  });

  testWidgets('Earnings re-reads its summary', (tester) async {
    final repo = CountingEarnings();
    await pumpScreen(
      tester,
      const EarningsScreen(),
      overrides: [earningsRepositoryProvider.overrideWithValue(repo)],
    );
    expect(repo.calls, 1);

    await pullDown(tester);
    expectRefetched(repo.calls, 'Earnings');
  });

  testWidgets('Profile re-reads the trainer profile', (tester) async {
    final repo = CountingProfile();
    await pumpScreen(
      tester,
      const ProfileScreen(),
      overrides: [profileRepositoryProvider.overrideWithValue(repo)],
    );
    expect(repo.calls, 1);

    await pullDown(tester);
    expectRefetched(repo.calls, 'Profile');
  });
}

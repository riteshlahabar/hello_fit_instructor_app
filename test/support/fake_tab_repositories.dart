// Riverpod 3 exports `Override` from `misc.dart`, not the main library.
import 'package:flutter_riverpod/misc.dart';
import 'package:trainer_app/core/network/api_result.dart';
import 'package:trainer_app/features/bookings/data/bookings_providers.dart';
import 'package:trainer_app/features/bookings/domain/booking_models.dart';
import 'package:trainer_app/features/bookings/domain/booking_request.dart';
import 'package:trainer_app/features/bookings/domain/bookings_repository.dart';
import 'package:trainer_app/features/clients/data/clients_providers.dart';
import 'package:trainer_app/features/clients/domain/client_models.dart';
import 'package:trainer_app/features/clients/domain/clients_repository.dart';
import 'package:trainer_app/features/dashboard/data/dashboard_providers.dart';
import 'package:trainer_app/features/dashboard/data/design_dashboard_repository.dart';
import 'package:trainer_app/features/earnings/data/earnings_providers.dart';
import 'package:trainer_app/features/earnings/domain/earnings_models.dart';
import 'package:trainer_app/features/earnings/domain/earnings_repository.dart';
import 'package:trainer_app/features/profile/data/profile_providers.dart';

import 'fake_profile_repository.dart';

/// The shell builds all five tabs through an `IndexedStack`, so every tab's
/// repository is read even while Home is showing. Any one of them left on the
/// HTTP client goes to a real socket and `pumpAndSettle` never settles.
///
/// So this is the whole set, in one place: a widget test that pumps the shell
/// spreads `tabOverrides` and is done.
List<Override> get tabOverrides => [
  profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
  dashboardRepositoryProvider.overrideWithValue(
    const DesignDashboardRepository(),
  ),
  bookingsRepositoryProvider.overrideWithValue(const FakeBookingsRepository()),
  clientsRepositoryProvider.overrideWithValue(const FakeClientsRepository()),
  earningsRepositoryProvider.overrideWithValue(const FakeEarningsRepository()),
];

class FakeBookingsRepository implements BookingsRepository {
  const FakeBookingsRepository();

  @override
  Future<ApiResult<BookingPage>> list({
    BookingFilter filter = BookingFilter.all,
    String? query,
  }) async =>
      const ApiSuccess(BookingPage(rows: [], summary: BookingSummary.empty));

  @override
  Future<ApiResult<BookingDetail>> detail(String sessionId) async =>
      const ApiFailure(code: 'NOT_FOUND', message: 'Booking not found');

  @override
  Future<ApiResult<List<BookingRequest>>> requests() async =>
      const ApiSuccess(<BookingRequest>[]);

  @override
  Future<ApiResult<void>> accept(String requestId, {String? note}) async =>
      const ApiSuccess(null);

  @override
  Future<ApiResult<void>> reject(
    String requestId, {
    required String reason,
    String? message,
  }) async => const ApiSuccess(null);
}

class FakeClientsRepository implements ClientsRepository {
  const FakeClientsRepository();

  @override
  Future<ApiResult<ClientPage>> list({
    ClientFilter filter = ClientFilter.all,
    String? query,
  }) async =>
      const ApiSuccess(ClientPage(rows: [], summary: ClientSummary.empty));

  @override
  Future<ApiResult<ClientProfile>> detail(String customerId) async =>
      const ApiFailure(code: 'NOT_FOUND', message: 'Not one of your clients');
}

class FakeEarningsRepository implements EarningsRepository {
  const FakeEarningsRepository();

  @override
  Future<ApiResult<EarningsSummary>> summary(EarningsPeriod period) async =>
      ApiSuccess(
        EarningsSummary(
          period: period.name,
          total: 0,
          changePercent: null,
          availableBalance: 0,
          pendingAmount: 0,
          withheldAmount: 0,
          paidToDate: 0,
          completedSessions: 0,
          averagePerSession: 0,
          chart: const [],
          transactions: const [],
          nextPayout: null,
        ),
      );
}

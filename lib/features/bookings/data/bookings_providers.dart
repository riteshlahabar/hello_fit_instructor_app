import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../../../core/state/ui_state.dart';
import '../../auth/data/auth_providers.dart';
import '../../dashboard/data/dashboard_providers.dart';
import '../domain/booking_models.dart';
import '../domain/booking_request.dart';
import '../domain/bookings_repository.dart';
import 'api_bookings_repository.dart';

final bookingsRepositoryProvider = Provider<BookingsRepository>(
  (ref) => ApiBookingsRepository(ref.watch(apiClientProvider)),
);

/// Which chip is lit on page 30, and what is in its search box.
final bookingFilterProvider =
    NotifierProvider<UiState<BookingFilter>, BookingFilter>(
      () => UiState(BookingFilter.all),
    );

final bookingQueryProvider = NotifierProvider<UiState<String>, String>(
  () => UiState(''),
);

/// Page 30's list. Re-reads itself when the chip or the query changes, so the
/// filtering happens on the server where the `where` clause is.
final bookingPageProvider = FutureProvider<BookingPage>((ref) async {
  final result = await ref
      .watch(bookingsRepositoryProvider)
      .list(
        filter: ref.watch(bookingFilterProvider),
        query: ref.watch(bookingQueryProvider),
      );

  return switch (result) {
    ApiSuccess(:final data) => data,
    ApiFailure(:final message) => throw Exception(message),
  };
});

/// Page 32.
final bookingDetailProvider = FutureProvider.family<BookingDetail, String>((
  ref,
  sessionId,
) async {
  final result = await ref.watch(bookingsRepositoryProvider).detail(sessionId);

  return switch (result) {
    ApiSuccess(:final data) => data,
    ApiFailure(:final message) => throw Exception(message),
  };
});

/// Page 31 — the §4.7 inbox.
final bookingRequestsProvider = FutureProvider<List<BookingRequest>>((
  ref,
) async {
  final result = await ref.watch(bookingsRepositoryProvider).requests();

  return switch (result) {
    ApiSuccess(:final data) => data,
    ApiFailure(:final message) => throw Exception(message),
  };
});

/// Owns the two writes, so no screen calls the repository itself.
///
/// Every answer invalidates the three readers an answer changes: the inbox it
/// came from, the bookings list whose buckets just moved, and the dashboard
/// whose request count is now stale. That is the whole point of routing the
/// writes through here.
class RequestController extends Notifier<void> {
  @override
  void build() {}

  Future<ApiResult<void>> accept(String requestId, {String? note}) =>
      _answer(() => _repo.accept(requestId, note: note));

  Future<ApiResult<void>> reject(
    String requestId, {
    required String reason,
    String? message,
  }) =>
      _answer(() => _repo.reject(requestId, reason: reason, message: message));

  BookingsRepository get _repo => ref.read(bookingsRepositoryProvider);

  Future<ApiResult<void>> _answer(
    Future<ApiResult<void>> Function() call,
  ) async {
    final result = await call();

    if (result.isSuccess) {
      ref.invalidate(bookingRequestsProvider);
      ref.invalidate(bookingPageProvider);
      ref.invalidate(dashboardSummaryProvider);
    }

    return result;
  }
}

final requestControllerProvider = NotifierProvider<RequestController, void>(
  RequestController.new,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../../../core/state/ui_state.dart';
import '../../auth/data/auth_providers.dart';
import '../../dashboard/data/dashboard_providers.dart';
import '../../earnings/data/earnings_providers.dart';
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

/// The §4.7 request list. Page 31's inbox was deleted on 23-11-2026, so this
/// now feeds only [requestByIdProvider] for pages 33 and 34.
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
/// Every answer invalidates the three readers an answer changes: the request
/// list, the bookings list whose buckets just moved, and the dashboard whose
/// request count is now stale. That is the whole point of routing the
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

/// Page 32's two buttons (client, 23-11-2026). Separate from
/// [RequestController] because these close a session rather than answer an
/// offer, and they invalidate one reader more: the earnings tab, which the
/// completion has just added a row to.
class SessionCloseController extends Notifier<void> {
  @override
  void build() {}

  Future<ApiResult<void>> complete(String sessionId, {required String otp}) =>
      _close(sessionId, () => _repo.complete(sessionId, otp: otp));

  Future<ApiResult<void>> cancel(
    String sessionId, {
    required String reason,
    bool clientAbsent = false,
  }) => _close(
    sessionId,
    () => _repo.cancel(sessionId, reason: reason, clientAbsent: clientAbsent),
  );

  BookingsRepository get _repo => ref.read(bookingsRepositoryProvider);

  Future<ApiResult<void>> _close(
    String sessionId,
    Future<ApiResult<void>> Function() call,
  ) async {
    final result = await call();

    if (result.isSuccess) {
      ref.invalidate(bookingDetailProvider(sessionId));
      ref.invalidate(bookingPageProvider);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(earningsSummaryProvider);
    }

    return result;
  }
}

final sessionCloseControllerProvider =
    NotifierProvider<SessionCloseController, void>(SessionCloseController.new);

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../domain/booking_models.dart';
import '../domain/booking_request.dart';
import '../domain/bookings_repository.dart';

/// Talks to `/app/instructor/bookings` and `/app/instructor/requests`.
class ApiBookingsRepository implements BookingsRepository {
  const ApiBookingsRepository(this._api);

  final ApiClient _api;

  static List<BookingRow> _rows(dynamic data) => switch (data) {
    final List<dynamic> list => list
        .map((e) => BookingRow.fromJson(e as Map<String, dynamic>))
        .toList(),
    _ => const [],
  };

  /// The summary tiles ride in `meta`, so the page is assembled from both
  /// halves of the envelope rather than from `data` alone.
  @override
  Future<ApiResult<BookingPage>> list({
    BookingFilter filter = BookingFilter.all,
    String? query,
  }) async {
    final result = await _api.get<List<BookingRow>>(
      '/app/instructor/bookings',
      query: {
        if (filter != BookingFilter.all) 'status': filter.name,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      },
      parse: _rows,
    );

    return switch (result) {
      ApiSuccess(:final data, :final meta) => ApiSuccess(
        BookingPage(
          rows: data,
          summary: BookingSummary.fromJson(
            meta?['summary'] as Map<String, dynamic>?,
          ),
        ),
      ),
      ApiFailure(:final code, :final message, :final details, :final statusCode) =>
        ApiFailure<BookingPage>(
          code: code,
          message: message,
          details: details,
          statusCode: statusCode,
        ),
    };
  }

  @override
  Future<ApiResult<BookingDetail>> detail(String sessionId) => _api.get(
    '/app/instructor/bookings/$sessionId',
    parse: (data) => BookingDetail.fromJson(data as Map<String, dynamic>),
  );

  @override
  Future<ApiResult<List<BookingRequest>>> requests() => _api.get(
    '/app/instructor/requests',
    parse: (data) => switch (data) {
      final List<dynamic> list => list
          .map((e) => BookingRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      _ => const <BookingRequest>[],
    },
  );

  @override
  Future<ApiResult<void>> accept(String requestId, {String? note}) => _api.post(
    '/app/instructor/requests/$requestId/accept',
    body: {if (note != null && note.trim().isNotEmpty) 'note': note.trim()},
    parse: (_) {},
  );

  @override
  Future<ApiResult<void>> reject(
    String requestId, {
    required String reason,
    String? message,
  }) => _api.post(
    '/app/instructor/requests/$requestId/reject',
    body: {
      'reason': reason,
      if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
    },
    parse: (_) {},
  );
}

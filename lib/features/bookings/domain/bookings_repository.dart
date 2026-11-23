import '../../../core/network/api_result.dart';
import 'booking_models.dart';
import 'booking_request.dart';

/// What pages 30–34 and 37 need, said without naming a route (DIP, as
/// `../../frontend-conventions.md` requires).
abstract interface class BookingsRepository {
  Future<ApiResult<BookingPage>> list({BookingFilter filter, String? query});

  Future<ApiResult<BookingDetail>> detail(String sessionId);

  Future<ApiResult<List<BookingRequest>>> requests();

  Future<ApiResult<void>> accept(String requestId, {String? note});

  Future<ApiResult<void>> reject(
    String requestId, {
    required String reason,
    String? message,
  });

  /// Page 32's Completed button. [otp] is the four digits the client reads
  /// off their own app — the proof the two of them met.
  Future<ApiResult<void>> complete(String sessionId, {required String otp});

  /// Page 32's Cancel button. [clientAbsent] is the one branch that changes
  /// the status: a no-show rather than a trainer cancellation.
  Future<ApiResult<void>> cancel(
    String sessionId, {
    required String reason,
    bool clientAbsent = false,
  });
}

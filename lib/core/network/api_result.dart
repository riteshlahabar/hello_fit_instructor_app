/// Mirrors the backend response envelope `{ success, data, meta, message }`
/// and its error shape `{ success:false, error:{ code, message, details } }`.
///
/// The backend guarantees one shape for every endpoint, so parsing lives here
/// once rather than in each repository.
sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is ApiSuccess<T>;

  /// Value on success, null on failure — for call sites that do not branch.
  T? get valueOrNull => switch (this) {
        ApiSuccess<T>(:final data) => data,
        ApiFailure<T>() => null,
      };
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data, {this.message, this.meta});

  final T data;
  final String? message;
  final Map<String, dynamic>? meta;
}

final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure({
    required this.code,
    required this.message,
    this.details,
    this.statusCode,
  });

  /// Stable code from the backend (`OTP_EXPIRED`, `TOKEN_EXPIRED`, …) which the
  /// app switches on to show a localised message.
  final String code;
  final String message;
  final Object? details;
  final int? statusCode;

  /// Field-level validation messages, when the failure was a 400.
  List<String> get validationMessages => switch (details) {
        final List<dynamic> list => list.map((e) => e.toString()).toList(),
        _ => const [],
      };
}

/// What a screen should actually show.
///
/// A 400 from the backend's global ValidationPipe always carries the same
/// useless `message` — "Request validation failed" — and puts the part a
/// person can act on in `details`: which field, and why. So read `details`
/// when it is there, and leave every other failure's message alone.
String envelopeMessage(String code, String message, Object? details) {
  if (code != ApiErrorCode.validationFailed) return message;

  final lines = switch (details) {
    final List<dynamic> list => list.map((e) => e.toString()).toList(),
    _ => const <String>[],
  };
  if (lines.isEmpty) return message;

  return lines.map(_sentence).join('\n');
}

String _sentence(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

/// Error codes the app needs to react to rather than just display.
abstract final class ApiErrorCode {
  static const validationFailed = 'VALIDATION_FAILED';
  static const unauthenticated = 'UNAUTHENTICATED';
  static const tokenExpired = 'TOKEN_EXPIRED';
  static const tokenInvalid = 'TOKEN_INVALID';
  static const forbidden = 'FORBIDDEN';
  static const otpInvalid = 'OTP_INVALID';
  static const otpExpired = 'OTP_EXPIRED';
  static const otpAttemptsExceeded = 'OTP_ATTEMPTS_EXCEEDED';
  static const accountSuspended = 'ACCOUNT_SUSPENDED';
  static const rateLimited = 'RATE_LIMITED';
  static const network = 'NETWORK_ERROR';
  static const unknown = 'INTERNAL_ERROR';
}

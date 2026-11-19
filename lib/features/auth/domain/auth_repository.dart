import '../../../core/network/api_result.dart';
import 'app_session.dart';

/// Sign-in, stated without naming HTTP. Spec §4.1 is OTP only — the app has no
/// password login, that is the admin panel's (`/admin/auth/login`).
abstract interface class AuthRepository {
  /// `POST /auth/otp/send`
  Future<ApiResult<OtpChallenge>> sendOtp(String mobile);

  /// `POST /auth/otp/verify` — also stores the token pair.
  Future<ApiResult<AppSession>> verifyOtp({
    required String mobile,
    required String code,
  });

  /// `POST /auth/logout`, then clears the stored tokens either way.
  Future<void> logout();

  /// True when a token pair is already on the device.
  Future<bool> hasStoredSession();
}

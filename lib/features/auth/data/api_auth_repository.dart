import 'dart:io';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/storage/token_store.dart';
import '../domain/app_session.dart';
import '../domain/auth_repository.dart';

/// Talks to `/auth/*`. The only place in the app that knows those paths.
class ApiAuthRepository implements AuthRepository {
  const ApiAuthRepository(this._api, this._tokens);

  final ApiClient _api;
  final TokenStore _tokens;

  @override
  Future<ApiResult<OtpChallenge>> sendOtp(String mobile) => _api.post(
    '/auth/otp/send',
    body: {'mobile': mobile},
    skipAuth: true,
    parse: (data) => OtpChallenge.fromJson(data as Map<String, dynamic>),
  );

  @override
  Future<ApiResult<AppSession>> verifyOtp({
    required String mobile,
    required String code,
  }) async {
    final result = await _api.post<Map<String, dynamic>>(
      '/auth/otp/verify',
      skipAuth: true,
      body: {
        'mobile': mobile,
        'code': code,
        'device': {
          'platform': Platform.isIOS ? 'IOS' : 'ANDROID',
          'deviceId': await _deviceId(),
        },
      },
      parse: (data) => data as Map<String, dynamic>,
    );

    return switch (result) {
      ApiSuccess(:final data) => await _storeAndMap(data),
      ApiFailure(
        :final code,
        :final message,
        :final details,
        :final statusCode,
      ) =>
        ApiFailure<AppSession>(
          code: code,
          message: message,
          details: details,
          statusCode: statusCode,
        ),
    };
  }

  Future<ApiResult<AppSession>> _storeAndMap(Map<String, dynamic> data) async {
    await _tokens.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
    return ApiSuccess(AppSession.fromJson(data));
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken != null) {
      await _api.post<dynamic>(
        '/auth/logout',
        body: {'refreshToken': refreshToken},
      );
    }
    await _tokens.clear();
  }

  @override
  Future<bool> hasStoredSession() async =>
      await _tokens.readAccessToken() != null;

  /// A stable per-install id. The backend only needs it to be unique per
  /// device so a logout can revoke that device's refresh chain.
  Future<String> _deviceId() async {
    const key = 'hf_device_id';
    final existing = await _tokens.readValue(key);
    if (existing != null) return existing;
    final fresh = 'trainer-${DateTime.now().microsecondsSinceEpoch}';
    await _tokens.writeValue(key, fresh);
    return fresh;
  }
}

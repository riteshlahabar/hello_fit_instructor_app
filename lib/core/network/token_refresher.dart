import 'package:dio/dio.dart';

import '../storage/token_store.dart';

/// Owns the refresh-token rotation, so [ApiClient] only has to ask "did it
/// work?" once per failed request.
///
/// Concurrent callers await the same attempt: a replayed rotation would make
/// the backend treat the token as stolen and revoke the whole chain.
class TokenRefresher {
  TokenRefresher(this._dio, this._tokenStore);

  final Dio _dio;
  final TokenStore _tokenStore;

  Future<bool>? _inFlight;

  Future<bool> refreshOnce() {
    return _inFlight ??= _perform().whenComplete(() {
      _inFlight = null;
    });
  }

  Future<bool> _perform() async {
    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null) return false;

    final response = await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      options: Options(extra: {'skipAuth': true}),
    );

    final body = response.data;
    if (body is! Map<String, dynamic> || body['success'] != true) {
      await _tokenStore.clear();
      return false;
    }

    final data = body['data'] as Map<String, dynamic>;
    await _tokenStore.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
    return true;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/storage/token_store.dart';
import '../domain/app_session.dart';
import '../domain/auth_repository.dart';
import 'api_auth_repository.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(ref.watch(tokenStoreProvider));
  client.onSessionExpired = () =>
      ref.read(authControllerProvider.notifier).onSessionLost();
  return client;
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ApiAuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStoreProvider),
  ),
);

/// Where the app is, as far as sign-in goes.
sealed class AuthState {
  const AuthState();
}

/// Splash is still reading the token store.
class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

class AuthSignedIn extends AuthState {
  const AuthSignedIn(this.session);

  /// Null when the app started with a stored token and has not re-read the
  /// person yet — the token is enough to enter the shell.
  final AppSession? session;
}

/// Owns the session. Screens read it; nothing else writes tokens.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthUnknown();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// Splash calls this once.
  ///
  /// A failure to read the keystore must not leave the app on [AuthUnknown] —
  /// that state keeps the router pinned to the splash screen forever.
  Future<void> restore() async {
    try {
      state = await _repo.hasStoredSession()
          ? const AuthSignedIn(null)
          : const AuthSignedOut();
    } catch (_) {
      state = const AuthSignedOut();
    }
  }

  Future<ApiResult<OtpChallenge>> sendOtp(String mobile) =>
      _repo.sendOtp(mobile);

  Future<ApiResult<AppSession>> verifyOtp({
    required String mobile,
    required String code,
  }) async {
    final result = await _repo.verifyOtp(mobile: mobile, code: code);
    if (result case ApiSuccess(:final data)) {
      state = AuthSignedIn(data);
    }
    return result;
  }

  Future<void> signOut() async {
    await _repo.logout();
    state = const AuthSignedOut();
  }

  /// Called by the API client when a refresh fails.
  void onSessionLost() => state = const AuthSignedOut();
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

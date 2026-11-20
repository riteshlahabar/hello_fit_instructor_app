import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_app/app/router.dart';
import 'package:trainer_app/core/network/api_result.dart';
import 'package:trainer_app/core/theme/app_theme.dart';
import 'package:trainer_app/features/auth/data/auth_providers.dart';
import 'package:trainer_app/features/auth/domain/app_session.dart';
import 'package:trainer_app/features/auth/domain/auth_repository.dart';
import 'package:trainer_app/features/profile/data/profile_providers.dart';

import 'support/fake_tab_repositories.dart';

/// Stands in for the keystore-backed repository, which cannot run in a test.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.stored, this.throwOnRead = false});

  final bool stored;
  final bool throwOnRead;

  @override
  Future<bool> hasStoredSession() async {
    if (throwOnRead) throw StateError('keystore unavailable');
    return stored;
  }

  @override
  Future<ApiResult<OtpChallenge>> sendOtp(String mobile) async =>
      const ApiSuccess(OtpChallenge(sent: true));

  @override
  Future<ApiResult<AppSession>> verifyOtp({
    required String mobile,
    required String code,
  }) async => const ApiFailure(code: 'OTP_INVALID', message: 'nope');

  @override
  Future<void> logout() async {}
}

Future<void> _pump(
  WidgetTester tester,
  AuthRepository repo, {
  String? landing,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        // One of these cases lands on the shell, which builds every tab.
        ...tabOverrides,
        if (landing != null)
          landingRouteProvider.overrideWith((ref) async => landing),
      ],
      child: Consumer(
        builder: (context, ref, _) => MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: ref.watch(routerProvider),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 1400));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('splash hands over to the intro carousel when signed out', (
    tester,
  ) async {
    await _pump(tester, _FakeAuthRepository(stored: false));

    expect(find.text('TRAIN MORE.\nGROW FASTER.'), findsOneWidget);
    expect(find.text('GET STARTED   →'), findsOneWidget);
    expect(find.text('EMPOWER MOVEMENT · INSPIRE PROGRESS'), findsNothing);
  });

  testWidgets('a keystore failure still leaves the splash', (tester) async {
    await _pump(tester, _FakeAuthRepository(stored: false, throwOnRead: true));

    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('a half-finished application opens the wizard, not the shell', (
    tester,
  ) async {
    await _pump(
      tester,
      _FakeAuthRepository(stored: true),
      landing: '/onboarding/profile',
    );

    expect(find.text('Create Your\nTrainer Profile'), findsOneWidget);
  });

  testWidgets('an approved trainer goes straight to the shell', (tester) async {
    await _pump(tester, _FakeAuthRepository(stored: true), landing: '/');

    expect(find.text('Your overview'), findsOneWidget);
  });
}

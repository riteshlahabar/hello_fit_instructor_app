import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/auth_providers.dart';
import '../features/auth/presentation/mobile_screen.dart';
import '../features/auth/presentation/otp_screen.dart';
import '../features/onboarding/presentation/bank_account_screen.dart';
import '../features/onboarding/presentation/create_profile_screen.dart';
import '../features/onboarding/presentation/documents_screen.dart';
import '../features/onboarding/presentation/intro_screen.dart';
import '../features/onboarding/presentation/personal_info_screen.dart';
import '../features/onboarding/presentation/professional_screen.dart';
import '../features/onboarding/presentation/profile_preview_screen.dart';
import '../features/onboarding/presentation/service_area_screen.dart';
import '../features/onboarding/presentation/specialisation_screen.dart';
import '../features/onboarding/presentation/submit_screen.dart';
import '../features/onboarding/presentation/verification_status_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/shell/presentation/trainer_shell.dart';

/// Routes, plus the one redirect that decides splash → intro → login → shell.
///
/// Rebuilt whenever [authControllerProvider] changes, so a sign-out drops the
/// person back to the mobile-number page without any screen pushing a route.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final isSplash = location == '/splash';
      final isAuthRoute = location.startsWith('/login') || location == '/intro';

      return switch (auth) {
        AuthUnknown() => isSplash ? null : '/splash',
        AuthSignedOut() => isAuthRoute ? null : '/intro',
        AuthSignedIn() => isAuthRoute ? '/' : null,
      };
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/intro',
        name: 'intro',
        builder: (context, state) => const IntroScreen(),
      ),
      GoRoute(
        path: '/login/mobile',
        name: 'login-mobile',
        builder: (context, state) => const MobileScreen(),
      ),
      GoRoute(
        path: '/login/otp',
        name: 'login-otp',
        builder: (context, state) => OtpScreen(mobile: state.extra as String),
      ),
      GoRoute(
        path: '/onboarding/profile',
        name: 'onboarding-profile',
        builder: (context, state) => const CreateProfileScreen(),
      ),
      GoRoute(
        path: '/onboarding/personal',
        name: 'onboarding-personal',
        builder: (context, state) => const PersonalInfoScreen(),
      ),
      GoRoute(
        path: '/onboarding/professional',
        name: 'onboarding-professional',
        builder: (context, state) => const ProfessionalScreen(),
      ),
      GoRoute(
        path: '/onboarding/service-area',
        name: 'onboarding-service-area',
        builder: (context, state) => const ServiceAreaScreen(),
      ),
      GoRoute(
        path: '/onboarding/bank',
        name: 'onboarding-bank',
        builder: (context, state) => const BankAccountScreen(),
      ),
      GoRoute(
        path: '/onboarding/specialisation',
        name: 'onboarding-specialisation',
        builder: (context, state) => const SpecialisationScreen(),
      ),
      GoRoute(
        path: '/onboarding/documents',
        name: 'onboarding-documents',
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: '/onboarding/submit',
        name: 'onboarding-submit',
        builder: (context, state) => const SubmitScreen(),
      ),
      GoRoute(
        path: '/onboarding/status',
        name: 'onboarding-status',
        builder: (context, state) => const VerificationStatusScreen(),
      ),
      GoRoute(
        path: '/onboarding/preview',
        name: 'onboarding-preview',
        builder: (context, state) => const ProfilePreviewScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'shell',
        builder: (context, state) => const TrainerShell(),
      ),
    ],
  );
});

/// Bridges Riverpod to go_router's `refreshListenable`.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

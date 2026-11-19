import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../auth/data/auth_providers.dart';
import '../../profile/data/profile_providers.dart';

/// Page 01 — Splash. Reads the token store while it shows, then the router's
/// redirect takes over.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      await ref.read(authControllerProvider.notifier).restore();
      if (!mounted) return;

      // Navigate here rather than waiting on the router's redirect: if the
      // refresh listener ever misses the state change, the splash would sit
      // on screen for good.
      final auth = ref.read(authControllerProvider);
      if (auth is! AuthSignedIn) {
        context.go('/intro');
        return;
      }

      // A stored token alone does not mean the shell: the application may
      // still be half finished. See [landingRouteProvider].
      final landing = await ref.read(landingRouteProvider.future);
      if (!mounted) return;
      context.go(landing);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HFColors.ivory,
      body: Stack(
        alignment: Alignment.center,
        children: const [
          _Backdrop(),
          _Brand(),
          Align(alignment: Alignment.bottomCenter, child: _Footer()),
        ],
      ),
    );
  }
}

/// `.glow` + `.orbit` and its two inset rings.
class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.45),
      child: SizedBox(
        width: 330,
        height: 330,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x10E33E29),
              ),
            ),
            for (final size in [280.0, 240.0, 196.0])
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: HFColors.taupe.withAlpha(0x55)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// `.brand-wrap` — logo, wordmark, role, tagline.
class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 104,
          height: 104,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: HFColors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A5B4030),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
        const SizedBox(height: 18),
        Text.rich(
          TextSpan(
            text: 'Hello',
            children: [
              TextSpan(
                text: 'Fit',
                style: AppTheme.display(43, color: HFColors.primary),
              ),
            ],
          ),
          style: AppTheme.display(43),
        ),
        const SizedBox(height: 10),
        const Text(
          'TRAINER APP',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: HFColors.metricCaption,
          ),
        ),
        const SizedBox(height: 42),
        Text.rich(
          TextSpan(
            text: 'Your time, ',
            children: [
              TextSpan(
                text: 'Your Place',
                style: AppTheme.display(20, color: HFColors.primary),
              ),
            ],
          ),
          style: AppTheme.display(20),
        ),
      ],
    );
  }
}

/// `.bottom` — orange rule over the strapline.
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 3,
            decoration: BoxDecoration(
              color: HFColors.primary,
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'EMPOWER MOVEMENT · INSPIRE PROGRESS',
            style: TextStyle(
              fontSize: 8,
              letterSpacing: 1.5,
              color: HFColors.metricCaption,
            ),
          ),
        ],
      ),
    );
  }
}

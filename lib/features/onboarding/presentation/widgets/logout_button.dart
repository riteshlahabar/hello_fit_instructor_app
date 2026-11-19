import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../auth/data/auth_providers.dart';

/// Signing out from inside the wizard.
///
/// A half-finished applicant has no other way out: the shell carries the
/// profile tab, and the shell is only reached once the application is in.
/// Signing out flips [authControllerProvider], which the router listens to, so
/// no screen has to push a route.
class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
      style: TextButton.styleFrom(
        minimumSize: const Size(36, 36),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        foregroundColor: HFColors.primary,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'LOG OUT',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: .7,
        ),
      ),
    );
  }
}

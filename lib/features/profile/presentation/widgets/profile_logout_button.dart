import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/data/auth_providers.dart';

/// `.logout` on page 65 — the full-width button at the foot of the profile
/// tab.
///
/// This is the app's only way out since 20-11-2026 (client): the registration
/// wizard no longer carries one, because a trainer mid-registration now lands
/// back on the page they stopped at and can reach the profile tab once the
/// application is in.
///
/// Signing out flips [authControllerProvider], which the router listens to, so
/// no screen has to push a route.
class ProfileLogoutButton extends ConsumerWidget {
  const ProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF2ED),
          foregroundColor: const Color(0xFFBD3A28),
          side: const BorderSide(color: Color(0xFFE9B6AA)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'LOG OUT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: .5,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../data/profile_providers.dart';
import '../domain/instructor_profile.dart';
import 'widgets/profile_identity_card.dart';
import 'widgets/profile_logout_button.dart';
import 'widgets/profile_menu_group.dart';

/// Page 65 — Trainer Profile & Settings. The shell's fifth tab.
///
/// The rows are page 65's "My account" group. **App preferences** (push,
/// email, language) and **Support & legal** (help, terms, privacy) are the
/// design's other two groups and are deliberately absent: nothing in the API
/// stores a notification preference and pages 68/72/73 are not built, so a row
/// here would be a dead end. → `state/working-order.md`.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);

    return switch (state) {
      AsyncData(:final value) when value != null => _Body(profile: value),
      AsyncError(:final error) => _Message(
        text: '$error'.replaceFirst('Exception: ', ''),
        onRetry: () => ref.invalidate(profileControllerProvider),
      ),
      AsyncData() => const _Message(
        text: 'Your trainer profile has not been created yet.',
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.profile});

  final InstructorProfile profile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACCOUNT · PREFERENCES',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.7,
              color: HFColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Manage your trainer profile and account details.',
            style: TextStyle(
              fontSize: 11,
              height: 1.6,
              color: HFColors.muted,
            ),
          ),
          const SizedBox(height: 14),
          ProfileIdentityCard(profile: profile),
          ProfileMenuGroup(
            label: 'MY ACCOUNT',
            rows: [
              ProfileMenuRow(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                sub: 'Photo, personal, professional and service details',
                onTap: () => context.push('/profile/edit'),
              ),
              ProfileMenuRow(
                icon: Icons.currency_rupee_rounded,
                title: 'Bank & Payout Details',
                sub: 'Manage your payment information',
                onTap: () => context.push('/profile/bank'),
              ),
              ProfileMenuRow(
                icon: Icons.badge_outlined,
                title: 'Certifications & Documents',
                sub: 'Upload or replace your KYC and certificates',
                onTap: () => context.push('/profile/documents'),
              ),
              ProfileMenuRow(
                icon: Icons.visibility_outlined,
                title: 'Profile Preview',
                sub: 'See your profile the way a client reads it',
                onTap: () => context.push('/onboarding/preview'),
              ),
              ProfileMenuRow(
                icon: Icons.verified_outlined,
                title: 'Verification Status',
                sub: 'Where your application stands',
                onTap: () => context.push('/onboarding/status'),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const ProfileLogoutButton(),
        ],
      ),
    );
  }
}

/// An empty or failed profile read still has to offer the way out, or a
/// trainer whose profile will not load cannot sign out of the app.
class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: HFColors.muted),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          const SizedBox(height: 10),
          const ProfileLogoutButton(),
        ],
      ),
    );
  }
}

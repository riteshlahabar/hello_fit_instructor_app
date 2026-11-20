import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/hf_primary_button.dart';
import '../../profile/data/profile_providers.dart';
import 'widgets/preview_blocks.dart';
import 'widgets/wizard_scaffold.dart';

/// Page 23 — Profile Preview. Everything here is read back from
/// `GET /app/instructor/profile`.
///
/// The HTML also previews a session price. That is deliberately absent: admin
/// sets every price (client, 17 Nov), so a trainer's profile carries none.
class ProfilePreviewScreen extends ConsumerWidget {
  const ProfilePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider).value;

    return WizardScaffold(
      stepLabel: 'PROFILE PREVIEW',
      progress: 1,
      title: 'Your Profile,\nAs Clients See It',
      sub: 'This is what a client reads before sending you a booking request.',
      onBack: context.canPop() ? context.pop : null,
      children: profile == null
          ? const [Center(child: CircularProgressIndicator())]
          : [
              PreviewIdentity(profile: profile),
              const SizedBox(height: 12),
              PreviewFacts(profile: profile),
              const SizedBox(height: 12),
              if (profile.specialisations.isNotEmpty)
                PreviewChips(
                  title: 'Specialities',
                  values: profile.specialisations,
                ),
              if (profile.languages.isNotEmpty)
                PreviewChips(title: 'Languages', values: profile.languages),
              const SizedBox(height: 16),
              HFPrimaryButton(
                label: 'BACK TO DASHBOARD',
                trailingArrow: false,
                onPressed: () => context.go('/'),
              ),
            ],
    );
  }
}

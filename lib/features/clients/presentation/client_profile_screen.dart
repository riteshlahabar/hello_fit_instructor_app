import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_card.dart';
import '../../../core/widgets/hf_field_grid.dart';
import '../../../core/widgets/hf_list_pieces.dart';
import '../../../core/widgets/hf_note_field.dart';
import '../../../core/widgets/hf_pieces.dart';
import '../../../core/widgets/hf_pushed_page.dart';
import '../data/clients_providers.dart';
import '../domain/client_models.dart';
import 'widgets/client_session_row.dart';

/// Page 39 — Client Profile.
///
/// Four of the design's cards are deliberately absent, and all four for the
/// same reason: nothing stores them.
///
/// * **Mobile and email** — contact runs through masked calling (spec 10.1),
///   so handing the trainer a raw number would defeat it.
/// * **Age and gender** — on `CustomerProfile`, but not on this surface: the
///   trainer is shown what the booking carries.
/// * **Workout plans and goal progress** — pages 51–56, outside the PDF, no
///   tables.
/// * **Start Session / Message / Edit** — pages 45–50 and 64, not built.
///
/// What is left is the real thing: who they are, what they have booked, what
/// it was worth, and the sessions themselves.
class ClientProfileScreen extends ConsumerWidget {
  const ClientProfileScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(clientProfileProvider(customerId));

    return HFPushedPage(
      backLabel: 'My Clients',
      eyebrow: 'Client management',
      title: 'CLIENT\nPROFILE.',
      sub: "A quick overview of your client's details and training activity.",
      onRefresh: () async =>
          ref.refresh(clientProfileProvider(customerId).future),
      children: switch (profile) {
        AsyncValue(:final value?) => _body(value),
        AsyncError(:final error) => [
          HFEmptyPanel(message: '$error'.replaceFirst('Exception: ', '')),
        ],
        _ => const [
          Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
              child: CircularProgressIndicator(color: HFColors.primary),
            ),
          ),
        ],
      },
    );
  }

  List<Widget> _body(ClientProfile profile) {
    final client = profile.client;

    return [
      HFCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                HFAvatar(initials: client.initials, size: 46, radius: 14),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: HFColors.ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Joined ${client.joinedAt}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: HFColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                HFStatusPill(
                  label: client.active ? 'ACTIVE CLIENT' : 'INACTIVE',
                  bucket: client.active ? 'confirmed' : 'completed',
                ),
              ],
            ),
            const SizedBox(height: 12),
            HFCountTiles(
              tiles: [
                ('${client.sessions}', 'Sessions'),
                ('${client.completed}', 'Completed'),
                ('${client.upcoming}', 'Upcoming'),
              ],
            ),
          ],
        ),
      ),
      const HFSectionHead(title: 'Training summary'),
      HFFieldGrid(
        fields: [
          ('Training type', client.service),
          ('Total value', rupees(client.value)),
          ('First session', client.firstSessionOn),
          ('Last session', client.lastSessionOn),
        ],
      ),
      const SizedBox(height: 9),
      const HFFinePrint(
        icon: Icons.phone_disabled_outlined,
        text: 'Client contact details are not shown here — calls and messages '
            'go through HelloFit so both numbers stay private.',
      ),
      const HFSectionHead(title: 'Recent sessions'),
      if (profile.recent.isEmpty)
        const HFEmptyPanel(message: 'No sessions recorded yet.')
      else
        for (final session in profile.recent) ...[
          ClientSessionRow(session: session),
          const SizedBox(height: 8),
        ],
      const SizedBox(height: 10),
    ];
  }
}

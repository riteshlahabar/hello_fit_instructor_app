import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/hf_pieces.dart';
import '../../domain/client_models.dart';

/// `.client` — one row on page 38.
///
/// The design's second line reads "Personal Training · Joined 12 Aug 2026" on
/// an active client and "· Last session 20 Oct 2026" on an inactive one, so
/// the line follows the client's own state.
///
/// **The design's "2 plans" count is not here.** Workout plans are pages
/// 51–56, which are outside the PDF and have no tables, so there is nothing to
/// count. Sessions and value are what the booking rows actually carry.
class ClientCard extends StatelessWidget {
  const ClientCard({super.key, required this.client, this.onTap});

  final TrainerClient client;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: HFColors.white,
          border: Border.all(color: HFColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            HFAvatar(initials: client.initials, size: 40, radius: 13),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    client.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: HFColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    client.active
                        ? '${client.service} · Joined ${client.joinedAt}'
                        : '${client.service} · Last session '
                              '${client.lastSessionOn}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: HFColors.muted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${client.sessions} '
                    '${client.sessions == 1 ? 'session' : 'sessions'}'
                    ' · ${rupees(client.value)}',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: HFColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            HFStatusPill(
              label: client.active ? 'ACTIVE' : 'INACTIVE',
              bucket: client.active ? 'confirmed' : 'completed',
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 17,
              color: HFColors.taupe,
            ),
          ],
        ),
      ),
    );
  }
}

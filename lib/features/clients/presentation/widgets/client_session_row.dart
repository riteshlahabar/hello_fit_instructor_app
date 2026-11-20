import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/hf_pieces.dart';
import '../../domain/client_models.dart';

/// `.session` — one line of page 39's "Recent session" list.
class ClientSessionRow extends StatelessWidget {
  const ClientSessionRow({super.key, required this.session});

  final ClientSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: HFColors.white,
        border: Border.all(color: HFColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  session.service,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: HFColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${session.date} · ${session.time} · '
                  '${session.durationMin} minutes',
                  style: const TextStyle(fontSize: 9, color: HFColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rupees(session.amount),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: HFColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                session.statusLabel,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .3,
                  color: HFColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

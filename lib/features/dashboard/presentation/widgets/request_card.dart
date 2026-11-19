import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/hf_card.dart';
import '../../domain/dashboard_summary.dart';

/// `.card > .request` — one waiting booking request, avatar then review link.
class RequestCard extends StatelessWidget {
  const RequestCard({super.key, required this.request, this.onReview});

  final BookingRequestPreview request;
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) {
    return HFCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: HFColors.avatarBg,
              shape: BoxShape.circle,
            ),
            child: Text(
              request.initials,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: HFColors.avatarInk,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  request.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: HFColors.ink,
                  ),
                ),
                Text(
                  request.subtitle,
                  style: const TextStyle(fontSize: 10, color: HFColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onReview,
            child: const Text(
              'Review ›',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: HFColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

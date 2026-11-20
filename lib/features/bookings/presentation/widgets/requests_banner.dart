import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tokens.dart';
import '../../data/bookings_providers.dart';

/// `.banner` on page 31, shown at the head of page 30 — the way in to the
/// §4.7 inbox. Renders nothing at all when no answer is owed, so the screen
/// does not carry a permanent empty strip.
class RequestsBanner extends ConsumerWidget {
  const RequestsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(bookingRequestsProvider).value?.length ?? 0;
    if (count == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.pushNamed('booking-requests'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: HFColors.statusBg,
            border: Border.all(color: HFColors.statusBorder),
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
                      count == 1
                          ? 'A request needs your attention'
                          : 'Requests need your attention',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: HFColors.statusTitle,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Respond promptly to secure the booking.',
                      style: TextStyle(fontSize: 9, color: HFColors.statusBody),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                count < 10 ? '0$count' : '$count',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: HFColors.primary,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: HFColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

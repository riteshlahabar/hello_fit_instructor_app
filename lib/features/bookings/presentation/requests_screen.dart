import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_list_pieces.dart';
import '../../../core/widgets/hf_pushed_page.dart';
import '../data/bookings_providers.dart';
import '../domain/booking_request.dart';
import 'widgets/request_card.dart';

/// Page 31 — New Booking Requests, the §4.7 inbox. Pushed from page 30's
/// banner and from the dashboard.
///
/// **The design's "All new / Personal / Online" chips are not here.** They
/// filtered on session format, and session format was deleted on 20-11-2026
/// (home-service only) — there is no column left to filter on and no second
/// axis in the payload worth inventing one from.
/// → `state/frontend/trainer-app.md`.
class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(bookingRequestsProvider);

    return HFPushedPage(
      backLabel: 'All Bookings',
      eyebrow: 'Take action on new leads',
      title: 'NEW BOOKING\nREQUESTS.',
      sub:
          'Check the details and respond to clients waiting for '
          'confirmation.',
      onRefresh: () async => ref.refresh(bookingRequestsProvider.future),
      children: [
        _Banner(count: requests.value?.length ?? 0),
        const SizedBox(height: 13),
        ...switch (requests) {
          AsyncLoading() => const [
            Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: CircularProgressIndicator(color: HFColors.primary),
              ),
            ),
          ],
          AsyncError(:final error) => [
            HFEmptyPanel(message: '$error'.replaceFirst('Exception: ', '')),
          ],
          AsyncValue(:final value?) when value.isEmpty => const [
            HFEmptyPanel(message: 'No new requests waiting on your answer.'),
          ],
          AsyncValue(:final value?) => [
            for (final request in value) ...[
              RequestCard(
                request: request,
                onDetails: () => context.pushNamed(
                  'booking-detail',
                  pathParameters: {'id': request.sessionId},
                ),
                onRespond: () => _respond(context, request),
              ),
              const SizedBox(height: 10),
            ],
          ],
        },
      ],
    );
  }

  /// "Respond" opens the accept screen, which is the decision the trainer is
  /// being asked for; declining is one tap further in, on page 33's own
  /// Decline button. The design's card has one Respond button, not two.
  void _respond(BuildContext context, BookingRequest request) {
    context.pushNamed('request-accept', pathParameters: {'id': request.id});
  }
}

/// `.banner` — the count strip. Shown even at zero on this screen, unlike the
/// one on page 30: an empty inbox is the answer the trainer came for.
class _Banner extends StatelessWidget {
  const _Banner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: HFColors.statusBg,
        border: Border.all(color: const Color(0xFFF2CABC)),
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
                  count == 0
                      ? 'Nothing waiting on you'
                      : 'Requests need your attention',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9A3D2C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count == 0
                      ? 'New requests will appear here as they arrive.'
                      : 'Respond promptly to secure the booking.',
                  style: const TextStyle(fontSize: 8, color: Color(0xFF9B6A5D)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            count < 10 ? '0$count' : '$count',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: HFColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

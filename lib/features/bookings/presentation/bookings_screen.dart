import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_list_pieces.dart';
import '../../../core/widgets/hf_search_field.dart';
import '../data/bookings_providers.dart';
import '../domain/booking_models.dart';
import 'widgets/booking_card.dart';
import 'widgets/requests_banner.dart';

/// Page 30 — All Bookings. The Bookings tab of the shell.
///
/// Page 37's Booking History is the same list under the Completed and
/// Cancelled chips, so it is not a second screen: the client's two HTML pages
/// differ only in which chip starts lit.
class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(bookingPageProvider);
    final filter = ref.watch(bookingFilterProvider);

    return RefreshIndicator(
      color: HFColors.primary,
      onRefresh: () async => ref.refresh(bookingPageProvider.future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          const _Heading(),
          HFCountTiles(
            tiles: [
              ('${page.value?.summary.total ?? 0}', 'Total bookings'),
              ('${page.value?.summary.upcoming ?? 0}', 'Upcoming'),
              ('${page.value?.summary.pending ?? 0}', 'Pending'),
            ],
          ),
          const SizedBox(height: 12),
          const RequestsBanner(),
          HFSearchField(
            hint: 'Search client, service or code',
            onChanged: (value) =>
                ref.read(bookingQueryProvider.notifier).set(value),
          ),
          const SizedBox(height: 11),
          HFFilterChips<BookingFilter>(
            values: BookingFilter.values,
            labelOf: (value) => value.label,
            selected: filter,
            onSelect: (value) =>
                ref.read(bookingFilterProvider.notifier).set(value),
          ),
          const SizedBox(height: 12),
          ...switch (page) {
            AsyncLoading() => const [
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: CircularProgressIndicator(color: HFColors.primary),
                ),
              ),
            ],
            AsyncError(:final error) => [
              HFEmptyPanel(message: '$error'),
            ],
            AsyncValue(:final value?) when value.rows.isEmpty => const [
              HFEmptyPanel(
                message: 'No bookings match your search or selected filter.',
              ),
            ],
            AsyncValue(:final value?) => [
              for (final row in value.rows) ...[
                BookingCard(
                  row: row,
                  onTap: () => context.pushNamed(
                    'booking-detail',
                    pathParameters: {'id': row.sessionId},
                  ),
                ),
                const SizedBox(height: 9),
              ],
            ],
          },
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'YOUR TRAINING CALENDAR',
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              color: HFColors.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text('ALL BOOKINGS.', style: AppTheme.display(29)),
          const SizedBox(height: 4),
          const Text(
            'Manage every client booking from one place.',
            style: TextStyle(fontSize: 11, color: HFColors.muted),
          ),
        ],
      ),
    );
  }
}

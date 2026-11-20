import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_list_pieces.dart';
import '../../../core/widgets/hf_refresh.dart';
import '../../../core/widgets/hf_search_field.dart';
import '../data/clients_providers.dart';
import '../domain/client_models.dart';
import 'widgets/client_card.dart';

/// Page 38 — My Clients. The shell's third tab.
///
/// **No "+ Add" button**, though the design has one: a client is a customer
/// the platform assigned to this trainer, folded out of `BookingSession`.
/// There is no client table to insert into, and a trainer creating a customer
/// account would be a second, unverified front door into `User` — so page 44
/// is not built. → `state/frontend/trainer-app.md`.
class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(clientPageProvider);
    final filter = ref.watch(clientFilterProvider);
    final summary = page.value?.summary ?? ClientSummary.empty;

    return HFRefreshList(
      onRefresh: () => ref.refresh(clientPageProvider.future),
      children: [
        const _Heading(),
        HFCountTiles(
          tiles: [
            ('${summary.all}', 'All clients'),
            ('${summary.active}', 'Active'),
            ('${summary.inactive}', 'Inactive'),
          ],
        ),
        const SizedBox(height: 12),
        HFSearchField(
          hint: 'Search client or service',
          onChanged: (value) =>
              ref.read(clientQueryProvider.notifier).set(value),
        ),
        const SizedBox(height: 11),
        HFFilterChips<ClientFilter>(
          values: ClientFilter.values,
          labelOf: (value) => value.label,
          selected: filter,
          onSelect: (value) =>
              ref.read(clientFilterProvider.notifier).set(value),
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
            HFEmptyPanel(message: '$error'.replaceFirst('Exception: ', '')),
          ],
          AsyncValue(:final value?) when value.rows.isEmpty => const [
            HFEmptyPanel(
              message: 'No clients match your search or selected filter.',
            ),
          ],
          AsyncValue(:final value?) => [
            _Count(shown: value.rows.length),
            for (final client in value.rows) ...[
              ClientCard(
                client: client,
                onTap: () => context.pushNamed(
                  'client-profile',
                  pathParameters: {'id': client.id},
                ),
              ),
              const SizedBox(height: 9),
            ],
          ],
        },
      ],
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
          const Text(
            'YOUR FITNESS COMMUNITY',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              color: HFColors.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text('MY CLIENTS.', style: AppTheme.display(29)),
          const SizedBox(height: 4),
          const Text(
            'Manage your client relationships and view their activity.',
            style: TextStyle(fontSize: 11, height: 1.5, color: HFColors.muted),
          ),
        ],
      ),
    );
  }
}

/// `.listhead` — "Client list · 6 shown".
class _Count extends StatelessWidget {
  const _Count({required this.shown});

  final int shown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        'Client list · $shown shown',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: .3,
          color: HFColors.muted,
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../../../core/state/ui_state.dart';
import '../../auth/data/auth_providers.dart';
import '../domain/client_models.dart';
import '../domain/clients_repository.dart';
import 'api_clients_repository.dart';

final clientsRepositoryProvider = Provider<ClientsRepository>(
  (ref) => ApiClientsRepository(ref.watch(apiClientProvider)),
);

final clientFilterProvider =
    NotifierProvider<UiState<ClientFilter>, ClientFilter>(
      () => UiState(ClientFilter.all),
    );

final clientQueryProvider = NotifierProvider<UiState<String>, String>(
  () => UiState(''),
);

/// Page 38. Both the chip and the search box are server-side filters, so the
/// list is a single watched call rather than a local `where`.
final clientPageProvider = FutureProvider<ClientPage>((ref) async {
  final result = await ref
      .watch(clientsRepositoryProvider)
      .list(
        filter: ref.watch(clientFilterProvider),
        query: ref.watch(clientQueryProvider),
      );

  return switch (result) {
    ApiSuccess(:final data) => data,
    ApiFailure(:final message) => throw Exception(message),
  };
});

/// Page 39.
final clientProfileProvider = FutureProvider.family<ClientProfile, String>((
  ref,
  customerId,
) async {
  final result = await ref.watch(clientsRepositoryProvider).detail(customerId);

  return switch (result) {
    ApiSuccess(:final data) => data,
    ApiFailure(:final message) => throw Exception(message),
  };
});

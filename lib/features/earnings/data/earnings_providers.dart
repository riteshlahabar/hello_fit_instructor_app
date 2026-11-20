import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/state/ui_state.dart';
import '../../auth/data/auth_providers.dart';
import '../domain/earnings_models.dart';
import '../domain/earnings_repository.dart';

/// Talks to `/app/instructor/earnings/summary`. Small enough to live beside
/// its provider — one route, one shape, no branching.
class ApiEarningsRepository implements EarningsRepository {
  const ApiEarningsRepository(this._api);

  final ApiClient _api;

  @override
  Future<ApiResult<EarningsSummary>> summary(EarningsPeriod period) => _api.get(
    '/app/instructor/earnings/summary',
    query: {'period': period.name},
    parse: (data) => EarningsSummary.fromJson(data as Map<String, dynamic>),
  );
}

final earningsRepositoryProvider = Provider<EarningsRepository>(
  (ref) => ApiEarningsRepository(ref.watch(apiClientProvider)),
);

/// Which chip is lit on page 57.
final earningsPeriodProvider =
    NotifierProvider<UiState<EarningsPeriod>, EarningsPeriod>(
      () => UiState(EarningsPeriod.month),
    );

final earningsSummaryProvider = FutureProvider<EarningsSummary>((ref) async {
  final result = await ref
      .watch(earningsRepositoryProvider)
      .summary(ref.watch(earningsPeriodProvider));

  return switch (result) {
    ApiSuccess(:final data) => data,
    ApiFailure(:final message) => throw Exception(message),
  };
});

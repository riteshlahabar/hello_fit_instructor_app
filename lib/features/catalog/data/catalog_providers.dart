import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../auth/data/auth_providers.dart';
import '../domain/service_category.dart';

/// The live `ServiceCategory` master behind page 15's specialty tiles
/// (client, 19-11-2026).
///
/// `GET /categories` is public and already returns only active rows in
/// `sortOrder`, so there is no trainer-specific route to add — the website
/// and the customer app read the same list.
abstract class CatalogRepository {
  Future<ApiResult<List<ServiceCategory>>> categories();
}

class ApiCatalogRepository implements CatalogRepository {
  ApiCatalogRepository(this._api);

  final ApiClient _api;

  @override
  Future<ApiResult<List<ServiceCategory>>> categories() =>
      _api.get<List<ServiceCategory>>(
        '/categories',
        skipAuth: true,
        parse: (data) => (data as List<dynamic>)
            .map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => ApiCatalogRepository(ref.watch(apiClientProvider)),
);

/// Read once per screen open. A failure surfaces on the tile list rather than
/// being swallowed: with no categories there is nothing to pick, and the
/// submit gate still demands at least one specialisation.
final serviceCategoriesProvider = FutureProvider<List<ServiceCategory>>((
  ref,
) async {
  final result = await ref.watch(catalogRepositoryProvider).categories();
  return switch (result) {
    ApiSuccess(:final data) => data,
    ApiFailure(:final message) => throw Exception(message),
  };
});

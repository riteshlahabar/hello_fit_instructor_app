import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../domain/client_models.dart';
import '../domain/clients_repository.dart';

/// Talks to `/app/instructor/clients`.
class ApiClientsRepository implements ClientsRepository {
  const ApiClientsRepository(this._api);

  final ApiClient _api;

  static List<TrainerClient> _rows(dynamic data) => switch (data) {
    final List<dynamic> list =>
      list
          .map((e) => TrainerClient.fromJson(e as Map<String, dynamic>))
          .toList(),
    _ => const [],
  };

  @override
  Future<ApiResult<ClientPage>> list({
    ClientFilter filter = ClientFilter.all,
    String? query,
  }) async {
    final result = await _api.get<List<TrainerClient>>(
      '/app/instructor/clients',
      query: {
        if (filter != ClientFilter.all) 'status': filter.name,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      },
      parse: _rows,
    );

    return switch (result) {
      ApiSuccess(:final data, :final meta) => ApiSuccess(
        ClientPage(
          rows: data,
          summary: ClientSummary.fromJson(
            meta?['summary'] as Map<String, dynamic>?,
          ),
        ),
      ),
      ApiFailure(
        :final code,
        :final message,
        :final details,
        :final statusCode,
      ) =>
        ApiFailure<ClientPage>(
          code: code,
          message: message,
          details: details,
          statusCode: statusCode,
        ),
    };
  }

  @override
  Future<ApiResult<ClientProfile>> detail(String customerId) => _api.get(
    '/app/instructor/clients/$customerId',
    parse: (data) => ClientProfile.fromJson(data as Map<String, dynamic>),
  );
}

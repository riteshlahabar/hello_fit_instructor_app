import '../../../core/network/api_result.dart';
import 'client_models.dart';

/// Pages 38 and 39. Read-only by design: a trainer never creates a client.
abstract interface class ClientsRepository {
  Future<ApiResult<ClientPage>> list({ClientFilter filter, String? query});

  Future<ApiResult<ClientProfile>> detail(String customerId);
}

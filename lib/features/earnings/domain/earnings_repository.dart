import '../../../core/network/api_result.dart';
import 'earnings_models.dart';

/// Page 57. The session-wise rows behind page 58 stay on the older
/// `GET /app/instructor/earnings`, which this does not duplicate.
abstract interface class EarningsRepository {
  Future<ApiResult<EarningsSummary>> summary(EarningsPeriod period);
}

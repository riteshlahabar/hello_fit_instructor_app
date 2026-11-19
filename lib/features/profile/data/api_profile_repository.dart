import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../domain/bank_account.dart';
import '../domain/instructor_profile.dart';
import '../domain/profile_repository.dart';

/// Talks to `/app/instructor/*`.
class ApiProfileRepository implements ProfileRepository {
  const ApiProfileRepository(this._api);

  final ApiClient _api;

  static InstructorProfile _profile(dynamic data) =>
      InstructorProfile.fromJson(data as Map<String, dynamic>);

  static List<InstructorDocument> _documents(dynamic data) => switch (data) {
    final List<dynamic> list => list
        .map((e) => InstructorDocument.fromJson(e as Map<String, dynamic>))
        .toList(),
    _ => const [],
  };

  @override
  Future<ApiResult<InstructorProfile>> apply({
    required String name,
    String? gender,
    int? experienceYears,
  }) => _api.post(
    '/app/instructor/apply',
    body: {
      'name': name,
      'gender': ?gender,
      'experienceYears': ?experienceYears,
    },
    parse: _profile,
  );

  /// Two calls: the profile, then its documents. The profile route does not
  /// embed them, and every screen that shows a checklist needs both.
  @override
  Future<ApiResult<InstructorProfile>> load() async {
    final profile = await _api.get('/app/instructor/profile', parse: _profile);
    if (profile case ApiSuccess(:final data)) {
      final docs = await _api.get(
        '/app/instructor/documents',
        parse: _documents,
      );
      return ApiSuccess(data.withDocuments(docs.valueOrNull ?? const []));
    }
    return profile;
  }

  @override
  Future<ApiResult<InstructorProfile>> update(Map<String, dynamic> changes) =>
      _api.patch('/app/instructor/profile', body: changes, parse: _profile);

  @override
  Future<ApiResult<InstructorDocument>> uploadDocument({
    required String filePath,
    required String docType,
    String? number,
    String? issueDate,
    String? expiryDate,
  }) => _api.upload(
    '/app/instructor/documents',
    filePath: filePath,
    fields: {
      'docType': docType,
      if (number != null && number.isNotEmpty) 'number': number,
      'issueDate': ?issueDate,
      'expiryDate': ?expiryDate,
    },
    parse: (data) => InstructorDocument.fromJson(data as Map<String, dynamic>),
  );

  @override
  Future<ApiResult<void>> deleteDocument(String documentId) =>
      _api.delete('/app/instructor/documents/$documentId');

  @override
  Future<ApiResult<void>> acceptCodeOfConduct() =>
      _api.post('/app/instructor/code-of-conduct');

  @override
  Future<ApiResult<InstructorProfile>> submitForReview() =>
      _api.post('/app/instructor/submit', parse: _profile);

  @override
  Future<ApiResult<BankAccount?>> loadBankAccount() => _api.get(
    '/app/instructor/bank-account',
    parse: (data) => data == null
        ? null
        : BankAccount.fromJson(data as Map<String, dynamic>),
  );

  @override
  Future<ApiResult<BankAccount>> saveBankAccount({
    required String payoutMethod,
    String? holderName,
    String? bankName,
    String? accountNumber,
    String? ifsc,
    String? accountType,
    String? upiId,
  }) => _api.put(
    '/app/instructor/bank-account',
    // Only the chosen side is sent. The DTO requires exactly that side and
    // the service nulls the other, so sending both would be meaningless.
    body: payoutMethod == 'UPI'
        ? {'payoutMethod': 'UPI', 'upiId': upiId}
        : {
            'payoutMethod': 'BANK',
            'holderName': holderName,
            'bankName': bankName,
            'accountNumber': accountNumber,
            'ifsc': ifsc,
            'accountType': accountType,
          },
    parse: (data) => BankAccount.fromJson(data as Map<String, dynamic>),
  );
}

import '../../../core/network/api_result.dart';
import 'bank_account.dart';
import 'instructor_profile.dart';

/// Everything the onboarding wizard and the Profile tab need.
///
/// Mirrors `/app/instructor/*` one call per route; nothing above this layer
/// knows a path or an HTTP verb.
abstract interface class ProfileRepository {
  /// `POST /app/instructor/apply` — starts the application. Deliberately
  /// minimal: the long profile is a PATCH afterwards.
  Future<ApiResult<InstructorProfile>> apply({
    required String name,
    String? gender,
    int? experienceYears,
  });

  /// `GET /app/instructor/profile`, documents included.
  Future<ApiResult<InstructorProfile>> load();

  /// `PATCH /app/instructor/profile`. Only the keys passed are sent.
  Future<ApiResult<InstructorProfile>> update(Map<String, dynamic> changes);

  /// `POST /app/instructor/documents` — multipart.
  Future<ApiResult<InstructorDocument>> uploadDocument({
    required String filePath,
    required String docType,
    String? number,
    String? issueDate,
    String? expiryDate,
  });

  /// `DELETE /app/instructor/documents/:id`
  Future<ApiResult<void>> deleteDocument(String documentId);

  /// `POST /app/instructor/code-of-conduct`
  Future<ApiResult<void>> acceptCodeOfConduct();

  /// `POST /app/instructor/submit` — refused with reasons when short.
  Future<ApiResult<InstructorProfile>> submitForReview();

  /// `GET /app/instructor/bank-account` — null until one is saved.
  Future<ApiResult<BankAccount?>> loadBankAccount();

  /// `PUT /app/instructor/bank-account`. A whole-body replace, never a patch:
  /// a new number against an old IFSC would route money to a real but wrong
  /// branch.
  /// UPI or bank, never both (client, 19-11-2026): the side not chosen is
  /// cleared by the server, so a switch leaves no stale account behind.
  Future<ApiResult<BankAccount>> saveBankAccount({
    required String payoutMethod,
    String? holderName,
    String? bankName,
    String? accountNumber,
    String? ifsc,
    String? accountType,
    String? upiId,
  });
}

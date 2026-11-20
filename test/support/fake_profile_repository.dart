import 'package:trainer_app/core/network/api_result.dart';
import 'package:trainer_app/features/profile/domain/bank_account.dart';
import 'package:trainer_app/features/profile/domain/instructor_profile.dart';
import 'package:trainer_app/features/profile/domain/profile_contact.dart';
import 'package:trainer_app/features/profile/domain/profile_repository.dart';

/// Stands in for the HTTP repository in widget tests.
///
/// The shell builds every tab through an `IndexedStack`, so the Profile tab is
/// constructed even while Home is showing. Without this the profile read goes
/// to a real socket and `pumpAndSettle` never settles on the spinner.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({this.stage = 'APPROVED'});

  final String stage;

  InstructorProfile get _profile => InstructorProfile(
    name: 'Tejas Joshi',
    email: 'tejas@example.com',
    experienceYears: 6,
    languages: const ['English'],
    specialisations: const ['Yoga'],
    travelRadiusKm: 12,
    gender: 'MALE',
    dob: DateTime(1994, 3, 2),
    onboarding: OnboardingStatus(
      stage: stage,
      progressPercent: 100,
      requiredDocuments: const ['PHOTO'],
      missingDocuments: const [],
      missingProfileFields: const [],
      codeOfConductAccepted: true,
      canSubmit: true,
      blockedBy: const [],
    ),
    documents: const [],
    contact: const ProfileContact(
      addressLine: '14 Hill Road',
      city: 'Pune',
      state: 'Maharashtra',
      pincode: '411038',
      qualification: 'Certified Personal Trainer',
      clientsTrainedBand: '26-50',
      serviceLocality: 'Kothrud',
    ),
  );

  @override
  Future<ApiResult<InstructorProfile>> apply({
    required String name,
    String? gender,
    int? experienceYears,
  }) async => ApiSuccess(_profile);

  @override
  Future<ApiResult<InstructorProfile>> load() async => ApiSuccess(_profile);

  @override
  Future<ApiResult<InstructorProfile>> update(
    Map<String, dynamic> changes,
  ) async => ApiSuccess(_profile);

  @override
  Future<ApiResult<InstructorDocument>> uploadDocument({
    required String filePath,
    required String docType,
    String? number,
    String? issueDate,
    String? expiryDate,
  }) async => const ApiSuccess(
    InstructorDocument(id: 'd1', docType: 'PHOTO', verified: true),
  );

  @override
  Future<ApiResult<void>> deleteDocument(String documentId) async =>
      const ApiSuccess(null);

  @override
  Future<ApiResult<void>> acceptCodeOfConduct() async => const ApiSuccess(null);

  @override
  Future<ApiResult<InstructorProfile>> submitForReview() async =>
      ApiSuccess(_profile);

  @override
  Future<ApiResult<BankAccount?>> loadBankAccount() async =>
      const ApiSuccess(null);

  @override
  Future<ApiResult<BankAccount>> saveBankAccount({
    required String payoutMethod,
    String? holderName,
    String? bankName,
    String? accountNumber,
    String? ifsc,
    String? accountType,
    String? upiId,
  }) async => throw UnimplementedError();
}

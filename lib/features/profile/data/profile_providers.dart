import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../../auth/data/auth_providers.dart';
import '../domain/instructor_profile.dart';
import '../domain/profile_repository.dart';
import 'api_profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ApiProfileRepository(ref.watch(apiClientProvider)),
);

/// The trainer's own profile. Every onboarding screen reads this and calls
/// [ProfileController.save] rather than touching the repository itself.
class ProfileController extends AsyncNotifier<InstructorProfile?> {
  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  @override
  Future<InstructorProfile?> build() async {
    final result = await _repo.load();
    return switch (result) {
      ApiSuccess(:final data) => data,
      // A person who has not applied yet has no profile; that is not an error.
      ApiFailure() => null,
    };
  }

  Future<ApiResult<InstructorProfile>> apply({
    required String name,
    String? gender,
    int? experienceYears,
  }) => _run(
    () => _repo.apply(
      name: name,
      gender: gender,
      experienceYears: experienceYears,
    ),
  );

  Future<ApiResult<InstructorProfile>> save(Map<String, dynamic> changes) =>
      _run(() => _repo.update(changes));

  Future<ApiResult<InstructorProfile>> submitForReview() =>
      _run(_repo.submitForReview);

  Future<ApiResult<void>> acceptCodeOfConduct() async {
    final result = await _repo.acceptCodeOfConduct();
    if (result.isSuccess) await refresh();
    return result;
  }

  Future<ApiResult<InstructorDocument>> uploadDocument({
    required String filePath,
    required String docType,
    String? number,
    String? issueDate,
    String? expiryDate,
  }) async {
    final result = await _repo.uploadDocument(
      filePath: filePath,
      docType: docType,
      number: number,
      issueDate: issueDate,
      expiryDate: expiryDate,
    );
    if (result.isSuccess) await refresh();
    return result;
  }

  Future<ApiResult<void>> deleteDocument(String id) async {
    final result = await _repo.deleteDocument(id);
    if (result.isSuccess) await refresh();
    return result;
  }

  Future<void> refresh() async {
    state = AsyncData(await _repo.load().then((r) => r.valueOrNull));
  }

  /// Runs a write, then puts the returned profile straight into state so the
  /// next screen does not have to re-fetch.
  Future<ApiResult<InstructorProfile>> _run(
    Future<ApiResult<InstructorProfile>> Function() call,
  ) async {
    final result = await call();
    if (result case ApiSuccess(:final data)) {
      // The write routes answer without documents; keep the ones we hold.
      state = AsyncData(data.withDocuments(state.value?.documents ?? const []));
    }
    return result;
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, InstructorProfile?>(
      ProfileController.new,
    );

/// Where a signed-in trainer belongs on launch.
///
/// A profile row is not enough: an application that is still in review, or was
/// rejected, belongs in the wizard. Only an approved trainer reaches the shell.
///
/// Never throws. The splash waits on this before it navigates, so an error
/// here would leave the app on the splash screen for good; the wizard is the
/// safe answer, and it shows the real status once the profile call succeeds.
final landingRouteProvider = FutureProvider<String>((ref) async {
  try {
    final profile = await ref.watch(profileControllerProvider.future);
    final approved = profile?.onboarding.isApproved ?? false;
    return approved ? '/' : '/onboarding/profile';
  } catch (_) {
    return '/onboarding/profile';
  }
});

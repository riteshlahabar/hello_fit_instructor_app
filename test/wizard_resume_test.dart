import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_app/features/onboarding/domain/wizard_resume.dart';
import 'package:trainer_app/features/profile/domain/instructor_profile.dart';
import 'package:trainer_app/features/profile/domain/profile_contact.dart';

OnboardingStatus _status({List<String> missingDocs = const []}) =>
    OnboardingStatus(
      stage: 'APPLIED',
      progressPercent: 40,
      requiredDocuments: const ['PHOTO'],
      missingDocuments: missingDocs,
      missingProfileFields: const [],
      codeOfConductAccepted: false,
      canSubmit: false,
      blockedBy: const [],
    );

/// A profile filled up to and including [upto] steps of the wizard, where 0 is
/// a bare application and 6 is everything but the bank page.
InstructorProfile profile(int upto) => InstructorProfile(
  name: upto >= 1 ? 'Tejas Joshi' : '',
  gender: upto >= 1 ? 'MALE' : null,
  dob: upto >= 1 ? DateTime(1994, 3, 2) : null,
  experienceYears: upto >= 3 ? 6 : 0,
  languages: const [],
  specialisations: upto >= 4 ? const ['Yoga'] : const [],
  travelRadiusKm: upto >= 6 ? 12 : null,
  onboarding: _status(missingDocs: upto >= 5 ? const [] : const ['PHOTO']),
  documents: const [],
  contact: ProfileContact(
    addressLine: upto >= 2 ? '14 Hill Road' : null,
    city: upto >= 2 ? 'Pune' : null,
    state: upto >= 2 ? 'Maharashtra' : null,
    pincode: upto >= 2 ? '411038' : null,
    qualification: upto >= 3 ? 'Certified Personal Trainer' : null,
    clientsTrainedBand: upto >= 3 ? '26-50' : null,
    serviceLocality: upto >= 6 ? 'Kothrud' : null,
  ),
);

void main() {
  group('where a half-finished applicant resumes', () {
    test('no profile at all starts at page 12', () {
      expect(wizardResumeRoute(null), '/onboarding/profile');
    });

    test('each unfinished step is the one offered', () {
      // Client, 20-11-2026: skip what is filled, show the next screen.
      const expected = [
        '/onboarding/profile',
        '/onboarding/personal',
        '/onboarding/professional',
        '/onboarding/specialisation',
        '/onboarding/documents',
        '/onboarding/service-area',
        '/onboarding/bank',
      ];
      for (var filled = 0; filled < expected.length; filled++) {
        expect(
          wizardResumeRoute(profile(filled)),
          expected[filled],
          reason: '$filled step(s) filled should resume at ${expected[filled]}',
        );
      }
    });

    test('everything but the bank page lands on the bank page', () {
      expect(wizardResumeRoute(profile(6)), '/onboarding/bank');
    });

    test('the order matches the wizard, not the route table', () {
      expect(wizardOrder.first, '/onboarding/profile');
      expect(wizardOrder.last, '/onboarding/bank');
      expect(wizardOrder.length, 7);
    });
  });
}

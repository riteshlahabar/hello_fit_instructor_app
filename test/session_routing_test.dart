import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_app/features/auth/domain/app_session.dart';

AppSession session({bool profile = false, String? stage}) => AppSession(
  userId: 'u1',
  mobile: '9000000001',
  roles: const ['CUSTOMER'],
  isNewAccount: false,
  hasInstructorProfile: profile,
  instructorOnboardingStage: stage,
);

void main() {
  group('where sign-in lands', () {
    test('a brand new account applies first', () {
      expect(session().needsApplication, isTrue);
    });

    test('an unsubmitted application goes back to the wizard', () {
      // APPLIED is what `POST apply` leaves behind; `submit` moves it on. So
      // this is the one state that is genuinely mid-registration.
      expect(session(profile: true, stage: 'APPLIED').needsApplication, isTrue);
    });

    test('a submitted application waiting on review lands home', () {
      // The bug fixed on 20-11-2026: `submit` leaves the stage at
      // DOCUMENTS_SUBMITTED and only an admin sets APPROVED, so asking for
      // APPROVED sent every waiting trainer back to page 12 at each login.
      for (final stage in [
        'DOCUMENTS_SUBMITTED',
        'SCREENING_CALL',
        'DEMO_SESSION',
      ]) {
        expect(
          session(profile: true, stage: stage).needsApplication,
          isFalse,
          reason: '$stage is submitted and belongs on the home screen',
        );
      }
    });

    test('a rejected application lands home, with the banner', () {
      expect(
        session(profile: true, stage: 'REJECTED').needsApplication,
        isFalse,
      );
    });

    test('an approved trainer lands home', () {
      expect(
        session(profile: true, stage: 'APPROVED').needsApplication,
        isFalse,
      );
    });
  });
}

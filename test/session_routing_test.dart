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

    test('a half-finished application goes back to the wizard', () {
      // The bug: a profile row existed, so sign-in sent an APPLIED trainer
      // to the shell and the wizard became unreachable.
      expect(
        session(profile: true, stage: 'APPLIED').needsApplication,
        isTrue,
      );
    });

    test('a rejected application goes back to the wizard', () {
      expect(
        session(profile: true, stage: 'REJECTED').needsApplication,
        isTrue,
      );
    });

    test('only an approved trainer reaches the shell', () {
      expect(
        session(profile: true, stage: 'APPROVED').needsApplication,
        isFalse,
      );
    });
  });
}

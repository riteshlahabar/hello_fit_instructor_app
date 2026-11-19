import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_app/features/profile/domain/instructor_profile.dart';

OnboardingStatus status({
  required bool coc,
  List<String> docs = const [],
  List<String> fields = const [],
}) => OnboardingStatus(
  stage: 'APPLIED',
  progressPercent: 80,
  requiredDocuments: const ['PHOTO'],
  missingDocuments: docs,
  missingProfileFields: fields,
  codeOfConductAccepted: coc,
  // What the API says: false until the code of conduct is accepted.
  canSubmit: coc && docs.isEmpty && fields.isEmpty,
  blockedBy: [
    if (fields.isNotEmpty) 'Complete your profile: ${fields.join(', ')}',
    if (docs.isNotEmpty) 'Upload these documents: ${docs.join(', ')}',
    if (!coc) 'Accept the code of conduct',
  ],
);

void main() {
  group('submit gate', () {
    test('an otherwise complete application can press Submit', () {
      // The deadlock: canSubmit is false purely because accepting the code of
      // conduct is part of pressing the button it was disabling.
      final s = status(coc: false);
      expect(s.canSubmit, isFalse);
      expect(s.readyApartFromCodeOfConduct, isTrue);
    });

    test('a missing document still blocks the button', () {
      expect(status(coc: false, docs: ['PAN']).readyApartFromCodeOfConduct,
          isFalse);
    });

    test('a missing profile field still blocks the button', () {
      expect(status(coc: false, fields: ['bio']).readyApartFromCodeOfConduct,
          isFalse);
    });

    test('the code-of-conduct reason is hidden, the real ones are not', () {
      final s = status(coc: false, docs: ['PAN']);
      expect(s.blockersToShow, ['Upload these documents: PAN']);
    });

    test('once accepted, nothing is filtered out', () {
      final s = status(coc: true, docs: ['PAN']);
      expect(s.blockersToShow, s.blockedBy);
    });
  });
}

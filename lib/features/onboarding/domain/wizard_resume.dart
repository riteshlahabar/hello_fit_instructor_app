import '../../profile/domain/instructor_profile.dart';

/// Where a half-finished applicant belongs in the wizard.
///
/// Client, 20-11-2026: "if applicant is mid-registration then skip the
/// registration which information fill up and show next registration screen."
/// So an applicant who comes back does not retype page 12 — they land on the
/// first page they have not filled yet.
///
/// The order is the wizard's own `context.push` chain, not the route table's,
/// which is alphabetical by accident.
const wizardOrder = <String>[
  '/onboarding/profile',
  '/onboarding/personal',
  '/onboarding/professional',
  '/onboarding/specialisation',
  '/onboarding/documents',
  '/onboarding/service-area',
  '/onboarding/bank',
];

bool _blank(String? value) => value == null || value.trim().isEmpty;

/// Page 12 — name, gender, date of birth.
bool _profileDone(InstructorProfile p) =>
    !_blank(p.name) && !_blank(p.gender) && p.dob != null;

/// Page 13 — the postal address. `landmark` is optional on the screen, so it
/// is not a gate; `pincode` is, because the screen validates it.
bool _personalDone(InstructorProfile p) =>
    !_blank(p.contact.addressLine) &&
    !_blank(p.contact.city) &&
    !_blank(p.contact.state) &&
    !_blank(p.contact.pincode);

/// Page 14 — professional background.
bool _professionalDone(InstructorProfile p) =>
    !_blank(p.contact.qualification) &&
    !_blank(p.contact.clientsTrainedBand) &&
    p.experienceYears > 0;

/// Page 15 — at least one speciality.
bool _specialisationDone(InstructorProfile p) => p.specialisations.isNotEmpty;

/// Page 16 — every document the API says is required is uploaded.
bool _documentsDone(InstructorProfile p) =>
    p.onboarding.missingDocuments.isEmpty;

/// Page 18 — base locality and travel radius.
bool _serviceAreaDone(InstructorProfile p) =>
    !_blank(p.contact.serviceLocality) && (p.travelRadiusKm ?? 0) > 0;

/// The first wizard page this applicant has not finished.
///
/// Page 20 (bank) is the last resume target: whether an account is on file
/// takes a second request, and the bank screen already renders the saved
/// account when there is one, so landing there costs an approved trainer
/// nothing and never strands an unfinished one.
String wizardResumeRoute(InstructorProfile? profile) {
  if (profile == null) return wizardOrder.first;

  final done = <bool>[
    _profileDone(profile),
    _personalDone(profile),
    _professionalDone(profile),
    _specialisationDone(profile),
    _documentsDone(profile),
    _serviceAreaDone(profile),
  ];

  for (var i = 0; i < done.length; i++) {
    if (!done[i]) return wizardOrder[i];
  }
  return '/onboarding/bank';
}

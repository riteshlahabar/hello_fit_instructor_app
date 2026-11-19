/// The two fixed dropdowns on page 14. Lists, not free text, because the
/// admin trainer table filters and groups on them.
///
/// Years of experience is **not** here: the client made it a plain number box
/// on 19-11-2026, so there is no band list any more.
class ProfessionalOptions {
  const ProfessionalOptions._();

  /// Stored verbatim: `clientsTrainedBand` is a string for exactly this.
  static const clients = {
    '1-10': '1–10',
    '11-25': '11–25',
    '26-50': '26–50',
    '51-100': '51–100',
    '100+': '100+',
  };

  static const qualifications = {
    'Certified Personal Trainer': 'Certified Personal Trainer',
    'Diploma in Fitness Training': 'Diploma in Fitness Training',
    'Degree in Sports Science': 'Degree in Sports Science',
    'Physical Education': 'Physical Education',
    'Other recognised qualification': 'Other recognised qualification',
  };
}

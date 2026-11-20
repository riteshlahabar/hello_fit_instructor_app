import 'package:flutter/foundation.dart';

import '../../../core/dates/app_date.dart';
import 'profile_contact.dart';

/// One uploaded KYC or certificate file.
@immutable
class InstructorDocument {
  const InstructorDocument({
    required this.id,
    required this.docType,
    required this.verified,
    this.number,
    this.expiryDate,
  });

  factory InstructorDocument.fromJson(Map<String, dynamic> json) =>
      InstructorDocument(
        id: json['id'] as String,
        docType: '${json['docType']}',
        verified: json['verifiedAt'] != null,
        number: json['number'] as String?,
        expiryDate: parseApiDate(json['expiryDate']),
      );

  final String id;
  final String docType;
  final bool verified;
  final String? number;
  final DateTime? expiryDate;
}

/// The `onboarding` block `instructor.service.ts` decorates every profile
/// response with — the checklist pages 21 and 22 render.
@immutable
class OnboardingStatus {
  const OnboardingStatus({
    required this.stage,
    required this.progressPercent,
    required this.requiredDocuments,
    required this.missingDocuments,
    required this.missingProfileFields,
    required this.codeOfConductAccepted,
    required this.canSubmit,
    required this.blockedBy,
  });

  factory OnboardingStatus.fromJson(Map<String, dynamic> json) =>
      OnboardingStatus(
        stage: '${json['stage']}',
        progressPercent: (json['progressPercent'] as num?)?.toInt() ?? 0,
        requiredDocuments: _strings(json['requiredDocuments']),
        missingDocuments: _strings(json['missingDocuments']),
        missingProfileFields: _strings(json['missingProfileFields']),
        codeOfConductAccepted: json['codeOfConductAccepted'] as bool? ?? false,
        canSubmit: json['canSubmit'] as bool? ?? false,
        blockedBy: _strings(json['blockedBy']),
      );

  final String stage;
  final int progressPercent;
  final List<String> requiredDocuments;
  final List<String> missingDocuments;
  final List<String> missingProfileFields;
  final bool codeOfConductAccepted;
  final bool canSubmit;
  final List<String> blockedBy;

  /// `canSubmit` stays false until the code of conduct is accepted — but
  /// accepting it is the first half of pressing Submit, so gating the button
  /// on `canSubmit` deadlocks: the button can never run the code that unlocks
  /// the button. This is everything the applicant must finish on their own.
  bool get readyApartFromCodeOfConduct =>
      canSubmit || (missingDocuments.isEmpty && missingProfileFields.isEmpty);

  /// The code-of-conduct reason is the checkbox directly above the button, so
  /// listing it under "still needed" reads as a blocker with nowhere to go.
  List<String> get blockersToShow => codeOfConductAccepted
      ? blockedBy
      : blockedBy.where((r) => !r.startsWith('Accept the code')).toList();

  bool get isApproved => stage == 'APPROVED';
  bool get isRejected => stage == 'REJECTED';
}

/// The trainer's own profile, as `GET /app/instructor/profile` returns it.
@immutable
class InstructorProfile {
  const InstructorProfile({
    required this.name,
    required this.experienceYears,
    required this.languages,
    required this.specialisations,
    required this.onboarding,
    required this.documents,
    required this.contact,
    this.bio,
    this.email,
    this.gender,
    this.dob,
    this.travelRadiusKm,
  });

  factory InstructorProfile.fromJson(
    Map<String, dynamic> json, {
    List<InstructorDocument> documents = const [],
  }) => InstructorProfile(
    name: '${json['name']}',
    experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
    languages: _strings(json['languages']),
    specialisations: _strings(json['specialisations']),
    onboarding: OnboardingStatus.fromJson(
      (json['onboarding'] as Map<String, dynamic>?) ?? const {},
    ),
    contact: ProfileContact.fromJson(json),
    documents: documents,
    bio: json['bio'] as String?,
    email: json['email'] as String?,
    gender: json['gender'] as String?,
    dob: parseApiDate(json['dob']),
    travelRadiusKm: (json['travelRadiusKm'] as num?)?.toInt(),
  );

  final String name;
  final int experienceYears;
  final List<String> languages;
  final List<String> specialisations;
  final OnboardingStatus onboarding;
  final List<InstructorDocument> documents;

  /// The address and professional-background columns (19 Nov 2026).
  final ProfileContact contact;

  /// A User column, flattened onto the own-profile response so page 66's box
  /// can show the address already on file (client, 20-11-2026).
  final String? email;

  final String? bio;
  final String? gender;
  final DateTime? dob;
  final int? travelRadiusKm;

  InstructorProfile withDocuments(List<InstructorDocument> docs) =>
      InstructorProfile(
        name: name,
        experienceYears: experienceYears,
        languages: languages,
        specialisations: specialisations,
        onboarding: onboarding,
        documents: docs,
        contact: contact,
        bio: bio,
        email: email,
        gender: gender,
        dob: dob,
        travelRadiusKm: travelRadiusKm,
      );
}

List<String> _strings(dynamic value) => switch (value) {
  final List<dynamic> list => list.map((e) => '$e').toList(),
  _ => const [],
};

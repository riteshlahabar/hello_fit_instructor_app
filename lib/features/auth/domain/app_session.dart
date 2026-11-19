import 'package:flutter/foundation.dart';

/// The signed-in person, as `POST /auth/otp/verify` returns them
/// (`AppSession` in `auth.service.ts`).
@immutable
class AppSession {
  const AppSession({
    required this.userId,
    required this.mobile,
    required this.roles,
    required this.isNewAccount,
    required this.hasInstructorProfile,
    required this.instructorOnboardingStage,
  });

  factory AppSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return AppSession(
      userId: user['id'] as String,
      mobile: user['mobile'] as String,
      roles: (user['roles'] as List<dynamic>).map((r) => '$r').toList(),
      isNewAccount: user['isNewAccount'] as bool? ?? false,
      hasInstructorProfile: user['hasInstructorProfile'] as bool? ?? false,
      instructorOnboardingStage: user['instructorOnboardingStage'] as String?,
    );
  }

  final String userId;
  final String mobile;
  final List<String> roles;
  final bool isNewAccount;
  final bool hasInstructorProfile;

  /// Null until the person applies to teach. One of `APPLIED`,
  /// `DOCUMENTS_SUBMITTED`, `SCREENING_CALL`, `DEMO_SESSION`, `APPROVED`,
  /// `REJECTED`.
  final String? instructorOnboardingStage;

  bool get isInstructor => roles.contains('INSTRUCTOR');

  /// Where this person belongs after sign-in.
  ///
  /// A first OTP login only ever creates a CUSTOMER (`auth.service.ts`), so in
  /// the trainer app the common case is "apply first". A profile row is not
  /// enough on its own: an application that is still APPLIED, or that came
  /// back REJECTED, belongs in the wizard too — the shell is for a trainer the
  /// team has approved.
  bool get needsApplication =>
      !hasInstructorProfile || instructorOnboardingStage != 'APPROVED';
}

/// Whether the OTP was accepted and how long it lives.
@immutable
class OtpChallenge {
  const OtpChallenge({required this.sent, this.expiresAt, this.devCode});

  factory OtpChallenge.fromJson(Map<String, dynamic> json) => OtpChallenge(
    sent: json['sent'] as bool? ?? false,
    expiresAt: json['expiresAt'] == null
        ? null
        : DateTime.tryParse('${json['expiresAt']}'),
    devCode: json['devCode'] as String?,
  );

  final bool sent;
  final DateTime? expiresAt;

  /// Only present when the API runs with `NODE_ENV=development`.
  final String? devCode;
}

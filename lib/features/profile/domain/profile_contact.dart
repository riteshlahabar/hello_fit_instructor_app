import 'package:flutter/foundation.dart';

/// The address, professional-background and studio half of a provider's
/// profile — the columns added for the onboarding wizard on 19 Nov 2026
/// (`InstructorContactDto` on the API side).
///
/// Grouped rather than flattened onto [InstructorProfile] so neither file
/// grows a dozen more fields, and so a screen that only edits this half takes
/// one object.
@immutable
class ProfileContact {
  const ProfileContact({
    this.addressLine,
    this.landmark,
    this.city,
    this.state,
    this.pincode,
    this.country,
    this.qualification,
    this.institute,
    this.clientsTrainedBand,
    this.serviceLocality,
    this.studioName,
    this.studioAddress,
  });

  factory ProfileContact.fromJson(Map<String, dynamic> json) => ProfileContact(
    addressLine: json['addressLine'] as String?,
    landmark: json['landmark'] as String?,
    city: json['city'] as String?,
    state: json['state'] as String?,
    pincode: json['pincode'] as String?,
    country: json['country'] as String?,
    qualification: json['qualification'] as String?,
    institute: json['institute'] as String?,
    clientsTrainedBand: json['clientsTrainedBand'] as String?,
    serviceLocality: json['serviceLocality'] as String?,
    studioName: json['studioName'] as String?,
    studioAddress: json['studioAddress'] as String?,
  );

  /// Postal address (page 13).
  final String? addressLine;
  final String? landmark;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;

  /// Professional background (page 14).
  final String? qualification;
  final String? institute;
  final String? clientsTrainedBand;

  /// Where they work (page 18).
  final String? serviceLocality;
  final String? studioName;
  final String? studioAddress;
}

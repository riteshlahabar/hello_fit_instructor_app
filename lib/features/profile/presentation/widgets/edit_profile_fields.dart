import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../onboarding/domain/professional_options.dart';
import '../../../onboarding/presentation/widgets/dob_gender_row.dart';
import '../../../onboarding/presentation/widgets/radius_slider.dart';
import '../../../onboarding/presentation/widgets/wizard_field.dart';
import '../../../onboarding/presentation/widgets/wizard_scaffold.dart';
import 'edit_profile_controllers.dart';

/// "BASIC INFORMATION" — page 66's first group. The mobile number is shown but
/// not editable: it is the login identity and no API route changes it.
List<Widget> basicFields({
  required EditProfileControllers c,
  required Map<String, String?> errors,
  required String mobile,
  required String? gender,
  required String dobText,
  required VoidCallback onPickDob,
  required ValueChanged<String?> onGenderChanged,
  required VoidCallback onBioChanged,
}) => [
  const WizardSectionLabel('BASIC INFORMATION'),
  WizardField(
    label: 'FULL NAME *',
    error: errors['name'],
    child: WizardInput(controller: c.name, hint: 'Your full name'),
  ),
  WizardField(
    label: 'EMAIL ADDRESS',
    error: errors['email'],
    child: WizardInput(
      controller: c.email,
      hint: 'you@example.com',
      keyboardType: TextInputType.emailAddress,
    ),
  ),
  WizardField(
    label: 'MOBILE NUMBER',
    child: WizardInput(
      controller: TextEditingController(text: '+91 $mobile'),
      enabled: false,
    ),
  ),
  DobGenderRow(
    dobText: dobText,
    gender: gender,
    genders: genderLabels,
    onPickDob: onPickDob,
    onGenderChanged: onGenderChanged,
  ),
  WizardField(
    label: 'ABOUT ME',
    error: errors['bio'],
    child: WizardInput(
      controller: c.bio,
      hint: 'What clients should know about how you train',
      maxLines: 4,
      maxLength: 300,
      onChanged: (_) => onBioChanged(),
    ),
  ),
];

/// "PROFESSIONAL SUMMARY" — page 66's second group. Experience is a plain
/// number box, not the HTML's band list: the client made that call on
/// 19-11-2026 and page 14 already follows it.
List<Widget> professionalFields({
  required EditProfileControllers c,
  required Map<String, String?> errors,
  required String? qualification,
  required String? clientBand,
  required ValueChanged<String?> onQualification,
  required ValueChanged<String?> onClientBand,
}) => [
  const WizardSectionLabel('PROFESSIONAL SUMMARY'),
  WizardField(
    label: 'YEARS OF EXPERIENCE *',
    error: errors['experience'],
    child: WizardInput(
      controller: c.experience,
      hint: 'e.g. 5',
      keyboardType: TextInputType.number,
      maxLength: 2,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    ),
  ),
  WizardField(
    label: 'HIGHEST QUALIFICATION',
    child: WizardDropdown<String>(
      value: qualification,
      items: ProfessionalOptions.qualifications,
      hint: 'Select a qualification',
      onChanged: onQualification,
    ),
  ),
  WizardField(
    label: 'INSTITUTE / ACADEMY',
    child: WizardInput(controller: c.institute, hint: 'Where you trained'),
  ),
  WizardField(
    label: 'CLIENTS TRAINED',
    child: WizardDropdown<String>(
      value: clientBand,
      items: ProfessionalOptions.clients,
      hint: 'Select a range',
      onChanged: onClientBand,
    ),
  ),
];

/// "ADDRESS & SERVICE AREA" — pages 13 and 18, folded into one group because
/// the client asked for every field editable in one place (20-11-2026).
List<Widget> locationFields({
  required EditProfileControllers c,
  required Map<String, String?> errors,
  required double radius,
  required ValueChanged<double> onRadius,
}) => [
  const WizardSectionLabel('ADDRESS & SERVICE AREA'),
  WizardField(
    label: 'ADDRESS *',
    error: errors['addressLine'],
    child: WizardInput(controller: c.addressLine, hint: 'House, street'),
  ),
  WizardField(
    label: 'LANDMARK',
    child: WizardInput(controller: c.landmark, hint: 'Nearby landmark'),
  ),
  Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: WizardField(
          label: 'CITY *',
          error: errors['city'],
          child: WizardInput(controller: c.city, hint: 'City'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: WizardField(
          label: 'PIN CODE',
          error: errors['pincode'],
          child: WizardInput(
            controller: c.pincode,
            hint: '6-digit PIN',
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ),
    ],
  ),
  WizardField(
    label: 'STATE *',
    error: errors['state'],
    child: WizardInput(controller: c.state, hint: 'State'),
  ),
  WizardField(
    label: 'AREA / LOCALITY YOU SERVE *',
    error: errors['locality'],
    child: WizardInput(controller: c.locality, hint: 'e.g. Kothrud, Baner'),
  ),
  WizardField(
    label: 'MAXIMUM TRAVEL DISTANCE',
    child: RadiusSlider(value: radius, onChanged: onRadius),
  ),
];

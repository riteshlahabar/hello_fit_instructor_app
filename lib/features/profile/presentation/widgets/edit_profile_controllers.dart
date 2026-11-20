import 'package:flutter/material.dart';

/// The text controllers page 66's form owns, in one bag so the screen file
/// stays about saving rather than about a dozen `TextEditingController` lines.
class EditProfileControllers {
  final name = TextEditingController();
  final email = TextEditingController();
  final bio = TextEditingController();
  final institute = TextEditingController();
  final experience = TextEditingController();
  final addressLine = TextEditingController();
  final landmark = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final pincode = TextEditingController();
  final locality = TextEditingController();

  List<TextEditingController> get all => [
    name,
    email,
    bio,
    institute,
    experience,
    addressLine,
    landmark,
    city,
    state,
    pincode,
    locality,
  ];

  void dispose() {
    for (final c in all) {
      c.dispose();
    }
  }
}

const genderLabels = {
  'FEMALE': 'Female',
  'MALE': 'Male',
  'OTHER': 'Non-binary',
  'UNDISCLOSED': 'Prefer not to say',
};

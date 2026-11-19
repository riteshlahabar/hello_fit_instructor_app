import 'package:flutter/material.dart';

import 'wizard_field.dart';

/// The `.grid` pair on page 12 — date of birth beside gender.
class DobGenderRow extends StatelessWidget {
  const DobGenderRow({
    super.key,
    required this.dobText,
    required this.gender,
    required this.genders,
    required this.onPickDob,
    required this.onGenderChanged,
  });

  final String dobText;
  final String? gender;
  final Map<String, String> genders;
  final VoidCallback onPickDob;
  final ValueChanged<String?> onGenderChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: WizardField(
            label: 'DATE OF BIRTH',
            child: InkWell(
              onTap: onPickDob,
              child: IgnorePointer(
                child: WizardInput(
                  controller: TextEditingController(text: dobText),
                  hint: 'DD-MM-YYYY',
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: WizardField(
            label: 'GENDER',
            child: WizardDropdown<String>(
              value: gender,
              hint: 'Select gender',
              items: genders,
              onChanged: onGenderChanged,
            ),
          ),
        ),
      ],
    );
  }
}

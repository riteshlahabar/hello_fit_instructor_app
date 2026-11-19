import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'upper_case_formatter.dart';
import 'wizard_field.dart';

/// The five bank fields of page 20, shown only when the payout radio is on
/// `BANK`. Split out of `bank_account_screen.dart` so that file stays under
/// the project's 200-line limit.
class BankFields extends StatelessWidget {
  const BankFields({
    super.key,
    required this.holder,
    required this.bank,
    required this.account,
    required this.confirm,
    required this.ifsc,
    required this.accountType,
    required this.errors,
    required this.onAccountTypeChanged,
  });

  final TextEditingController holder;
  final TextEditingController bank;
  final TextEditingController account;
  final TextEditingController confirm;
  final TextEditingController ifsc;
  final String accountType;
  final Map<String, String> errors;
  final ValueChanged<String> onAccountTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WizardField(
          label: 'ACCOUNT HOLDER NAME *',
          error: errors['holder'],
          child: WizardInput(
            controller: holder,
            hint: 'Name as per bank records',
          ),
        ),
        WizardField(
          label: 'BANK NAME *',
          error: errors['bank'],
          child: WizardInput(controller: bank, hint: 'Enter your bank name'),
        ),
        WizardField(
          label: 'ACCOUNT NUMBER *',
          error: errors['account'],
          child: WizardInput(
            controller: account,
            hint: 'Enter bank account number',
            keyboardType: TextInputType.number,
            maxLength: 18,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
        WizardField(
          label: 'CONFIRM ACCOUNT NUMBER *',
          error: errors['confirm'],
          child: WizardInput(
            controller: confirm,
            hint: 'Re-enter account number',
            keyboardType: TextInputType.number,
            maxLength: 18,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
        WizardField(
          label: 'IFSC CODE *',
          error: errors['ifsc'],
          child: WizardInput(
            controller: ifsc,
            hint: 'e.g. HDFC0001234',
            maxLength: 11,
            inputFormatters: [UpperCaseFormatter()],
          ),
        ),
        WizardField(
          label: 'ACCOUNT TYPE',
          child: WizardDropdown<String>(
            value: accountType,
            items: const {'SAVINGS': 'Savings', 'CURRENT': 'Current'},
            onChanged: (v) => onAccountTypeChanged(v ?? 'SAVINGS'),
          ),
        ),
      ],
    );
  }
}

/// Page 20's client-side rules, mirroring `UpsertBankAccountDto` so nobody
/// has to submit to find out. Only the chosen payout side is checked, exactly
/// as the DTO does it — UPI or bank, never both (client, 19-11-2026).
///
/// A pure function on trimmed strings, off the widget: the screen holds the
/// controllers, this holds the rules, and the rules are testable without a
/// pump. Keys match the `errors` map `BankFields` and `WizardField` read.
Map<String, String> bankFormErrors({
  required String method,
  required String holder,
  required String bank,
  required String account,
  required String confirm,
  required String ifsc,
  required String upi,
}) {
  final errors = <String, String>{};

  if (method == 'UPI') {
    if (!RegExp(r'^[\w.\-]{2,60}@[A-Za-z]{2,30}$').hasMatch(upi.trim())) {
      errors['upi'] = 'UPI ID should look like name@bank';
    }
    return errors;
  }

  if (holder.trim().length < 2) {
    errors['holder'] = 'Enter the name as per bank records';
  }
  if (bank.trim().length < 2) {
    errors['bank'] = 'Enter your bank name';
  }
  if (!RegExp(r'^\d{9,18}$').hasMatch(account.trim())) {
    errors['account'] = 'Account number must be 9 to 18 digits';
  } else if (account.trim() != confirm.trim()) {
    errors['confirm'] = 'Account numbers do not match';
  }
  if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc.trim().toUpperCase())) {
    errors['ifsc'] = 'Enter a valid IFSC, e.g. HDFC0001234';
  }

  return errors;
}

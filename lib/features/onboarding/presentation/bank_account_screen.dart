import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_result.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_primary_button.dart';
import '../../profile/data/profile_providers.dart';
import 'widgets/bank_account_on_file.dart';
import 'widgets/bank_fields.dart';
import 'widgets/payout_method_radio.dart';
import 'widgets/wizard_field.dart';
import 'widgets/wizard_scaffold.dart';

/// Page 20 — Payout Details. `PUT /app/instructor/bank-account`.
///
/// **UPI or bank, never both** (client, 19-11-2026). The chosen side is
/// compulsory and the other is hidden; the server clears it, so switching
/// cannot leave a stale account number behind.
///
/// The number is write-only: the API returns `••••6789`, never the account,
/// so an existing account shows masked and must be retyped to change.
class BankAccountScreen extends ConsumerStatefulWidget {
  const BankAccountScreen({super.key, this.inWizard = true});

  /// False when the profile tab opened it (client, 20-11-2026): a trainer
  /// editing their payout details must come back to Profile, not be pushed on
  /// to the submit screen they already passed.
  final bool inWizard;

  @override
  ConsumerState<BankAccountScreen> createState() => _State();
}

class _State extends ConsumerState<BankAccountScreen> {
  final _holder = TextEditingController();
  final _bank = TextEditingController();
  final _account = TextEditingController();
  final _confirm = TextEditingController();
  final _ifsc = TextEditingController();
  final _upi = TextEditingController();
  String _method = 'BANK';
  String _type = 'SAVINGS';
  final _errors = <String, String>{};
  String _status = '';
  String? _existingMask;
  bool _busy = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    for (final c in [_holder, _bank, _account, _confirm, _ifsc, _upi]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final result = await ref.read(profileRepositoryProvider).loadBankAccount();
    if (!mounted || _loaded) return;
    if (result case ApiSuccess(:final data) when data != null) {
      setState(() {
        _loaded = true;
        _method = data.payoutMethod;
        _holder.text = data.holderName ?? '';
        _bank.text = data.bankName ?? '';
        _ifsc.text = data.ifsc ?? '';
        _upi.text = data.upiId ?? '';
        _type = data.accountType ?? 'SAVINGS';
        _existingMask = data.accountNumberMasked;
      });
    }
  }

  /// Mirrors `UpsertBankAccountDto` so nobody has to submit to find out — and
  /// only the chosen side is checked, exactly as the DTO does it.
  bool _validate() {
    _errors.clear();

    if (_method == 'UPI') {
      final upi = _upi.text.trim();
      if (!RegExp(r'^[\w.\-]{2,60}@[A-Za-z]{2,30}$').hasMatch(upi)) {
        _errors['upi'] = 'UPI ID should look like name@bank';
      }
    } else {
      if (_holder.text.trim().length < 2) {
        _errors['holder'] = 'Enter the name as per bank records';
      }
      if (_bank.text.trim().length < 2) {
        _errors['bank'] = 'Enter your bank name';
      }
      if (!RegExp(r'^\d{9,18}$').hasMatch(_account.text.trim())) {
        _errors['account'] = 'Account number must be 9 to 18 digits';
      } else if (_account.text.trim() != _confirm.text.trim()) {
        _errors['confirm'] = 'Account numbers do not match';
      }
      if (!RegExp(
        r'^[A-Z]{4}0[A-Z0-9]{6}$',
      ).hasMatch(_ifsc.text.trim().toUpperCase())) {
        _errors['ifsc'] = 'Enter a valid IFSC, e.g. HDFC0001234';
      }
    }

    setState(() {});
    return _errors.isEmpty;
  }

  Future<void> _save() async {
    setState(() => _status = '');
    if (!_validate()) return;

    setState(() => _busy = true);
    final result = await ref
        .read(profileRepositoryProvider)
        .saveBankAccount(
          payoutMethod: _method,
          holderName: _holder.text.trim(),
          bankName: _bank.text.trim(),
          accountNumber: _account.text.trim(),
          ifsc: _ifsc.text.trim().toUpperCase(),
          accountType: _type,
          upiId: _upi.text.trim(),
        );
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case ApiSuccess():
        if (widget.inWizard) {
          context.push('/onboarding/submit');
        } else if (context.canPop()) {
          context.pop();
        } else {
          setState(() => _status = 'Bank details saved');
        }
      case ApiFailure(:final message):
        setState(() => _status = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      stepLabel: 'PAYOUT SETUP',
      progress: 6 / 6,
      title: 'Payout\nDetails',
      sub: 'Where your earnings are transferred once a session is completed.',
      onBack: context.canPop() ? context.pop : null,
      children: [
        // Only meaningful alongside the bank side — a UPI payout has no
        // account number to have on file.
        if (_existingMask != null && _method == 'BANK')
          BankAccountOnFile(mask: _existingMask!),
        const WizardSectionLabel('HOW YOU WANT TO BE PAID'),
        PayoutMethodRadio(
          value: _method,
          onChanged: (value) => setState(() {
            _method = value;
            _errors.clear();
          }),
        ),
        if (_method == 'UPI')
          WizardField(
            label: 'UPI ID *',
            error: _errors['upi'],
            child: WizardInput(controller: _upi, hint: 'name@bank'),
          )
        else
          BankFields(
            holder: _holder,
            bank: _bank,
            account: _account,
            confirm: _confirm,
            ifsc: _ifsc,
            accountType: _type,
            errors: _errors,
            onAccountTypeChanged: (v) => setState(() => _type = v),
          ),
        const SizedBox(height: 8),
        HFPrimaryButton(
          label: 'SAVE & CONTINUE',
          busy: _busy,
          onPressed: _save,
        ),
        SizedBox(
          height: 22,
          child: Center(
            child: Text(
              _status,
              style: const TextStyle(fontSize: 10, color: HFColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

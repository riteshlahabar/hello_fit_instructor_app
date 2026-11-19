import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_result.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_primary_button.dart';
import '../../profile/data/profile_providers.dart';
import 'widgets/wizard_field.dart';
import 'widgets/wizard_scaffold.dart';

/// Page 13 — Personal Information. Step 2 of 6.
/// `PATCH /app/instructor/profile` with the address columns added 19 Nov.
class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _State();
}

class _State extends ConsumerState<PersonalInfoScreen> {
  final _address = TextEditingController();
  final _landmark = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();
  String _country = 'India';
  final _errors = <String, String>{};
  String _status = '';
  bool _busy = false;
  bool _loaded = false;

  @override
  void dispose() {
    for (final c in [_address, _landmark, _city, _state, _pincode]) {
      c.dispose();
    }
    super.dispose();
  }

  void _prefill() {
    if (_loaded) return;
    final profile = ref.read(profileControllerProvider).value;
    if (profile == null) return;
    _loaded = true;
    _address.text = profile.contact.addressLine ?? '';
    _landmark.text = profile.contact.landmark ?? '';
    _city.text = profile.contact.city ?? '';
    _state.text = profile.contact.state ?? '';
    _pincode.text = profile.contact.pincode ?? '';
    _country = profile.contact.country ?? 'India';
  }

  /// Client-side rules, matching the DTO so nobody has to submit to find out.
  bool _validate() {
    _errors.clear();
    if (_address.text.trim().isEmpty) _errors['address'] = 'Enter your address';
    if (_city.text.trim().length < 2) _errors['city'] = 'Enter your city';
    if (_state.text.trim().length < 2) _errors['state'] = 'Enter your state';
    final pin = _pincode.text.trim();
    if (pin.isNotEmpty && !RegExp(r'^\d{6}$').hasMatch(pin)) {
      _errors['pincode'] = 'PIN code must be 6 digits';
    }
    setState(() {});
    return _errors.isEmpty;
  }

  Future<void> _save() async {
    setState(() => _status = '');
    if (!_validate()) return;

    setState(() => _busy = true);
    final pin = _pincode.text.trim();
    final result = await ref.read(profileControllerProvider.notifier).save({
      'addressLine': _address.text.trim(),
      'landmark': _landmark.text.trim(),
      'city': _city.text.trim(),
      'state': _state.text.trim(),
      // The DTO's six-digit rule rejects an empty string, so a blank PIN is
      // left out of the body rather than sent as ''.
      if (pin.isNotEmpty) 'pincode': pin,
      'country': _country,
    });
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case ApiSuccess():
        context.push('/onboarding/professional');
      case ApiFailure(:final message):
        setState(() => _status = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(profileControllerProvider);
    _prefill();

    return WizardScaffold(
      stepLabel: 'STEP 2 OF 6',
      progress: 2 / 6,
      title: 'Personal\nInformation',
      sub:
          'Complete your personal details so clients can connect with you and '
          'find the right trainer.',
      onBack: context.canPop() ? context.pop : null,
      children: [
        const WizardSectionLabel('ABOUT YOU'),
        WizardField(
          label: 'ADDRESS *',
          error: _errors['address'],
          child: WizardInput(
            controller: _address,
            hint: 'House / building, street and area',
            maxLines: 3,
          ),
        ),
        WizardField(
          label: 'LANDMARK',
          child: WizardInput(controller: _landmark, hint: 'Nearby landmark'),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: WizardField(
                label: 'CITY *',
                error: _errors['city'],
                child: WizardInput(controller: _city, hint: 'Enter city'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: WizardField(
                label: 'STATE *',
                error: _errors['state'],
                child: WizardInput(controller: _state, hint: 'Enter state'),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: WizardField(
                label: 'PIN CODE',
                error: _errors['pincode'],
                child: WizardInput(
                  controller: _pincode,
                  hint: '6-digit PIN',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: WizardField(
                label: 'COUNTRY',
                child: WizardDropdown<String>(
                  value: _country,
                  items: const {'India': 'India', 'Other': 'Other'},
                  onChanged: (v) => setState(() => _country = v ?? 'India'),
                ),
              ),
            ),
          ],
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

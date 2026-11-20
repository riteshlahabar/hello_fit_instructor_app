import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_result.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_primary_button.dart';
import '../../profile/data/profile_providers.dart';
import 'widgets/radius_slider.dart';
import 'widgets/wizard_field.dart';
import 'widgets/wizard_scaffold.dart';

/// Page 18 — Service Areas.
///
/// Session location went on 20-11-2026 (client): HelloFit is home-service
/// only, every trainer travels to the customer, so the page is the base
/// locality and the travel radius — there is nothing left to choose.
class ServiceAreaScreen extends ConsumerStatefulWidget {
  const ServiceAreaScreen({super.key});

  @override
  ConsumerState<ServiceAreaScreen> createState() => _State();
}

class _State extends ConsumerState<ServiceAreaScreen> {
  final _locality = TextEditingController();
  final _city = TextEditingController();
  final _pincode = TextEditingController();
  double _radius = 10;
  final _errors = <String, String>{};
  String _status = '';
  bool _busy = false;
  bool _loaded = false;

  @override
  void dispose() {
    for (final c in [_locality, _city, _pincode]) {
      c.dispose();
    }
    super.dispose();
  }

  void _prefill() {
    if (_loaded) return;
    final profile = ref.read(profileControllerProvider).value;
    if (profile == null) return;
    _loaded = true;
    _locality.text = profile.contact.serviceLocality ?? '';
    _city.text = profile.contact.city ?? '';
    _pincode.text = profile.contact.pincode ?? '';
    _radius = (profile.travelRadiusKm ?? 10).toDouble().clamp(1, 30);
  }

  Future<void> _save() async {
    _errors.clear();
    if (_locality.text.trim().isEmpty) {
      _errors['locality'] = 'Enter the area you serve';
    }
    if (_city.text.trim().length < 2) _errors['city'] = 'Enter your city';
    final pin = _pincode.text.trim();
    if (pin.isNotEmpty && !RegExp(r'^\d{6}$').hasMatch(pin)) {
      _errors['pincode'] = 'PIN code must be 6 digits';
    }
    setState(() {});
    if (_errors.isNotEmpty) return;

    setState(() {
      _busy = true;
      _status = '';
    });
    final result = await ref.read(profileControllerProvider.notifier).save({
      'serviceLocality': _locality.text.trim(),
      'city': _city.text.trim(),
      // Omitted when blank: the DTO's six-digit rule rejects an empty string.
      if (pin.isNotEmpty) 'pincode': pin,
      'travelRadiusKm': _radius.round(),
    });
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case ApiSuccess():
        context.push('/onboarding/bank');
      case ApiFailure(:final message):
        setState(() => _status = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(profileControllerProvider);
    _prefill();

    return WizardScaffold(
      stepLabel: 'SERVICE SETUP',
      progress: 5 / 6,
      title: 'Service Areas &\nTraining Locations',
      sub:
          'Tell clients where you work. Set your base location and how far '
          'you are willing to travel to a session.',
      onBack: context.canPop() ? context.pop : null,
      children: [
        const WizardSectionLabel('YOUR BASE LOCATION'),
        WizardField(
          label: 'AREA / LOCALITY *',
          error: _errors['locality'],
          child: WizardInput(
            controller: _locality,
            hint: 'e.g. Kothrud, Baner, Andheri',
          ),
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
          ],
        ),
        WizardField(
          label: 'MAXIMUM TRAVEL DISTANCE',
          child: RadiusSlider(
            value: _radius,
            onChanged: (v) => setState(() => _radius = v),
          ),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_result.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_primary_button.dart';
import '../../profile/data/profile_providers.dart';
import 'widgets/radius_slider.dart';
import 'widgets/training_mode_tiles.dart';
import 'widgets/wizard_field.dart';
import 'widgets/wizard_scaffold.dart';

/// Page 18 — Service Areas & Training Locations.
///
/// The HTML offers four modes; `SessionFormat` has three. "Outdoor / Park" is
/// deliberately absent rather than folded into another value — see
/// `state/frontend/trainer-app.md`.
class ServiceAreaScreen extends ConsumerStatefulWidget {
  const ServiceAreaScreen({super.key});

  @override
  ConsumerState<ServiceAreaScreen> createState() => _State();
}

class _State extends ConsumerState<ServiceAreaScreen> {
  final _locality = TextEditingController();
  final _city = TextEditingController();
  final _pincode = TextEditingController();
  final _studio = TextEditingController();
  final _formats = <String>{'CUSTOMER_HOME'};
  double _radius = 10;
  final _errors = <String, String>{};
  String _status = '';
  bool _busy = false;
  bool _loaded = false;

  @override
  void dispose() {
    for (final c in [_locality, _city, _pincode, _studio]) {
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
    _studio.text = profile.contact.studioName ?? '';
    _radius = (profile.travelRadiusKm ?? 10).toDouble().clamp(1, 30);
    if (profile.sessionFormats.isNotEmpty) {
      _formats
        ..clear()
        ..addAll(profile.sessionFormats);
    }
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
    if (_formats.isEmpty) _status = 'Choose at least one training location';
    setState(() {});
    if (_errors.isNotEmpty || _formats.isEmpty) return;

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
      'sessionFormats': _formats.toList(),
      'studioName': _formats.contains('PROVIDER_LOCATION')
          ? _studio.text.trim()
          : '',
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
          'Tell clients where you train. Set your base location, travel '
          'distance and the training options you offer.',
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
        const WizardSectionLabel('HOW DO YOU TRAIN?'),
        TrainingModeTiles(
          selected: _formats,
          onToggle: (value) => setState(() {
            if (!_formats.remove(value)) _formats.add(value);
          }),
        ),
        if (_formats.contains('PROVIDER_LOCATION'))
          WizardField(
            label: 'STUDIO / GYM NAME & ADDRESS',
            child: WizardInput(
              controller: _studio,
              hint: 'Enter your studio name or address',
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

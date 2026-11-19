import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_result.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_primary_button.dart';
import '../../profile/data/profile_providers.dart';
import '../domain/professional_options.dart';
import 'widgets/wizard_field.dart';
import 'widgets/wizard_scaffold.dart';

/// Page 14 — Professional Details. Step 3 of 6.
class ProfessionalScreen extends ConsumerStatefulWidget {
  const ProfessionalScreen({super.key});

  @override
  ConsumerState<ProfessionalScreen> createState() => _State();
}

class _State extends ConsumerState<ProfessionalScreen> {
  final _institute = TextEditingController();

  /// "About me" — pages 23 and 66 show it, registration never asked for it,
  /// and the submit gate demands it (client, 19-11-2026). It sits on this
  /// step rather than page 12 because it is background prose, not a basic
  /// detail.
  final _bio = TextEditingController();

  /// A plain number, not a band (client, 19-11-2026). The HTML drew a band
  /// dropdown and the band floor was being stored, which lost the real
  /// figure; `experienceYears` is an int, so now the trainer types it.
  final _years = TextEditingController();
  String? _clientBand;
  String? _qualification;
  final _errors = <String, String>{};
  String _status = '';
  bool _busy = false;
  bool _loaded = false;

  @override
  void dispose() {
    _institute.dispose();
    _years.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _prefill() {
    if (_loaded) return;
    final profile = ref.read(profileControllerProvider).value;
    if (profile == null) return;
    _loaded = true;
    _years.text = profile.experienceYears > 0
        ? '${profile.experienceYears}'
        : '';
    _clientBand = profile.contact.clientsTrainedBand;
    _qualification = profile.contact.qualification;
    _institute.text = profile.contact.institute ?? '';
    _bio.text = profile.bio ?? '';
  }

  Future<void> _save() async {
    _errors.clear();
    final years = int.tryParse(_years.text.trim());
    if (_years.text.trim().isEmpty) {
      _errors['years'] = 'Enter your years of experience';
    } else if (years == null || years < 0 || years > 60) {
      // 60 is the DTO's @Max; 70 here let the screen pass a body the API
      // then rejected as "Request validation failed".
      _errors['years'] = 'Enter a whole number of years, 0 to 60';
    }
    if (_qualification == null) {
      _errors['qualification'] = 'Choose your qualification';
    }
    // The submit gate refuses an empty bio, so catching it here saves the
    // trainer finishing the wizard and being blocked at the last step.
    if (_bio.text.trim().length < 20) {
      _errors['bio'] = 'Write at least a couple of lines about yourself';
    }
    setState(() => _status = '');
    if (_errors.isNotEmpty) return;

    setState(() => _busy = true);
    final result = await ref.read(profileControllerProvider.notifier).save({
      'experienceYears': years,
      'clientsTrainedBand': ?_clientBand,
      'qualification': ?_qualification,
      'institute': _institute.text.trim(),
      'bio': _bio.text.trim(),
    });
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case ApiSuccess():
        context.push('/onboarding/specialisation');
      case ApiFailure(:final message):
        setState(() => _status = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(profileControllerProvider);
    _prefill();

    return WizardScaffold(
      stepLabel: 'STEP 3 OF 6',
      progress: 3 / 6,
      title: 'Professional\nDetails',
      sub:
          'Tell clients about your training background so they can judge the '
          'fit before they book.',
      onBack: context.canPop() ? context.pop : null,
      children: [
        const WizardSectionLabel('YOUR BACKGROUND'),
        WizardField(
          label: 'YEARS OF EXPERIENCE *',
          error: _errors['years'],
          child: WizardInput(
            controller: _years,
            hint: 'e.g. 4',
            keyboardType: TextInputType.number,
            maxLength: 2,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
        WizardField(
          label: 'CLIENTS TRAINED',
          child: WizardDropdown<String>(
            value: _clientBand,
            hint: 'Select a range',
            items: ProfessionalOptions.clients,
            onChanged: (v) => setState(() => _clientBand = v),
          ),
        ),
        WizardField(
          label: 'HIGHEST FITNESS / SPORTS QUALIFICATION *',
          error: _errors['qualification'],
          child: WizardDropdown<String>(
            value: _qualification,
            hint: 'Select qualification',
            items: ProfessionalOptions.qualifications,
            onChanged: (v) => setState(() => _qualification = v),
          ),
        ),
        WizardField(
          label: 'CERTIFICATION / INSTITUTE NAME',
          child: WizardInput(
            controller: _institute,
            hint: 'Enter institute or certification provider',
          ),
        ),
        WizardField(
          label: 'ABOUT ME *',
          error: _errors['bio'],
          child: WizardInput(
            controller: _bio,
            hint: 'How you train, who you train, what a session feels like',
            maxLines: 4,
            maxLength: 600,
            onChanged: (_) {
              if (_errors['bio'] != null) {
                setState(() => _errors.remove('bio'));
              }
            },
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

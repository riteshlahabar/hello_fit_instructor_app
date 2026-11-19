import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/dates/app_date.dart';
import '../../../core/network/api_result.dart';
import '../../../core/widgets/hf_primary_button.dart';
import '../../auth/data/auth_providers.dart';
import '../../profile/data/profile_providers.dart';
import 'widgets/dob_gender_row.dart';
import 'widgets/logout_button.dart';
import 'widgets/photo_picker_row.dart';
import 'widgets/wizard_field.dart';
import 'widgets/wizard_scaffold.dart';

/// Page 12 — Create Trainer Profile. Step 1 of 6.
///
/// `POST /app/instructor/apply` the first time, `PATCH` after. The photo goes
/// up as a `PHOTO` document.
class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() => _State();
}

class _State extends ConsumerState<CreateProfileScreen> {
  static const _genders = {
    'FEMALE': 'Female',
    'MALE': 'Male',
    'OTHER': 'Non-binary',
    'UNDISCLOSED': 'Prefer not to say',
  };

  final _name = TextEditingController();
  String? _gender;
  DateTime? _dob;
  File? _photo;
  String? _nameError;
  String _status = '';
  bool _busy = false;
  bool _loaded = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _prefill() {
    if (_loaded) return;
    final profile = ref.read(profileControllerProvider).value;
    if (profile == null) return;
    _loaded = true;
    _name.text = profile.name;
    _gender = profile.gender;
    _dob = profile.dob;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 28),
      firstDate: DateTime(now.year - 80),
      lastDate: DateTime(now.year - 16),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _uploadPhoto(String path) async {
    setState(() {
      _photo = File(path);
      _busy = true;
    });
    final result = await ref
        .read(profileControllerProvider.notifier)
        .uploadDocument(filePath: path, docType: 'PHOTO');
    if (!mounted) return;
    setState(() {
      _busy = false;
      _status = switch (result) {
        ApiSuccess() => 'Photo uploaded',
        ApiFailure(:final message) => message,
      };
    });
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    setState(() {
      _nameError = name.length < 2 ? 'Enter your full name' : null;
      _status = '';
    });
    if (_nameError != null) return;

    setState(() => _busy = true);
    final controller = ref.read(profileControllerProvider.notifier);
    final existing = ref.read(profileControllerProvider).value;

    final result = existing == null
        ? await controller.apply(name: name, gender: _gender)
        : await controller.save({
            'name': name,
            'gender': ?_gender,
            if (_dob != null) 'dob': formatDdMmYyyy(_dob!),
          });

    // apply() cannot carry the date of birth, so it follows as a PATCH.
    final after = existing == null && _dob != null && result.isSuccess
        ? await controller.save({'dob': formatDdMmYyyy(_dob!)})
        : result;

    if (!mounted) return;
    setState(() => _busy = false);

    switch (after) {
      case ApiSuccess():
        context.push('/onboarding/personal');
      case ApiFailure(:final message):
        setState(() => _status = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(profileControllerProvider);
    _prefill();
    final session = ref.watch(authControllerProvider);
    final mobile = session is AuthSignedIn ? session.session?.mobile : null;

    return WizardScaffold(
      stepLabel: 'STEP 1 OF 6',
      progress: 1 / 6,
      title: 'Create Your\nTrainer Profile',
      sub:
          'Let’s get to know you. Add your basic details to start building '
          'your HelloFit trainer profile.',
      onBack: context.canPop() ? context.pop : null,
      trailing: const LogoutButton(),
      children: [
        const WizardSectionLabel('PROFILE PHOTO'),
        PhotoPickerRow(file: _photo, busy: _busy, onPicked: _uploadPhoto),
        const WizardSectionLabel('BASIC INFORMATION'),
        WizardField(
          label: 'FULL NAME *',
          error: _nameError,
          child: WizardInput(
            controller: _name,
            hint: 'Enter your full name',
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
        ),
        DobGenderRow(
          dobText: _dob == null ? '' : formatDdMmYyyy(_dob!),
          gender: _gender,
          genders: _genders,
          onPickDob: _pickDob,
          onGenderChanged: (value) => setState(() => _gender = value),
        ),
        WizardField(
          label: 'MOBILE NUMBER',
          child: WizardInput(
            controller: TextEditingController(text: mobile ?? ''),
            enabled: false,
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
              style: const TextStyle(fontSize: 10, color: Color(0xFF75695E)),
            ),
          ),
        ),
      ],
    );
  }
}

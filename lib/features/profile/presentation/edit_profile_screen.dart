import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/dates/app_date.dart';
import '../../../core/network/api_result.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_primary_button.dart';
import '../../auth/data/auth_providers.dart';
import '../../onboarding/presentation/widgets/photo_picker_row.dart';
import '../../onboarding/presentation/widgets/wizard_scaffold.dart';
import '../data/profile_providers.dart';
import 'widgets/edit_profile_controllers.dart';
import 'widgets/edit_profile_fields.dart';

/// Page 66 — Edit Profile, reached from the profile tab.
///
/// Every field a trainer owns is editable here in one pass (client,
/// 20-11-2026), so it carries pages 13, 14 and 18's fields as well as page
/// 66's own. Specialisations and documents keep their own screens — a tile
/// grid and a file list do not belong in a text form.
///
/// Saving is one `PATCH /app/instructor/profile` and then a pop: this screen
/// is not in the wizard chain and must never push the next step.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _State();
}

class _State extends ConsumerState<EditProfileScreen> {
  final _c = EditProfileControllers();
  final _errors = <String, String?>{};
  File? _photo;
  String? _gender;
  String? _qualification;
  String? _clientBand;
  DateTime? _dob;
  double _radius = 10;
  String _status = '';
  bool _busy = false;
  bool _loaded = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _prefill() {
    if (_loaded) return;
    final profile = ref.read(profileControllerProvider).value;
    if (profile == null) return;
    _loaded = true;
    _c.name.text = profile.name;
    _c.email.text = profile.email ?? '';
    _c.bio.text = profile.bio ?? '';
    _c.experience.text = profile.experienceYears > 0
        ? '${profile.experienceYears}'
        : '';
    _c.institute.text = profile.contact.institute ?? '';
    _c.addressLine.text = profile.contact.addressLine ?? '';
    _c.landmark.text = profile.contact.landmark ?? '';
    _c.city.text = profile.contact.city ?? '';
    _c.state.text = profile.contact.state ?? '';
    _c.pincode.text = profile.contact.pincode ?? '';
    _c.locality.text = profile.contact.serviceLocality ?? '';
    _gender = profile.gender;
    _dob = profile.dob;
    _radius = (profile.travelRadiusKm ?? 10).toDouble().clamp(1, 30);
    _qualification = profile.contact.qualification;
    _clientBand = profile.contact.clientsTrainedBand;
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
        ApiSuccess() => 'Photo updated',
        ApiFailure(:final message) => message,
      };
    });
  }

  /// Blank clears a field, so every optional string goes as typed and the API
  /// turns a trimmed-to-nothing value into null. `pincode` is the exception:
  /// the DTO's six-digit rule rejects an empty string.
  Map<String, dynamic> _changes() {
    final pin = _c.pincode.text.trim();
    final email = _c.email.text.trim();
    return {
      'name': _c.name.text.trim(),
      'bio': _c.bio.text.trim(),
      'experienceYears': int.parse(_c.experience.text.trim()),
      'addressLine': _c.addressLine.text.trim(),
      'landmark': _c.landmark.text.trim(),
      'city': _c.city.text.trim(),
      'state': _c.state.text.trim(),
      if (pin.isNotEmpty) 'pincode': pin,
      if (email.isNotEmpty) 'email': email,
      'institute': _c.institute.text.trim(),
      'serviceLocality': _c.locality.text.trim(),
      'travelRadiusKm': _radius.round(),
      'gender': ?_gender,
      'qualification': ?_qualification,
      'clientsTrainedBand': ?_clientBand,
      if (_dob != null) 'dob': formatDdMmYyyy(_dob!),
    };
  }

  bool _validate() {
    _errors.clear();
    if (_c.name.text.trim().length < 2) {
      _errors['name'] = 'Enter your full name';
    }
    final email = _c.email.text.trim();
    if (email.isNotEmpty && !email.contains('@')) {
      _errors['email'] = 'Enter a valid email address';
    }
    final years = int.tryParse(_c.experience.text.trim());
    if (years == null || years < 0 || years > 60) {
      _errors['experience'] = 'Enter years of experience';
    }
    if (_c.addressLine.text.trim().isEmpty) {
      _errors['addressLine'] = 'Enter your address';
    }
    if (_c.city.text.trim().length < 2) _errors['city'] = 'Enter your city';
    if (_c.state.text.trim().length < 2) _errors['state'] = 'Enter your state';
    final pin = _c.pincode.text.trim();
    if (pin.isNotEmpty && !RegExp(r'^\d{6}$').hasMatch(pin)) {
      _errors['pincode'] = 'PIN code must be 6 digits';
    }
    if (_c.locality.text.trim().isEmpty) {
      _errors['locality'] = 'Enter the area you serve';
    }
    setState(() {});
    return _errors.isEmpty;
  }

  Future<void> _save() async {
    if (!_validate()) return;

    setState(() {
      _busy = true;
      _status = '';
    });
    final result = await ref
        .read(profileControllerProvider.notifier)
        .save(_changes());
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case ApiSuccess():
        if (context.canPop()) {
          context.pop();
        } else {
          setState(() => _status = 'Changes saved');
        }
      case ApiFailure(:final message):
        setState(() => _status = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(profileControllerProvider);
    _prefill();
    final auth = ref.watch(authControllerProvider);
    final mobile = auth is AuthSignedIn ? auth.session?.mobile : null;

    return WizardScaffold(
      stepLabel: 'MY ACCOUNT',
      progress: null,
      shellChrome: true,
      title: 'Edit Profile',
      sub:
          'Keep your trainer profile up to date so clients can get to know '
          'you.',
      onBack: context.canPop() ? context.pop : null,
      children: [
        const WizardSectionLabel('PROFILE PHOTO'),
        PhotoPickerRow(file: _photo, busy: _busy, onPicked: _uploadPhoto),
        ...basicFields(
          c: _c,
          errors: _errors,
          mobile: mobile ?? '',
          gender: _gender,
          dobText: _dob == null ? '' : formatDdMmYyyy(_dob!),
          onPickDob: _pickDob,
          onGenderChanged: (v) => setState(() => _gender = v),
          onBioChanged: () => setState(() {}),
        ),
        ...professionalFields(
          c: _c,
          errors: _errors,
          qualification: _qualification,
          clientBand: _clientBand,
          onQualification: (v) => setState(() => _qualification = v),
          onClientBand: (v) => setState(() => _clientBand = v),
        ),
        ...locationFields(
          c: _c,
          errors: _errors,
          radius: _radius,
          onRadius: (v) => setState(() => _radius = v),
        ),
        const SizedBox(height: 8),
        HFPrimaryButton(label: 'SAVE CHANGES', busy: _busy, onPressed: _save),
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

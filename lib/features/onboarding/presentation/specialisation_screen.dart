import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_result.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_primary_button.dart';
import '../../catalog/data/catalog_providers.dart';
import '../../catalog/domain/service_category.dart';
import '../../profile/data/profile_providers.dart';
import 'widgets/specialty_tile.dart';
import 'widgets/wizard_scaffold.dart';

/// Page 15 — Fitness Specialization. Step 4 of 6.
/// `PATCH /app/instructor/profile { specialisations }`.
///
/// The tiles are the live `ServiceCategory` master since 19-11-2026 (client),
/// not the ten hard-coded rows the HTML drew. What is stored is the category
/// **name**, because `specialisations` is a `String[]`.
class SpecialisationScreen extends ConsumerStatefulWidget {
  const SpecialisationScreen({super.key});

  @override
  ConsumerState<SpecialisationScreen> createState() => _State();
}

class _State extends ConsumerState<SpecialisationScreen> {
  final _selected = <String>{};
  String _status = '';
  bool _busy = false;
  bool _loaded = false;

  void _prefill() {
    if (_loaded) return;
    final profile = ref.read(profileControllerProvider).value;
    if (profile == null) return;
    _loaded = true;
    _selected.addAll(profile.specialisations);
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      setState(() => _status = 'Choose at least one specialty');
      return;
    }

    setState(() {
      _busy = true;
      _status = '';
    });
    final result = await ref
        .read(profileControllerProvider.notifier)
        .save({'specialisations': _selected.toList()});
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case ApiSuccess():
        context.push('/onboarding/documents');
      case ApiFailure(:final message):
        setState(() => _status = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(profileControllerProvider);
    _prefill();
    final categories = ref.watch(serviceCategoriesProvider);

    return WizardScaffold(
      stepLabel: 'STEP 4 OF 6',
      progress: 4 / 6,
      title: 'Fitness\nSpecialization',
      sub:
          'Select the training areas you specialise in. This helps us match '
          'you with clients who share your fitness goals.',
      onBack: context.canPop() ? context.pop : null,
      children: [
        const WizardSectionLabel('CHOOSE YOUR SPECIALTIES'),
        ...switch (categories) {
          AsyncData(:final value) => _tiles(value),
          AsyncError(:final error) => [_Retry(message: '$error', ref: ref)],
          _ => const [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        },
        const SizedBox(height: 6),
        Text(
          'Selected: ${_selected.length}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF75695E),
          ),
        ),
        const SizedBox(height: 16),
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

  List<Widget> _tiles(List<ServiceCategory> categories) {
    if (categories.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No specialties are published yet. Please try again later.',
            style: TextStyle(fontSize: 12, color: Color(0xFF75695E)),
          ),
        ),
      ];
    }

    return [
      for (final category in categories)
        SpecialtyTile(
          category: category,
          selected: _selected.contains(category.name),
          onTap: () => setState(() {
            if (!_selected.remove(category.name)) {
              _selected.add(category.name);
            }
          }),
        ),
    ];
  }
}

/// A failed category read is shown, not swallowed — with nothing to tick the
/// trainer cannot pass the submit gate and needs to know why.
class _Retry extends StatelessWidget {
  const _Retry({required this.message, required this.ref});

  final String message;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            message.replaceFirst('Exception: ', ''),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: HFColors.primary),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => ref.invalidate(serviceCategoriesProvider),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

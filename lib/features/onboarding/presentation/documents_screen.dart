import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_result.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_primary_button.dart';
import '../../profile/data/profile_providers.dart';
import 'widgets/document_row.dart';
import 'widgets/wizard_scaffold.dart';

/// Page 16 — Certifications & Documents. Step 5 of 6.
///
/// The rows are the API's own `onboarding.requiredDocuments`, not a list
/// hard-coded here: the policy lives in `settings.defaults.ts`.
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key, this.inWizard = true});

  /// False when the profile tab opened it — see [BankAccountScreen.inWizard].
  final bool inWizard;

  @override
  ConsumerState<DocumentsScreen> createState() => _State();
}

class _State extends ConsumerState<DocumentsScreen> {
  String _status = '';
  String? _busyType;

  static const _labels = {
    'ID_PROOF': 'Identity proof',
    'ADDRESS_PROOF': 'Address proof',
    'PAN': 'PAN card',
    'BANK_DETAILS': 'Bank details',
    'YOGA_CERTIFICATION': 'Certification',
    'POLICE_VERIFICATION': 'Police verification',
    'PHOTO': 'Profile photo',
    'OTHER': 'Other document',
  };

  Future<void> _upload(String docType) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
      imageQuality: 90,
    );
    if (picked == null) return;

    setState(() {
      _busyType = docType;
      _status = '';
    });
    final result = await ref
        .read(profileControllerProvider.notifier)
        .uploadDocument(filePath: picked.path, docType: docType);
    if (!mounted) return;
    setState(() {
      _busyType = null;
      if (result case ApiFailure(:final message)) _status = message;
    });
  }

  Future<void> _delete(String id) async {
    final result = await ref
        .read(profileControllerProvider.notifier)
        .deleteDocument(id);
    if (!mounted) return;
    if (result case ApiFailure(:final message)) {
      setState(() => _status = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileControllerProvider).value;
    final required = profile?.onboarding.requiredDocuments ?? const <String>[];
    final held = {for (final d in profile?.documents ?? const []) d.docType: d};

    return WizardScaffold(
      stepLabel: widget.inWizard ? 'STEP 5 OF 6' : 'MY ACCOUNT',
      progress: widget.inWizard ? 5 / 6 : null,
      shellChrome: !widget.inWizard,
      title: 'Certifications &\nDocuments',
      sub:
          'Upload the documents we need to verify you before your profile '
          'goes live.',
      onBack: context.canPop() ? context.pop : null,
      onRefresh: () => ref.refresh(profileControllerProvider.future),
      children: [
        const WizardSectionLabel('REQUIRED DOCUMENTS'),
        for (final docType in required)
          DocumentRow(
            label: _labels[docType] ?? docType,
            document: held[docType],
            busy: _busyType == docType,
            onUpload: () => _upload(docType),
            onDelete: held[docType] == null
                ? null
                : () => _delete(held[docType]!.id),
          ),
        const SizedBox(height: 16),
        HFPrimaryButton(
          label: widget.inWizard ? 'SAVE & CONTINUE' : 'DONE',
          onPressed: () => widget.inWizard
              ? context.push('/onboarding/service-area')
              : context.pop(),
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

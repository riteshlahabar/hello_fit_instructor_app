import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tokens.dart';

/// The frame pages 12–21 share: back button, "STEP n OF 6", a single progress
/// bar, Anton heading and sub copy.
///
/// **No logo.** The client removed it from all eight registration screens on
/// 19-11-2026, overriding their own HTML — it repeats on every step and eats
/// the space the form needs. Splash and the intro carousel keep theirs.
class WizardScaffold extends StatelessWidget {
  const WizardScaffold({
    super.key,
    required this.stepLabel,
    required this.progress,
    required this.title,
    required this.sub,
    required this.children,
    this.onBack,
    this.trailing,
  });

  /// e.g. `STEP 1 OF 6`, or `PROFILE SETUP` on the pages outside the count.
  final String stepLabel;

  /// 0..1 — the width of `.progress span`.
  final double progress;
  final String title;
  final String sub;
  final List<Widget> children;
  final VoidCallback? onBack;

  /// Optional control at the right of the header row.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HFColors.ivory,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 42,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (onBack != null)
                      InkWell(
                        onTap: onBack,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: HFColors.white,
                            border: Border.all(color: const Color(0xFFE8DCCF)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.chevron_left, size: 22),
                        ),
                      )
                    else
                      const SizedBox(width: 36),
                    Text(
                      stepLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .7,
                        color: Color(0xFF75695E),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 17, 0, 19),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFEADFD4),
                    valueColor: const AlwaysStoppedAnimation(HFColors.primary),
                  ),
                ),
              ),
              Text(title, style: AppTheme.display(34)),
              const SizedBox(height: 9),
              Text(
                sub,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.7,
                  color: Color(0xFF75695E),
                ),
              ),
              const SizedBox(height: 22),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// `.section-label` — the small orange caps rule above a group of fields.
class WizardSectionLabel extends StatelessWidget {
  const WizardSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: HFColors.primary,
        ),
      ),
    );
  }
}

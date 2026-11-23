import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/hf_header.dart';
import '../../../../core/widgets/hf_refresh.dart';
import '../../../shell/presentation/widgets/shell_nav_bar.dart';

/// The frame pages 12–21 share: back button, "STEP n OF 6", a single progress
/// bar, Anton heading and sub copy.
///
/// **No logo.** The client removed it from all eight registration screens on
/// 19-11-2026, overriding their own HTML — it repeats on every step and eats
/// the space the form needs. Splash and the intro carousel keep theirs.
///
/// **[shellChrome] is the exception** (client, 23-11-2026). The screens that
/// borrow this frame from *inside* the app — Edit Profile, and the bank and
/// document screens when they are reached from the Profile tab rather than
/// from the wizard — carry the header bar with the heading in it and the tab
/// bar at the foot, like every other in-app screen. The wizard steps
/// themselves do not: a half-onboarded applicant cannot reach the shell those
/// tabs lead to.
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
    this.onRefresh,
    this.shellChrome = false,
  });

  /// e.g. `STEP 1 OF 6`, or `PROFILE SETUP` on the pages outside the count.
  final String stepLabel;

  /// 0..1 — the width of `.progress span`. Null hides the bar, for the
  /// screens outside the wizard that borrow this frame (page 66).
  final double? progress;
  final String title;
  final String sub;
  final List<Widget> children;
  final VoidCallback? onBack;

  /// Optional control at the right of the header row.
  final Widget? trailing;

  /// Pull-to-refresh, for the steps that *read back* what the API holds — the
  /// document rows, the submit blockers, the verification stage. The
  /// text-entry steps leave it null: their fields are a local draft, so a
  /// re-fetch would either show nothing new or throw away typing.
  final Future<void> Function()? onRefresh;

  /// True on the in-app screens: header bar with the heading, tab bar at the
  /// foot, and no second copy of the heading in the body.
  final bool shellChrome;

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      physics: HFRefresh.physics,
      padding: EdgeInsets.fromLTRB(22, shellChrome ? 4 : 14, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: shellChrome ? 20 : 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // The back control moves into the header bar under
                // [shellChrome], so the row keeps only the step label.
                if (shellChrome)
                  const SizedBox.shrink()
                else if (onBack != null)
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
          if (progress != null)
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
            )
          else
            SizedBox(height: shellChrome ? 4 : 17),
          if (!shellChrome) ...[
            Text(title, style: AppTheme.display(34)),
            const SizedBox(height: 9),
          ],
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
    );

    final scroller = onRefresh == null
        ? body
        : HFRefresh(onRefresh: onRefresh!, child: body);

    return Scaffold(
      backgroundColor: HFColors.ivory,
      body: SafeArea(
        bottom: !shellChrome,
        child: shellChrome
            ? Column(
                children: [
                  HFHeader(title: _heading, onBack: onBack),
                  Expanded(child: scroller),
                ],
              )
            : scroller,
      ),
      bottomNavigationBar: shellChrome
          ? const ShellNavBar(popToShell: true)
          : null,
    );
  }

  /// The Anton heading breaks its line with `\n`; a header bar is one line.
  String get _heading => title.replaceAll('\n', ' ');
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

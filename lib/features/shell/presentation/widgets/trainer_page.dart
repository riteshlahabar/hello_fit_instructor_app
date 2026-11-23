import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/hf_header.dart';
import '../../../../core/widgets/hf_refresh.dart';
import 'shell_nav_bar.dart';

/// The frame the pushed screens share — pages 31, 32, 33, 34 and 39.
///
/// Replaced `core/widgets/hf_pushed_page.dart` on 23-11-2026, when the client
/// asked for **the header bar and the tab bar on every screen, with the
/// screen's heading in the header**. So:
///
/// - the heading is in [HFHeader], not in a block above the first card, and
///   the back chevron rides in that same row;
/// - [ShellNavBar] sits under the optional action bar, so a trainer can leave
///   a pushed screen for any tab without going back first;
/// - what is left in the scrollable is the one-line [sub] and the screen's
///   own content.
///
/// Deliberately not `WizardScaffold`: that frame owns the step label and the
/// progress bar, and none of these screens is a wizard step.
class TrainerPage extends StatelessWidget {
  const TrainerPage({
    super.key,
    required this.heading,
    required this.children,
    this.sub,
    this.footer,
    this.onRefresh,
  });

  /// Goes in the header bar, upper-cased. One line — the old frame's `\n` in
  /// the Anton heading has nothing to break here.
  final String heading;

  /// The muted line of copy under the header. Null where the screen opens
  /// straight onto its content.
  final String? sub;

  final List<Widget> children;

  /// The sticky action bar pages 33 and 34 carry, above the tab bar.
  final Widget? footer;

  /// Pull-to-refresh, for the screens reading a list.
  final Future<void> Function()? onRefresh;

  /// Back pops the screen. The fallback matters: these routes are top-level,
  /// so one reached by `go` rather than `push` has nothing behind it, and a
  /// plain `maybePop` would leave a chevron that does nothing. Falling back to
  /// the shell keeps the control honest.
  static void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      physics: HFRefresh.physics,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        if (sub case final line?)
          Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 11,
                height: 1.6,
                color: HFColors.muted,
              ),
            ),
          ),
        ...children,
      ],
    );

    return Scaffold(
      backgroundColor: HFColors.ivory,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HFHeader(title: heading, onBack: () => _back(context)),
            Expanded(
              child: onRefresh == null
                  ? body
                  : HFRefresh(onRefresh: onRefresh!, child: body),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (footer case final bar?)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 11, 20, 11),
              decoration: const BoxDecoration(
                color: HFColors.white,
                border: Border(top: BorderSide(color: HFColors.line)),
              ),
              child: bar,
            ),
          const ShellNavBar(popToShell: true),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// The frame pages 31, 32, 33, 34 and 39 share: a back row, the
/// eyebrow / Anton heading / sub block, then the screen's own content, with an
/// optional action bar pinned at the foot.
///
/// Deliberately not `WizardScaffold`: that frame owns the step label and the
/// progress bar, and none of these screens is a wizard step.
class HFPushedPage extends StatelessWidget {
  const HFPushedPage({
    super.key,
    required this.backLabel,
    required this.eyebrow,
    required this.title,
    required this.sub,
    required this.children,
    this.footer,
    this.onRefresh,
  });

  /// The words beside the chevron — `All Bookings`, `Booking Requests`.
  final String backLabel;
  final String eyebrow;

  /// Anton display heading. Embed `\n` where the design breaks the line.
  final String title;
  final String sub;
  final List<Widget> children;

  /// The sticky action bar pages 32, 33 and 34 carry.
  final Widget? footer;

  /// Pull-to-refresh, for the screens reading a list.
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      children: [
        _BackRow(label: backLabel),
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: HFColors.primary,
                ),
              ),
              const SizedBox(height: 5),
              Text(title, style: AppTheme.display(30)),
              const SizedBox(height: 5),
              Text(
                sub,
                style: const TextStyle(
                  fontSize: 10,
                  height: 1.6,
                  color: HFColors.muted,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );

    return Scaffold(
      backgroundColor: HFColors.ivory,
      body: SafeArea(
        child: onRefresh == null
            ? body
            : RefreshIndicator(
                color: HFColors.primary,
                onRefresh: onRefresh!,
                child: body,
              ),
      ),
      bottomNavigationBar: footer == null
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 11, 20, 11),
                decoration: const BoxDecoration(
                  color: HFColors.white,
                  border: Border(top: BorderSide(color: HFColors.line)),
                ),
                child: footer,
              ),
            ),
    );
  }
}

class _BackRow extends StatelessWidget {
  const _BackRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.chevron_left_rounded,
                size: 18,
                color: HFColors.muted,
              ),
              const SizedBox(width: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: HFColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

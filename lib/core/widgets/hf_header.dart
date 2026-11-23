import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// App header bar — back control left, the screen's heading beside it,
/// notification button right.
///
/// CSS: `header{padding:19px 21px 12px}`.
///
/// **No logo** (client, 23-11-2026). It repeated on every screen and bought
/// nothing: the brand mark is on the splash, the intro carousel and the login
/// pages, which is where a person needs to be told whose app this is. In the
/// app it was only eating the width the heading wants. The logo asset is
/// unchanged — it is those three frames that draw it, never this bar.
///
/// **Every screen carries this bar, with its heading in it** (client,
/// 23-11-2026). The heading therefore lives here rather than inside the
/// scrollable, so it stays on screen while the body scrolls, and a pushed
/// screen shows the back control in the same row instead of a link above the
/// first card.
///
/// Who passes [onBack] — the one rule the app navigates by:
///
/// - **Home tab: no back control.** It is the root; there is nowhere behind
///   it but the launcher.
/// - **The other four tabs: back returns to Home**, which is also what the
///   Android system back does there ([TrainerShell] owns both).
/// - **A pushed screen: back pops it** ([TrainerPage], [WizardScaffold] under
///   `shellChrome`), matching the system back.
/// - **A wizard step** keeps its own back control in the body row, not here.
class HFHeader extends StatelessWidget {
  const HFHeader({
    super.key,
    this.title,
    this.onBack,
    this.hasUnread = true,
    this.onNotifications,
  });

  /// The screen heading, upper-cased in the display face. Null on the bare
  /// bar — splash and the auth pages, which have no heading of their own.
  final String? title;

  /// Shown as a chevron at the head of the row. Null leaves the heading
  /// flush left, which is the Home tab and nothing else.
  final VoidCallback? onBack;

  final bool hasUnread;
  final VoidCallback? onNotifications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(21, 19, 21, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (onBack != null) ...[
            _BackChevron(onTap: onBack!),
            const SizedBox(width: 10),
          ],
          if (title case final heading?) ...[
            Expanded(
              child: Text(
                heading.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.display(19),
              ),
            ),
            const SizedBox(width: 8),
          ] else
            const Spacer(),
          HFIconButton(
            icon: Icons.notifications_none_rounded,
            badge: hasUnread,
            onTap: onNotifications,
          ),
        ],
      ),
    );
  }
}

/// The back control, in the header row rather than above the content. Sized
/// to match [HFIconButton] on the other end of the row, so the bar reads as
/// one line of controls.
class _BackChevron extends StatelessWidget {
  const _BackChevron({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(HFRadius.iconButton),
      child: Container(
        width: 37,
        height: 37,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: HFColors.white,
          border: Border.all(color: HFColors.line),
          borderRadius: BorderRadius.circular(HFRadius.iconButton),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          size: 19,
          color: HFColors.ink,
        ),
      ),
    );
  }
}

/// `.iconbtn` — 37x37 white square, hairline border, optional orange dot.
class HFIconButton extends StatelessWidget {
  const HFIconButton({
    super.key,
    required this.icon,
    this.badge = false,
    this.onTap,
  });

  final IconData icon;
  final bool badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(HFRadius.iconButton),
      child: Container(
        width: 37,
        height: 37,
        decoration: BoxDecoration(
          color: HFColors.white,
          border: Border.all(color: HFColors.line),
          borderRadius: BorderRadius.circular(HFRadius.iconButton),
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, size: 17, color: HFColors.ink)),
            if (badge)
              Positioned(
                right: 7,
                top: 7,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: HFColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: HFColors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

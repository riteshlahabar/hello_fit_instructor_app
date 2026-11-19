import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// App header bar — logo left, notification button right.
/// CSS: `header{padding:19px 21px 12px}`. The HTML sets `.logo{width:116px}`,
/// but the asset is square, so 116 renders a 116px-tall header — the client
/// asked for a small mark (19 Nov), so it is 44x44 here.
class HFHeader extends StatelessWidget {
  const HFHeader({
    super.key,
    this.hasUnread = true,
    this.onNotifications,
  });

  final bool hasUnread;
  final VoidCallback? onNotifications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(21, 19, 21, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 44,
            height: 44,
            fit: BoxFit.contain,
          ),
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

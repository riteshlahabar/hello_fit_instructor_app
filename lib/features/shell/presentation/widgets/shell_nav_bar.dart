import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/hf_bottom_nav.dart';
import '../shell_controller.dart';

/// The five-tab bar, wired to [shellControllerProvider].
///
/// **Every screen carries it** (client, 23-11-2026), not only the shell. On a
/// pushed screen ([popToShell]) a tap selects the tab *and* returns to the
/// shell, so a cell means the same thing wherever the trainer presses it —
/// otherwise the bar would light a tab the screen behind it is not showing.
class ShellNavBar extends ConsumerWidget {
  const ShellNavBar({super.key, this.popToShell = false});

  /// True on a pushed screen: the tap has to go back to `/` for the tab it
  /// just selected to be the thing on screen.
  final bool popToShell;

  /// Tab order and labels come from the `nav` in the client's page-24 HTML.
  static const items = <HFNavItem>[
    HFNavItem(Icons.home_rounded, 'Home'),
    HFNavItem(Icons.calendar_month_rounded, 'Bookings'),
    HFNavItem(Icons.people_alt_rounded, 'Clients'),
    HFNavItem(Icons.currency_rupee_rounded, 'Earnings'),
    HFNavItem(Icons.account_circle_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(shellControllerProvider);

    return HFBottomNav(
      items: items,
      currentIndex: tab.index,
      onTap: (index) {
        ref.read(shellControllerProvider.notifier).selectIndex(index);
        if (popToShell) context.go('/');
      },
    );
  }
}

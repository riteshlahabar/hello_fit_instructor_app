import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_bottom_nav.dart';
import '../../../core/widgets/hf_header.dart';
import '../../bookings/presentation/bookings_screen.dart';
import '../../clients/presentation/clients_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../earnings/presentation/earnings_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import 'shell_controller.dart';

/// The trainer shell — header bar on top, tab bar at the foot.
/// Tab order and labels come from the `nav` in the client's page-24 HTML.
class TrainerShell extends ConsumerWidget {
  const TrainerShell({super.key});

  static const _items = <HFNavItem>[
    HFNavItem(Icons.home_rounded, 'Home'),
    HFNavItem(Icons.calendar_month_rounded, 'Bookings'),
    HFNavItem(Icons.people_alt_rounded, 'Clients'),
    HFNavItem(Icons.currency_rupee_rounded, 'Earnings'),
    HFNavItem(Icons.account_circle_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(shellControllerProvider);

    return Scaffold(
      backgroundColor: HFColors.ivory,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HFHeader(),
            Expanded(
              child: IndexedStack(
                index: tab.index,
                children: const [
                  DashboardScreen(),
                  BookingsScreen(),
                  ClientsScreen(),
                  EarningsScreen(),
                  ProfileScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HFBottomNav(
        items: _items,
        currentIndex: tab.index,
        onTap: ref.read(shellControllerProvider.notifier).selectIndex,
      ),
    );
  }
}

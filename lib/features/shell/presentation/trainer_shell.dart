import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_header.dart';
import '../../bookings/presentation/bookings_screen.dart';
import '../../clients/presentation/clients_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../earnings/presentation/earnings_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import 'shell_controller.dart';
import 'widgets/shell_nav_bar.dart';

/// The trainer shell — header bar on top, tab bar at the foot.
///
/// The header carries the showing tab's heading (client, 23-11-2026), which is
/// why the five tab screens no longer draw a heading of their own.
///
/// **Home is the only screen in the app with no back control** (client,
/// 23-11-2026). The other four tabs are entered from Home, so back leaves them
/// the way it was entered: by returning to Home, never by closing the app.
/// The [PopScope] gives the Android system back the same meaning as the
/// chevron — the two must not disagree, or the hardware key would quit the app
/// from the Earnings tab while the on-screen arrow went to Home.
class TrainerShell extends ConsumerWidget {
  const TrainerShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(shellControllerProvider);
    final atHome = tab == TrainerTab.home;

    void goHome() =>
        ref.read(shellControllerProvider.notifier).select(TrainerTab.home);

    return PopScope(
      // Home pops for real — that is the launcher's business. Anywhere else
      // the pop is intercepted and spent on returning to Home.
      canPop: atHome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goHome();
      },
      child: Scaffold(
        backgroundColor: HFColors.ivory,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              HFHeader(title: tab.heading, onBack: atHome ? null : goHome),
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
        bottomNavigationBar: const ShellNavBar(),
      ),
    );
  }
}

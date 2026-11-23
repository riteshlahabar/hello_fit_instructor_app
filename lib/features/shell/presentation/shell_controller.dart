import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The five tabs of the trainer shell, in the order the client's HTML `nav`
/// lists them (page 24).
enum TrainerTab { home, bookings, clients, earnings, profile }

/// The heading each tab puts in the header bar (client, 23-11-2026). It is the
/// screen's own heading, not the tab label: the bar says `ALL BOOKINGS` where
/// the nav cell says `Bookings`.
extension TrainerTabHeading on TrainerTab {
  String get heading => switch (this) {
    TrainerTab.home => 'Home',
    TrainerTab.bookings => 'All Bookings',
    TrainerTab.clients => 'My Clients',
    TrainerTab.earnings => 'Earnings',
    TrainerTab.profile => 'Profile',
  };
}

/// Which tab the shell is showing. The dashboard switches tabs through this,
/// so it never holds a reference to the shell widget.
class ShellController extends Notifier<TrainerTab> {
  @override
  TrainerTab build() => TrainerTab.home;

  void select(TrainerTab tab) => state = tab;

  void selectIndex(int index) => state = TrainerTab.values[index];
}

final shellControllerProvider = NotifierProvider<ShellController, TrainerTab>(
  ShellController.new,
);

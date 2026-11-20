import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The five tabs of the trainer shell, in the order the client's HTML `nav`
/// lists them (page 24).
enum TrainerTab { home, bookings, clients, earnings, profile }

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

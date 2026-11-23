import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_app/core/theme/app_theme.dart';
import 'package:trainer_app/core/widgets/hf_bottom_nav.dart';
import 'package:trainer_app/features/shell/presentation/trainer_shell.dart';

import 'support/fake_tab_repositories.dart';

/// The header bar's two rules (client, 23-11-2026): no logo anywhere, and a
/// back control on every screen but Home.
void main() {
  Future<void> pumpShell(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        // The shell's IndexedStack builds all five tabs, so every one of their
        // reads has to be answered or the spinner never settles.
        overrides: tabOverrides,
        child: MaterialApp(theme: AppTheme.light(), home: const TrainerShell()),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The nav cell, not any other text reading the same: the IndexedStack keeps
  /// all five tabs in the tree, so a bare `find.text` is ambiguous.
  Finder navCell(String label) => find.descendant(
    of: find.byType(HFBottomNav),
    matching: find.text(label),
  );

  final backArrow = find.byIcon(Icons.arrow_back_rounded);

  testWidgets('the header carries no logo', (tester) async {
    await pumpShell(tester);

    expect(
      find.image(const AssetImage('assets/images/logo.png')),
      findsNothing,
    );
  });

  testWidgets('Home has no back control; the other tabs go back to it', (
    tester,
  ) async {
    await pumpShell(tester);
    expect(find.text('HOME'), findsOneWidget);
    expect(backArrow, findsNothing);

    await tester.tap(navCell('Bookings'));
    await tester.pumpAndSettle();
    expect(find.text('ALL BOOKINGS'), findsOneWidget);
    expect(backArrow, findsOneWidget);

    await tester.tap(backArrow);
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
    expect(backArrow, findsNothing);
  });

  testWidgets('the system back goes to Home before it leaves the app', (
    tester,
  ) async {
    await pumpShell(tester);
    await tester.tap(navCell('Earnings'));
    await tester.pumpAndSettle();
    expect(find.text('EARNINGS'), findsOneWidget);

    final popped = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(popped, isTrue, reason: 'the shell consumed the back press');
    expect(find.text('HOME'), findsOneWidget);
  });
}

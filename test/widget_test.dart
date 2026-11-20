import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_app/core/theme/app_theme.dart';
import 'package:trainer_app/features/shell/presentation/trainer_shell.dart';

import 'support/fake_tab_repositories.dart';

void main() {
  testWidgets('shell shows the dashboard and all five tabs', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        // The shell's IndexedStack builds all five tabs, so every one of their
        // reads has to be answered or the spinner never settles.
        overrides: tabOverrides,
        child: MaterialApp(theme: AppTheme.light(), home: const TrainerShell()),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in ['Home', 'Clients', 'Earnings', 'Profile']) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    expect(find.text('Your overview'), findsOneWidget);
    expect(find.text('Profile verification in progress'), findsOneWidget);
  });
}
